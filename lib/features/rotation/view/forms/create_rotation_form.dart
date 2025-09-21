import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/core/views/widgets/async_loading_button.dart';
import '../../model/rotation.dart';
import '../../../resident/model/resident.dart';
import '../../../supervisor/model/supervisor.dart';
import '../../../resident/repositories/resident_repository.dart';
import '../../../supervisor/repositories/supervisor_repository.dart';
import '../../repositories/rotation_repository.dart';

/// Provider to fetch all residents for selection
final allResidentsProvider = FutureProvider.autoDispose<List<Resident>>((
  ref,
) async {
  final repository = ref.watch(residentRepositoryProvider);
  return repository.getAllResidents();
});

/// Provider to fetch active supervisors for selection
final allSupervisorsProvider = FutureProvider.autoDispose<List<Supervisor>>((
  ref,
) async {
  final repository = ref.watch(supervisorRepositoryProvider);
  return repository.getActiveSupervisors();
});

class CreateRotationForm extends ConsumerStatefulWidget {
  final Rotation? initialRotation;
  final VoidCallback? onSaved;

  const CreateRotationForm({super.key, this.initialRotation, this.onSaved});

  @override
  ConsumerState<CreateRotationForm> createState() => _CreateRotationFormState();
}

class _CreateRotationFormState extends ConsumerState<CreateRotationForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtl = TextEditingController();
  final _descCtl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  final Set<String> _selectedResidentIds = {};
  final Set<String> _selectedSupervisorIds = {};

  bool get isEditing => widget.initialRotation != null;

  @override
  void dispose() {
    _titleCtl.dispose();
    _descCtl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // If editing, populate fields from the initial rotation
    final r = widget.initialRotation;
    if (r != null) {
      _titleCtl.text = r.title;
      _descCtl.text = r.description;
      _startDate = r.startDate;
      _endDate = r.endDate;
      _selectedResidentIds.addAll(r.assignedResidents);
      _selectedSupervisorIds.addAll(r.assignedSupervisors);
    }
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final initial =
        _endDate ?? (_startDate ?? now).add(const Duration(days: 7));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _startDate ?? DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick start and end dates')),
      );
      return;
    }
    if (!_startDate!.isBefore(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start date must be before end date')),
      );
      return;
    }

    final rotationRepo = ref.read(rotationRepositoryProvider);

    final now = DateTime.now();

    // Convert selected ids to Map<String,bool> for storage (firestore shape)
    final assignedResidents = {for (var id in _selectedResidentIds) id: true};
    final assignedSupervisors = {for (var id in _selectedSupervisorIds) id: true};

    // Build rotation object (preserve id/createdAt when editing)
    final initial = widget.initialRotation;
    final rotation = Rotation(
      id: initial?.id ?? 'id',
      title: _titleCtl.text.trim(),
      description: _descCtl.text.trim(),
      startDate: _startDate!,
      endDate: _endDate!,
      status: initial?.status ?? 'scheduled',
      // Rotation model now expects lists of ids
      assignedResidents: assignedResidents.keys.toList(),
      assignedSupervisors: assignedSupervisors.keys.toList(),
      createdAt: initial?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      if (isEditing) {
        await rotationRepo.updateRotation(rotation.id, rotation);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Rotation updated')));
          widget.onSaved?.call();
          Navigator.of(context).pop();
        }
      } else {
        await rotationRepo.addRotation(rotation);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Rotation created')));
          widget.onSaved?.call();
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Error updating rotation: $e'
                : 'Error creating rotation: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final residentsAsync = ref.watch(allResidentsProvider);
    final supervisorsAsync = ref.watch(allSupervisorsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleCtl,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descCtl,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickStartDate,
                    child: Text(
                      _startDate == null
                          ? 'Pick start date'
                          : 'Start: ${_startDate!.toLocal().toIso8601String().split('T').first}',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickEndDate,
                    child: Text(
                      _endDate == null
                          ? 'Pick end date'
                          : 'End: ${_endDate!.toLocal().toIso8601String().split('T').first}',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Supervisors multi-select
            supervisorsAsync.when(
              data: (supervisors) => _buildMultiSelectCard(
                title: 'Assign Supervisors',
                items: supervisors
                    .map(
                      (s) => _IdLabel(
                        id: s.id,
                        label: '${s.firstName} ${s.lastName}',
                      ),
                    )
                    .toList(),
                selectedIds: _selectedSupervisorIds,
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => Text('Error loading supervisors: $e'),
            ),

            const SizedBox(height: 12),

            // Residents multi-select
            residentsAsync.when(
              data: (residents) => _buildMultiSelectCard(
                title: 'Assign Residents',
                items: residents
                    .map(
                      (r) => _IdLabel(
                        id: r.id,
                        label: '${r.firstName} ${r.lastName} (${r.pgy})',
                      ),
                    )
                    .toList(),
                selectedIds: _selectedResidentIds,
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => Text('Error loading residents: $e'),
            ),

            const SizedBox(height: 16),
            AsyncGenericButton(
              text: isEditing ? 'Update Rotation' : 'Create Rotation',
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiSelectCard({
    required String title,
    required List<_IdLabel> items,
    required Set<String> selectedIds,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...items.map((it) {
              final selected = selectedIds.contains(it.id);
              return CheckboxListTile(
                title: Text(it.label),
                value: selected,
                onChanged: (v) {
                  setState(() {
                    if (v == true)
                      selectedIds.add(it.id);
                    else
                      selectedIds.remove(it.id);
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _IdLabel {
  final String id;
  final String label;
  _IdLabel({required this.id, required this.label});
}
