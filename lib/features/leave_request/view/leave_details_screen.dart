import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ophth_board/core/views/widgets/async_loading_button.dart';
import '../../resident/providers/resident_provider.dart';
import '../../signatures/providers/signature_provider.dart';
import '../model/leave_request.dart';
import '../../pdf/controller/pdf_controller.dart';

class LeaveDetailsScreen extends ConsumerWidget {
  final LeaveRequest leaveRequest;

  const LeaveDetailsScreen({
    super.key,
    required this.leaveRequest,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resident = ref.watch(getResidentByIdProvider(leaveRequest.residentId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Fetch signatures if available
    final residentSignature = leaveRequest.residentSignatureId != null
        ? ref.watch(signatureByIdProvider(leaveRequest.residentSignatureId!))
        : const AsyncValue.data(null);
    
    final supervisorSignature = leaveRequest.supervisorSignatureId != null
        ? ref.watch(signatureByIdProvider(leaveRequest.supervisorSignatureId!))
        : const AsyncValue.data(null);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Annual Leave Request',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              leaveRequest.status,
                              colorScheme,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            leaveRequest.status.toDisplayString(),
                            style: textTheme.bodyMedium?.copyWith(
                              color: _getStatusTextColor(
                                leaveRequest.status,
                                colorScheme,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Requested on ${DateFormat('MMM dd, yyyy').format(leaveRequest.requestedAt)}',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Leave Duration Card
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: colorScheme.onSurface,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Leave Duration',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildDurationRow(
                      'Start Date:',
                      DateFormat('MMM dd, yyyy').format(leaveRequest.startDate),
                      textTheme,
                      colorScheme,
                    ),
                    const SizedBox(height: 12),
                    _buildDurationRow(
                      'End Date:',
                      DateFormat('MMM dd, yyyy').format(leaveRequest.endDate),
                      textTheme,
                      colorScheme,
                    ),
                    const SizedBox(height: 12),
                    _buildDurationRow(
                      'Total Days:',
                      '${_calculateDaysDifference(leaveRequest.startDate, leaveRequest.endDate)} days',
                      textTheme,
                      colorScheme,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Resident Information Card
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 20,
                          color: colorScheme.onSurface,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Resident Information',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow(
                      'Name:',
                      leaveRequest.residentName,
                      textTheme,
                      colorScheme,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Year:',
                      'Year 1', // You might want to add this to your model
                      textTheme,
                      colorScheme,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Current Rotation:',
                      'Ophthalmology', // You might want to add this to your model
                      textTheme,
                      colorScheme,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Notes Card
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.note,
                          size: 20,
                          color: colorScheme.onSurface,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Notes',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      leaveRequest.notes,
                      style: textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: !leaveRequest.isApproved()
                  ? const SizedBox.shrink()
                  : AsyncGenericButton(
                      text: 'View as PDF',
                      onPressed: () async {
                        await PdfController().fillAndViewLeaveForm(
                          context,
                          leaveRequest,
                          resident.value!,
                          residentSignature: residentSignature.value,
                          supervisorSignature: supervisorSignature.value,
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationRow(
    String label,
    String value,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Color _getStatusColor(LeaveStatus status, ColorScheme colorScheme) {
    switch (status) {
      case LeaveStatus.pending:
        return colorScheme.inverseSurface;
      case LeaveStatus.approved:
        return Colors.green.withValues(alpha: 0.2);
      case LeaveStatus.rejected:
        return Colors.red.withValues(alpha: 0.2);
    }
  }

  Color _getStatusTextColor(LeaveStatus status, ColorScheme colorScheme) {
    switch (status) {
      case LeaveStatus.pending:
        return colorScheme.onInverseSurface;
      case LeaveStatus.approved:
        return Colors.green.shade700;
      case LeaveStatus.rejected:
        return Colors.red.shade700;
    }
  }

  int _calculateDaysDifference(DateTime startDate, DateTime endDate) {
    return endDate.difference(startDate).inDays + 1;
  }
}
