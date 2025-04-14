import 'package:cloud_firestore/cloud_firestore.dart';

class PatientProfile {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final DateTime dateOfBirth;
  final String gender;
  final String? doctorId;
  final List<String> conditions;
  final List<Medication> medications;
  final List<String> allergies;
  final Map<String, dynamic>? healthStats;
  final List<MedicalReport> reports;
  final DateTime createdAt;
  final DateTime updatedAt;

  PatientProfile({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    required this.dateOfBirth,
    required this.gender,
    this.doctorId,
    required this.conditions,
    required this.medications,
    required this.allergies,
    this.healthStats,
    required this.reports,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PatientProfile.fromFirestore(DocumentSnapshot doc) {
    try {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return PatientProfile(
        id: doc.id,
        userId: data['userId']?.toString() ?? '',
        firstName: data['firstName']?.toString() ?? '',
        lastName: data['lastName']?.toString() ?? '',
        email: data['email']?.toString() ?? '',
        phone: data['phone']?.toString(),
        dateOfBirth:
            (data['dateOfBirth'] as Timestamp?)?.toDate() ?? DateTime.now(),
        gender: data['gender']?.toString() ?? '',
        doctorId: data['doctorId']?.toString(),
        conditions: List<String>.from(data['conditions'] ?? []),
        medications: (data['medications'] as List<dynamic>?)
                ?.map((m) => Medication.fromMap(m as Map<String, dynamic>))
                .toList() ??
            [],
        allergies: List<String>.from(data['allergies'] ?? []),
        healthStats: data['healthStats'] as Map<String, dynamic>?,
        reports: (data['reports'] as List<dynamic>?)
                ?.map((r) => MedicalReport.fromFirestore(r as DocumentSnapshot))
                .toList() ??
            [],
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt:
            (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e) {
      throw Exception('Error parsing patient profile: $e');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'gender': gender,
      'doctorId': doctorId,
      'conditions': conditions,
      'medications': medications.map((m) => m.toMap()).toList(),
      'allergies': allergies,
      'healthStats': healthStats,
      'reports': reports.map((r) => r.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

class Medication {
  final String name;
  final String dosage;
  final String frequency;
  final DateTime startDate;
  final String? notes;

  Medication({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    this.notes,
  });

  factory Medication.fromMap(Map<String, dynamic> map) {
    try {
      return Medication(
        name: map['name']?.toString() ?? '',
        dosage: map['dosage']?.toString() ?? '',
        frequency: map['frequency']?.toString() ?? '',
        startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
        notes: map['notes']?.toString(),
      );
    } catch (e) {
      throw Exception('Error parsing medication: $e');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'startDate': Timestamp.fromDate(startDate),
      'notes': notes,
    };
  }
}

class MedicalReport {
  final String id;
  final String type;
  final String content;
  final DateTime date;
  final String? doctorId;
  final Map<String, dynamic>? metadata;

  MedicalReport({
    required this.id,
    required this.type,
    required this.content,
    required this.date,
    this.doctorId,
    this.metadata,
  });

  factory MedicalReport.fromFirestore(DocumentSnapshot doc) {
    try {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return MedicalReport(
        id: doc.id,
        type: data['type']?.toString() ?? '',
        content: data['content']?.toString() ?? '',
        date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        doctorId: data['doctorId']?.toString(),
        metadata: data['metadata'] as Map<String, dynamic>?,
      );
    } catch (e) {
      throw Exception('Error parsing medical report from Firestore: $e');
    }
  }

  factory MedicalReport.fromMap(Map<String, dynamic> map) {
    try {
      return MedicalReport(
        id: map['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        type: map['type']?.toString() ?? '',
        content: map['content']?.toString() ?? '',
        date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        doctorId: map['doctorId']?.toString(),
        metadata: map['metadata'] as Map<String, dynamic>?,
      );
    } catch (e) {
      throw Exception('Error parsing medical report: $e');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'content': content,
      'date': Timestamp.fromDate(date),
      'doctorId': doctorId,
      'metadata': metadata,
    };
  }
}
