import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: "Display Name",
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 15),
            const TextField(
              decoration: InputDecoration(
                labelText: "Bio / Status",
                prefixIcon: Icon(Icons.info_outline),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Just pop back for now (Mock functionality)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Profile Updated (Demo)"))
                  );
                  Navigator.pop(context);
                },
                child: const Text("Save Changes"),
              ),
            )
          ],
        ),
      ),
    );
  }
}