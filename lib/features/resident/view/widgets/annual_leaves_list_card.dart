import 'package:flutter/material.dart';
import 'package:ophth_board/core/utils/boali_date_extenstions.dart';
import 'package:ophth_board/features/leave_request/model/leave_request.dart';

import '../../../leave_request/view/leave_details_screen.dart';

class AnnualLeavesListCard extends StatelessWidget {
  final List<LeaveRequest> leaveRequestList;

  const AnnualLeavesListCard({super.key, required this.leaveRequestList});

  Color _getStatusColor(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.pending:
        return Colors.orange;
      case LeaveStatus.approved:
        return Colors.green;
      case LeaveStatus.rejected:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: leaveRequestList
              .map(
                (leaveRequest) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              LeaveDetailsScreen(leaveRequest: leaveRequest),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left section - Start date and duration
                              Text(leaveRequest.startDate.monthAndDay),

                              // Middle section - Duration indicator
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade400,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              height: 1,
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          Icon(Icons.calendar_today, size: 16),
                                          Expanded(
                                            child: Container(
                                              height: 1,
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade400,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${leaveRequest.endDate.difference(leaveRequest.startDate).inDays + 1} days',
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Right section - End date and status
                              Text(leaveRequest.endDate.monthAndDay),

                              const SizedBox(width: 16),

                              // Status section (replacing price)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(leaveRequest.status),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  leaveRequest.status.toDisplayString(),
                                ),
                              ),
                            ],
                          ),

                          // Notes section
                          if (leaveRequest.notes.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Notes:'),
                                  const SizedBox(height: 4),
                                  Text(leaveRequest.notes),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
