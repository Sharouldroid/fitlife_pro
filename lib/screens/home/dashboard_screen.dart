import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text("User"),
              accountEmail: Text(user?.email ?? "guest@fitlife.com"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.teal),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text("Activity History"),
              onTap: () => Navigator.pushNamed(context, '/home'), // Goes to list
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
             ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatCard("Total Workouts", "12", Icons.directions_run),
            const SizedBox(height: 10),
            _buildStatCard("Calories Burned", "3,450 kcal", Icons.local_fire_department),
            const SizedBox(height: 10),
            _buildStatCard("Active Minutes", "420 mins", Icons.timer),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.teal),
        title: Text(title),
        subtitle: Text(
          value, 
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }
}