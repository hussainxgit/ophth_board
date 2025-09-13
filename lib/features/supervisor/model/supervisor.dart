import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ophth_board/core/models/user.dart';

class Supervisor extends UserCredentials {
  final double? averageScore;

  // Change from List<String> to Map<String, bool> for better Firebase indexing
  final Map<String, bool> assignedResidents; // residentId -> true
  final Map<String, bool> activeRotations; // rotationId -> true

  Supervisor({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.civilId,
    super.profileImageUrl,
    required super.createdAt,
    required super.updatedAt,
    super.isActive,
    super.phoneNumber,
    required this.assignedResidents,
    this.averageScore,
    super.workingPlace,
    super.fileNumber,
    required this.activeRotations,
  });

  @override
  UserRole get role => UserRole.supervisor;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'phoneNumber': phoneNumber,
      'role': role.name,
      'assignedResidents': assignedResidents,
      'averageScore': averageScore,
      'activeRotations': activeRotations,
      'civilId': civilId,
      'workingPlace': workingPlace,
      'fileNumber': fileNumber,
    };
  }

  factory Supervisor.fromJson(Map<String, dynamic> json) {
    return Supervisor(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      profileImageUrl: json['profileImageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isActive: json['isActive'],
      phoneNumber: json['phoneNumber'],
      assignedResidents: Map<String, bool>.from(json['assignedResidents']),
      averageScore: json['averageScore'],
      activeRotations: Map<String, bool>.from(json['activeRotations']),
      civilId: json['civilId'],
      workingPlace: json['workingPlace'],
      fileNumber: json['fileNumber'],
    );
  }

  factory Supervisor.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Supervisor(
      id: doc.id,
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      phoneNumber: data['phoneNumber'],
      assignedResidents: Map<String, bool>.from(
        data['assignedResidents'] ?? {},
      ),
      averageScore: (data['averageScore'] as num?)?.toDouble(),
      activeRotations: Map<String, bool>.from(data['activeRotations'] ?? {}),
      civilId: data['civilId'] ?? '',
      workingPlace: data['workingPlace'],
      fileNumber: data['fileNumber'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Supervisor && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
