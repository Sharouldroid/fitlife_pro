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
  late TextEditingController _typeController;
  late TextEditingController _durationController;
  late TextEditingController _caloriesController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _typeController = TextEditingController(text: widget.currentData['type']);
    _durationController = TextEditingController(text: widget.currentData['duration']);
    _caloriesController = TextEditingController(text: widget.currentData['calories']);
    _notesController = TextEditingController(text: widget.currentData['notes']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Activity"), backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _typeController, decoration: const InputDecoration(labelText: "Activity Type"), validator: (val) => val!.isEmpty ? "Required" : null),
              TextFormField(controller: _durationController, decoration: const InputDecoration(labelText: "Duration"), keyboardType: TextInputType.number, validator: (val) => val!.isEmpty ? "Required" : null),
              TextFormField(controller: _caloriesController, decoration: const InputDecoration(labelText: "Calories"), keyboardType: TextInputType.number, validator: (val) => val!.isEmpty ? "Required" : null),
              TextFormField(controller: _notesController, decoration: const InputDecoration(labelText: "Notes"), maxLines: 3),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, padding: const EdgeInsets.symmetric(vertical: 15)),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await DatabaseService().updateActivity(
                      docId: widget.docId,
                      type: _typeController.text,
                      duration: _durationController.text,
                      calories: _caloriesController.text,
                      notes: _notesController.text,
                    );
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                },
                child: const Text("Update Activity", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}