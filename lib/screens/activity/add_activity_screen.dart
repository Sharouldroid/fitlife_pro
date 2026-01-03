import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({Key? key}) : super(key: key);

  @override
  _AddActivityScreenState createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();

  // Activity Dropdown Values (METs)
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
  
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _isLoading = false;
  double _userWeight = 70.0; 

  @override
  void initState() {
    super.initState();
    _fetchUserWeight();
    _durationController.addListener(_calculateCalories);
  }

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
        // Handle error silently
      }
    }
  }

  void _calculateCalories() {
    final durationText = _durationController.text;
    if (_selectedActivity == null || durationText.isEmpty) return;
    
    final double duration = double.tryParse(durationText) ?? 0;
    
    // Logic check: only calculate if duration is positive
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
        title: const Text("Add New Activity"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? Colors.transparent : Colors.teal,
        foregroundColor: Colors.white,
      ),
      // --- UX IMPROVEMENT: KEYBOARD DISMISSAL ---
      body: GestureDetector(
        onTap: () {
          // This closes the keyboard when tapping anywhere outside
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                      _calculateCalories();
                    });
                  },
                  validator: (val) => val == null ? "Please select an activity" : null,
                ),

                const SizedBox(height: 20),
                
                // VALIDATED DURATION FIELD
                CustomTextField(
                  controller: _durationController,
                  label: "Duration (minutes)",
                  hint: "e.g. 30",
                  prefixIcon: Icons.timer,
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Please enter duration";
                    if (double.tryParse(val) == null) return "Must be a number";
                    if (double.parse(val) <= 0) return "Must be positive";
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // VALIDATED CALORIES FIELD
                CustomTextField(
                  controller: _caloriesController,
                  label: "Calories Burned (Est.)",
                  hint: "Auto-calculated",
                  prefixIcon: Icons.local_fire_department,
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Please enter calories";
                    if (double.tryParse(val) == null) return "Must be a number";
                    if (double.parse(val) <= 0) return "Must be positive";
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _notesController,
                  label: "Notes (Optional)",
                  hint: "How did it feel?",
                  prefixIcon: Icons.note_alt_outlined,
                  maxLines: 3,
                ),
                
                const SizedBox(height: 35),
                CustomButton(
                  text: "Save Activity",
                  isLoading: _isLoading,
                  icon: Icons.check_circle_outline,
                  onPressed: _saveActivity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveActivity() async {
    FocusScope.of(context).unfocus(); // Close keyboard
    
    if (_formKey.currentState!.validate()) {
      
      // --- LOGIC CHECK: Prevent sending 0 or negative numbers ---
      double dur = double.tryParse(_durationController.text) ?? 0;
      double cal = double.tryParse(_caloriesController.text) ?? 0;

      if (dur <= 0 || cal <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Duration and Calories must be greater than 0"),
            backgroundColor: Colors.red,
          )
        );
        return;
      }

      setState(() => _isLoading = true);
      try {
        final User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await DatabaseService().addActivity(
            uid: user.uid,
            type: _selectedActivity!, 
            duration: _durationController.text.trim(),
            calories: _caloriesController.text.trim(),
            notes: _notesController.text.trim(),
          );
          if (!mounted) return;
          setState(() => _isLoading = false);
          _showSuccessDialog(context);
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                const Text("Great Job!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text("Activity added successfully.", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
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
                      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
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