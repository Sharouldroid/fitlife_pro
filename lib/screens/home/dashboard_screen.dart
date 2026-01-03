import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/database_service.dart';
import '../../config/routes.dart'; // Import AppRoutes

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
           return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final User? user = userSnapshot.data;
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
                _buildGreeting(user, isDark),
                
                const SizedBox(height: 30),

                // --- STATS SECTION ---
                StreamBuilder<DocumentSnapshot>(
                  stream: DatabaseService().getUserProfile(uid),
                  builder: (context, profileSnapshot) {
                    
                    if (profileSnapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 250, 
                        child: Center(child: CircularProgressIndicator())
                      );
                    }

                    String totalCalories = "0";
                    String totalWorkouts = "0";
                    String totalDuration = "0 min";

                    if (profileSnapshot.hasData && profileSnapshot.data!.exists) {
                      Map<String, dynamic> data = profileSnapshot.data!.data() as Map<String, dynamic>;
                      
                      num cals = data['totalCalories'] ?? 0;
                      num works = data['totalWorkouts'] ?? 0;
                      num dur = data['totalDuration'] ?? 0;

                      totalCalories = cals.toStringAsFixed(0);
                      totalWorkouts = works.toString();
                      totalDuration = "${dur.toStringAsFixed(0)} min";
                    }

                    return Column(
                      children: [
                        // Row 1
                        Row(
                          children: [
                            Expanded(
                              child: _buildGradientCard(
                                title: "Total Calories",
                                value: totalCalories, 
                                icon: Icons.local_fire_department,
                                colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: StreamBuilder<QuerySnapshot>(
                                stream: DatabaseService().getUserMetrics(uid),
                                builder: (context, metricSnapshot) {
                                  String bmi = "--";
                                  if (metricSnapshot.hasData && metricSnapshot.data!.docs.isNotEmpty) {
                                    var latest = metricSnapshot.data!.docs.first.data() as Map<String, dynamic>;
                                    bmi = latest['bmi'].toString();
                                  }
                                  return _buildGradientCard(
                                    title: "Current BMI",
                                    value: bmi,
                                    icon: Icons.monitor_weight,
                                    colors: [Colors.purple.shade300, Colors.purple.shade700],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        // Row 2
                        Row(
                          children: [
                            Expanded(
                              child: _buildGradientCard(
                                title: "Workouts",
                                value: totalWorkouts,
                                icon: Icons.fitness_center,
                                colors: [Colors.teal.shade300, Colors.teal.shade700],
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildGradientCard(
                                title: "Duration",
                                value: totalDuration,
                                icon: Icons.timer,
                                colors: [Colors.blue.shade300, Colors.blue.shade700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                ),

                const SizedBox(height: 40),

                // CTA Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.addActivity),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                      foregroundColor: Colors.teal,
                      elevation: 5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
    );
  }

  Widget _buildGreeting(User? user, bool isDark) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.teal.shade100,
          backgroundImage: user?.photoURL != null 
              ? NetworkImage(user!.photoURL!) 
              : null,
          child: user?.photoURL == null 
              ? const Icon(Icons.person, color: Colors.teal, size: 30) 
              : null,
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, ${user?.displayName ?? 'Athlete'}! 👋",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              "Let's check your progress.",
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGradientCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> colors,
  }) {
    // FIX FOR OVERFLOW:
    // We remove fixed 'height' and use padding/constraints instead.
    // This allows the card to grow if the font is large or progress bar is added.
    return Container(
      constraints: const BoxConstraints(minHeight: 160), // Ensure minimum size
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
          const SizedBox(height: 15), // Add spacing instead of relying on alignment
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
              
              // --- VISUAL LOGIC: Progress Bar for Calories ---
              if (title == "Total Calories") ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: ((double.tryParse(value) ?? 0) / 2000).clamp(0.0, 1.0),
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    minHeight: 6,
                  ),
                ),
              ],
            ],
          ),
        ],
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
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: user?.photoURL != null 
                  ? NetworkImage(user!.photoURL!) 
                  : null,
              child: user?.photoURL == null 
                  ? const Icon(Icons.person, color: Colors.teal, size: 40)
                  : null,
            ),
            decoration: const BoxDecoration(color: Colors.teal),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text("History"),
            onTap: () => Navigator.pushNamed(context, AppRoutes.activityList),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text("Calendar"),
            onTap: () => Navigator.pushNamed(context, AppRoutes.calendar),
          ),
          ListTile(
            leading: const Icon(Icons.monitor_weight),
            title: const Text("Body Metrics Tracker"),
            onTap: () => Navigator.pushNamed(context, AppRoutes.bodyMetrics), 
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Notifications"),
            onTap: () => Navigator.pushNamed(context, '/notifications'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
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