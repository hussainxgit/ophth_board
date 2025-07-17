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
    };
  }

  factory Resident.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Resident(
      id: doc.id,
      email: data['email'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      currentRotationId: data['currentRotationId'],
      averageScore: data['averageScore'],
      profileImageUrl: data['profileImageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isActive: data['isActive'],
      phoneNumber: data['phoneNumber'],
      pgy: data['pgy'],
    );
  }
}
