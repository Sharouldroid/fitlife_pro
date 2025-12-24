import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  // --- COLLECTION REFERENCES ---
  final CollectionReference activityCollection =
      FirebaseFirestore.instance.collection('activities');
  
  final CollectionReference metricsCollection = 
      FirebaseFirestore.instance.collection('body_metrics');

  // ==================================================
  //                ACTIVITY FUNCTIONS
  // ==================================================

  // 1. Add Activity
  Future<void> addActivity({
    required String uid,
    required String type,
    required String duration,
    required String calories,
    required String notes,
  }) async {
    await activityCollection.add({
      'uid': uid,
      'type': type,
      'duration': duration,
      'calories': calories,
      'notes': notes,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // 2. Get User Activities (Stream)
  Stream<QuerySnapshot> getUserData(String uid) {
    return activityCollection
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // 3. Update Activity
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

  // 4. Delete Activity
  Future<void> deleteActivity(String docId) async {
    return await activityCollection.doc(docId).delete();
  }
  //BODY METRICS FUNCTIONS
  // 1. Add Body Metric (Weight/BMI)
  Future<void> addMetric({
    required String uid, 
    required String weight, 
    required String bmi
  }) async {
    await metricsCollection.add({
      'uid': uid,
      'weight': weight,
      'bmi': bmi,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // 2. Get User Metrics (Stream)
  Stream<QuerySnapshot> getUserMetrics(String uid) {
    return metricsCollection
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // 3. Update Metric
  Future<void> updateMetric({
    required String docId, 
    required String weight, 
    required String bmi
  }) async {
    await metricsCollection.doc(docId).update({
      'weight': weight,
      'bmi': bmi,
    });
  }

  // 4. Delete Metric
  Future<void> deleteMetric(String docId) async {
    await metricsCollection.doc(docId).delete();
  }
}