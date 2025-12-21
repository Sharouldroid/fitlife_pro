import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final CollectionReference activityCollection =
      FirebaseFirestore.instance.collection('activities');

  // Add Activity
  Future<void> addActivity({
    required String uid,
    required String type,
    required String duration,
    required String calories,
    required String notes,
  }) async {
    // FIX: Removed 'return' here. Just await the command.
    await activityCollection.add({
      'uid': uid,
      'type': type,
      'duration': duration,
      'calories': calories,
      'notes': notes,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Get User Data Stream
  Stream<QuerySnapshot> getUserData(String uid) {
    return activityCollection
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Update Activity
  Future<void> updateActivity({
    required String docId,
    required String type,
    required String duration,
    required String calories,
    required String notes,
  }) async {
    return await activityCollection.doc(docId).update({
      'type': type,
      'duration': duration,
      'calories': calories,
      'notes': notes,
    });
  }

  // Delete Activity
  Future<void> deleteActivity(String docId) async {
    return await activityCollection.doc(docId).delete();
  }
}