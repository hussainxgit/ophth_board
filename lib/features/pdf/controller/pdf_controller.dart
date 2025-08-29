import 'package:flutter/material.dart';

import '../../evaluations/model/resident_evaluation/resident_evaluation.dart';
import '../../evaluations/model/resident_evaluation/resident_evaluation_enums.dart';
import '../model/pdf_model.dart';
import '../view/pdf_viewer_screen.dart';

class PdfController {
  final PdfModel _model = PdfModel();

  // Add helper method to convert TrainingLevel to index
  int _getTrainingLevelIndex(TrainingLevel level) {
    switch (level) {
      case TrainingLevel.r1:
        return 0;
      case TrainingLevel.r2:
        return 1;
      case TrainingLevel.r3:
        return 2;
      case TrainingLevel.r4:
        return 3;
      case TrainingLevel.r5:
        return 4;
      // Add fellowship levels if needed
      default:
        return 0; // Default to R1
    }
  }

  Future<void> fillAndViewForm(
    BuildContext context,
    ResidentEvaluation residentEvaluation,
  ) async {
    // Flatten evaluation criteria from all categories
    final criteria = residentEvaluation.categories
        .expand((category) => category.criteria)
        .toList();

    // Map EvaluationScore to PDF radio button indices (0-based)
    final scoreToIndex = {
      EvaluationScore.unsatisfactory: 0,
      EvaluationScore.needsImprovement: 1,
      EvaluationScore.meetsExpectations: 2,
      EvaluationScore.exceedsExpectations: 3,
      EvaluationScore.outstanding: 4,
      EvaluationScore.notApplicable: 5,
    };

    // Create form data map
    final Map<String, dynamic> formData = {
      'program': 'Ophtalmology',
      'rotation': residentEvaluation.rotationTitle,
      'site_1': '',
      'site_2': '',
      'level_trainee': _getTrainingLevelIndex(residentEvaluation.trainingLevel),
      'trainee_name': residentEvaluation.residentName,
      'supervisor_name': residentEvaluation.supervisorName,
      'additional_comments': residentEvaluation.additionalComments,
      'trainee_signature': residentEvaluation.residentSignature ?? '',
      'supervisor_signature': residentEvaluation.supervisorSignature ?? '',
      'overall': residentEvaluation.getOverallCompetence() - 1,
    };

    // Map criteria to numbered fields (1 to 35)
    final criteriaMapping = [
      'basicScience',
      'clinicalKnowledge',
      'dataGathering',
      'ancillaryTests',
      'clinicalJudgment',
      'emergencyPerformance',
      'selfAssessment',
      'procedures',
      'patientSafety',
      'therapeuticRelationship',
      'patientInformation',
      'professionalRelationship',
      'counseling',
      'documentation',
      'acceptsOpinions',
      'teamwork',
      'consultation',
      'timeManagement',
      'resourceAllocation',
      'organizationWork',
      'informationTechnology',
      'evidenceBasedMedicine',
      'preventiveMeasures',
      'publicHealth',
      'patientAdvocacy',
      'decisionMaking',
      'learningEvents',
      'feedback',
      'evidenceBasedApproach',
      'education',
      'recognizesLimitations',
      'responsibility',
      'honesty',
      'boundaries',
      'punctuality',
    ];

    for (int i = 0; i < criteria.length && i < criteriaMapping.length; i++) {
      print(criteria[i].name);
      if (criteria[i].name == criteriaMapping[i]) {
        final scoreIndex = scoreToIndex[criteria[i].score];
        print('Filling ${criteria[i].name} with index $scoreIndex');
        if (scoreIndex != null) {
          formData['$i'] = scoreIndex;
        } else {
          print(
            'Warning: No score mapping for ${criteria[i].name} (${criteria[i].score})',
          );
        }
      } else {
        print(
          'Warning: Criteria name mismatch: ${criteria[i].name} != ${criteriaMapping[i]}',
        );
      }
    }

    try {
      final outputPath = await _model.fillPdfForm(context, formData);
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(pdfPath: outputPath),
        ),
      );
    } catch (e) {
      print('Error filling PDF form: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
