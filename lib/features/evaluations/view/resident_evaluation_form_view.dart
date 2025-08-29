import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/features/evaluations/model/resident_evaluation/evaluation_category.dart';
import 'package:ophth_board/features/evaluations/model/resident_evaluation/resident_evaluation_enums.dart';
import 'package:ophth_board/features/evaluations/provider/resident_evaluation_provider.dart';

class ResidentEvaluationFormView extends ConsumerStatefulWidget {
  final String rotationId;
  final String supervisorId;
  final String residentId;
  final String residentName;
  final String supervisorName;
  final String rotationName;

  const ResidentEvaluationFormView({
    super.key,
    required this.rotationId,
    required this.supervisorId,
    required this.residentId,
    required this.residentName,
    required this.supervisorName,
    required this.rotationName,
  });

  @override
  ConsumerState<ResidentEvaluationFormView> createState() =>
      _ResidentEvaluationFormViewState();
}

class _ResidentEvaluationFormViewState
    extends ConsumerState<ResidentEvaluationFormView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeEvaluation();
  }

  void _initializeEvaluation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(residentEvaluationProvider.notifier).createNewEvaluation();
      _setInitialValues();
    });
  }

  void _setInitialValues() {
    final notifier = ref.read(residentEvaluationProvider.notifier);
    notifier.updateEvaluationField(widget.residentId, 'residentId');
    notifier.updateEvaluationField(widget.rotationId, 'rotationId');
    notifier.updateEvaluationField(widget.supervisorId, 'supervisorId');
    notifier.updateEvaluationField(widget.residentName, 'residentName');
    notifier.updateEvaluationField(widget.rotationName, 'rotationName');
    notifier.updateEvaluationField(widget.supervisorName, 'supervisorName');
    
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int get _totalPages {
    final evaluation = ref.read(residentEvaluationProvider).currentEvaluation;
    if (evaluation == null) return 1;
    return evaluation.categories.length +
        1; // Fixed: +1 for overall assessment page
  }

  bool get _isLastPage =>
      _currentPage == _totalPages - 1; // Fixed: -1 for zero-based index

  void _nextPage() {
    if (_isLastPage) {
      _submitForm();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitForm() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final notifier = ref.read(residentEvaluationProvider.notifier);
      final success = await notifier.saveEvaluation();

      if (!mounted) return;

      if (success) {
        _showSuccessSnackBar();
        Navigator.of(context).pop();
      } else {
        _showErrorSnackBar();
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Evaluation submitted successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar() {
    final errorMessage = ref.read(residentEvaluationProvider).errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage ?? 'Could not submit evaluation.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final evaluationState = ref.watch(residentEvaluationProvider);
    final evaluation = evaluationState.currentEvaluation;

    if (evaluationState.isLoading && evaluation == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (evaluation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resident Evaluation')),
        body: const Center(
          child: Text('Failed to load evaluation form. Please try again.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        title: const Text('Evaluate Resident'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildProgressHeader(),
          _buildResidentCard(widget.residentName),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              physics: const NeverScrollableScrollPhysics(),
              children: _buildPages(evaluation),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildProgressHeader() {
    final progress = (_currentPage + 1) / _totalPages;
    final percentage = (progress * 100).round();

    return Container(
      color: const Color(0xFF2C3E50),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${_currentPage + 1} of $_totalPages',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              Text(
                '$percentage%',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildResidentCard(String residentName) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.person, size: 30, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  residentName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rotation Evaluation',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFF2C3E50),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPages(evaluation) {
    return [
      ...evaluation.categories.map<Widget>(
        (category) => _CategoryPage(category: category),
      ),
      const _OverallAndCommentsPage(),
    ];
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: const BorderSide(color: Color(0xFF2C3E50)),
                ),
                child: const Text(
                  'Previous',
                  style: TextStyle(
                    color: Color(0xFF2C3E50),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C3E50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _isLastPage ? 'Submit' : 'Next Step',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPage extends ConsumerWidget {
  final EvaluationCategory category;

  const _CategoryPage({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final evaluationState = ref.watch(residentEvaluationProvider);
    final evaluation = evaluationState.currentEvaluation!;
    final notifier = ref.read(residentEvaluationProvider.notifier);
    final categoryIndex = evaluation.categories.indexOf(category);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rate the resident\'s performance on the following criteria',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...category.criteria.asMap().entries.map((entry) {
            final criterionIndex = entry.key;
            final criterion = entry.value;

            return _CriterionCard(
              criterion: criterion,
              onScoreChanged: (score) {
                notifier.updateCategoryScore(
                  categoryIndex,
                  criterionIndex,
                  score,
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

class _CriterionCard extends StatelessWidget {
  final criterion;
  final Function(EvaluationScore) onScoreChanged;

  const _CriterionCard({required this.criterion, required this.onScoreChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            criterion.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            criterion.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          _buildScoreSelector(criterion.score),
        ],
      ),
    );
  }

  Widget _buildScoreSelector(EvaluationScore? currentScore) {
    final scores = [
      {'value': EvaluationScore.unsatisfactory, 'label': 'Poor', 'number': '1'},
      {
        'value': EvaluationScore.needsImprovement,
        'label': 'Below',
        'number': '2',
      },
      {
        'value': EvaluationScore.meetsExpectations,
        'label': 'Meets',
        'number': '3',
      },
      {
        'value': EvaluationScore.exceedsExpectations,
        'label': 'Exceeds',
        'number': '4',
      },
      {
        'value': EvaluationScore.outstanding,
        'label': 'Superior',
        'number': '5',
      },
      {'value': EvaluationScore.notApplicable, 'label': 'N/A', 'number': 'NA'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: scores.length,
      itemBuilder: (context, index) {
        final score = scores[index];
        final isSelected = currentScore == score['value'];
        final isExceeds = score['value'] == EvaluationScore.exceedsExpectations;

        return GestureDetector(
          onTap: () => onScoreChanged(score['value'] as EvaluationScore),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? (isExceeds ? const Color(0xFF2C3E50) : Colors.grey[200])
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? (isExceeds ? const Color(0xFF2C3E50) : Colors.grey[400]!)
                    : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  score['number'] as String,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? (isExceeds ? Colors.white : Colors.black)
                        : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  score['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? (isExceeds ? Colors.white : Colors.black)
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OverallAndCommentsPage extends ConsumerWidget {
  const _OverallAndCommentsPage();

  // Auto-calculate overall competence based on category averages
  EvaluationScore _calculateOverallCompetence(evaluation) {
    if (evaluation.categories.isEmpty) return EvaluationScore.notApplicable;

    List<double> categoryAverages = [];

    for (final category in evaluation.categories) {
      final validScores = category.criteria
          .where(
            (c) => c.score != null && c.score != EvaluationScore.notApplicable,
          )
          .map((c) => c.score!.value.toDouble())
          .toList();

      if (validScores.isNotEmpty) {
        final average =
            validScores.reduce((a, b) => a + b) / validScores.length;
        categoryAverages.add(average);
      }
    }

    if (categoryAverages.isEmpty) return EvaluationScore.notApplicable;

    final overallAverage =
        categoryAverages.reduce((a, b) => a + b) / categoryAverages.length;
    final roundedScore = overallAverage.round();

    // Convert back to EvaluationScore
    switch (roundedScore) {
      case 1:
        return EvaluationScore.unsatisfactory;
      case 2:
        return EvaluationScore.needsImprovement;
      case 3:
        return EvaluationScore.meetsExpectations;
      case 4:
        return EvaluationScore.exceedsExpectations;
      case 5:
        return EvaluationScore.outstanding;
      default:
        return EvaluationScore.meetsExpectations;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final evaluationState = ref.watch(residentEvaluationProvider);
    final evaluation = evaluationState.currentEvaluation!;
    final notifier = ref.read(residentEvaluationProvider.notifier);

    // Auto-calculate overall competence
    final calculatedOverallCompetence = _calculateOverallCompetence(evaluation);

    // Update the evaluation if the calculated score is different from current
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (evaluation.overallCompetence != calculatedOverallCompetence) {
        notifier.updateEvaluationField(
          calculatedOverallCompetence,
          'overallCompetence',
        );
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall Assessment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                
                const SizedBox(height: 8),
                Text(
                  'Auto-calculated based on category averages',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall Competence',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C3E50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    calculatedOverallCompetence.description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              initialValue: evaluation.additionalComments,
              decoration: const InputDecoration(
                labelText: 'Additional Comments',
                border: OutlineInputBorder(),
                hintText: 'Provide any additional feedback or observations...',
              ),
              maxLines: 5,
              onChanged: (value) =>
                  notifier.updateEvaluationField(value, 'additionalComments'),
            ),
          ),
          if (evaluationState.errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      evaluationState.errorMessage!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
