import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/core/utils/boali_date_extenstions.dart';
import 'package:ophth_board/features/rotation/model/rotation.dart';
import 'package:ophth_board/features/evaluations/provider/resident_evaluation_provider.dart';

import '../../../core/models/user.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/views/widgets/custom_bottom_sheet.dart';
import 'forms/create_rotation_form.dart';
import '../../evaluations/view/resident_evaluation_form_view.dart';
import '../../evaluations/view/resident_evaluation_result_screen.dart';
import '../../resident/providers/resident_provider.dart';
import '../../supervisor/providers/supervisor_provider.dart';

class RotationDetailsPage extends ConsumerWidget {
  final Rotation rotation;

  const RotationDetailsPage({super.key, required this.rotation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final getRotationResidentsDetailsProvider = ref.watch(
      getResidentsByIdProvider(ResidentIdList(rotation.assignedResidents)),
    );
    final evaluationsProvider = ref.watch(
      getAllEvaluationsForRotationProvider(rotation.id),
    );

    final getCurrentUserProvider = ref.watch(currentUserProvider);
    final bool isSupervisor =
        getCurrentUserProvider?.role ==
        UserRole.supervisor; // Adjust based on your role field

    return Scaffold(
      appBar: isSupervisor ?
      AppBar(
        leading: SizedBox.shrink(),
        actions: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                // Show the custom bottom sheet with the CreateRotationForm in edit mode
                await CustomBottomSheet.show(
                  context: context,
                  child: CreateRotationForm(
                    initialRotation: rotation,
                    onSaved: () {
                      // Optionally you can trigger a refresh here if needed
                    },
                  ),
                  height: MediaQuery.of(context).size.height * 0.9,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                );
              },
            ),
        ],
      ): AppBar(
        leading: SizedBox.shrink(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Rotation Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          rotation.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            rotation.status.isNotEmpty
                                ? rotation.status
                                : 'Unkown',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(rotation.description, style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 8),
                        Text('${rotation.totalWeeks} weeks'),
                        const SizedBox(width: 24),
                        Icon(Icons.group, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${rotation.assignedResidents.length.toString()} residents',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Timeline Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Timeline',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 20),
                    _buildTimelineRow(
                      'Start Date',
                      rotation.startDate.formattedDate,
                    ),
                    const SizedBox(height: 16),
                    _buildTimelineRow(
                      'End Date',
                      rotation.endDate.formattedDate,
                    ),
                    const SizedBox(height: 16),
                    _buildTimelineRow(
                      'Current Week',
                      'Week ${rotation.weekOfRotation} of ${rotation.totalWeeks}',
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text('Progress'),
                        const Spacer(),
                        Text('${rotation.calculateProgress}%'),
                        const SizedBox(width: 8),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: rotation.calculateProgress / 100,
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Assigned Supervisors Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Assigned Supervisors',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Consumer(
                      builder: (context, ref, _) {
                        final supAsync = ref.watch(
                          getSupervisorsByIdProvider(
                            SupervisorIdList(rotation.assignedSupervisors),
                          ),
                        );

                        return supAsync.when(
                          data: (sups) {
                            if (sups.isEmpty) {
                              return Text('No supervisors assigned');
                            }
                            return Column(
                              children: sups
                                  .map(
                                    (s) => ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage:
                                            s.profileImageUrl != null
                                            ? NetworkImage(s.profileImageUrl!)
                                            : null,
                                        child: s.profileImageUrl == null
                                            ? Icon(
                                                Icons.person,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.surfaceContainer,
                                              )
                                            : null,
                                      ),
                                      title: Text(
                                        '${s.firstName} ${s.lastName}',
                                      ),
                                      subtitle: s.workingPlace != null
                                          ? Text(s.workingPlace!)
                                          : null,
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, st) =>
                              Text('Error loading supervisors: $e'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Assigned Residents Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Assigned Residents',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Only show evaluations if user is a supervisor
                    if (isSupervisor)
                      evaluationsProvider.when(
                        data: (evaluations) {
                          final evaluatedResidentIds = evaluations
                              .map((e) => e.residentId)
                              .toSet();
                          return getRotationResidentsDetailsProvider.when(
                            data: (residents) {
                              return Column(
                                children: residents
                                    .map(
                                      (resident) => _buildResidentTile(
                                        context,
                                        resident.fullName,
                                        resident.pgy,
                                        Colors.blue,
                                        evaluatedResidentIds.contains(
                                          resident.id,
                                        ),
                                        getCurrentUserProvider!.id,
                                        evaluations.isNotEmpty
                                            ? evaluations
                                                  .firstWhere(
                                                    (evaluation) =>
                                                        evaluation.residentId ==
                                                        resident.id,
                                                  )
                                                  .id!
                                            : null,
                                      ),
                                    )
                                    .toList(),
                              );
                            },
                            error: (error, stackTrace) =>
                                Text(error.toString()),
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        error: (error, stackTrace) => Text(error.toString()),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                      )
                    else
                      // For residents, show simplified resident list without evaluation options
                      getRotationResidentsDetailsProvider.when(
                        data: (residents) {
                          return Column(
                            children: residents
                                .map(
                                  (resident) => _buildSimpleResidentTile(
                                    context,
                                    resident.fullName,
                                    resident.pgy,
                                    Colors.blue,
                                  ),
                                )
                                .toList(),
                          );
                        },
                        error: (error, stackTrace) => Text(error.toString()),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineRow(String label, String value) {
    return Row(children: [Text(label), const Spacer(), Text(value)]);
  }

  Widget _buildResidentTile(
    BuildContext context,
    String name,
    String title,
    Color avatarColor,
    bool isEvaluated,
    String supervisorId,
    String? evaluationId,
  ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: avatarColor,
          child: Icon(
            Icons.person,
            color: Theme.of(context).colorScheme.surfaceContainer,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
        TextButton(
          onPressed: evaluationId != null
              ? () {
                  CustomBottomSheet.show(
                    context: context,
                    child: EvaluationResultsScreen(
                      evaluationId: evaluationId,
                      residentName: name,
                      residentLevel: 'Ophthalmology Resident - Year $title',
                    ),
                  );
                }
              : () {
                  CustomBottomSheet.show(
                    context: context,
                    child: ResidentEvaluationFormView(
                      residentName: name,
                      rotationId: rotation.id,
                      supervisorId: supervisorId,
                      residentId: rotation.assignedResidents.isNotEmpty
                          ? rotation.assignedResidents.first
                          : '',
                      supervisorName: rotation.assignedSupervisors.isNotEmpty
                          ? rotation.assignedSupervisors.first
                          : '',
                      rotationName: rotation.title,
                    ),
                  );
                },
          child: Text(isEvaluated ? 'View Evaluation' : 'Evaluate'),
        ),
      ],
    );
  }

  Widget _buildSimpleResidentTile(
    BuildContext context,
    String name,
    String title,
    Color avatarColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: avatarColor,
            child: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.surfaceContainer,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleMedium),
                Text(
                  'Year $title',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
