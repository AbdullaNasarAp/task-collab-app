import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final List<String> sharedWith;
  final String ownerEmail; // Added this field
  final Timestamp createdAt;
  final Timestamp updatedAt; // Added this field

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.sharedWith,
    required this.ownerEmail, // Added to constructor
    required this.createdAt,
    required this.updatedAt, // Added to constructor
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, String docId) {
    return TaskModel(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      sharedWith: List<String>.from(map['sharedWith'] ?? []),
      ownerEmail: map['ownerEmail'] ?? '', // Added with default value
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt:
          map['updatedAt'] ?? Timestamp.now(), // Added with default value
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'sharedWith': sharedWith,
      'ownerEmail': ownerEmail, // Added to map
      'createdAt': createdAt,
      'updatedAt': updatedAt, // Added to map
    };
  }

  // Optional: Add copyWith method for easier updates
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? sharedWith,
    String? ownerEmail,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      sharedWith: sharedWith ?? this.sharedWith,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
