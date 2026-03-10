import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Task> tasks = [];

  // Load tasks from Firestore
  Future<void> fetchTasks() async {
    final snapshot = await _firestore.collection('tasks').get();
    tasks = snapshot.docs.map((doc) {
      return Task(
        id: doc.id,
        title: doc['title'],
        isCompleted: doc['isCompleted'],
      );
    }).toList();
    notifyListeners();
  }

  // Add task to Firestore
  Future<void> addTask(String title) async {
    final user = FirebaseAuth.instance.currentUser;
    final docRef = await _firestore.collection('tasks').add({
      'title': title,
      'isCompleted': false,
      'createdAt': DateTime.now(),
      'userId': user!.uid,
    });
    tasks.add(Task(id: docRef.id, title: title));
    notifyListeners();
  }

  // Update task in Firestore
  Future<void> updateTask(String id, String newTitle) async {
    await _firestore.collection('tasks').doc(id).update({'title': newTitle});
    final task = tasks.firstWhere((task) => task.id == id);
    task.title = newTitle;
    notifyListeners();
  }

  // Delete task in Firestore
  Future<void> deleteTask(String id) async {
    await _firestore.collection('tasks').doc(id).delete();
    tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  // Toggle completion in Firestore
  Future<void> toggleTask(String id) async {
    final task = tasks.firstWhere((task) => task.id == id);
    final newStatus = !task.isCompleted;
    await _firestore.collection('tasks').doc(id).update({'isCompleted': newStatus});
    task.isCompleted = newStatus;
    notifyListeners();
  }
  Stream<List<Task>> getTasksStream() {
    final user = FirebaseAuth.instance.currentUser;
    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: user!.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task(
          id: doc.id,
          title: doc['title'],
          isCompleted: doc['isCompleted'],
        );
      }).toList();
    });
  }
}

