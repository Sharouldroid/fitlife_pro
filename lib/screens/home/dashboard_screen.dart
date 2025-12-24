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
        backgroundColor: Colors.teal, // Transparent for modern look
        foregroundColor: isDark ? Colors.teal : Colors.white, // Icon/Text color
      ),
      drawer: _buildDrawer(context, user),
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseService().getUserData(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(context);
          }

          // --- CALCULATE TOTALS ---
          final docs = snapshot.data!.docs;
          final int totalWorkouts = docs.length;
          double totalCalories = 0;
          int totalDuration = 0;

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            String calString = data['calories'].toString().replaceAll(RegExp(r'[^0-9.]'), '');
            totalCalories += double.tryParse(calString) ?? 0;

            String durRaw = data['duration'].toString().toLowerCase();
            String durNumber = durRaw.replaceAll(RegExp(r'[^0-9.]'), '');
            double val = double.tryParse(durNumber) ?? 0;

            if (durRaw.contains('h')) {
              totalDuration += (val * 60).toInt();
            } else {
              totalDuration += val.toInt();
            }
          }

          // --- MAIN LAYOUT ---
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. GREETING HEADER
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

                // 2. HERO CARD (Calories) - Uses Gradient
                _buildGradientCard(
                  title: "Calories Burned",
                  value: "${totalCalories.toStringAsFixed(0)} kcal",
                  icon: Icons.local_fire_department_rounded,
                  colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
                ),

                const SizedBox(height: 20),

                // 3. ROW OF SMALLER CARDS
                Row(
                  children: [
                    Expanded(
                      child: _buildGradientCard(
                        title: "Workouts",
                        value: "$totalWorkouts",
                        icon: Icons.fitness_center,
                        colors: [Colors.teal.shade300, Colors.teal.shade700],
                        isSmall: true,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildGradientCard(
                        title: "Duration",
                        value: "$totalDuration m",
                        icon: Icons.timer,
                        colors: [Colors.blue.shade300, Colors.blue.shade700],
                        isSmall: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // 4. ACTION BUTTON
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
          );
        },
      ),
    );
  }

  // --- MODERN GRADIENT CARD ---
  Widget _buildGradientCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> colors,
    bool isSmall = false,
  }) {
    return Container(
      height: isSmall ? 140 : 160,
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
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: isSmall ? 24 : 30),
          ),
          // Text Data
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: isSmall ? 24 : 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
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

  // --- EMPTY STATE ---
  Widget _buildEmptyState(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dashboard_customize_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            "Your Dashboard is Empty",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 10),
          const Text("Start by adding your first workout!", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/add_activity'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("Start Tracking", style: TextStyle(fontSize: 16, color: Colors.white)),
          )
        ],
      ),
    );
  }

  // --- DRAWER (Unchanged logic, just clean) ---
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