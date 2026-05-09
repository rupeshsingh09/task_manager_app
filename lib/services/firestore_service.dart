import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';

/// FirestoreService - handles all Cloud Firestore CRUD operations for tasks
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Returns the current user's tasks collection reference
  CollectionReference<Map<String, dynamic>> _tasksCollection() {
    final uid = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(uid).collection('tasks');
  }

  /// Returns a real-time stream of tasks for the current user
  /// Tasks are ordered by creation timestamp descending
  Stream<List<TaskModel>> getTasksStream() {
    return _tasksCollection()
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TaskModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Adds a new task to Firestore for the current user
  Future<void> addTask(TaskModel task) async {
    final data = task.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    await _tasksCollection().add(data);
  }

  /// Updates an existing task document by its ID
  Future<void> updateTask(TaskModel task) async {
    await _tasksCollection().doc(task.id).update(task.toMap());
  }

  /// Deletes a task document by its ID
  Future<void> deleteTask(String taskId) async {
    await _tasksCollection().doc(taskId).delete();
  }

  /// Toggles the completion status of a task
  Future<void> toggleTaskCompletion(String taskId, bool currentStatus) async {
    await _tasksCollection().doc(taskId).update({
      'isCompleted': !currentStatus,
    });
  }
}
