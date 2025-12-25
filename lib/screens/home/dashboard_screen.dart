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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("FitLife Pro"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? Colors.transparent : Colors.teal,
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(context, user),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. GREETING ---
            Text(
              "Hello, ${user?.displayName ?? 'Athlete'}! 👋",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              "Here is your daily summary.",
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 30),

            // --- 2. STATS GRID ---
            // We use a Column of Rows to create the 2x2 Grid effect
            
            // ROW 1: CALORIES & BMI
            Row(
              children: [
                // CALORIES CARD (Stream 1: Activities)
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: DatabaseService().getUserData(uid),
                    builder: (context, snapshot) {
                      String calories = "0";
                      if (snapshot.hasData) {
                        double total = 0;
                        for (var doc in snapshot.data!.docs) {
                          var data = doc.data() as Map<String, dynamic>;
                          total += double.tryParse(data['calories'].toString()) ?? 0;
                        }
                        calories = total.toStringAsFixed(0);
                      }
                      return _buildGradientCard(
                        title: "Calories",
                        value: "$calories kcal",
                        icon: Icons.local_fire_department,
                        colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
                        isSmall: true,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 15),
                
                // BMI CARD (Stream 2: Metrics)
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: DatabaseService().getUserMetrics(uid),
                    builder: (context, snapshot) {
                      String bmi = "--";
                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        var latest = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                        bmi = latest['bmi'].toString();
                      }
                      return _buildGradientCard(
                        title: "Current BMI",
                        value: bmi,
                        icon: Icons.monitor_weight,
                        // Purple Gradient for BMI
                        colors: [Colors.purple.shade300, Colors.purple.shade700],
                        isSmall: true,
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // ROW 2: WORKOUTS & DURATION
            StreamBuilder<QuerySnapshot>(
              stream: DatabaseService().getUserData(uid),
              builder: (context, snapshot) {
                // Default values
                String workouts = "0";
                String duration = "0 m";

                if (snapshot.hasData) {
                  var docs = snapshot.data!.docs;
                  workouts = docs.length.toString();
                  
                  double totalDur = 0;
                  for (var doc in docs) {
                    var data = doc.data() as Map<String, dynamic>;
                    totalDur += double.tryParse(data['duration'].toString()) ?? 0;
                  }
                  duration = "${totalDur.toStringAsFixed(0)} m";
                }

                return Row(
                  children: [
                    Expanded(
                      child: _buildGradientCard(
                        title: "Workouts",
                        value: workouts,
                        icon: Icons.fitness_center,
                        colors: [Colors.teal.shade300, Colors.teal.shade700],
                        isSmall: true,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildGradientCard(
                        title: "Duration",
                        value: duration,
                        icon: Icons.timer,
                        colors: [Colors.blue.shade300, Colors.blue.shade700],
                        isSmall: true,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 40),

            // --- 3. ACTION BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/add_activity'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                  foregroundColor: Colors.teal,
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  shadowColor: Colors.black26,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, size: 28),
                    SizedBox(width: 10),
                    Text("Log New Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MODERN CARD WIDGET ---
  Widget _buildGradientCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> colors,
    bool isSmall = false,
  }) {
    return Container(
      height: 150, // Fixed height for uniformity in grid
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- DRAWER (Standard) ---
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
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text("History"),
            onTap: () => Navigator.pushNamed(context, '/activity_list'),
          ),
          ListTile(
            leading: const Icon(Icons.monitor_weight),
            title: const Text("Body Metrics Tracker"),
            onTap: () => Navigator.pushNamed(context, '/body_metrics'),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () => Navigator.pushNamed(context, '/profile'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Notifications"),
            onTap: () => Navigator.pushNamed(context, '/notifications'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),
          const Divider(),
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