import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/database_service.dart';
import 'edit_activity_screen.dart';

class ActivityDetailScreen extends StatefulWidget {
  final String docId;
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
    // 1. DETECT DARK MODE
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Activity Details"),
        // Remove backgroundColor: Colors.teal so it uses Theme
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditActivityScreen(
                    docId: widget.docId,
                    currentData: widget.currentData,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context, isDark),
          ),
        ],
      ),
      // Remove backgroundColor: Colors.grey[50] so it uses Theme
      
      body: StreamBuilder<DocumentSnapshot>(
        stream: DatabaseService().activityCollection.doc(widget.docId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Activity not found (it may have been deleted)."));
          }

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
                  isDark: isDark, // Pass Dark Mode status
                ),
                const SizedBox(height: 15),
                _buildModernDetailCard(
                  icon: Icons.timer,
                  title: "Duration",
                  value: "${data['duration']} mins",
                  color: Colors.blue,
                  isDark: isDark,
                ),
                const SizedBox(height: 15),
                _buildModernDetailCard(
                  icon: Icons.local_fire_department,
                  title: "Calories Burned",
                  value: "${data['calories']} kcal",
                  color: Colors.orange,
                  isDark: isDark,
                ),
                const SizedBox(height: 25),
                
                // NOTES SECTION
                Text(
                  "Notes",
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    color: isDark ? Colors.white : Colors.black87
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    // Change Background based on Mode
                    color: isDark ? Colors.grey[800] : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    (data['notes'] != null && data['notes'].toString().isNotEmpty) 
                        ? data['notes'] 
                        : "No notes added.",
                    style: TextStyle(
                      fontSize: 16, 
                      height: 1.5, 
                      color: isDark ? Colors.grey[300] : Colors.black87
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- UPDATED CARD WIDGET ---
  Widget _buildModernDetailCard({
    required IconData icon, 
    required String title, 
    required String value, 
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Dynamic Background Color
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                style: TextStyle(
                  fontSize: 14, 
                  color: isDark ? Colors.grey[400] : Colors.grey[600]
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold, 
                  // Dynamic Text Color
                  color: isDark ? Colors.white : Colors.black87
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- DELETE CONFIRMATION POPUP ---
  void _showDeleteConfirmation(BuildContext context, bool isDark) {
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
              color: isDark ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(20),
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
                Text(
                  "Delete Activity?",
                  style: TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "This action cannot be undone.\nAre you sure?",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel", style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _isLoading ? null : () async {
                          Navigator.pop(context);
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

  Future<void> _performDelete() async {
    setState(() => _isLoading = true);
    try {
      await DatabaseService().deleteActivity(widget.docId);
      if (!mounted) return;
      // We pass 'false' for isDark here just for simplicity, or you can pass actual state
      // But typically success dialogs look fine in standard colors or we update that too.
      // For now, let's just close the screen to match standard behavior.
      Navigator.pop(context); 
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}