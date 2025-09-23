import 'package:flutter/material.dart';
import 'package:ophth_board/features/evaluations/model/resident_evaluation/resident_evaluation.dart';

/// Card used to show an evaluation summary in lists with modern Material Design
class EvaluationListCard extends StatelessWidget {
  final ResidentEvaluation evaluation;
  final VoidCallback? onView;

  const EvaluationListCard({super.key, required this.evaluation, this.onView});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = evaluation.id != null;
    final date = evaluation.evaluationDate != null
        ? evaluation.evaluationDate!
              .toLocal()
              .toIso8601String()
              .split('T')
              .first
        : '—';

    return Hero(
      tag: 'evaluation_${evaluation.id ?? evaluation.residentId}',
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 2,
        shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onView,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surface.withOpacity(0.8),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, theme, isCompleted),
                  const SizedBox(height: 16),
                  _buildResidentInfo(context, theme),
                  const SizedBox(height: 12),
                  _buildRotationInfo(context, theme, date),
                  const SizedBox(height: 16),
                  _buildFooter(context, theme, isCompleted),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isCompleted) {
    return Row(
      children: [
        _buildAvatar(context, theme),
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
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                evaluation.trainingLevelDisplay,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(context, theme, isCompleted),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context, ThemeData theme) {
    final letter = evaluation.residentName.isNotEmpty
        ? evaluation.residentName[0].toUpperCase()
        : 'R';
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          letter,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, ThemeData theme, bool isCompleted) {
    final color = isCompleted ? Colors.green : Colors.orange;
    final icon = isCompleted ? Icons.check_circle : Icons.pending;
    final label = isCompleted ? 'Completed' : 'Pending';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResidentInfo(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person_outline,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              evaluation.residentName.isNotEmpty
                  ? evaluation.residentName
                  : 'Unknown Resident',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (evaluation.supervisorName.isNotEmpty) ...[
            Container(
              width: 1,
              height: 16,
              color: theme.colorScheme.outline.withOpacity(0.3),
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
            Icon(
              Icons.supervisor_account_outlined,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                evaluation.supervisorName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRotationInfo(BuildContext context, ThemeData theme, String date) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      evaluation.rotationTitle.isNotEmpty
                          ? evaluation.rotationTitle
                          : 'Unknown Rotation',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Date: $date',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, ThemeData theme, bool isCompleted) {
    return Row(
      children: [
        if (isCompleted) ...[
          _buildScoreChip(context, theme),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: _buildProgressIndicator(context, theme, isCompleted),
        ),
        const SizedBox(width: 12),
        _buildActionButton(context, theme, isCompleted),
      ],
    );
  }

  Widget _buildScoreChip(BuildContext context, ThemeData theme) {
    final score = evaluation.getOverallCompetence();
    final color = _getScoreColor(score);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            score.toString(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context, ThemeData theme, bool isCompleted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isCompleted ? 'Evaluation Complete' : 'Awaiting Completion',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: isCompleted ? 1.0 : 0.0,
          backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(
            isCompleted ? Colors.green : Colors.orange,
          ),
          borderRadius: BorderRadius.circular(2),
          minHeight: 4,
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, ThemeData theme, bool isCompleted) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onView,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCompleted ? Icons.visibility : Icons.edit,
                  size: 16,
                  color: theme.colorScheme.onPrimary,
                ),
                const SizedBox(width: 6),
                Text(
                  isCompleted ? 'View' : 'Complete',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 4) return Colors.green;
    if (score >= 3) return Colors.blue;
    if (score >= 2) return Colors.orange;
    return Colors.red;
  }
}
