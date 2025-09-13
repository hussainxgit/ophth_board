import 'package:flutter/material.dart';

import '../../evaluations/model/resident_evaluation/resident_evaluation.dart';
import '../../evaluations/model/resident_evaluation/resident_evaluation_enums.dart';
import '../../leave_request/model/leave_request.dart';
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

  // Backwards-compatible method for evaluations
  Future<void> fillAndViewEvaluationForm(
    BuildContext context,
    ResidentEvaluation residentEvaluation,
  ) async {
    final formData = _buildEvaluationFormData(residentEvaluation);
    final template = 'assets/pdf_forms/form_template.pdf';
    await _fillAndShow(
      context,
      formData,
      templateAsset: template,
      title: 'Resident Evaluation',
      filenamePrefix: 'resident_evaluation',
    );
  }

  // New method for leave requests
  Future<void> fillAndViewLeaveForm(
    BuildContext context,
    LeaveRequest leaveRequest,
  ) async {
    final formData = _buildLeaveFormData(leaveRequest);
    final template = 'assets/pdf_forms/resident_leave_request.pdf';
    await _fillAndShow(
      context,
      formData,
      templateAsset: template,
      title: 'Leave Request',
      filenamePrefix: 'leave_request',
    );
  }

  // Generic internal method
  Future<void> _fillAndShow(
    BuildContext context,
    Map<String, dynamic> formData, {
    required String templateAsset,
    required String title,
    required String filenamePrefix,
  }) async {
    try {
      final outputPath = await _model.fillPdfForm(
        context,
        formData,
        templateAsset: templateAsset,
      );
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(
            pdfPath: outputPath,
            title: title,
            filenamePrefix: filenamePrefix,
          ),
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

  Map<String, dynamic> _buildEvaluationFormData(
    ResidentEvaluation residentEvaluation,
  ) {
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

    // Base fields
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
      if (criteria[i].name == criteriaMapping[i]) {
        final scoreIndex = scoreToIndex[criteria[i].score];
        if (scoreIndex != null) {
          formData['$i'] = scoreIndex;
        }
      }
    }

    return formData;
  }

  Map<String, dynamic> _buildLeaveFormData(LeaveRequest leaveRequest) {
    // Map leave request fields to PDF form field names expected by template
    return {
      'resident_name': leaveRequest.residentName,
      'leave_type': 'annual', // Placeholder, adjust as needed
      'leave_start_date': leaveRequest.startDate.toIso8601String(),
      'leave__total_days': leaveRequest.totalDays.toString(),
      'leave_end_date': leaveRequest.endDate.toIso8601String(),
      'status': leaveRequest.status.toDisplayString(),
    };
  }
}
