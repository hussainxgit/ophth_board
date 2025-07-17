// Individual evaluation criterion
import 'resident_evaluation_enums.dart';

class EvaluationCriterion {
  final String name;
  final String description;
  EvaluationScore score;

  EvaluationCriterion({
    required this.name,
    required this.description,
    this.score = EvaluationScore.notApplicable,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'score': score.value,
  };

  factory EvaluationCriterion.fromJson(Map<String, dynamic> json) {
    return EvaluationCriterion(
      name: json['name'],
      description: json['description'],
      score: EvaluationScore.values.firstWhere(
        (s) => s.value == json['score'],
        orElse: () => EvaluationScore.notApplicable,
      ),
    );
  }

  EvaluationCriterion copyWith({
    String? name,
    String? description,
    EvaluationScore? score,
  }) {
    return EvaluationCriterion(
      name: name ?? this.name,
      description: description ?? this.description,
      score: score ?? this.score,
    );
  }
}
