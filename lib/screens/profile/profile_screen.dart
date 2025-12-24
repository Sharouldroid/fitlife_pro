import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile_screen.dart'; 
import '../../services/auth_service.dart'; // To handle Logout

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  // Refresh user data when screen loads
  @override
  void initState() {
    super.initState();
    _refreshUser();
  }

  Future<void> _refreshUser() async {
    await user?.reload();
    setState(() {}); // Rebuild UI with new data
  }

  @override
  Widget build(BuildContext context) {
    // Detect Dark Mode
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color mutedColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      // Allow the body to extend behind the AppBar for a modern look
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
            // --- 1. HEADER SECTION (Gradient + Avatar) ---
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Background Gradient
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
                // Profile Picture
                Positioned(
                  bottom: -50,
                  child: Container(
                    padding: const EdgeInsets.all(4), // Border width
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
            
            const SizedBox(height: 60), // Space for the overlapping avatar

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

            // Edit Profile Chip
            ActionChip(
              label: const Text("Edit Profile"),
              avatar: const Icon(Icons.edit, size: 16),
              backgroundColor: isDark ? Colors.teal.withOpacity(0.2) : Colors.teal.shade50,
              labelStyle: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
              side: BorderSide.none,
              onPressed: () async {
                // Navigate to Edit and wait for return
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                );
                _refreshUser(); // Refresh name when coming back
              },
            ),

            const SizedBox(height: 30),

            // --- 3. STATS CARD ---
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
                    Container(height: 40, width: 1, color: Colors.grey[300]), // Divider
                    _buildStatItem("Plan", "Free", isDark),
                    Container(height: 40, width: 1, color: Colors.grey[300]), // Divider
                    _buildStatItem("Weight", "65kg", isDark),
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
              // Navigation is handled by the Auth Wrapper in main.dart
            }, isDark, isRed: true),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Stats
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

  // Helper Widget for Menu Options
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