import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final List<String> sharedWith;
  final String ownerEmail;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final bool isCompleted; // Added for completion status
  final String priority; // Added for priority level
  final Timestamp? dueDate; // Added for due date (nullable)

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.sharedWith,
    required this.ownerEmail,
    required this.createdAt,
    required this.updatedAt,
    this.isCompleted = false, // Default to not completed
    this.priority = 'none', // Default to no priority
    this.dueDate, // Optional due date
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, String docId) {
    return TaskModel(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      sharedWith: List<String>.from(map['sharedWith'] ?? []),
      ownerEmail: map['ownerEmail'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
      isCompleted: map['isCompleted'] ?? false,
      priority: map['priority'] ?? 'none',
      dueDate: map['dueDate'], // Nullable, no default needed
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'sharedWith': sharedWith,
      'ownerEmail': ownerEmail,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isCompleted': isCompleted,
      'priority': priority,
      'dueDate': dueDate,
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? sharedWith,
    String? ownerEmail,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    bool? isCompleted,
    String? priority,
    Timestamp? dueDate,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      sharedWith: sharedWith ?? this.sharedWith,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}
