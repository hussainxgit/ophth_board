import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/features/evaluations/model/resident_evaluation/resident_evaluation.dart';
import 'package:ophth_board/features/evaluations/provider/resident_evaluation_provider.dart';
import 'resident_evaluation_result_screen.dart';
import '../../../core/models/user.dart';
import '../../../core/providers/auth_provider.dart';
import 'widgets/evaluation_list_card.dart';
import 'resident_evaluation_form_view.dart';

/// Evaluation list screen styled like the leave list screen.
/// If [rotationId] or [residentId] is provided, it will fetch that specific list.
/// Otherwise it falls back to the currently authenticated user to decide.
class EvaluationListScreen extends ConsumerWidget {
  final String? rotationId;
  final String? residentId;
  final String title;

  const EvaluationListScreen({
    super.key,
    this.rotationId,
    this.residentId,
    this.title = 'Evaluations',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    if (rotationId == null && residentId == null && currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: Text('Please sign in to view evaluations')),
      );
    }

    // Choose provider precedence: explicit args > current user role
    final provider = (rotationId != null)
        ? getAllEvaluationsForRotationProvider(rotationId!)
        : (residentId != null)
        ? getAllEvaluationsForResidentProvider(residentId!)
        : (currentUser!.role == UserRole.resident
              ? getAllEvaluationsForResidentProvider(currentUser.id)
              : getAllEvaluationsForRotationProvider(currentUser.id));

    final evaluationsList = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        shrinkWrap: true,
        children: [
          evaluationsList.when(
            data: (evaluationList) => evaluationList.isNotEmpty
                ? Column(
                    children: evaluationList.map<Widget>((evaluation) {
                      return EvaluationListCard(
                        evaluation: evaluation,
                        onView: () {
                          if (evaluation.id != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EvaluationResultsScreen(
                                  evaluationId: evaluation.id!,
                                  residentName:
                                      evaluation.residentName.isNotEmpty
                                      ? evaluation.residentName
                                      : 'Resident',
                                  residentLevel:
                                      evaluation.trainingLevelDisplay,
                                ),
                              ),
                            );
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ResidentEvaluationFormView(
                                  residentName: evaluation.residentName,
                                  rotationId: evaluation.rotationId,
                                  supervisorId: evaluation.supervisorId,
                                  residentId: evaluation.residentId,
                                  supervisorName: evaluation.supervisorName,
                                  rotationName: evaluation.rotationTitle,
                                ),
                              ),
                            );
                          }
                        },
                      );
                    }).toList(),
                  )
                : const Center(
                    child: Text(
                      'No evaluations found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text(
              'Error fetching evaluations: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
