import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/features/leave_request/model/leave_request.dart';
import 'package:ophth_board/features/leave_request/provider/leave_request_provider.dart';
import 'package:ophth_board/features/leave_request/view/leave_details_screen.dart';

import '../../../core/models/user.dart';
import '../../../core/providers/auth_provider.dart';
import '../view/widgets/leave_list_card.dart';

class LeaveListScreen extends ConsumerWidget {
  const LeaveListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final leaveRequestList = currentUser?.role == UserRole.resident
        ? ref.watch(allResidentLeavesProvider(currentUser!.id))
        : ref.watch(supervisorLeaveRequestListProvider(currentUser!.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Leave Requests')),
      body: ListView(
        shrinkWrap: true,
        children: [
          leaveRequestList.when(
            data: (annualLeaveRequestList) => annualLeaveRequestList.isNotEmpty
                ? Column(
                    children: annualLeaveRequestList.map<Widget>((
                      leaveRequest,
                    ) {
                      return LeaveListCard(
                        leaveRequest: leaveRequest,
                        isSupervisor: currentUser.role == UserRole.supervisor,
                        onApprove: currentUser.role == UserRole.supervisor
                            ? () async {
                                if (leaveRequest.id == null) return;

                                final result = await ref
                                    .read(
                                      leaveRequestOperationsProvider.notifier,
                                    )
                                    .updateLeaveRequestStatus(
                                      requestId: leaveRequest.id!,
                                      newStatus: LeaveStatus.approved,
                                      approverId: currentUser.id,
                                    );
                                if (result.isSuccess) {
                                  // Invalidate the provider to refresh the list
                                  if (currentUser.role == UserRole.resident) {
                                    ref.invalidate(
                                      residentLeaveRequestListProvider(
                                        currentUser.id,
                                      ),
                                    );
                                  } else {
                                    ref.invalidate(
                                      supervisorLeaveRequestListProvider(
                                        currentUser.id,
                                      ),
                                    );
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Leave approved'),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error: ${result.errorMessage}',
                                      ),
                                    ),
                                  );
                                }
                              }
                            : null,
                        onReject: currentUser.role == UserRole.supervisor
                            ? (String? comments) async {
                                if (leaveRequest.id == null) return;

                                final result = await ref
                                    .read(
                                      leaveRequestOperationsProvider.notifier,
                                    )
                                    .updateLeaveRequestStatus(
                                      requestId: leaveRequest.id!,
                                      newStatus: LeaveStatus.rejected,
                                      approverId: currentUser.id,
                                      comments: comments,
                                    );
                                if (context.mounted) {
                                  if (result.isSuccess) {
                                    // Invalidate supervisor list to refresh
                                    ref.invalidate(
                                      supervisorLeaveRequestListProvider(
                                        currentUser.id,
                                      ),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Leave rejected'),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error: ${result.errorMessage}',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              }
                            : null,
                        onViewDetails: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => LeaveDetailsScreen(
                                leaveRequest: leaveRequest,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  )
                : Center(
                    child: const Text(
                      'No pending leaves requests',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text(
              'Error fetching current annual leaves: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
