import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../../services/database_service.dart'; // Import Database Service
import '../../services/auth_service.dart'; 
import 'edit_profile_screen.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _refreshUser();
  }

  Future<void> _refreshUser() async {
    await user?.reload();
    if (mounted) setState(() {}); 
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color mutedColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 1. HEADER SECTION ---
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark 
                          ? [Colors.teal.shade900, Colors.black]
                          : [Colors.teal.shade400, Colors.teal.shade800],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: user?.photoURL != null 
                          ? NetworkImage(user!.photoURL!) 
                          : null,
                      child: user?.photoURL == null
                          ? const Icon(Icons.person, size: 60, color: Colors.grey)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 60),

            // --- 2. NAME & EMAIL ---
            Text(
              user?.displayName ?? "User",
              style: TextStyle(
                fontSize: 26, 
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              user?.email ?? "No Email",
              style: TextStyle(fontSize: 16, color: mutedColor),
            ),
            
            const SizedBox(height: 15),

            ActionChip(
              label: const Text("Edit Profile"),
              avatar: const Icon(Icons.edit, size: 16),
              backgroundColor: isDark ? Colors.teal.withOpacity(0.2) : Colors.teal.shade50,
              labelStyle: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
              side: BorderSide.none,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                );
                _refreshUser();
              },
            ),

            const SizedBox(height: 30),

            // --- 3. STATS CARD (Updated Logic) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem("Friends", "12", isDark),
                    Container(height: 40, width: 1, color: Colors.grey[300]),
                    
                    _buildStatItem("Plan", "Free", isDark),
                    Container(height: 40, width: 1, color: Colors.grey[300]),
                    
                    // --- DYNAMIC WEIGHT ---
                    StreamBuilder<QuerySnapshot>(
                      // We reuse the existing service method.
                      // Since it orders by descending timestamp, the first doc is the latest.
                      stream: DatabaseService().getUserMetrics(user?.uid ?? ''),
                      builder: (context, snapshot) {
                        String weightText = "--";
                        
                        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                          final latestDoc = snapshot.data!.docs.first;
                          final data = latestDoc.data() as Map<String, dynamic>;
                          weightText = "${data['weight']}kg";
                        }

                        return _buildStatItem("Weight", weightText, isDark);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- 4. MENU OPTIONS ---
            _buildMenuOption(context, "Activity History", Icons.history, () {
              Navigator.pushNamed(context, '/activity_list');
            }, isDark),
            
            _buildMenuOption(context, "Body Metrics", Icons.monitor_weight_outlined, () {
              Navigator.pushNamed(context, '/body_metrics');
            }, isDark),
            
            _buildMenuOption(context, "Log Out", Icons.logout, () async {
              await AuthService().signOut();
            }, isDark, isRed: true),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuOption(BuildContext context, String title, IconData icon, VoidCallback onTap, bool isDark, {bool isRed = false}) {
    Color iconColor = isRed ? Colors.redAccent : Colors.teal;
    Color textColor = isRed 
        ? Colors.redAccent 
        : (isDark ? Colors.white : Colors.black87);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: textColor,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}