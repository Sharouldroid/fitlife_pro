import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // 1. IMPORT INTL FOR DATE FORMATTING
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import 'activity_detail_screen.dart';
import '../../widgets/activity_card.dart';

class ActivityListScreen extends StatefulWidget {
  const ActivityListScreen({Key? key}) : super(key: key);

  @override
  State<ActivityListScreen> createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen> {
  // State for filtering
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Running', 'Cycling', 'Swimming', 'Weights', 'Football','Walk'];

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String uid = user?.uid ?? '';
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
        centerTitle: true, 
        elevation: 0,
        backgroundColor: isDark ? Colors.transparent : Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => await AuthService().signOut(),
          )
        ],
      ),
      body: Column(
        children: [
          // 1. HORIZONTAL FILTER CHIPS
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (ctx, i) => const SizedBox(width: 10),
              itemBuilder: (ctx, i) {
                final filter = _filters[i];
                final bool isSelected = _selectedFilter == filter;
                return ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() => _selectedFilter = filter);
                  },
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  selectedColor: Colors.teal,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  side: BorderSide.none,
                );
              },
            ),
          ),

          // 2. ACTIVITY LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: DatabaseService().getUserData(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState(isDark);
                }

                // Filter Logic
                var documents = snapshot.data!.docs;
                if (_selectedFilter != 'All') {
                  documents = documents.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final type = data['type'].toString().toLowerCase();
                    return type.contains(_selectedFilter.toLowerCase());
                  }).toList();
                }

                if (documents.isEmpty) {
                  return Center(child: Text("No $_selectedFilter activities found."));
                }

                return ListView.builder(
                  itemCount: documents.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemBuilder: (context, index) {
                    final doc = documents[index];
                    final data = doc.data() as Map<String, dynamic>;

                    // --- DATE FORMATTING LOGIC ---
                    String formattedDate = "";
                    if (data['timestamp'] != null) {
                      Timestamp t = data['timestamp'];
                      // Creates format like: "Oct 24, 2025"
                      formattedDate = DateFormat.yMMMd().format(t.toDate());
                    } else {
                      formattedDate = "Just now";
                    }
                    // -----------------------------

                    return Dismissible(
                      key: Key(doc.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white, size: 30),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Delete Activity?"),
                            content: const Text("This action cannot be undone."),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text("Cancel")),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true), 
                                child: const Text("Delete", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) async {
                        await DatabaseService().deleteActivity(doc.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Activity deleted")),
                        );
                      },
                      child: ActivityCard(
                        title: data['type'] ?? 'Unknown',
                        // UPDATED SUBTITLE: Shows Duration AND Date
                        subtitle: "${data['duration']} mins  •  $formattedDate",
                        calories: "${data['calories']} kcal",
                        icon: _getIconForType(data['type']),
                        color: _getColorForType(data['type']),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ActivityDetailScreen(docId: doc.id, currentData: data),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add_activity'),
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add),
        label: const Text("New Entry"),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 15),
          Text(
            "No activities found.", 
            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 5),
          Text("Get moving and log your first workout!", style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  IconData _getIconForType(String? type) {
    final t = type?.toLowerCase() ?? '';
    if (t.contains('run')) return Icons.directions_run;
    if (t.contains('walk')) return Icons.directions_walk;
    if (t.contains('swim')) return Icons.pool;
    if (t.contains('bike') || t.contains('cycl')) return Icons.directions_bike;
    if (t.contains('weight') || t.contains('lift') || t.contains('gym')) return Icons.fitness_center;
    if (t.contains('football')) return Icons.sports_soccer;
    return Icons.bolt; 
  }

  Color _getColorForType(String? type) {
    final t = type?.toLowerCase() ?? '';
    if (t.contains('run')) return Colors.orange;
    if (t.contains('swim')) return Colors.blue;
    if (t.contains('football')) return Colors.purple;
    if (t.contains('weight')) return Colors.redAccent;
    if (t.contains('walk'))return Colors.brown;
    if (t.contains('bike') || t.contains('cycl')) return Colors.pinkAccent;
    return Colors.teal;
  }
}