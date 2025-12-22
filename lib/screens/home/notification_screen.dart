import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.notifications_active, color: Colors.orange),
            title: Text("Time to workout!"),
            subtitle: Text("It's been 2 days since your last run."),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info, color: Colors.blue),
            title: Text("Update Available"),
            subtitle: Text("FitLife Pro version 1.1 is out."),
          ),
        ],
      ),
    );
  }
}