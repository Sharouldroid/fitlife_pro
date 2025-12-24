import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';
// IMPORT YOUR CUSTOM WIDGETS
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({Key? key}) : super(key: key);

  @override
  _AddActivityScreenState createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _typeController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Activity"),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50], 
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. TYPE INPUT
              CustomTextField(
                controller: _typeController,
                label: "Activity Type",
                hint: "e.g. Running, Swimming",
                prefixIcon: Icons.fitness_center,
                validator: (val) => val!.isEmpty ? "Please enter a type" : null,
              ),
              const SizedBox(height: 20),

              // 2. DURATION INPUT
              CustomTextField(
                controller: _durationController,
                label: "Duration (minutes)",
                hint: "e.g. 30",
                prefixIcon: Icons.timer,
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? "Please enter duration" : null,
              ),
              const SizedBox(height: 20),

              // 3. CALORIES INPUT
              CustomTextField(
                controller: _caloriesController,
                label: "Calories Burned",
                hint: "e.g. 250",
                prefixIcon: Icons.local_fire_department,
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? "Please enter calories" : null,
              ),
              const SizedBox(height: 20),

              // 4. NOTES INPUT
              CustomTextField(
                controller: _notesController,
                label: "Notes (Optional)",
                hint: "How did it feel?",
                prefixIcon: Icons.note_alt_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 35),

              // 5. SAVE BUTTON
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
    );
  }

  // --- SAVE LOGIC ---
  Future<void> _saveActivity() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          await DatabaseService().addActivity(
            uid: user.uid,
            type: _typeController.text.trim(),
            duration: _durationController.text.trim(),
            calories: _caloriesController.text.trim(),
            notes: _notesController.text.trim(),
          );

          if (!mounted) return;
          setState(() => _isLoading = false);
          _showSuccessDialog(context);
        } else {
          throw Exception("No user logged in");
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- MODERN POPUP FUNCTION ---
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26, blurRadius: 10, offset: Offset(0, 10)),
              ],
            ),
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
                  "Great Job!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Activity added successfully.\nKeep up the good work!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // 1. Close the Dialog
                      
                      // 2. Redirect to Dashboard (Removes previous screens so back button works correctly)
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