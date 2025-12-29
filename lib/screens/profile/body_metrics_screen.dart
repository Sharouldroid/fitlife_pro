import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class BodyMetricsScreen extends StatefulWidget {
  const BodyMetricsScreen({Key? key}) : super(key: key);

  @override
  State<BodyMetricsScreen> createState() => _BodyMetricsScreenState();
}

class _BodyMetricsScreenState extends State<BodyMetricsScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController(); 
  
  String _calculatedBMI = "";
  double _bmiValue = 0.0;
  bool _isLoading = false;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Body Metrics"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? Colors.transparent : Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // --- INPUT SECTION ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _weightController,
                          label: "Weight (kg)",
                          prefixIcon: Icons.monitor_weight_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: CustomTextField(
                          controller: _heightController,
                          label: "Height (cm)",
                          prefixIcon: Icons.height,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: "Calculate & Save",
                    icon: Icons.calculate_outlined,
                    isLoading: _isLoading,
                    onPressed: _calculateAndSave,
                  ),
                  
                  // LAST CALCULATION DISPLAY
                  if (_calculatedBMI.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: _getBMIColor(_bmiValue).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _getBMIColor(_bmiValue), width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info_outline, color: _getBMIColor(_bmiValue)),
                          const SizedBox(width: 10),
                          Column(
                            children: [
                              Text(
                                "BMI: $_calculatedBMI",
                                style: TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold,
                                  color: _getBMIColor(_bmiValue),
                                ),
                              ),
                              Text(
                                _getBMICategory(_bmiValue),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _getBMIColor(_bmiValue),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),

          // --- HISTORY HEADER ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              children: [
                Text(
                  "History",
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const Spacer(),
                Icon(Icons.history, size: 18, color: isDark ? Colors.grey : Colors.grey[600]),
              ],
            ),
          ),

          // --- HISTORY LIST ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: DatabaseService().getUserMetrics(user?.uid ?? ''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState(isDark);
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    
                    double bmi = double.tryParse(data['bmi'].toString()) ?? 0;
                    String category = _getBMICategory(bmi);

                    // Date formatting
                    String dateString = "Just now";
                    if (data['timestamp'] != null) {
                      DateTime date = (data['timestamp'] as Timestamp).toDate();
                      dateString = "${date.day}/${date.month}/${date.year}";
                    }

                    return Dismissible(
                      key: Key(doc.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (dir) async {
                        await DatabaseService().deleteMetric(doc.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Entry deleted")),
                        );
                      },
                      child: Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        color: isDark ? Colors.grey[800] : Colors.white,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _getBMIColor(bmi).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.speed, color: _getBMIColor(bmi)),
                          ),
                          title: Text(
                            "${data['weight']} kg",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            "BMI: ${data['bmi']} ($category)\n$dateString",
                            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          ),
                          isThreeLine: true, // Allow subtitle to wrap
                          onTap: () => _showEditDialog(doc.id, data['weight'], data['bmi'], isDark),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- LOGIC: Calculate, Show Popup & Save ---
  Future<void> _calculateAndSave() async {
    if (_weightController.text.isEmpty || _heightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter Weight and Height")));
      return;
    }

    // Hide keyboard
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      double weight = double.parse(_weightController.text);
      double heightCm = double.parse(_heightController.text);
      double heightM = heightCm / 100;
      double bmiVal = weight / (heightM * heightM);
      String bmiString = bmiVal.toStringAsFixed(1);
      
      setState(() {
        _bmiValue = bmiVal;
        _calculatedBMI = bmiString;
      });

      // 1. SHOW POPUP RESULT
      await _showBMIResultDialog(bmiVal, bmiString);

      // 2. SAVE TO DB
      if (user != null) {
        await DatabaseService().addMetric(
          uid: user!.uid,
          weight: _weightController.text,
          bmi: bmiString,
        );
        _weightController.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- NEW POPUP DIALOG ---
  Future<void> _showBMIResultDialog(double bmi, String bmiString) async {
    String category = _getBMICategory(bmi);
    Color color = _getBMIColor(bmi);
    String advice = _getBMIAdvice(bmi);

    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(child: Text("BMI Result", style: TextStyle(fontWeight: FontWeight.bold))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
              ),
              child: Text(
                bmiString,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              category.toUpperCase(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              advice,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Save to History", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  // --- LOGIC: Edit Dialog ---
  void _showEditDialog(String docId, String currentWeight, String currentBMI, bool isDark) {
    TextEditingController editWeightCtrl = TextEditingController(text: currentWeight);
    TextEditingController editBMICtrl = TextEditingController(text: currentBMI);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        title: Text("Update Metric", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editWeightCtrl, 
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: "Weight (kg)",
                labelStyle: TextStyle(color: isDark ? Colors.grey : Colors.black54),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.grey : Colors.black)),
              )
            ),
            const SizedBox(height: 10),
            TextField(
              controller: editBMICtrl, 
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: "BMI (Manual)",
                labelStyle: TextStyle(color: isDark ? Colors.grey : Colors.black54),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.grey : Colors.black)),
              )
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text("Cancel", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () async {
              await DatabaseService().updateMetric(
                docId: docId,
                weight: editWeightCtrl.text,
                bmi: editBMICtrl.text,
              );
              Navigator.pop(ctx);
            },
            child: const Text("Update", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 70, color: Colors.grey[400]),
          const SizedBox(height: 10),
          Text("No logs yet.", style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
        ],
      ),
    );
  }

  // --- BMI HELPERS ---
  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25) return "Normal Weight";
    if (bmi < 30) return "Overweight";
    return "Obese";
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue; 
    if (bmi < 25) return Colors.green;  
    if (bmi < 30) return Colors.orange; 
    return Colors.red;                  
  }

  String _getBMIAdvice(double bmi) {
    if (bmi < 18.5) return "You might need to eat more nutrient-rich foods.";
    if (bmi < 25) return "Great job! Keep maintaining your healthy lifestyle.";
    if (bmi < 30) return "Consider a balanced diet and regular exercise.";
    return "Consult a doctor for a personalized health plan.";
  }
}