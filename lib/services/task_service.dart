import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:task_collab_app/model/task_model.dart';
import 'package:uuid/uuid.dart';

class TaskService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Uuid _uuid;

  TaskService({FirebaseFirestore? firestore, FirebaseAuth? auth, Uuid? uuid})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance,
      _uuid = uuid ?? const Uuid();

  String get currentUserEmail =>
      _auth.currentUser?.email?.trim().toLowerCase() ?? '';

  CollectionReference get _taskRef => _firestore.collection('tasks');

  Stream<List<TaskModel>> streamTasks() {
    final email = currentUserEmail;
    if (email.isEmpty) return Stream.value([]);

    final ownedTasksStream = _taskRef
        .where('ownerEmail', isEqualTo: email)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_convertSnapshot);

    final sharedTasksStream = _taskRef
        .where('sharedWith', arrayContains: email)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_convertSnapshot);

    return Rx.combineLatest2(ownedTasksStream, sharedTasksStream, (
      List<TaskModel> owned,
      List<TaskModel> shared,
    ) {
      final allTasks = [...owned, ...shared];
      final uniqueTasks = _removeDuplicates(allTasks);
      uniqueTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return uniqueTasks;
    });
  }

  Future<TaskModel> createTask({
    required String title,
    required String description,
    List<String>? sharedWith,
    bool isCompleted = false,
    String priority = 'none',
    Timestamp? dueDate,
  }) async {
    final email = currentUserEmail;
    if (email.isEmpty) throw Exception('User not authenticated');

    final id = _uuid.v4();
    final task = TaskModel(
      id: id,
      title: title,
      description: description,
      ownerEmail: email,
      sharedWith: sharedWith ?? [email],
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      isCompleted: isCompleted,
      priority: priority,
      dueDate: dueDate,
    );

    await _taskRef.doc(id).set(task.toMap());
    return task;
  }

  Future<void> updateTask(TaskModel task) async {
    final email = currentUserEmail;
    if (email.isEmpty) throw Exception('User not authenticated');
    if (!task.sharedWith.contains(email) && task.ownerEmail != email) {
      throw Exception('Unauthorized to update this task');
    }

    await _taskRef.doc(task.id).update({
      ...task.toMap(),
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> shareTask(String taskId, String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    final currentEmail = currentUserEmail;

    if (currentEmail.isEmpty) throw Exception('User not authenticated');
    if (normalizedEmail == currentEmail) {
      throw Exception('Cannot share with yourself');
    }

    final doc = await _taskRef.doc(taskId).get();
    if (!doc.exists) throw Exception('Task not found');

    final task = TaskModel.fromMap(doc.data()! as Map<String, dynamic>, doc.id);
    if (task.ownerEmail != currentEmail) {
      throw Exception('Only task owner can share');
    }

    await _taskRef.doc(taskId).update({
      'sharedWith': FieldValue.arrayUnion([normalizedEmail]),
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deleteTask(String taskId) async {
    final email = currentUserEmail;
    if (email.isEmpty) throw Exception('User not authenticated');

    final doc = await _taskRef.doc(taskId).get();
    if (!doc.exists) throw Exception('Task not found');

    final task = TaskModel.fromMap(doc.data()! as Map<String, dynamic>, doc.id);
    if (task.ownerEmail != email) {
      throw Exception('Only task owner can delete');
    }

    await _taskRef.doc(taskId).delete();
  }

  Future<List<TaskModel>> getTasks() async {
    final email = currentUserEmail;
    if (email.isEmpty) return [];

    final ownedTasks = await _taskRef
        .where('ownerEmail', isEqualTo: email)
        .orderBy('createdAt', descending: true)
        .get()
        .then(_convertSnapshot);

    final sharedTasks = await _taskRef
        .where('sharedWith', arrayContains: email)
        .orderBy('createdAt', descending: true)
        .get()
        .then(_convertSnapshot);

    return _removeDuplicates([...ownedTasks, ...sharedTasks]);
  }

  List<TaskModel> _convertSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return TaskModel.fromMap(doc.data()! as Map<String, dynamic>, doc.id);
    }).toList();
  }

  List<TaskModel> _removeDuplicates(List<TaskModel> tasks) {
    final seen = <String>{};
    return tasks.where((task) => seen.add(task.id)).toList();
  }
}
