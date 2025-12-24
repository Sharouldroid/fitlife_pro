import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import 'activity_detail_screen.dart';
// IMPORT YOUR CUSTOM WIDGET
import '../../widgets/activity_card.dart'; 

class ActivityListScreen extends StatelessWidget {
  const ActivityListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String uid = user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Activity History"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
            },
          )
        ],
      ),
      backgroundColor: Colors.grey[50], // Light background for contrast
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseService().getUserData(uid),
        builder: (context, snapshot) {
          // 1. Error State
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // 2. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 3. Empty State
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 15),
                  const Text(
                    "No activities found.\nStart by adding a new workout!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // 4. Data List
          final documents = snapshot.data!.docs;
          
          return ListView.builder(
            itemCount: documents.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemBuilder: (context, index) {
              final doc = documents[index];
              final data = doc.data() as Map<String, dynamic>;

              // Using your new Custom ActivityCard Widget
              return ActivityCard(
                title: data['type'] ?? 'Unknown Workout',
                subtitle: "${data['duration']} mins",
                calories: "${data['calories']} kcal",
                icon: _getIconForType(data['type']), // Dynamic Icon logic
                color: _getColorForType(data['type']), // Dynamic Color logic
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActivityDetailScreen(
                        docId: doc.id, 
                        currentData: data
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add_activity'),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Helper to pick a nice icon based on the workout name
  IconData _getIconForType(String? type) {
    final t = type?.toLowerCase() ?? '';
    if (t.contains('run')) return Icons.directions_run;
    if (t.contains('walk')) return Icons.directions_walk;
    if (t.contains('swim')) return Icons.pool;
    if (t.contains('bike') || t.contains('cycl')) return Icons.directions_bike;
    if (t.contains('yoga')) return Icons.self_improvement;
    return Icons.fitness_center; // Default
  }

  // Helper to pick a color based on workout type
  Color _getColorForType(String? type) {
    final t = type?.toLowerCase() ?? '';
    if (t.contains('run')) return Colors.orange;
    if (t.contains('swim')) return Colors.blue;
    if (t.contains('yoga')) return Colors.purple;
    return Colors.teal; // Default
  }
}