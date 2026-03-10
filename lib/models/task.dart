class Task {
  String id;
  String title;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  Map<String, dynamic> toFirestore(String userId) {
    return {
      'title': title,
      'isCompleted': isCompleted,
      'userId': userId,
      'createdAt': DateTime.now(),
    };
  }

  factory Task.fromMap(String id, Map<String, dynamic> map) {
    return Task(
      id: id,
      title: map['title'],
      isCompleted: map['isCompleted'],
    );
  }
}