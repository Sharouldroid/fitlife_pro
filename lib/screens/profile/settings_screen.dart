import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';
import '../../config/theme_manager.dart'; 

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _isFixing = false;

  // --- THE FIX FUNCTION (Recalculate) ---
  Future<void> _runDataFix() async {
    setState(() => _isFixing = true);
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      try {
        await DatabaseService().recalculateUserStats(user.uid);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Success! Your Dashboard stats are now accurate."),
            backgroundColor: Colors.green,
          )
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red)
        );
      }
    }
    if (mounted) {
      setState(() => _isFixing = false);
    }
  }

  // --- THE DEBUG FUNCTION (Reset to 0) ---
  Future<void> _runDebugReset() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await DatabaseService().debugResetStats(user.uid);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("DEBUG: Stats reset to 0. Go check Dashboard."),
          backgroundColor: Colors.red,
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? Colors.transparent : Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // 1. Notification Switch
          SwitchListTile(
            title: const Text("Notifications"),
            subtitle: const Text("Receive daily workout reminders"),
            value: _notifications,
            activeColor: Colors.teal,
            onChanged: (val) => setState(() => _notifications = val),
          ),

          // 2. Dark Mode Switch
          ValueListenableBuilder<bool>(
            valueListenable: themeNotifier,
            builder: (context, isDark, child) {
              return SwitchListTile(
                title: const Text("Dark Mode"),
                subtitle: const Text("Reduce eye strain"),
                value: isDark, 
                activeColor: Colors.teal,
                onChanged: (val) {
                  themeNotifier.value = val;
                },
              );
            },
          ),
          
          const Divider(),

          // 3. DATA MANAGEMENT SECTION
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text("Data Management", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
          ),
          
          // REPAIR BUTTON
          ListTile(
            leading: _isFixing 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) 
              : const Icon(Icons.sync, color: Colors.orange),
            title: const Text("Sync & Repair Stats"),
            subtitle: const Text("Fix dashboard zeros or incorrect totals."),
            onTap: _isFixing ? null : _runDataFix,
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),

          // DEBUG BUTTON (TEMPORARY)
          ListTile(
            leading: const Icon(Icons.bug_report, color: Colors.red),
            title: const Text("Debug: Reset to Zero"),
            subtitle: const Text("Simulate broken data for testing."),
            onTap: _runDebugReset,
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),

          const Divider(),
          
          // 4. About Section
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