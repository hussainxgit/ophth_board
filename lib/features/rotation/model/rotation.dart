import 'package:cloud_firestore/cloud_firestore.dart';

class Rotation {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final List<String> assignedResidents; // list of residentIds
  final List<String> assignedSupervisors; // list of supervisorIds
  final DateTime createdAt;
  final DateTime updatedAt;


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
  });

  // Factory constructor to create Rotation from Firestore document
  factory Rotation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Rotation(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      assignedResidents: _convertToList(data['assignedResidents']),
      assignedSupervisors: _convertToList(data['assignedSupervisors']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      status: data['status'] ?? '',
    );
  }

  // Helper to convert Firebase stored value to List<String>
  static List<String> _convertToList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      // If stored as list of ids or list of maps
      final List<String> result = [];
      for (final item in value) {
        if (item is String) {
          result.add(item);
        } else if (item is Map<String, dynamic>) {
          // maybe map like {id: true}
          item.forEach((key, val) {
            if (val == true) result.add(key);
          });
        }
      }
      return result;
    } else if (value is Map<String, dynamic>) {
      // previously stored as map id->true
      return value.entries
          .where((e) => e.value == true)
          .map((e) => e.key)
          .toList();
    }
    return [];
  }

  // Method to convert Rotation to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      // store as map for backwards compatibility and efficient queries
      'assignedResidents': {for (var id in assignedResidents) id: true},
      'assignedSupervisors': {for (var id in assignedSupervisors) id: true},
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
