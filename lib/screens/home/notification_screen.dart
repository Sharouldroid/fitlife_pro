import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Detect Dark Mode
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
        elevation: 0,
        // FIX: Teal in Light Mode, Transparent in Dark Mode
        backgroundColor: isDark ? Colors.transparent : Colors.teal,
        // FIX: Always White text (White on Teal looks best)
        foregroundColor: Colors.white,
        // Color handled by Theme in main.dart
      ),
      // Background color handled by Theme
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildNotificationCard(
            context,
            title: "Time to workout!",
            subtitle: "It's been 2 days since your last run.",
            time: "2h ago",
            icon: Icons.notifications_active,
            color: Colors.orange,
            isDark: isDark,
          ),
          _buildNotificationCard(
            context,
            title: "Update Available",
            subtitle: "FitLife Pro version 1.1 is out.",
            time: "1d ago",
            icon: Icons.info_outline,
            color: Colors.blue,
            isDark: isDark,
          ),
          _buildNotificationCard(
            context,
            title: "Welcome!",
            subtitle: "Thanks for joining FitLife Pro.",
            time: "3d ago",
            icon: Icons.star,
            color: Colors.teal,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          radius: 25,
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle,
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
          ),
        ),
        trailing: Text(
          time,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ),
    );
  }
}