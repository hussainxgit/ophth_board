import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/features/evaluations/model/resident_evaluation/resident_evaluation.dart';
import 'package:ophth_board/features/pdf/controller/pdf_controller.dart';
import '../../pdf/view/pdf_viewer_screen.dart';
import '../model/resident_evaluation/evaluation_category.dart';
import '../provider/resident_evaluation_provider.dart';

class EvaluationResultsScreen extends ConsumerWidget {
  final String evaluationId;
  final String residentName;
  final String residentLevel;

  const EvaluationResultsScreen({
    super.key,
    required this.evaluationId,
    required this.residentName,
    required this.residentLevel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final evaluation = ref.watch(
      supervisorActiveRotationsProviderForResidents(evaluationId),
    );

    return SafeArea(
      top: false,
      child: Scaffold(
        bottomNavigationBar: // Action Buttons
        evaluation.when(
          data: (evaluation) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildActionButtons(context, evaluation!),
          ),
          error: (error, stack) => Text('Error: $error'),
          loading: () {
            return null;
          },
        ),

        appBar: AppBar(
          title: Text('Evaluation Results'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _shareResults(context),
            ),
          ],
        ),
        body: evaluation.when(
          data: (evaluation) {
            if (evaluation == null) {
              return const Center(child: Text('Evaluation not found.'));
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCompletionCard(context),
                  const SizedBox(height: 16),
                  _buildResidentInfoCard(context, evaluation),
                  const SizedBox(height: 16),
                  _buildPerformanceBreakdown(context, evaluation),
                  const SizedBox(height: 16),
                  // Additional comments section
                  if (evaluation.additionalComments.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Additional Comments',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              evaluation.additionalComments,
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }

  Widget _buildCompletionCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: theme.colorScheme.onPrimary,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Evaluation Completed',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResidentInfoCard(
    BuildContext context,
    ResidentEvaluation evaluation,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.person,
                size: 32,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),

            // Resident Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    residentName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$residentLevel - ${evaluation.trainingLevelDisplay}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Scores
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  evaluation.getOverallCompetence().toString(),
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Overall Score',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getPerformanceLevelColor(
                      context,
                      evaluation.getOverallCompetence().toDouble(),
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _getPerformanceLevelText(evaluation.getOverallCompetence()),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceBreakdown(
    BuildContext context,
    ResidentEvaluation evaluation,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Breakdown',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // Categories
            ...evaluation.categories.map((category) {
              return _buildCategoryItem(context, category);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, EvaluationCategory category) {
    final theme = Theme.of(context);
    final averageScore = category.averageScore.round();
    final performanceLevel = _getPerformanceLevelText(averageScore);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getCategoryDescription(category.title),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                averageScore.toStringAsFixed(0),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                performanceLevel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: _getPerformanceLevelColor(
                    context,
                    averageScore.toDouble(),
                  ),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ResidentEvaluation evaluation,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _savePDF(context, evaluation),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: theme.colorScheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Save PDF',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Done',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getPerformanceLevelText(int score) {
    if (score >= 4) return 'Superior';
    if (score >= 4) return 'Excesseds';
    if (score >= 3) return 'Meets';
    if (score >= 2) return 'Below';
    if (score >= 1) return 'Unsatisfactory';
    return 'Unsatisfactory';
  }

  Color _getPerformanceLevelColor(BuildContext context, double score) {
    final theme = Theme.of(context);

    if (score >= 4.5) return theme.colorScheme.primary;
    if (score >= 3.5) return theme.colorScheme.secondary;
    if (score >= 2.5) return theme.colorScheme.tertiary;
    if (score >= 1.5) return theme.colorScheme.error;
    return theme.colorScheme.error;
  }

  String _getCategoryDescription(String categoryTitle) {
    switch (categoryTitle) {
      case 'Medical Expert':
        return 'Clinical knowledge & expertise';
      case 'Communicator':
        return 'Patient & team interaction';
      case 'Collaborator':
        return 'Teamwork & cooperation';
      case 'Manager':
        return 'Resource & time management';
      case 'Health Advocate':
        return 'Patient advocacy & care';
      case 'Scholar':
        return 'Learning & education';
      case 'Professional':
        return 'Professional conduct';
      default:
        return 'Professional competency';
    }
  }

  void _savePDF(BuildContext context, ResidentEvaluation evaluation) async {
    final PdfController pdfController = PdfController();
    await pdfController.fillAndViewForm(context, evaluation);
  }

  void _shareResults(BuildContext context) {
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Results shared successfully'),
        backgroundColor: theme.colorScheme.secondary,
      ),
    );
  }
}
