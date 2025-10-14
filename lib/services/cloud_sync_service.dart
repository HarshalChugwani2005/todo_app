// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo_model.dart';
import 'mock_firebase_service.dart';

class CloudSyncService {
  static final CloudSyncService _instance = CloudSyncService._internal();
  factory CloudSyncService() => _instance;
  CloudSyncService._internal();

  final MockFirebaseService _mockFirebase = MockFirebaseService();

  // Authentication methods using Mock Firebase
  Future<bool> isSignedIn() async {
    return _mockFirebase.isSignedIn();
  }

  Future<String?> getCurrentUserId() async {
    return _mockFirebase.getCurrentUserId();
  }

  Future<bool> signIn(String email, String password) async {
    return _mockFirebase.signIn(email, password);
  }

  Future<bool> signUp(String email, String password) async {
    return _mockFirebase.signUp(email, password);
  }

  Future<void> signOut() async {
    await _mockFirebase.signOut();
  }

  Future<bool> syncToCloud(List<Todo> todos) async {
    return _mockFirebase.syncToCloud(todos);
  }

  Future<List<Todo>?> syncFromCloud() async {
    return _mockFirebase.syncFromCloud();
  }

  Future<DateTime?> getLastSyncTime() async {
    return _mockFirebase.getLastSyncTime();
  }

  Future<bool> hasConflicts() async {
    return _mockFirebase.hasConflicts();
  }

  Future<Map<String, dynamic>> getSyncStatus() async {
    return _mockFirebase.getSyncStatus();
  }
}