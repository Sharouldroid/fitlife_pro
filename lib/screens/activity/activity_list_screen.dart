import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import 'activity_detail_screen.dart';
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
        // REMOVED: backgroundColor: Colors.teal
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => await AuthService().signOut(),
          )
        ],
      ),
      // REMOVED: backgroundColor: Colors.grey[50]
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseService().getUserData(uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 15),
                  const Text("No activities found.", style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          final documents = snapshot.data!.docs;
          return ListView.builder(
            itemCount: documents.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemBuilder: (context, index) {
              final doc = documents[index];
              final data = doc.data() as Map<String, dynamic>;

              return ActivityCard(
                title: data['type'] ?? 'Unknown',
                subtitle: "${data['duration']} mins",
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
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add_activity'),
        backgroundColor: Colors.teal, // Floating buttons usually keep their accent color
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getIconForType(String? type) {
    final t = type?.toLowerCase() ?? '';
    if (t.contains('run')) return Icons.directions_run;
    if (t.contains('walk')) return Icons.directions_walk;
    if (t.contains('swim')) return Icons.pool;
    if (t.contains('bike') || t.contains('cycl')) return Icons.directions_bike;
    if (t.contains('yoga')) return Icons.self_improvement;
    return Icons.fitness_center;
  }

  Color _getColorForType(String? type) {
    final t = type?.toLowerCase() ?? '';
    if (t.contains('run')) return Colors.orange;
    if (t.contains('swim')) return Colors.blue;
    if (t.contains('yoga')) return Colors.purple;
    return Colors.teal;
  }
}