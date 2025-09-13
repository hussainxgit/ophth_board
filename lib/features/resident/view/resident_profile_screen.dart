import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/features/leave_request/view/forms/annual_leave_request_form.dart';
import 'package:ophth_board/features/resident/model/resident.dart';
import 'package:ophth_board/features/resident/view/widgets/annual_leaves_list_card.dart';
import 'package:ophth_board/features/resident/view/widgets/resident_profile_header_card.dart';
import 'package:ophth_board/features/resident/view/widgets/current_rotation_card.dart';

import '../../leave_request/provider/leave_request_provider.dart';
import '../../leave_request/view/leave_details_screen.dart';
import '../../leave_request/view/widgets/leave_list_card.dart';
import '../../rotation/providers/rotation_provider.dart';
import 'widgets/resident_profile_list_header.dart';
import 'widgets/rotation_progress_card.dart';

class ResidentProfileScreen extends ConsumerWidget {
  final Resident resident;

  const ResidentProfileScreen({super.key, required this.resident});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch current rotation for the resident
    final currentRotation = ref.watch(currentRotationProvider(resident.id));
    final upcomingRotationsList = ref.watch(
      upcomingRotationsProvider(resident.id),
    );
    final annualLeaveRequestList = ref.watch(residentLeaveRequestsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        // Invalidate the current rotation provider to trigger a refresh
        ref.invalidate(currentRotationProvider(resident.id));
        ref.invalidate(upcomingRotationsProvider(resident.id));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            ResidentProfileHeader(resident: resident),
            const SizedBox(height: 16),
            // Current Rotation Card
            ResidentProfileListHeader(
              icon: Icons.access_time,
              title: 'Current Rotation',
              buttonLabel: '',
            ),
            currentRotation.when(
              data: (rotation) => rotation != null
                  ? CurrentRotationCard(
                      rotation: rotation,
                      residentId: resident.id,
                      residentName: resident.fullName,
                    )
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
            ResidentProfileListHeader(
              icon: Icons.upcoming_outlined,
              title: 'Upcoming rotations',
              buttonLabel: '',
            ),
            upcomingRotationsList.when(
              data: (rotation) => rotation.isNotEmpty
                  ? RotationProgressCard(rotations: rotation)
                  : Center(
                      child: const Text(
                        'No upcoming  rotation assigned',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text(
                'Error fetching current rotation: $error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
            ResidentProfileListHeader(
              icon: Icons.airplane_ticket_outlined,
              title: 'Annual leaves',
              buttonLabel: 'Apply for leave',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AnnualLeaveRequestForm(),
                  ),
                );
              },
            ),
            annualLeaveRequestList.when(
              data: (annualLeaveRequestList) =>
                  annualLeaveRequestList.isNotEmpty
                  ? Column(
                      children: annualLeaveRequestList
                          .map((leaveRequest) {
                            return LeaveListCard(
                              leaveRequest: leaveRequest,
                              isSupervisor: false,
                              onApprove: null,
                              onReject: null,
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
                          })
                          .toList()
                          .getRange(
                            0,
                            annualLeaveRequestList.length >= 3
                                ? 3
                                : annualLeaveRequestList.length,
                          )
                          .toList(),
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
