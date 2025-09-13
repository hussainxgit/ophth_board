import 'package:flutter/material.dart';
import 'package:ophth_board/core/utils/boali_date_extenstions.dart';
import '../../model/leave_request.dart';

/// Generic leave list card widget for both resident and supervisor roles.
class LeaveListCard extends StatelessWidget {
  final LeaveRequest leaveRequest;
  final bool isSupervisor;
  final VoidCallback? onApprove;
  final void Function(String? comments)? onReject;
  final VoidCallback? onViewDetails;

  const LeaveListCard({
    super.key,
    required this.leaveRequest,
    required this.isSupervisor,
    this.onApprove,
    this.onReject,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onViewDetails,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildDateInfo(context),
              if (leaveRequest.notes.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildNotes(context),
              ],
              if (isSupervisor) ...[
                const SizedBox(height: 16),
                _buildSupervisorActions(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            leaveRequest.residentName[0].toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                leaveRequest.residentName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Requested ${leaveRequest.requestedAt.pastDatePeriod}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        _buildStatusChip(context),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final statusColors = {
      'pending': Colors.orange,
      'approved': Colors.green,
      'rejected': Colors.red,
    };

    final color = statusColors[leaveRequest.status.name] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        leaveRequest.status.name,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color.shade700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDateInfo(BuildContext context) {
    final days =
        leaveRequest.endDate.difference(leaveRequest.startDate).inDays + 1;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDateColumn(
                  'START',
                  leaveRequest.startDate.monthAndDay,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$days ${days == 1 ? 'day' : 'days'}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Expanded(
                child: _buildDateColumn(
                  'END',
                  leaveRequest.endDate.monthAndDay,
                  isEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDateConnector(context),
        ],
      ),
    );
  }

  Widget _buildDateColumn(String label, String date, {bool isEnd = false}) {
    return Column(
      crossAxisAlignment: isEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          date,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildDateConnector(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Container(
            height: 1.5,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ],
              ),
            ),
          ),
        ),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildNotes(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sticky_note_2_outlined,
                size: 14,
                color: Colors.amber.shade700,
              ),
              const SizedBox(width: 6),
              Text(
                'Notes',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber.shade700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            leaveRequest.notes,
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildSupervisorActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => onReject?.call(null),
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Reject'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade600,
              side: BorderSide(color: Colors.red.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onApprove,
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Approve'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
