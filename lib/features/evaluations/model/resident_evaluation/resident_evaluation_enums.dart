// Enums for better type safety
enum TrainingLevel { r1, r2, r3, r4, r5, f1, f2, f3 }

enum TrainingType { residency }

enum EvaluationScore {
  unsatisfactory(1, 'Unsatisfactory'),
  needsImprovement(2, 'Needs improvement'),
  meetsExpectations(3, 'Meets expectations'),
  exceedsExpectations(4, 'Exceeds expectations'),
  outstanding(5, 'Outstanding'),
  notApplicable(6, 'N/A');

  const EvaluationScore(this.value, this.description);
  final int value;
  final String description;
}
