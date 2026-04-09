import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task.dart';

class TaskService {
  final CollectionReference _tasksRef =
      FirebaseFirestore.instance.collection('tasks');

  Future<void> addTask(String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;

    await _tasksRef.add({
      'title': trimmed,
      'isCompleted': false,
      'subtasks': <Map<String, dynamic>>[],
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<Task>> streamTasks() {
    return _tasksRef.orderBy('createdAt').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  Future<void> toggleTask(Task task) async {
    await _tasksRef.doc(task.id).update({
      'isCompleted': !task.isCompleted,
    });
  }

  Future<void> updateTask(Task task) async {
    await _tasksRef.doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksRef.doc(taskId).delete();
  }

  Future<void> addSubtask(Task task, String subtaskTitle) async {
    final trimmed = subtaskTitle.trim();
    if (trimmed.isEmpty) return;

    final updatedSubtasks = List<Map<String, dynamic>>.from(task.subtasks)
      ..add({
        'title': trimmed,
        'isDone': false,
      });

    await _tasksRef.doc(task.id).update({
      'subtasks': updatedSubtasks,
    });
  }

  Future<void> deleteSubtask(Task task, int index) async {
    final updatedSubtasks = List<Map<String, dynamic>>.from(task.subtasks);

    if (index < 0 || index >= updatedSubtasks.length) return;

    updatedSubtasks.removeAt(index);

    await _tasksRef.doc(task.id).update({
      'subtasks': updatedSubtasks,
    });
  }

  Future<void> toggleSubtask(Task task, int index) async {
    final updatedSubtasks = List<Map<String, dynamic>>.from(task.subtasks);

    if (index < 0 || index >= updatedSubtasks.length) return;

    final current = Map<String, dynamic>.from(updatedSubtasks[index]);
    current['isDone'] = !(current['isDone'] ?? false);
    updatedSubtasks[index] = current;

    await _tasksRef.doc(task.id).update({
      'subtasks': updatedSubtasks,
    });
  }
}