import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user document reference
  DocumentReference get _userDoc {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(user.uid);
  }

  // Save chat messages
  Future<void> saveChatMessage(String text, bool isUser) async {
    await _userDoc.collection('chats').add({
      'text': text,
      'isUser': isUser,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Get chat messages stream
  Stream<QuerySnapshot> getChatMessages() {
    return _userDoc
        .collection('chats')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Save medical data
  Future<void> saveMedicalData(Map<String, dynamic> data) async {
    await _userDoc.set({
      'medicalData': data,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Get medical data
  Future<Map<String, dynamic>?> getMedicalData() async {
    final doc = await _userDoc.get();
    final data = doc.data() as Map<String, dynamic>?;
    return data?['medicalData'] as Map<String, dynamic>?;
  }

  // Save user preferences
  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    await _userDoc.set({
      'preferences': preferences,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Get user preferences
  Future<Map<String, dynamic>?> getUserPreferences() async {
    final doc = await _userDoc.get();
    final data = doc.data() as Map<String, dynamic>?;
    return data?['preferences'] as Map<String, dynamic>?;
  }

  // Save notifications
  Future<void> saveNotification(Map<String, dynamic> notification) async {
    await _userDoc.collection('notifications').add({
      ...notification,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  // Get notifications
  Stream<QuerySnapshot> getNotifications() {
    return _userDoc
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _userDoc.collection('notifications').doc(notificationId).update({
      'read': true,
    });
  }
}
