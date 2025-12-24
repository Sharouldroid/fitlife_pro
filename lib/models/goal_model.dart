class GoalModel {
  final String? id; // Firestore Document ID (Useful for deleting/updating)
  final String uid; // User who owns this goal
  final String description; // e.g. "Run 5km"
  final bool isCompleted;
  final DateTime? timestamp; // Good for sorting

  GoalModel({
    this.id,
    required this.uid,
    required this.description,
    this.isCompleted = false,
    this.timestamp,
  });

  // 1. Convert to Map (For saving)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'description': description,
      'isCompleted': isCompleted,
      'timestamp': timestamp?.millisecondsSinceEpoch,
    };
  }

  // 2. Create from Map (For reading)
  // We pass the docId separately because it's not inside the data map
  factory GoalModel.fromMap(Map<String, dynamic> map, String docId) {
    return GoalModel(
      id: docId,
      uid: map['uid'] ?? '',
      description: map['description'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      timestamp: map['timestamp'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp']) 
          : null,
    );
  }
}