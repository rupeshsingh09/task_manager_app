/// Task Model - represents a single task document in Firestore
class TaskModel {
  final String id;
  final String title;
  final String description;
  final String date;
  final bool isCompleted;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.isCompleted = false,
  });

  /// Creates a TaskModel from a Firestore document snapshot map
  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  /// Converts TaskModel to a map for storing in Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date,
      'isCompleted': isCompleted,
    };
  }

  /// Returns a copy of this TaskModel with given fields replaced
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? date,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
