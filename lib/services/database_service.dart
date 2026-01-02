import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final CollectionReference activityCollection = FirebaseFirestore.instance.collection('activities');
  final CollectionReference metricsCollection = FirebaseFirestore.instance.collection('body_metrics');
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  // ==================================================
  //                ACTIVITY FUNCTIONS
  // ==================================================

  // --- ADD ACTIVITY (AGGREGATED) ---
  Future<void> addActivity({
    required String uid,
    required String type,
    required String duration,
    required String calories,
    required String notes,
  }) async {
    final double durationVal = double.tryParse(duration) ?? 0.0;
    final double caloriesVal = double.tryParse(calories) ?? 0.0;

    WriteBatch batch = FirebaseFirestore.instance.batch();
    DocumentReference newActivityRef = activityCollection.doc();

    batch.set(newActivityRef, {
      'uid': uid,
      'type': type,
      'duration': duration,
      'calories': calories,
      'notes': notes,
      'timestamp': FieldValue.serverTimestamp(),
    });

    DocumentReference userRef = userCollection.doc(uid);
    batch.set(
      userRef,
      {
        'totalWorkouts': FieldValue.increment(1),
        'totalDuration': FieldValue.increment(durationVal),
        'totalCalories': FieldValue.increment(caloriesVal),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  // --- 2. GET USER ACTIVITIES (STREAM) ---
  Stream<QuerySnapshot> getUserData(String uid) {
    return activityCollection
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // --- 2b. GET USER PROFILE (STREAM) ---
  Stream<DocumentSnapshot> getUserProfile(String uid) {
    return userCollection.doc(uid).snapshots();
  }

  // --- UPDATE ACTIVITY ---
  Future<void> updateActivity({
    required String docId,
    required String type,
    required String duration,
    required String calories,
    required String notes,
  }) async {
    final double newDurationVal = double.tryParse(duration) ?? 0.0;
    final double newCaloriesVal = double.tryParse(calories) ?? 0.0;
    final DocumentReference activityRef = activityCollection.doc(docId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(activityRef);
      if (!snapshot.exists) throw Exception("Activity does not exist!");

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      double oldDurationVal = double.tryParse(data['duration'] ?? '0') ?? 0.0;
      double oldCaloriesVal = double.tryParse(data['calories'] ?? '0') ?? 0.0;
      String uid = data['uid'];
      DocumentReference userRef = userCollection.doc(uid);

      double durationDiff = newDurationVal - oldDurationVal;
      double caloriesDiff = newCaloriesVal - oldCaloriesVal;

      transaction.update(activityRef, {
        'type': type,
        'duration': duration,
        'calories': calories,
        'notes': notes,
      });

      transaction.update(userRef, {
        'totalDuration': FieldValue.increment(durationDiff),
        'totalCalories': FieldValue.increment(caloriesDiff),
      });
    });
  }

  // --- DELETE ACTIVITY ---
  Future<void> deleteActivity(String docId) async {
    final DocumentReference activityRef = activityCollection.doc(docId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(activityRef);
      if (!snapshot.exists) return;

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      double oldDurationVal = double.tryParse(data['duration'] ?? '0') ?? 0.0;
      double oldCaloriesVal = double.tryParse(data['calories'] ?? '0') ?? 0.0;
      String uid = data['uid'];
      DocumentReference userRef = userCollection.doc(uid);

      transaction.update(userRef, {
        'totalWorkouts': FieldValue.increment(-1),
        'totalDuration': FieldValue.increment(-oldDurationVal),
        'totalCalories': FieldValue.increment(-oldCaloriesVal),
      });

      transaction.delete(activityRef);
    });
  }

  // ==================================================
  //              MIGRATION / REPAIR TOOLS
  // ==================================================
  
  // 1. Recalculate (The Fix)
  Future<void> recalculateUserStats(String uid) async {
    QuerySnapshot snapshot = await activityCollection.where('uid', isEqualTo: uid).get();
    
    double totalCals = 0;
    double totalDur = 0;
    int totalCount = snapshot.docs.length;

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      totalCals += double.tryParse(data['calories'].toString()) ?? 0;
      totalDur += double.tryParse(data['duration'].toString()) ?? 0;
    }

    await userCollection.doc(uid).set({
      'totalWorkouts': totalCount,
      'totalCalories': totalCals,
      'totalDuration': totalDur,
    }, SetOptions(merge: true)); 
  }

  // 2. DEBUG RESET (The Break)
  Future<void> debugResetStats(String uid) async {
    await userCollection.doc(uid).set({
      'totalWorkouts': 0,
      'totalCalories': 0,
      'totalDuration': 0,
    }, SetOptions(merge: true));
  }

  // ==================================================
  //              BODY METRICS FUNCTIONS
  // ==================================================

  Future<void> addMetric({required String uid, required String weight, required String bmi}) async {
    await metricsCollection.add({
      'uid': uid,
      'weight': weight,
      'bmi': bmi,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getUserMetrics(String uid) {
    return metricsCollection
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> updateMetric({required String docId, required String weight, required String bmi}) async {
    await metricsCollection.doc(docId).update({'weight': weight, 'bmi': bmi});
  }

  Future<void> deleteMetric(String docId) async {
    await metricsCollection.doc(docId).delete();
  }
}