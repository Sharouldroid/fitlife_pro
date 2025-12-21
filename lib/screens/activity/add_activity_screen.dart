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
  String type = '';
  String duration = '';
  String calories = '';
  String notes = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Activity"), backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Activity Type (e.g. Running)"),
                validator: (val) => val!.isEmpty ? "Please enter a type" : null,
                onChanged: (val) => type = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Duration (minutes)"),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? "Please enter duration" : null,
                onChanged: (val) => duration = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Calories Burned"),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? "Please enter calories" : null,
                onChanged: (val) => calories = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Notes"),
                maxLines: 3,
                onChanged: (val) => notes = val,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, padding: const EdgeInsets.symmetric(vertical: 15)),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final User? user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await DatabaseService().addActivity(
                        uid: user.uid,
                        type: type,
                        duration: duration,
                        calories: calories,
                        notes: notes,
                      );
                      Navigator.pop(context);
                    }
                  }
                },
                child: const Text("Save Activity", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}