import 'package:flutter/material.dart';
import 'package:ophth_board/features/evaluations/model/resident_evaluation/resident_evaluation.dart';

/// Card used to show an evaluation summary in lists (similar style to leave cards)
class EvaluationListCard extends StatelessWidget {
  final ResidentEvaluation evaluation;
  final VoidCallback? onView;

  const EvaluationListCard({super.key, required this.evaluation, this.onView});

  @override
  Widget build(BuildContext context) {
    final date = evaluation.evaluationDate != null
        ? evaluation.evaluationDate!
              .toLocal()
              .toIso8601String()
              .split('T')
              .first
        : '—';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  evaluation.residentName.isNotEmpty
                      ? evaluation.residentName[0].toUpperCase()
                      : 'R',
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
                      evaluation.residentName.isNotEmpty
                          ? evaluation.residentName
                          : evaluation.rotationTitle.isNotEmpty
                          ? evaluation.rotationTitle
                          : 'Evaluation',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${evaluation.rotationTitle.isNotEmpty ? '${evaluation.rotationTitle} · ' : ''}Date: $date',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    evaluation.getOverallCompetence().toString(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Overall', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  TextButton(onPressed: onView, child: const Text('View')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
