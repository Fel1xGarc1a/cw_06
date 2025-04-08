import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../models/task.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  static String? get currentUserId => _auth.currentUser?.uid;

  static CollectionReference<Map<String, dynamic>> get tasksCollection =>
      _firestore.collection('users').doc(currentUserId).collection('tasks');

  static Stream<List<Task>> getTasks() {
    return tasksCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Task.fromMap(doc.data())).toList());
  }

  static Future<void> addTask(Task task) async {
    await tasksCollection.doc(task.id).set(task.toMap());
  }

  static Future<void> updateTask(Task task) async {
    await tasksCollection.doc(task.id).update(task.toMap());
  }

  static Future<void> deleteTask(String taskId) async {
    await tasksCollection.doc(taskId).delete();
  }

  static Future<void> toggleTaskCompletion(Task task) async {
    task.isCompleted = !task.isCompleted;
    await updateTask(task);
  }
} 