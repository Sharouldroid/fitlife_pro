import 'package:flutter/material.dart';
import '../../services/database_service.dart';
// IMPORT CUSTOM WIDGETS
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
    // Pre-fill data from the passed Map
    _typeController = TextEditingController(text: widget.currentData['type']);
    _durationController = TextEditingController(text: widget.currentData['duration']);
    _caloriesController = TextEditingController(text: widget.currentData['calories']);
    _notesController = TextEditingController(text: widget.currentData['notes']);
  }

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
        title: const Text("Edit Activity"), 
        // REMOVED: backgroundColor: Colors.teal (Now handled by Theme)
        elevation: 0,
      ),
      // REMOVED: backgroundColor: Colors.grey[50] (Now handled by Theme)
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Activity Type
              CustomTextField(
                controller: _typeController,
                label: "Activity Type",
                prefixIcon: Icons.fitness_center,
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 20),

              // 2. Duration
              CustomTextField(
                controller: _durationController,
                label: "Duration",
                prefixIcon: Icons.timer,
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 20),

              // 3. Calories
              CustomTextField(
                controller: _caloriesController,
                label: "Calories",
                prefixIcon: Icons.local_fire_department,
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 20),

              // 4. Notes
              CustomTextField(
                controller: _notesController,
                label: "Notes",
                prefixIcon: Icons.note_alt_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 35),

              // 5. UPDATE BUTTON
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
    );
  }

  // --- UPDATE LOGIC ---
  Future<void> _updateActivity() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        await DatabaseService().updateActivity(
          docId: widget.docId,
          type: _typeController.text.trim(),
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
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              // Allow Theme to handle card color (Dark Grey vs White)
              color: Theme.of(context).dialogBackgroundColor, 
              borderRadius: BorderRadius.circular(20),
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
                // Text color automatically adapts via Theme
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