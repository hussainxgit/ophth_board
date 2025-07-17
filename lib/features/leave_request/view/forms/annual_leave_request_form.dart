import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/core/providers/auth_provider.dart';
import 'package:ophth_board/features/leave_request/model/leave_request.dart';
import 'package:ophth_board/features/leave_request/provider/leave_request_provider.dart';
import 'package:ophth_board/features/supervisor/repositories/supervisor_repository.dart';
import 'package:ophth_board/features/supervisor/model/supervisor.dart';

class AnnualLeaveRequestForm extends ConsumerStatefulWidget {
  const AnnualLeaveRequestForm({super.key});

  @override
  ConsumerState<AnnualLeaveRequestForm> createState() =>
      _AnnualLeaveRequestFormState();
}

class _AnnualLeaveRequestFormState
    extends ConsumerState<AnnualLeaveRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSubmitting = false;
  Supervisor? _selectedSupervisor;
  List<Supervisor>? _supervisors;

  @override
  void initState() {
    super.initState();
    _loadSupervisors();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadSupervisors() async {
    try {
      final supervisors = await ref
          .read(supervisorRepositoryProvider)
          .getActiveSupervisors();
      if (mounted) {
        setState(() {
          _supervisors = supervisors;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load supervisors')),
        );
      }
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select start date',
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _endDate ??
          _startDate?.add(const Duration(days: 1)) ??
          DateTime.now().add(const Duration(days: 2)),
      firstDate: _startDate ?? DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select end date',
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  int _calculateLeaveDays() {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Annual Leave'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _supervisors == null
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.airplane_ticket_outlined,
                                  color: theme.primaryColor,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Annual Leave Request',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your request will be reviewed by your current rotation supervisor.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Supervisor selection
                    Text(
                      'Select Supervisor',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Supervisor>(
                      value: _selectedSupervisor,
                      items: _supervisors!
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.fullName),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSupervisor = value;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'Choose supervisor',
                      ),
                      validator: (value) =>
                          value == null ? 'Please select a supervisor' : null,
                    ),

                    const SizedBox(height: 24),

                    // Date Selection Section
                    Text(
                      'Leave Dates',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Start Date
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.calendar_today,
                          color: theme.primaryColor,
                        ),
                        title: const Text('Start Date'),
                        subtitle: Text(
                          _startDate != null
                              ? _formatDate(_startDate!)
                              : 'Select start date',
                          style: TextStyle(
                            color: _startDate != null
                                ? Colors.black87
                                : Colors.grey,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: _selectStartDate,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // End Date
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.calendar_today,
                          color: theme.primaryColor,
                        ),
                        title: const Text('End Date'),
                        subtitle: Text(
                          _endDate != null
                              ? _formatDate(_endDate!)
                              : 'Select end date',
                          style: TextStyle(
                            color: _endDate != null
                                ? Colors.black87
                                : Colors.grey,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: _startDate != null ? _selectEndDate : null,
                      ),
                    ),

                    // Leave Duration Display
                    if (_startDate != null && _endDate != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.primaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Total leave days: ${_calculateLeaveDays()}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Notes Section
                    Text(
                      'Additional Notes',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText:
                            'Enter any additional information about your leave request (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: theme.primaryColor),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Submit Leave Request',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Cancel Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: theme.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both start and end dates')),
      );
      return;
    }

    final currentUser = ref.read(authProvider).user;
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final leaveRequest = LeaveRequest(
      residentId: currentUser.id,
      residentName: currentUser.displayName,
      supervisorId: _selectedSupervisor!.id,
      startDate: _startDate!,
      endDate: _endDate!,
      notes: _notesController.text.trim(),
      requestedAt: DateTime.now(),
    );

    final result = await ref
        .read(leaveRequestOperationsProvider.notifier)
        .submitLeaveRequest(leaveRequest);

    setState(() {
      _isSubmitting = false;
    });

    if (result.isSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Leave request submitted successfully!'),
          ),
        );
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit request: ${result.errorMessage}'),
          ),
        );
      }
    }
  }
}
