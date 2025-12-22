import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile_screen.dart'; // Import the file we just made

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Reload user data to show latest changes
    final user = FirebaseAuth.instance.currentUser;
    user?.reload(); 

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"), 
        backgroundColor: Colors.teal,
        actions: [
          // EDIT BUTTON
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
            },
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.teal,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 20),
              
              // Display Name (Username)
              Text(
                user?.displayName ?? "No Username",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              
              // Email
              Text(
                user?.email ?? "No Email",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              
              const SizedBox(height: 40),
              
              // Stats Row
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(children: [
                    Text("0", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text("Friends")
                  ]),
                  Column(children: [
                    Text("Standard", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text("Plan")
                  ]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}