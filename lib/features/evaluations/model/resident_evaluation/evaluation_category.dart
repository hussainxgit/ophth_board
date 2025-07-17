

// Individual evaluation criterion
import 'evaluation_criterion.dart';
import 'resident_evaluation_enums.dart';

// Evaluation category (e.g., Medical Expert, Communicator)
class EvaluationCategory {
  final String title;
  final List<EvaluationCriterion> criteria;

  EvaluationCategory({required this.title, required this.criteria});

  // Calculate average score for the category
  double get averageScore {
    final validScores = criteria
        .where((c) => c.score != EvaluationScore.notApplicable)
        .map((c) => c.score.value)
        .toList();

    if (validScores.isEmpty) return 0.0;
    return validScores.reduce((a, b) => a + b) / validScores.length;
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'criteria': criteria.map((c) => c.toJson()).toList(),
  };

  factory EvaluationCategory.fromJson(Map<String, dynamic> json) {
    return EvaluationCategory(
      title: json['title'],
      criteria: (json['criteria'] as List)
          .map((c) => EvaluationCriterion.fromJson(c))
          .toList(),
    );
  }

  EvaluationCategory copyWith({
    String? title,
    List<EvaluationCriterion>? criteria,
  }) {
    return EvaluationCategory(
      title: title ?? this.title,
      criteria: criteria ?? this.criteria,
    );
  }
}
