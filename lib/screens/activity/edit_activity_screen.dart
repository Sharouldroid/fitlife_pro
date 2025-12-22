import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class EditActivityScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> currentData;

  const EditActivityScreen({Key? key, required this.docId, required this.currentData}) : super(key: key);

  @override
  _EditActivityScreenState createState() => _EditActivityScreenState();
}

class _EditActivityScreenState extends State<EditActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _typeController;
  late TextEditingController _durationController;
  late TextEditingController _caloriesController;
  late TextEditingController _notesController;
  
  // Loading State
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill data
    _typeController = TextEditingController(text: widget.currentData['type']);
    _durationController = TextEditingController(text: widget.currentData['duration']);
    _caloriesController = TextEditingController(text: widget.currentData['calories']);
    _notesController = TextEditingController(text: widget.currentData['notes']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Activity"), 
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 1. Activity Type
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: "Activity Type",
                  prefixIcon: Icon(Icons.fitness_center),
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 15),

              // 2. Duration
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: "Duration",
                  prefixIcon: Icon(Icons.timer),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 15),

              // 3. Calories
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(
                  labelText: "Calories",
                  prefixIcon: Icon(Icons.local_fire_department),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 15),

              // 4. Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: "Notes",
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 25),

              // 5. UPDATE BUTTON with Popup Logic
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _isLoading ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _isLoading = true); // Start Loading
                      
                      await DatabaseService().updateActivity(
                        docId: widget.docId,
                        type: _typeController.text,
                        duration: _durationController.text,
                        calories: _caloriesController.text,
                        notes: _notesController.text,
                      );
                      
                      setState(() => _isLoading = false); // Stop Loading

                      // Show Success Popup
                      _showSuccessDialog(context);
                    }
                  },
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Update Activity", style: TextStyle(fontSize: 18, color: Colors.white)),
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
                BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 10)),
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
                      Navigator.of(context).pop(); // Close Dialog
                      Navigator.of(context).pop(); // Close Edit Screen
                      Navigator.of(context).pop(); // Close Detail Screen (Return to List)
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