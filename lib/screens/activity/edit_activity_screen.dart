import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Needed for User Weight
import '../../services/database_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EditActivityScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> currentData;

  const EditActivityScreen({Key? key, required this.docId, required this.currentData}) : super(key: key);

  @override
  _EditActivityScreenState createState() => _EditActivityScreenState();
}

class _EditActivityScreenState extends State<EditActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // 1. ADDED DROPDOWN VALUES
  final Map<String, double> _activityMETs = {
    'Running (Fast)': 9.8,
    'Running (Jog)': 7.0,
    'Cycling (Vigorous)': 8.5,
    'Cycling (Casual)': 5.5,
    'Swimming': 8.0,
    'Weight Lifting': 5.0,
    'Walking (Brisk)': 3.8,
    'Yoga': 2.5,
    'HIIT / Circuit': 8.0,
    'Sports (Soccer/Basketball)': 7.5,
    'Other': 4.0,
  };

  String? _selectedActivity; 
  
  // Controllers
  late TextEditingController _durationController;
  late TextEditingController _caloriesController;
  late TextEditingController _notesController;
  
  bool _isLoading = false;
  double _userWeight = 70.0; 

  @override
  void initState() {
    super.initState();
    // 2. PRE-FILL DATA Logic
    _selectedActivity = widget.currentData['type'];
    
    // Safety check: If saved activity isn't in our new list, default to 'Other'
    if (!_activityMETs.containsKey(_selectedActivity)) {
      _selectedActivity = 'Other'; 
    }

    _durationController = TextEditingController(text: widget.currentData['duration'].toString());
    _caloriesController = TextEditingController(text: widget.currentData['calories'].toString());
    _notesController = TextEditingController(text: widget.currentData['notes']);

    _fetchUserWeight();
    _durationController.addListener(_calculateCalories);
  }

  // 3. FETCH WEIGHT FOR RE-CALCULATION
  Future<void> _fetchUserWeight() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snapshot = await DatabaseService().getUserMetrics(user.uid).first;
        if (snapshot.docs.isNotEmpty) {
          final data = snapshot.docs.first.data() as Map<String, dynamic>;
          if (mounted) {
            setState(() {
              _userWeight = double.tryParse(data['weight'].toString()) ?? 70.0;
            });
          }
        }
      } catch (e) {
        // Silent fail
      }
    }
  }

  // 4. AUTO-CALCULATE LOGIC
  void _calculateCalories() {
    final durationText = _durationController.text;
    if (_selectedActivity == null || durationText.isEmpty) return;
    
    final double duration = double.tryParse(durationText) ?? 0;
    if (duration <= 0) return;

    double met = _activityMETs[_selectedActivity] ?? 4.0;
    final double caloriesBurned = (met * 3.5 * _userWeight) / 200 * duration;
    _caloriesController.text = caloriesBurned.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _durationController.dispose();
    _caloriesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Activity"), 
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? Colors.transparent : Colors.teal,
        foregroundColor: Colors.white,
      ),
      // 5. KEYBOARD DISMISSAL
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 6. DROPDOWN IMPLEMENTATION
                DropdownButtonFormField<String>(
                  value: _selectedActivity,
                  decoration: InputDecoration(
                    labelText: "Activity Type",
                    prefixIcon: const Icon(Icons.fitness_center),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    filled: true,
                    fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                  ),
                  items: _activityMETs.keys.map((String activity) {
                    return DropdownMenuItem<String>(
                      value: activity,
                      child: Text(activity),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedActivity = val;
                      _calculateCalories(); // Recalculate if type changes
                    });
                  },
                  validator: (val) => val == null ? "Required" : null,
                ),

                const SizedBox(height: 20),

                // 7. DURATION WITH VALIDATION
                CustomTextField(
                  controller: _durationController,
                  label: "Duration",
                  prefixIcon: Icons.timer,
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Required";
                    if (double.tryParse(val) == null) return "Must be number";
                    if (double.parse(val) <= 0) return "Positive only";
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 8. CALORIES WITH VALIDATION
                CustomTextField(
                  controller: _caloriesController,
                  label: "Calories",
                  prefixIcon: Icons.local_fire_department,
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Required";
                    if (double.tryParse(val) == null) return "Must be number";
                    if (double.parse(val) <= 0) return "Positive only";
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  controller: _notesController,
                  label: "Notes",
                  prefixIcon: Icons.note_alt_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 35),

                CustomButton(
                  text: "Update Activity",
                  isLoading: _isLoading,
                  icon: Icons.update,
                  onPressed: _updateActivity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UPDATE LOGIC WITH VALIDATION ---
  Future<void> _updateActivity() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      
      // Safety Check
      double dur = double.tryParse(_durationController.text) ?? 0;
      double cal = double.tryParse(_caloriesController.text) ?? 0;

      if (dur <= 0 || cal <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Values must be positive"), backgroundColor: Colors.red),
        );
        return;
      }

      setState(() => _isLoading = true);
      
      try {
        await DatabaseService().updateActivity(
          docId: widget.docId,
          type: _selectedActivity!, // Use dropdown value
          duration: _durationController.text.trim(),
          calories: _caloriesController.text.trim(),
          notes: _notesController.text.trim(),
        );
        
        if (!mounted) return;
        setState(() => _isLoading = false);

        _showSuccessDialog(context);
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating: $e")),
        );
      }
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.green,
                  radius: 40,
                  child: Icon(Icons.check, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Updated!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Activity details have been successfully updated.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); 
                      Navigator.of(context).pop(); 
                    },
                    child: const Text("OK", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}