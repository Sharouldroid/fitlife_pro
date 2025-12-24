import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Add intl package to pubspec.yaml if you want formatted dates
import '../../services/database_service.dart';

class BodyMetricsScreen extends StatefulWidget {
  const BodyMetricsScreen({Key? key}) : super(key: key);

  @override
  State<BodyMetricsScreen> createState() => _BodyMetricsScreenState();
}

class _BodyMetricsScreenState extends State<BodyMetricsScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  
  // Controllers for adding data
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController(); // For BMI calc
  
  // State for BMI Calculation
  String _calculatedBMI = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Body Metrics Tracker"),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          // --- INPUT SECTION ---
          _buildInputSection(),

          const Divider(thickness: 2),

          // --- HISTORY LIST SECTION ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: DatabaseService().getUserMetrics(user?.uid ?? ''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No logs yet. Add your weight above!"));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    
                    // Format Date (Optional)
                    String dateString = "Just now";
                    if (data['timestamp'] != null) {
                      DateTime date = (data['timestamp'] as Timestamp).toDate();
                      dateString = "${date.day}/${date.month}/${date.year}";
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.shade100,
                          child: const Icon(Icons.monitor_weight, color: Colors.teal),
                        ),
                        title: Text("${data['weight']} kg"),
                        subtitle: Text("BMI: ${data['bmi']} | Date: $dateString"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(doc.id),
                        ),
                        // Tap to Edit
                        onTap: () => _showEditDialog(doc.id, data['weight'], data['bmi']),
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

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.teal.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Log New Entry", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Weight (kg)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.fitness_center),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Height (cm)", // For auto BMI
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.height),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Calculate BMI & Save"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: _calculateAndSave,
            ),
          ),
          if (_calculatedBMI.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text("Last Calculated BMI: $_calculatedBMI", 
                style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
            )
        ],
      ),
    );
  }

  // --- LOGIC FUNCTIONS ---

  void _calculateAndSave() async {
    if (_weightController.text.isEmpty || _heightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter Weight and Height")));
      return;
    }

    // 1. Calculate BMI
    double weight = double.parse(_weightController.text);
    double heightCm = double.parse(_heightController.text);
    double heightM = heightCm / 100;
    double bmiVal = weight / (heightM * heightM);
    String bmiString = bmiVal.toStringAsFixed(1);

    setState(() => _calculatedBMI = bmiString);

    // 2. Save to Firebase
    if (user != null) {
      await DatabaseService().addMetric(
        uid: user!.uid,
        weight: _weightController.text,
        bmi: bmiString,
      );
      
      // Clear inputs
      _weightController.clear();
      FocusScope.of(context).unfocus(); // Close keyboard
    }
  }

  void _confirmDelete(String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Entry?"),
        content: const Text("This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await DatabaseService().deleteMetric(docId);
              Navigator.pop(ctx);
            },
            child: const Text("Delete"),
          )
        ],
      ),
    );
  }

  void _showEditDialog(String docId, String currentWeight, String currentBMI) {
    TextEditingController editWeightCtrl = TextEditingController(text: currentWeight);
    TextEditingController editBMICtrl = TextEditingController(text: currentBMI);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Update Metric"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: editWeightCtrl, decoration: const InputDecoration(labelText: "Weight (kg)")),
            const SizedBox(height: 10),
            TextField(controller: editBMICtrl, decoration: const InputDecoration(labelText: "BMI (Manual)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await DatabaseService().updateMetric(
                docId: docId,
                weight: editWeightCtrl.text,
                bmi: editBMICtrl.text,
              );
              Navigator.pop(ctx);
            },
            child: const Text("Update"),
          )
        ],
      ),
    );
  }
}