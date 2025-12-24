import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/database_service.dart';
import 'edit_activity_screen.dart';

class ActivityDetailScreen extends StatefulWidget {
  final String docId;
  // We keep this just for the initial loading state or placeholder
  final Map<String, dynamic> currentData;

  const ActivityDetailScreen({
    Key? key,
    required this.docId,
    required this.currentData,
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
        elevation: 0,
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
                    currentData: widget.currentData, // Pass current data to prepopulate form
                  ),
                ),
              );
            },
          ),
          // DELETE BUTTON
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      backgroundColor: Colors.grey[50], // Modern light background
      
      // REAL-TIME DATA STREAM
      body: StreamBuilder<DocumentSnapshot>(
        stream: DatabaseService().activityCollection.doc(widget.docId).snapshots(),
        builder: (context, snapshot) {
          // 1. Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error or Deleted
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Activity not found (it may have been deleted)."));
          }

          // 3. Data Loaded
          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModernDetailCard(
                  icon: Icons.fitness_center,
                  title: "Activity Type",
                  value: data['type'],
                  color: Colors.teal,
                ),
                const SizedBox(height: 15),
                _buildModernDetailCard(
                  icon: Icons.timer,
                  title: "Duration",
                  value: "${data['duration']} mins",
                  color: Colors.blue,
                ),
                const SizedBox(height: 15),
                _buildModernDetailCard(
                  icon: Icons.local_fire_department,
                  title: "Calories Burned",
                  value: "${data['calories']} kcal",
                  color: Colors.orange,
                ),
                const SizedBox(height: 25),
                
                // NOTES SECTION
                const Text(
                  "Notes",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    (data['notes'] != null && data['notes'].toString().isNotEmpty) 
                        ? data['notes'] 
                        : "No notes added.",
                    style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- MODERN CARD WIDGET ---
  Widget _buildModernDetailCard({
    required IconData icon, 
    required String title, 
    required String value, 
    required Color color
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- DELETE CONFIRMATION POPUP ---
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 10)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  radius: 35,
                  child: Icon(Icons.delete_forever, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Delete Activity?",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "This action cannot be undone.\nAre you sure?",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Cancel", style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        onPressed: _isLoading ? null : () async {
                          Navigator.pop(context); // Close Confirmation
                          await _performDelete();
                        },
                        child: const Text("Delete", style: TextStyle(color: Colors.white, fontSize: 16)),
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

  Future<void> _performDelete() async {
    setState(() => _isLoading = true);
    
    try {
      await DatabaseService().deleteActivity(widget.docId);
      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 15),
              const Text("Deleted!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Pop detail screen
                  },
                  child: const Text("OK", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}