import 'package:flutter/material.dart';
import 'package:ophth_board/core/utils/boali_date_extenstions.dart';

import '../../evaluations/model/resident_evaluation/resident_evaluation.dart';
import '../../evaluations/model/resident_evaluation/resident_evaluation_enums.dart';
import '../../leave_request/model/leave_request.dart';
import '../../resident/model/resident.dart';
import '../../signatures/model/signature.dart';
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

  // Updated method for evaluations with signature data
  Future<void> fillAndViewEvaluationForm(
    BuildContext context,
    ResidentEvaluation residentEvaluation, {
    Signature? residentSignature,
    Signature? supervisorSignature,
  }) async {
    final formData = _buildEvaluationFormData(
      residentEvaluation,
      residentSignature: residentSignature,
      supervisorSignature: supervisorSignature,
    );
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
    Resident resident, {
    Signature? residentSignature,
    Signature? supervisorSignature,
  }) async {
    final formData = _buildLeaveFormData(
      leaveRequest,
      resident,
      residentSignature: residentSignature,
      supervisorSignature: supervisorSignature,
    );
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
      print('=== PDF Form Data Debug ===');
      print('Template: $templateAsset');
      formData.forEach((key, value) {
        if (key.contains('signature') && value != null) {
          print('$key: [SVG DATA - ${value.toString().length} characters]');
        } else {
          print('$key: $value');
        }
      });
      print('=== End Form Data Debug ===');
      
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

  /// Debug helper that prints all form field names in the given PDF template.
  Future<void> printPdfFormFields(
    BuildContext context, {
    String templateAsset = 'assets/pdf_forms/form_template.pdf',
  }) async {
    try {
      print('=== Debugging PDF Form Fields ===');
      final names = await _model.listPdfFormFields(
        context,
        templateAsset: templateAsset,
      );
      print('PDF form fields in $templateAsset:');
      for (int i = 0; i < names.length; i++) {
        print('[$i] ${names[i]}');
      }
      if (names.isEmpty) print('(no fields found)');
      print('=== End PDF Form Fields Debug ===');
    } catch (e) {
      print('Error printing PDF form fields: $e');
    }
  }

  /// Test method to debug signature field issues
  Future<void> debugSignatureFields(BuildContext context) async {
    print('=== Testing Signature Field Debug ===');
    
    // Test with evaluation form
    await printPdfFormFields(context, templateAsset: 'assets/pdf_forms/form_template.pdf');
    
    // Test with leave request form  
    await printPdfFormFields(context, templateAsset: 'assets/pdf_forms/resident_leave_request.pdf');
    
    // Test with sample SVG data
    const testSvgData = '<svg xmlns="http://www.w3.org/2000/svg" width="400" height="200" viewBox="0 0 400 200"><path d="M50,50 L100,50 L100,100" stroke="#000000" stroke-width="2.0" fill="none" stroke-linecap="round" stroke-linejoin="round"/></svg>';
    
    final testFormData = {
      'resident_signature': testSvgData,
      'supervisor_signature': testSvgData,
    };
    
    print('Testing with sample signature data...');
    try {
      await _model.fillPdfForm(
        context,
        testFormData,
        templateAsset: 'assets/pdf_forms/form_template.pdf',
      );
    } catch (e) {
      print('Error in signature test: $e');
    }
    
    print('=== End Signature Field Debug ===');
  }

  Map<String, dynamic> _buildEvaluationFormData(
    ResidentEvaluation residentEvaluation, {
    Signature? residentSignature,
    Signature? supervisorSignature,
  }) {
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
      'overall': residentEvaluation.getOverallCompetence(),
      'resident_signature': residentSignature?.signatureStoragePath,
      'supervisor_resident': supervisorSignature?.signatureStoragePath, // Use correct field name from PDF
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
          print(
            'Assigning ${criteria[i].name} to field ${i + 1} with index $scoreIndex',
          );
          formData['${i + 1}'] = scoreIndex;
        }
      } else {
        print(
          'Warning: Criteria name mismatch at index $i. Expected ${criteriaMapping[i]}, found ${criteria[i].name}',
        );
      }
    }

    return formData;
  }

  Map<String, dynamic> _buildLeaveFormData(
    LeaveRequest leaveRequest,
    Resident resident, {
    Signature? residentSignature,
    Signature? supervisorSignature,
  }) {
    // Map leave request fields to PDF form field names expected by template
    final formData = {
      'resident_name': resident.fullName,
      'civil_id': resident.civilId,
      'file_number': resident.fileNumber,
      'working_place': resident.workingPlace,
      'resident_level': 'PGY${resident.pgy}', // Assuming pgy
      'leave_type': 'annual', // Placeholder, adjust as needed
      'leave_start_date': leaveRequest.startDate.formattedDate,
      'leave__total_days': leaveRequest.totalDays.toString(),
      'leave_end_date': leaveRequest.endDate.formattedDate,
      'status': leaveRequest.status.toDisplayString(),
    };

    // Add signature SVG data if available (stored in signatureStoragePath field)
    if (residentSignature != null) {
      formData['resident_signature'] = residentSignature.signatureStoragePath;
    }

    if (supervisorSignature != null) {
      formData['resident_signature'] =
          supervisorSignature.signatureStoragePath;
    }

    return formData;
  }
}
