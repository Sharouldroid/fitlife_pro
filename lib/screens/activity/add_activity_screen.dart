import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({Key? key}) : super(key: key);

  @override
  _AddActivityScreenState createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form Variables
  String type = '';
  String duration = '';
  String calories = '';
  String notes = '';
  
  // Loading State (Prevents double-clicks and stuck UI)
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Activity"), 
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 1. TYPE INPUT
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Activity Type (e.g. Running)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                validator: (val) => val!.isEmpty ? "Please enter a type" : null,
                onChanged: (val) => type = val,
              ),
              const SizedBox(height: 15),

              // 2. DURATION INPUT
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Duration (minutes)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                ),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? "Please enter duration" : null,
                onChanged: (val) => duration = val,
              ),
              const SizedBox(height: 15),

              // 3. CALORIES INPUT
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Calories Burned",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_fire_department),
                ),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? "Please enter calories" : null,
                onChanged: (val) => calories = val,
              ),
              const SizedBox(height: 15),

              // 4. NOTES INPUT
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Notes (Optional)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
                onChanged: (val) => notes = val,
              ),
              const SizedBox(height: 25),

              // 5. SAVE BUTTON (With Error Handling Fix)
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  // Disable button while loading
                  onPressed: _isLoading ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      // START LOADING
                      setState(() => _isLoading = true); 

                      try {
                        final User? user = FirebaseAuth.instance.currentUser;
                        
                        if (user != null) {
                          // Attempt to save to Firebase
                          await DatabaseService().addActivity(
                            uid: user.uid,
                            type: type,
                            duration: duration,
                            calories: calories,
                            notes: notes,
                          );

                          // STOP LOADING & SHOW SUCCESS
                          if (!mounted) return;
                          setState(() => _isLoading = false);
                          
                          // Trigger the Modern Popup
                          _showSuccessDialog(context); 
                        } else {
                          throw Exception("No user logged in");
                        }
                      } catch (e) {
                        // ERROR HANDLING: Stop loading & show message
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
                  },
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Activity", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- MODERN POPUP FUNCTION ---
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // User MUST tap OK to close
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
                BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 10)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Big Green Checkmark
                const CircleAvatar(
                  backgroundColor: Colors.green,
                  radius: 40,
                  child: Icon(Icons.check, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 20),
                
                // Success Text
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
                
                // OK Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // 1. Close the Dialog
                      Navigator.of(context).pop(); // 2. Go back to Activity List
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