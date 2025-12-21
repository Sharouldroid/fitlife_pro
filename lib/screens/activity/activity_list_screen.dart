import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import 'activity_detail_screen.dart';

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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseService().getUserData(uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No activities found.\nStart by adding a new workout!", textAlign: TextAlign.center));
          }

          final documents = snapshot.data!.docs;
          return ListView.builder(
            itemCount: documents.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final doc = documents[index];
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade100,
                    child: Icon(Icons.fitness_center, color: Colors.teal),
                  ),
                  title: Text(data['type'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Duration: ${data['duration']} | Burned: ${data['calories']} kcal"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add_activity'),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}