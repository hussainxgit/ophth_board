import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/core/models/result.dart';
import 'package:ophth_board/core/providers/auth_provider.dart';
import '../../../core/firebase/firebase_service.dart';
import '../repositories/leave_request_repository.dart';
import '../model/leave_request.dart';

// Repository provider
final leaveRequestRepositoryProvider = Provider<LeaveRequestRepository>((ref) {
  return LeaveRequestRepository(ref.watch(firestoreServiceProvider));
});

// Resident's leave requests stream
final residentLeaveRequestsProvider =
    StreamNotifierProvider<ResidentLeaveRequestsNotifier, List<LeaveRequest>>(
      ResidentLeaveRequestsNotifier.new,
    );

class ResidentLeaveRequestsNotifier extends StreamNotifier<List<LeaveRequest>> {
  @override
  Stream<List<LeaveRequest>> build() {
    final currentUser = ref.watch(authProvider).user;
    if (currentUser?.id == null) return Stream.value([]);

    return ref
        .watch(leaveRequestRepositoryProvider)
        .getResidentLeaveRequests(currentUser!.id);
  }
}

// Pending leave requests (for supervisors)
final supervisorLeaveRequestListProvider =
    FutureProvider.family<List<LeaveRequest>, String>((ref, superviorId) async {
      final repository = ref.watch(leaveRequestRepositoryProvider);
      return repository.getSupervisorPendingLeaveRequests(superviorId);
    });

// Leave request operations
final leaveRequestOperationsProvider =
    NotifierProvider<LeaveRequestOperationsNotifier, void>(
      LeaveRequestOperationsNotifier.new,
    );

// Pending leave requests (for residents)
final residentLeaveRequestListProvider =
    FutureProvider.family<List<LeaveRequest>, String>((ref, residentId) async {
      final repository = ref.watch(leaveRequestRepositoryProvider);
      return repository.getResidentPendingLeaveRequests(residentId);
    });

class LeaveRequestOperationsNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<Result<void>> submitLeaveRequest(LeaveRequest request) async {
    return ref.read(leaveRequestRepositoryProvider).createLeaveRequest(request);
  }

  Future<Result<void>> updateLeaveRequestStatus({
    required String requestId,
    required LeaveStatus newStatus,
    required String approverId,
    String? comments,
    String? supervisorSignatureId,
  }) async {
    return ref
        .read(leaveRequestRepositoryProvider)
        .updateLeaveRequestStatus(
          requestId,
          newStatus,
          approverId,
          comments,
          supervisorSignatureId: supervisorSignatureId,
        );
  }
}

// All leaves for a resident
final allResidentLeavesProvider =
    FutureProvider.family<List<LeaveRequest>, String>((ref, residentId) async {
      final repository = ref.watch(leaveRequestRepositoryProvider);
      return repository.getAllLeavesForResident(residentId);
    });
