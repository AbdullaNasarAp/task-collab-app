import 'package:flutter/material.dart';
import 'package:task_collab_app/model/task_model.dart';
import 'package:task_collab_app/services/task_service.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  String get currentUserEmail => _taskService.currentUserEmail;

  List<TaskModel> _tasks = [];
  List<TaskModel> get tasks => _tasks;

  bool isLoading = false;

  Future<void> fetchTasks() async {
    isLoading = true;
    notifyListeners();

    _tasks = await _taskService.getTasks();
    isLoading = false;
    notifyListeners();
  }

  Stream<List<TaskModel>> get taskStream {
    return _taskService.streamTasks(); // Now matches the service
  }

  Future<void> addTask({
    required String title,
    required String description,
  }) async {
    await _taskService.createTask(title: title, description: description);
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
}
