import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/features/leave_request/model/leave_request.dart';
import 'package:ophth_board/features/leave_request/provider/leave_request_provider.dart';

import '../../../core/models/user.dart';
import '../../../core/providers/auth_provider.dart';
import '../../supervisor/view/widgets/annual_leaves_list_card.dart';

class LeaveListScreen extends ConsumerWidget {
  final String supervisorId;
  const LeaveListScreen({super.key, required this.supervisorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final LeaveRequestList = currentUser?.role == UserRole.resident
        ? ref.watch(residentLeaveRequestListProvider(currentUser!.id))
        : ref.watch(supervisorLeaveRequestListProvider(supervisorId));

    return Scaffold(
      appBar: AppBar(title: const Text('Leave Requests')),
      body: ListView(
        shrinkWrap: true,
        children: [
          LeaveRequestList.when(
            data: (annualLeaveRequestList) => annualLeaveRequestList.isNotEmpty
                ? SupervisorAnnualLeavesListCard(
                    leaveRequestList: annualLeaveRequestList,
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
