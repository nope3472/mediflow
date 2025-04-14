import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medi_flow_new/chatbot.dart';
import '../models/patient_profile.dart';
import 'dart:async';

class MedicalHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AIService _aiService = AIService();

  // Add a stream controller for reports (if needed elsewhere)
  final _reportsController = StreamController<List<MedicalReport>>.broadcast();

  // Method to save a chat message in its own Firestore collection
  Future<void> saveChatMessage(MedicalReport report) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Save under a dedicated 'chat_history' collection with a subcollection 'reports'
      await _firestore
          .collection('chat_history')
          .doc(user.uid)
          .collection('reports')
          .add(report.toMap());
    } catch (e) {
      throw Exception('Failed to save chat history: $e');
    }
  }

  // Method to get a stream of chat history for the current user
  Stream<List<MedicalReport>> getChatHistoryStream() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    return _firestore
        .collection('chat_history')
        .doc(user.uid)
        .collection('reports')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicalReport.fromFirestore(doc))
            .toList());
  }

  // Method to get chat history as a list
  Future<List<MedicalReport>> getChatHistory() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final snapshot = await _firestore
          .collection('chat_history')
          .doc(user.uid)
          .collection('reports')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MedicalReport.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get chat history: $e');
    }
  }

  // Retain other methods if needed for different functionalities

  Future<PatientProfile?> getPatientProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc =
          await _firestore.collection('patient_profiles').doc(user.uid).get();
      if (!doc.exists) return null;
      return PatientProfile.fromFirestore(doc);
    } catch (e) {
      print('Error getting patient profile: $e');
      return null;
    }
  }

  Future<void> savePatientProfile(PatientProfile profile) async {
    try {
      await _firestore
          .collection('patient_profiles')
          .doc(profile.id)
          .set(profile.toMap());
    } catch (e) {
      print('Error saving patient profile: $e');
      rethrow;
    }
  }

  Future<String> collectMedicalHistory(Map<String, dynamic> responses) async {
    try {
      final prompt = _buildMedicalHistoryPrompt(responses);
      final response = await _aiService.sendTextMessage(prompt);
      return response ?? 'No response from AI service';
    } catch (e) {
      print('Error collecting medical history: $e');
      return 'Error collecting medical history';
    }
  }

  String _buildMedicalHistoryPrompt(Map<String, dynamic> responses) {
    return '''
    Based on the following patient responses, generate a structured medical history report:
    
    Personal Information:
    - Name: ${responses['name']}
    - Age: ${responses['age']}
    - Gender: ${responses['gender']}
    
    Medical History:
    - Current Medications: ${responses['medications']}
    - Known Conditions: ${responses['conditions']}
    - Allergies: ${responses['allergies']}
    
    Current Symptoms:
    - Main Symptom: ${responses['mainSymptom']}
    - Duration: ${responses['duration']}
    - Severity: ${responses['severity']}
    - Associated Symptoms: ${responses['associatedSymptoms']}
    
    Please provide:
    1. A structured summary of the information
    2. Relevant medical context
    3. Suggestions for next steps
    4. Any red flags that need immediate attention
    
    Do not provide diagnoses or specific treatment recommendations.
    ''';
  }

  void dispose() {
    _reportsController.close();
  }
}
