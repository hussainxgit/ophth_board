import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/user.dart';

class Resident extends UserCredentials {
  final String pgy;
  final String? currentRotationId; // Make nullable for flexibility
  final Map<String, bool>? completedRotations; // rotationId -> completed status
  final Map<String, bool>? evaluations; // evaluationId -> true
  final double? averageScore;
  Resident({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.civilId,
    this.currentRotationId,
    this.averageScore,
    super.profileImageUrl,
    required super.createdAt,
    required super.updatedAt,
    super.isActive,
    super.phoneNumber,
    required this.pgy,
    this.completedRotations,
    this.evaluations,
    super.workingPlace,
    super.fileNumber,
  });

  @override
  UserRole get role => UserRole.resident;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'currentRotationId': currentRotationId,
      'averageScore': averageScore,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'phoneNumber': phoneNumber,
      'pgy': pgy,
      'civilId': civilId,
      'role': role.name,
      'completedRotations': completedRotations,
      'evaluations': evaluations,
      'workingPlace': workingPlace,
      'fileNumber': fileNumber,
    };
  }

  factory Resident.fromFirestore(DocumentSnapshot doc) {
    final raw = doc.data();
    final data = (raw is Map<String, dynamic>) ? raw : <String, dynamic>{};

    // Safe helpers
    String string(Object? v) => v == null ? '' : v.toString();
    DateTime safeDate(Object? v) {
      try {
        if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
        if (v is Timestamp) return v.toDate();
        if (v is DateTime) return v;
        if (v is String) return DateTime.parse(v);
      } catch (_) {}
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return Resident(
      id: doc.id,
      email: string(data['email']),
      firstName: string(data['firstName']),
      lastName: string(data['lastName']),
      currentRotationId: data['currentRotationId'] != null ? string(data['currentRotationId']) : null,
      averageScore: (data['averageScore'] is num) ? (data['averageScore'] as num).toDouble() : null,
      profileImageUrl: data['profileImageUrl'] != null ? string(data['profileImageUrl']) : null,
      createdAt: safeDate(data['createdAt']),
      updatedAt: safeDate(data['updatedAt']),
      isActive: data['isActive'] ?? true,
      phoneNumber: data['phoneNumber'] != null ? string(data['phoneNumber']) : null,
      pgy: string(data['pgy']),
      civilId: string(data['civilId']),
      completedRotations: data['completedRotations'] != null
          ? Map<String, bool>.from(data['completedRotations'] as Map)
          : null,
      evaluations: data['evaluations'] != null
          ? Map<String, bool>.from(data['evaluations'] as Map)
          : null,
      workingPlace: data['workingPlace'] != null ? string(data['workingPlace']) : null,
      fileNumber: data['fileNumber'] != null ? string(data['fileNumber']) : null,
    );
  }
}
