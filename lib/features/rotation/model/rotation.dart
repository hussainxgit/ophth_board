import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ophth_board/features/resident/model/resident.dart';

import '../../supervisor/model/supervisor.dart';

class Rotation {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final Map<String, bool> assignedResidents; // residentId -> true
  final Map<String, bool> assignedSupervisors; // supervisorId -> true
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Resident> assignedResidentsDetails;
  final List<Supervisor> assignedSupervisorsDetails;


  const Rotation({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.assignedResidents,
    required this.assignedSupervisors,
    required this.createdAt,
    required this.updatedAt,
    this.assignedResidentsDetails = const [],
    this.assignedSupervisorsDetails = const [],
  });

  // Factory constructor to create Rotation from Firestore document
  factory Rotation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    print('Rotation data: $data');
    return Rotation(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      assignedResidents: _convertToMap(data['assignedResidents']),
      assignedSupervisors: _convertToMap(data['assignedSupervisors']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      status: data['status'] ?? '',
    );
  }
  // Helper method to convert Firebase array format to Map
  static Map<String, bool> _convertToMap(dynamic value) {
    if (value == null) return {};
    if (value is List) {
      // Handle array format: [{key: value}, {key2: value2}]
      final Map<String, bool> result = {};
      for (final item in value) {
        if (item is Map<String, dynamic>) {
          item.forEach((key, val) {
            result[key] = val == true;
          });
        }
      }
      return result;
    } else if (value is Map<String, dynamic>) {
      // Handle direct map format: {key: value, key2: value2}
      return Map<String, bool>.from(value);
    }
    return {};
  }

  // Method to convert Rotation to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'assignedResidents': assignedResidents,
      'assignedSupervisors': assignedSupervisors,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
      'status': status,
    };
  }

  int get calculateProgress {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0;
    if (now.isAfter(endDate)) return 100;
    final duration = endDate.difference(startDate);
    final progress = (now.difference(startDate).inDays / duration.inDays) * 100;
    return progress.round();
  }

  int get weekOfRotation {
    final totalDuration = endDate.difference(startDate).inDays;
    final weeks = (totalDuration / 7).ceil();
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0;
    if (now.isAfter(endDate)) return weeks;
    final elapsedDuration = now.difference(startDate).inDays;
    return (elapsedDuration / 7).ceil();
  }

  int get totalWeeks {
    final totalDuration = endDate.difference(startDate).inDays;
    return (totalDuration / 7).ceil();
  }
}
