import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import 'edit_activity_screen.dart';

class ActivityDetailScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> currentData;

  const ActivityDetailScreen({
    Key? key, 
    required this.docId, 
    required this.currentData
  }) : super(key: key);

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Activity Details"),
        backgroundColor: Colors.teal,
        actions: [
          // EDIT BUTTON
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditActivityScreen(
                    docId: widget.docId, 
                    currentData: widget.currentData
                  ),
                ),
              );
            },
          ),
          // DELETE BUTTON (Triggers Modern Popup)
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
            _buildDetailCard(
              icon: Icons.fitness_center,
              title: "Activity Type",
              value: widget.currentData['type'],
            ),
            const SizedBox(height: 15),
            _buildDetailCard(
              icon: Icons.timer,
              title: "Duration",
              value: "${widget.currentData['duration']} mins", // Display raw string or format it
            ),
            const SizedBox(height: 15),
            _buildDetailCard(
              icon: Icons.local_fire_department,
              title: "Calories Burned",
              value: "${widget.currentData['calories']} kcal",
            ),
            const SizedBox(height: 15),
            const Text("Notes:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.currentData['notes'] ?? "No notes added.",
                style: const TextStyle(fontSize: 16),
              ),
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
        subtitle: Text(
          value.toString(), 
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)
        ),
      ),
    );
  }

  // --- 1. MODERN DELETE CONFIRMATION ---
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  radius: 30,
                  child: Icon(Icons.delete_forever, size: 35, color: Colors.white),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Delete Activity?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Are you sure you want to remove this record? This action cannot be undone.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context), // Cancel
                        child: const Text("Cancel", style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _isLoading ? null : () async {
                          // 1. Close Confirmation Dialog
                          Navigator.pop(context);
                          
                          // 2. Perform Delete
                          await _performDelete();
                        },
                        child: const Text("Delete", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- 2. PERFORM DELETE & SHOW SUCCESS ---
  Future<void> _performDelete() async {
    setState(() => _isLoading = true);
    
    try {
      await DatabaseService().deleteActivity(widget.docId);
      
      // Show Success Dialog
      if (!mounted) return;
      _showSuccessDialog();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 3. MODERN SUCCESS DIALOG ---
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.green,
                  radius: 35,
                  child: Icon(Icons.check, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Deleted!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "The activity has been removed from your history.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Close Success Dialog
                      Navigator.pop(context); // Close Detail Screen -> Back to List
                    },
                    child: const Text("OK", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}