import 'package:cloud_firestore/cloud_firestore.dart';

enum LeaveStatus { pending, approved, rejected }

extension LeaveStatusExtension on LeaveStatus {
  String toDisplayString() {
    switch (this) {
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
    }
  }
}

// Helper serialization functions to keep enum <-> string conversion consistent
String leaveStatusToString(LeaveStatus status) => status.name;

LeaveStatus leaveStatusFromString(String? value) {
  if (value == null) return LeaveStatus.pending;
  return LeaveStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => LeaveStatus.pending,
  );
}

class LeaveRequest {
  final String? id; // Null for new requests, assigned by Firestore
  final String residentId;
  final String
  residentName; // To easily display resident name in supervisor view
  final String? supervisorId; // Optional, if a specific supervisor is assigned
  final DateTime startDate;
  final DateTime endDate;
  final String notes;
  final LeaveStatus status;
  final DateTime requestedAt;
  final DateTime? approvedRejectedAt;
  final String? approverId;
  final String? supervisorComments;

  LeaveRequest({
    this.id,
    required this.residentId,
    required this.residentName,
    this.supervisorId,
    required this.startDate,
    required this.endDate,
    required this.notes,
    this.status = LeaveStatus.pending,
    required this.requestedAt,
    this.approvedRejectedAt,
    this.approverId,
    this.supervisorComments,
  });

  factory LeaveRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeaveRequest(
      id: doc.id,
      residentId: data['residentId'] as String,
      residentName: data['residentName'] as String,
      supervisorId: data['supervisorId'] as String?,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      notes: data['notes'] as String,
      status: leaveStatusFromString(data['status'] as String?),
      requestedAt: (data['requestedAt'] as Timestamp).toDate(),
      approvedRejectedAt: (data['approvedRejectedAt'] as Timestamp?)?.toDate(),
      approverId: data['approverId'] as String?,
      supervisorComments: data['supervisorComments'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'residentId': residentId,
      'residentName': residentName,
      'supervisorId': supervisorId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'notes': notes,
      'status': leaveStatusToString(
        status,
      ), // Store enum as string (consistent helper)
      'requestedAt': Timestamp.fromDate(requestedAt),
      'approvedRejectedAt': approvedRejectedAt != null
          ? Timestamp.fromDate(approvedRejectedAt!)
          : null,
      'approverId': approverId,
      'supervisorComments': supervisorComments,
    };
  }

  int get totalDays => endDate.difference(startDate).inDays + 1;

  bool isApproved() {
    return status == LeaveStatus.approved;
  }
}
