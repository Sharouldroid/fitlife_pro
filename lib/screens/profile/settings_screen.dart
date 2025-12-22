import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), backgroundColor: Colors.teal),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Notifications"),
            subtitle: const Text("Receive daily workout reminders"),
            value: _notifications,
            activeColor: Colors.teal,
            onChanged: (val) => setState(() => _notifications = val),
          ),
          SwitchListTile(
            title: const Text("Dark Mode"),
            subtitle: const Text("Reduce eye strain"),
            value: _darkMode,
            activeColor: Colors.teal,
            onChanged: (val) => setState(() => _darkMode = val),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("About App"),
            subtitle: const Text("Version 1.0.0 (Assignment 2)"),
          ),
        ],
      ),
    );
  }
}