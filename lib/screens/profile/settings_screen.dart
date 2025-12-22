import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Enable Notifications"),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() => _notificationsEnabled = value);
            },
            secondary: const Icon(Icons.notifications),
          ),
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: _darkMode,
            onChanged: (bool value) {
              setState(() => _darkMode = value);
            },
            secondary: const Icon(Icons.dark_mode),
          ),
          const Divider(),
          ListTile(
            title: const Text("About App"),
            subtitle: const Text("Version 1.0.0"),
            leading: const Icon(Icons.info),
            onTap: () {
              // Show about dialog
              showAboutDialog(
                context: context,
                applicationName: "FitLife Pro",
                applicationVersion: "1.0.0",
                children: [const Text("Developed for Assignment 2")],
              );
            },
          )
        ],
      ),
    );
  }
}