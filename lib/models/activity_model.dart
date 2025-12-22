import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityModel {
  final String id;
  final String uid;
  final String type;
  final String duration;
  final String calories;
  final String notes;
  final DateTime timestamp;

  ActivityModel({
    required this.id,
    required this.uid,
    required this.type,
    required this.duration,
    required this.calories,
    required this.notes,
    required this.timestamp,
  });

  // Factory to create object from Firebase Data
  factory ActivityModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ActivityModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      type: data['type'] ?? '',
      duration: data['duration'] ?? '',
      calories: data['calories'] ?? '',
      notes: data['notes'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}