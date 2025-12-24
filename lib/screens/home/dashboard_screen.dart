import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/database_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String uid = user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.teal,
      ),
      drawer: _buildDrawer(context, user),
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseService().getUserData(uid),
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Empty State
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(context);
          }

          // 3. Calculate Totals (SMART LOGIC)
          final docs = snapshot.data!.docs;
          final int totalWorkouts = docs.length;
          double totalCalories = 0;
          int totalDuration = 0;

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            
            // --- CALORIES LOGIC ---
            String calString = data['calories'].toString().replaceAll(RegExp(r'[^0-9.]'), '');
            totalCalories += double.tryParse(calString) ?? 0;

            // --- DURATION LOGIC (Minutes & Hours) ---
            String durRaw = data['duration'].toString().toLowerCase();
            String durNumber = durRaw.replaceAll(RegExp(r'[^0-9.]'), '');
            double val = double.tryParse(durNumber) ?? 0;

            if (durRaw.contains('h')) {
              totalDuration += (val * 60).toInt();
            } else {
              totalDuration += val.toInt();
            }
          }

          // 4. Display Dashboard
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Your Progress",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                
                // Stat Cards
                _buildStatCard("Workouts", "$totalWorkouts", Icons.directions_run, Colors.teal),
                const SizedBox(height: 10),
                _buildStatCard("Calories", "${totalCalories.toStringAsFixed(0)} kcal", Icons.local_fire_department, Colors.orange),
                const SizedBox(height: 10),
                _buildStatCard("Duration", "$totalDuration mins", Icons.timer, Colors.blue),
                
                const SizedBox(height: 30),
                
                // Action Button
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/add_activity'),
                  icon: const Icon(Icons.add),
                  label: const Text("Log New Activity"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.all(15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.analytics_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 15),
          const Text("No activities yet!", style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/add_activity'),
            child: const Text("Start Tracking"),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          radius: 30,
          child: Icon(icon, size: 30, color: color),
        ),
        title: Text(title, style: const TextStyle(color: Colors.grey)),
        subtitle: Text(
          value, 
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, User? user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text("Welcome Back"),
            accountEmail: Text(user?.email ?? "User"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.teal),
            ),
            decoration: const BoxDecoration(color: Colors.teal),
          ),
          
          // 1. History
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text("History"),
            onTap: () => Navigator.pushNamed(context, '/activity_list'),
          ),

          // 2. NEW: Body Metrics Tracker (Added Here)
          ListTile(
            leading: const Icon(Icons.monitor_weight),
            title: const Text("Body Metrics Tracker"),
            onTap: () => Navigator.pushNamed(context, '/body_metrics'),
          ),

          // 3. Profile
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () => Navigator.pushNamed(context, '/profile'),
          ),

          // 4. Settings
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),
          
          const Divider(),
          
          // 5. Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}