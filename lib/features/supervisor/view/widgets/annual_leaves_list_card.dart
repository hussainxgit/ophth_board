import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/features/leave_request/model/leave_request.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../leave_request/provider/leave_request_provider.dart';
import '../../../leave_request/view/leave_details_screen.dart';
import 'leave_request_list_tile.dart';

class SupervisorAnnualLeavesListCard extends ConsumerWidget {
  final List<LeaveRequest> leaveRequestList;

  const SupervisorAnnualLeavesListCard({
    super.key,
    required this.leaveRequestList,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.read(currentUserProvider);

    return Card(
      child: Column(
        children: leaveRequestList
            .map(
              (leaveRequest) => LeaveRequestTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          LeaveDetailsScreen(leaveRequest: leaveRequest),
                    ),
                  );
                },
                onDeny: () {
                  print('Rejecting leave');
                  ref
                      .read(leaveRequestOperationsProvider.notifier)
                      .updateLeaveRequestStatus(
                        requestId: leaveRequest.id!,
                        newStatus: LeaveStatus.rejected,
                        approverId: currentUser!.id,
                      );
                },
                onApprove: () {
                  print('Approving leave');
                  ref
                      .read(leaveRequestOperationsProvider.notifier)
                      .updateLeaveRequestStatus(
                        requestId: leaveRequest.id!,
                        newStatus: LeaveStatus.approved,
                        approverId: currentUser!.id,
                      );
                },
                leaveRequest: leaveRequest,
              ),
            )
            .toList(),
      ),
    );
  }
}
