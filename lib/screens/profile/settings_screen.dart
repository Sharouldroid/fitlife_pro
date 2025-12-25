import 'package:flutter/material.dart';
// IMPORT THE THEME MANAGER (Adjust path if your folder structure is different)
import '../../config/theme_manager.dart'; 

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Local state for notifications (dummy logic for now)
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        elevation: 0,
        // FIX: Teal in Light Mode, Transparent in Dark Mode
        backgroundColor: isDark ? Colors.transparent : Colors.teal,
        // FIX: Always White text (White on Teal looks best)
        foregroundColor: Colors.white,
        
      ),
      body: ListView(
        children: [
          // 1. Notification Switch (Local State)
          SwitchListTile(
            title: const Text("Notifications"),
            subtitle: const Text("Receive daily workout reminders"),
            value: _notifications,
            activeColor: Colors.teal,
            onChanged: (val) => setState(() => _notifications = val),
          ),

          // 2. DARK MODE SWITCH (Global State)
          // We wrap this tile in ValueListenableBuilder so it listens to the global theme
          ValueListenableBuilder<bool>(
            valueListenable: themeNotifier,
            builder: (context, isDark, child) {
              return SwitchListTile(
                title: const Text("Dark Mode"),
                subtitle: const Text("Reduce eye strain"),
                value: isDark, // Value comes from the global variable
                activeColor: Colors.teal,
                onChanged: (val) {
                  // This updates the global variable, triggering main.dart to rebuild!
                  themeNotifier.value = val;
                },
              );
            },
          ),
          
          const Divider(),
          
          // 3. About Section
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("About App"),
            subtitle: Text("Version 1.0.0 (Assignment 2)"),
          ),
        ],
      ),
    );
  }
}