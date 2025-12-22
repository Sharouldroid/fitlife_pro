import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.teal,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              user?.email ?? "No Email",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("Member since 2024", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Log Out"),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}