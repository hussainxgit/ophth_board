import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/features/supervisor/model/supervisor.dart';
import 'package:ophth_board/features/supervisor/view/widgets/supervisor_profile_header_card.dart';
import '../../leave_request/provider/leave_request_provider.dart';
import '../../rotation/providers/rotation_provider.dart';
import 'widgets/annual_leaves_list_card.dart';
import 'widgets/current_rotation_card.dart';
import 'widgets/supervisor_profile_list_header.dart';

class SupervisorProfileScreen extends ConsumerWidget {
  final Supervisor supervisor;

  const SupervisorProfileScreen({super.key, required this.supervisor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch active rotation for the supervisor
    final activeRotation = ref.watch(
      supervisorActiveRotationsProvider(supervisor.id),
    );

    final supervisorLeaveRequestList = ref.watch(
      supervisorLeaveRequestListProvider(supervisor.id),
    );

    return RefreshIndicator(
      onRefresh: () async {
        // Invalidate the current rotation provider to trigger a refresh
        ref.invalidate(supervisorActiveRotationsProvider(supervisor.id));
        ref.invalidate(supervisorLeaveRequestListProvider(supervisor.id));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            SupervisorProfileHeader(supervisor: supervisor),
            const SizedBox(height: 16),
            SupervisorProfileListHeader(
              icon: Icons.access_time,
              title: 'Active Rotations',
              buttonLabel: '',
            ),
            activeRotation.when(
              data: (rotation) => rotation.isNotEmpty
                  ? SupervisorActiveRotationCard(rotation: rotation.first)
                  : Center(
                      child: const Text(
                        'No current rotation assigned',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text(
                'Error fetching current rotation: $error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
            SupervisorProfileListHeader(
              icon: Icons.airplane_ticket_outlined,
              title: 'Residents leaves requests',
              buttonLabel: 'View all',
              onTap: () {},
            ),
            supervisorLeaveRequestList.when(
              data: (annualLeaveRequestList) =>
                  annualLeaveRequestList.isNotEmpty
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
