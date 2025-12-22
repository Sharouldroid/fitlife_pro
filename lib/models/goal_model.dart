class GoalModel {
  final String uid;
  final String description; // e.g. "Run 5km"
  final bool isCompleted;

  GoalModel({required this.uid, required this.description, this.isCompleted = false});

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'description': description,
      'isCompleted': isCompleted,
    };
  }
}