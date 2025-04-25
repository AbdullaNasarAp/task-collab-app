import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:task_collab_app/model/task_model.dart';
import 'package:task_collab_app/services/task_service.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  String get currentUserEmail => _taskService.currentUserEmail;

  List<TaskModel> _tasks = [];
  List<TaskModel> get tasks => _tasks;

  bool isLoading = false;
  String _currentFilter = 'All'; // Track current filter

  Future<void> fetchTasks() async {
    isLoading = true;
    notifyListeners();

    _tasks = await _taskService.getTasks();
    isLoading = false;
    notifyListeners();
  }

  Stream<List<TaskModel>> get taskStream {
    return _taskService.streamTasks();
  }

  Future<void> addTask({
    required String title,
    required String description,
    String priority = 'none',
    DateTime? dueDate,
  }) async {
    await _taskService.createTask(
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate != null ? Timestamp.fromDate(dueDate) : null,
    );
    await fetchTasks();
  }

  Future<void> deleteTask(String taskId) async {
    await _taskService.deleteTask(taskId);
    await fetchTasks();
  }

  Future<void> shareTaskWithUser(
    BuildContext context,
    String taskId,
    String email,
  ) async {
    try {
      await _taskService.shareTask(taskId, email);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Task shared with $email')));
      }
      await fetchTasks();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to share task: $e')));
      }
    }
  }

  Future<void> updateTask(TaskModel updatedTask) async {
    try {
      await _taskService.updateTask(updatedTask);
      await fetchTasks();
    } catch (e) {
      debugPrint('Error updating task: $e');
      rethrow;
    }
  }

  void setFilter(String filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  List<TaskModel> get filteredTasks {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return _tasks.where((task) {
      switch (_currentFilter) {
        case 'Today':
          if (task.dueDate == null) return false;
          final dueDate = task.dueDate!.toDate();
          return dueDate.isAfter(todayStart) && dueDate.isBefore(todayEnd);
        case 'Completed':
          return task.isCompleted;
        case 'Shared':
          return task.sharedWith.length > 1; // More than just owner
        case 'High Priority':
          return task.priority == 'high';
        case 'All':
        default:
          return true;
      }
    }).toList();
  }

  // Stats for the UI
  Map<String, int> get taskStats {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    todayStart.add(const Duration(days: 1));

    return {
      'Total': _tasks.length,
      'Completed': _tasks.where((t) => t.isCompleted).length,
      'Pending': _tasks.where((t) => !t.isCompleted).length,
      'Shared': _tasks.where((t) => t.sharedWith.length > 1).length,
    };
  }
}
