import 'package:flutter/material.dart';
import 'package:ophth_board/core/utils/boali_date_extenstions.dart';

import '../../../leave_request/model/leave_request.dart';

class LeaveRequestTile extends StatelessWidget {
  final LeaveRequest leaveRequest;
  final VoidCallback? onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onDeny;

  const LeaveRequestTile({
    super.key,
    required this.leaveRequest,
    this.onTap,
    this.onApprove,
    this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Dismissible(
        key: Key(leaveRequest.id.toString()),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.close, color: Colors.white, size: 32),
              SizedBox(height: 4),
              Text(
                'Deny',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Deny Leave Request'),
              content: Text(
                'Are you sure you want to deny ${leaveRequest.residentName}\'s leave request?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Deny'),
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) {
          onDeny?.call();
        },
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildDateRange(context),
                if (leaveRequest.notes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildNotes(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          child: Text(
            leaveRequest.residentName[0].toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
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
              Text(
                leaveRequest.requestedAt.pastDatePeriod,
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        ElevatedButton(onPressed: (){
          onApprove?.call();
        }, child: const Text('Approve')),
      ],
    );
  }

  Widget _buildDateRange(BuildContext context) {
    final days =
        leaveRequest.endDate.difference(leaveRequest.startDate).inDays + 1;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Start Date'),
                    const SizedBox(height: 4),
                    Text(leaveRequest.startDate.monthAndDay),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$days ${days == 1 ? 'day' : 'days'}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('End Date'),
                    const SizedBox(height: 4),
                    Text(leaveRequest.endDate.monthAndDay),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildDateConnector(),
        ],
      ),
    );
  }

  Widget _buildDateConnector() {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.blue.shade400,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade200],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.blue.shade400,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildNotes() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.note_alt_outlined,
                size: 16,
                color: Colors.amber.shade700,
              ),
              const SizedBox(width: 4),
              Text(
                'Notes',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            leaveRequest.notes,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }
}
