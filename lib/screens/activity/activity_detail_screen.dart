import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import 'edit_activity_screen.dart';

class ActivityDetailScreen extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> currentData;

  const ActivityDetailScreen({Key? key, required this.docId, required this.currentData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Activity Details"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditActivityScreen(docId: docId, currentData: currentData),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailCard(icon: Icons.fitness_center, title: "Activity Type", value: currentData['type']),
            const SizedBox(height: 15),
            _buildDetailCard(icon: Icons.timer, title: "Duration", value: "${currentData['duration']} mins"),
            const SizedBox(height: 15),
            _buildDetailCard(icon: Icons.local_fire_department, title: "Calories Burned", value: "${currentData['calories']} kcal"),
            const SizedBox(height: 15),
            const Text("Notes:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
              child: Text(currentData['notes'] ?? "No notes added.", style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({required IconData icon, required String title, required dynamic value}) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, color: Colors.teal, size: 40),
        title: Text(title, style: const TextStyle(color: Colors.grey)),
        subtitle: Text(value.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Activity?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await DatabaseService().deleteActivity(docId);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Activity Deleted Successfully")));
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}