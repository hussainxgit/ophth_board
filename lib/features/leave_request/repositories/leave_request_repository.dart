import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ophth_board/core/models/result.dart';

import '../../../core/firebase/firebase_service.dart';
import '../model/leave_request.dart'; // Assuming this exists for error handling

class LeaveRequestRepository {
  final FirestoreService _firestoreService;
  static const String _collectionPath = 'leaveRequests';

  LeaveRequestRepository(this._firestoreService);

  /// Submits a new leave request.
  Future<Result<void>> createLeaveRequest(LeaveRequest request) async {
    try {
      await _firestoreService.addDocument(
        _collectionPath,
        request.toFirestore(),
      );
      return Result.success(null);
    } on FirebaseException catch (e) {
      return Result.error('Failed to submit leave request: ${e.message}');
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  /// Fetches all leave requests for a specific resident.
  Stream<List<LeaveRequest>> getResidentLeaveRequests(String residentId) {
    return _firestoreService
        .getCollectionStreamWithQuery(
          _collectionPath,
          filters: [
            QueryFilter(
              field: 'residentId',
              type: FilterType.isEqualTo,
              value: residentId,
            ),
          ],
        )
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LeaveRequest.fromFirestore(doc))
              .toList(),
        );
  }

  /// Fetches all pending leave requests for resident.
  Future<List<LeaveRequest>> getResidentPendingLeaveRequests(
    String residentId,
  ) async {
    try {
      final querySnapshot = await _firestoreService.getCollectionWithQuery(
        _collectionPath,
        filters: [
          QueryFilter(
            field: 'residentId',
            type: FilterType.isEqualTo,
            value: residentId,
          ),
          QueryFilter(
            field: 'status',
            type: FilterType.isEqualTo,
            value: 'pending',
          ),
        ],
      );
      return querySnapshot.docs
          .map((doc) => LeaveRequest.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Error fetching residents leaves requests: $e';
    }
  }

  /// Fetches all pending leave requests for supervisors to review.
  /// This can be modified to filter by supervisorId if requests are assigned.
  Future<List<LeaveRequest>> getSupervisorPendingLeaveRequests(
    String supervisorId,
  ) async {
    try {
      final querySnapshot = await _firestoreService.getCollectionWithQuery(
        _collectionPath,
        filters: [
          QueryFilter(
            field: 'supervisorId',
            type: FilterType.isEqualTo,
            value: supervisorId,
          ),
          QueryFilter(
            field: 'status',
            type: FilterType.isEqualTo,
            value: 'pending',
          ),
        ],
      );
      return querySnapshot.docs
          .map((doc) => LeaveRequest.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Error fetching residents leaves requests: $e';
    }
  }

  /// Updates the status of a leave request.
  Future<Result<void>> updateLeaveRequestStatus(
    String requestId,
    LeaveStatus newStatus,
    String approverId,
    String? comments,
  ) async {
    print('updating leave status');
    try {
      await _firestoreService.updateDocument(_collectionPath, requestId, {
        'status': newStatus.name,
        'approverId': approverId,
        'supervisorComments': comments,
      });
      return Result.success(null);
    } on FirebaseException catch (e) {
      return Result.error(
        'Failed to update leave request status: ${e.message}',
      );
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  /// Fetches all leave requests for a specific resident.
  Future<List<LeaveRequest>> getAllLeavesForResident(String residentId) async {
    try {
      final querySnapshot = await _firestoreService.getCollectionWithQuery(
        _collectionPath,
        filters: [
          QueryFilter(
            field: 'residentId',
            type: FilterType.isEqualTo,
            value: residentId,
          ),
        ],
      );
      return querySnapshot.docs
          .map((doc) => LeaveRequest.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Error fetching all leaves for resident: $e';
    }
  }
}
