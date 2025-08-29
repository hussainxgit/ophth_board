import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/core/utils/boali_date_extenstions.dart';
import 'package:ophth_board/features/rotation/model/rotation.dart';
import 'package:ophth_board/features/evaluations/provider/resident_evaluation_provider.dart';

import '../../../core/models/user.dart';
import '../../../core/providers/auth_provider.dart';
import '../../evaluations/view/resident_evaluation_form_view.dart';
import '../../evaluations/view/resident_evaluation_result_screen.dart';
import '../../resident/providers/resident_provider.dart';

class RotationDetailsPage extends ConsumerWidget {
  final Rotation rotation;

  const RotationDetailsPage({super.key, required this.rotation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final getRotationResidentsDetailsProvider = ref.watch(
      getResidentsByIdProvider(
        ResidentIdList(rotation.assignedResidents.keys.toList()),
      ),
    );
    final evaluationsProvider = ref.watch(
      getAllEvaluationsForRotationProvider(rotation.id),
    );

    final getCurrentUserProvider = ref.watch(currentUserProvider);
    final bool isSupervisor =
        getCurrentUserProvider?.role ==
        UserRole.supervisor; // Adjust based on your role field

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Rotation Details'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).colorScheme.surfaceContainer,
            ),
            onPressed: () {},
          ),
        ],
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
                          '${rotation.assignedResidents.entries.length.toString()} residents',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

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
                        Text(
                          '${rotation.assignedResidents.entries.length.toString()} residents',
                          style: Theme.of(context).textTheme.labelLarge,
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EvaluationResultsScreen(
                        evaluationId: evaluationId,
                        residentName: name,
                        residentLevel: 'Ophthalmology Resident - Year $title',
                      ),
                    ),
                  );
                }
              : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ResidentEvaluationFormView(
                        residentName: name,
                        rotationId: rotation.id,
                        supervisorId: supervisorId,
                        residentId: rotation.assignedResidents.keys.first,
                        supervisorName: rotation.assignedSupervisors.keys.first,
                        rotationName: rotation.title
                      ),
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
