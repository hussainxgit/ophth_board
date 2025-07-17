// Individual evaluation criterion
import 'package:cloud_firestore/cloud_firestore.dart';

import 'evaluation_category.dart';
import 'evaluation_criterion.dart';
import 'resident_evaluation_enums.dart';

// Main evaluation form class
class ResidentEvaluation {
  // Basic information
  String? id;
  String rotationId;
  String supervisorId;
  String residentId;
  TrainingLevel trainingLevel;
  TrainingType trainingType;

  // Evaluation categories
  List<EvaluationCategory> categories;

  // Overall competence
  EvaluationScore overallCompetence;

  // Additional information
  String additionalComments;
  DateTime? evaluationDate;
  String? residentSignature;
  DateTime? residentSignatureDate;
  String? supervisorSignature;
  DateTime? supervisorSignatureDate;
  bool isCompleted;

  ResidentEvaluation({
    this.id,
    this.rotationId = '',
    this.supervisorId = '',
    this.residentId = '',
    this.trainingLevel = TrainingLevel.r1,
    this.trainingType = TrainingType.residency,
    List<EvaluationCategory>? categories,
    this.overallCompetence = EvaluationScore.notApplicable,
    this.additionalComments = '',
    this.evaluationDate,
    this.residentSignature,
    this.residentSignatureDate,
    this.supervisorSignature,
    this.supervisorSignatureDate,
    this.isCompleted = false,
  }) : categories = categories ?? _getDefaultCategories();

  // Calculate overall average score
  double get overallAverageScore {
    if (categories.isEmpty) return 0.0;
    final averages = categories.map((c) => c.averageScore).toList();
    return averages.reduce((a, b) => a + b) / averages.length;
  }

  // Check if form is valid for submission
  bool get isValidForSubmission {
    return rotationId.isNotEmpty &&
        supervisorId.isNotEmpty &&
        residentId.isNotEmpty;
  }

  // Get training level display string
  String get trainingLevelDisplay {
    final levelMap = {
      TrainingLevel.r1: 'R1',
      TrainingLevel.r2: 'R2',
      TrainingLevel.r3: 'R3',
      TrainingLevel.r4: 'R4',
      TrainingLevel.r5: 'R5',
      TrainingLevel.f1: 'F1',
      TrainingLevel.f2: 'F2',
      TrainingLevel.f3: 'F3',
    };
    return levelMap[trainingLevel] ?? '';
  }

  Map<String, dynamic> toJson() => {
    'rotationId': rotationId,
    'supervisorId': supervisorId,
    'residentId': residentId,
    'trainingLevel': trainingLevel.index,
    'trainingType': trainingType.index,
    'categories': categories.map((c) => c.toJson()).toList(),
    'overallCompetence': overallCompetence.value,
    'additionalComments': additionalComments,
    'evaluationDate': evaluationDate?.toIso8601String(),
    'residentSignature': residentSignature,
    'residentSignatureDate': residentSignatureDate?.toIso8601String(),
    'supervisorSignature': supervisorSignature,
    'supervisorSignatureDate': supervisorSignatureDate?.toIso8601String(),
    'isCompleted': isCompleted,
  };

  factory ResidentEvaluation.fromJson(Map<String, dynamic> json) {
    return ResidentEvaluation(
      id: json['id'],
      rotationId: json['rotationId'] ?? '',
      supervisorId: json['supervisorId'] ?? '',
      residentId: json['residentId'] ?? '',
      trainingLevel: TrainingLevel.values[json['trainingLevel'] ?? 0],
      trainingType: TrainingType.values[json['trainingType'] ?? 0],
      categories: (json['categories'] as List?)
          ?.map((c) => EvaluationCategory.fromJson(c))
          .toList(),
      overallCompetence: EvaluationScore.values.firstWhere(
        (s) => s.value == json['overallCompetence'],
        orElse: () => EvaluationScore.notApplicable,
      ),
      additionalComments: json['additionalComments'] ?? '',
      evaluationDate: json['evaluationDate'] != null
          ? DateTime.parse(json['evaluationDate'])
          : null,
      residentSignature: json['residentSignature'],
      residentSignatureDate: json['residentSignatureDate'] != null
          ? DateTime.parse(json['residentSignatureDate'])
          : null,
      supervisorSignature: json['supervisorSignature'],
      supervisorSignatureDate: json['supervisorSignatureDate'] != null
          ? DateTime.parse(json['supervisorSignatureDate'])
          : null,
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  factory ResidentEvaluation.fromFirebase(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ResidentEvaluation.fromJson({'id': doc.id, ...data});
  }

  // Create a copy of the form
  ResidentEvaluation copyWith({
    String? id,
    String? program,
    String? rotationId,
    String? supervisorId,
    String? site,
    String? residentId,
    TrainingLevel? trainingLevel,
    TrainingType? trainingType,
    List<EvaluationCategory>? categories,
    EvaluationScore? overallCompetence,
    String? additionalComments,
    DateTime? evaluationDate,
    String? residentSignature,
    DateTime? residentSignatureDate,
    String? supervisorSignature,
    DateTime? supervisorSignatureDate,
    bool? isCompleted,
  }) {
    return ResidentEvaluation(
      id: id ?? this.id,
      rotationId: rotationId ?? this.rotationId,
      supervisorId: supervisorId ?? this.supervisorId,
      residentId: residentId ?? this.residentId,
      trainingLevel: trainingLevel ?? this.trainingLevel,
      trainingType: trainingType ?? this.trainingType,
      categories: categories ?? this.categories,
      overallCompetence: overallCompetence ?? this.overallCompetence,
      additionalComments: additionalComments ?? this.additionalComments,
      evaluationDate: evaluationDate ?? this.evaluationDate,
      residentSignature: residentSignature ?? this.residentSignature,
      residentSignatureDate:
          residentSignatureDate ?? this.residentSignatureDate,
      supervisorSignature: supervisorSignature ?? this.supervisorSignature,
      supervisorSignatureDate:
          supervisorSignatureDate ?? this.supervisorSignatureDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Default categories based on the form template
  static List<EvaluationCategory> _getDefaultCategories() {
    return [
      EvaluationCategory(
        title: 'Medical Expert',
        criteria: [
          EvaluationCriterion(
            name: 'basicScience',
            description: 'Basic science knowledge',
          ),
          EvaluationCriterion(
            name: 'clinicalKnowledge',
            description: 'Clinical knowledge',
          ),
          EvaluationCriterion(
            name: 'dataGathering',
            description: 'Data gathering (History and physical examination)',
          ),
          EvaluationCriterion(
            name: 'ancillaryTests',
            description: 'Choice and use of ancillary tests (e.g. Lab. Tests)',
          ),
          EvaluationCriterion(
            name: 'clinicalJudgment',
            description: 'Soundness of judgment and clinical decision',
          ),
          EvaluationCriterion(
            name: 'emergencyPerformance',
            description: 'Performance under emergency conditions',
          ),
          EvaluationCriterion(
            name: 'selfAssessment',
            description: 'Self-assessment ability (insight)',
          ),
          EvaluationCriterion(
            name: 'procedures',
            description:
                'Performs diagnostic and therapeutic procedures required in the rotationId',
          ),
          EvaluationCriterion(
            name: 'patientSafety',
            description: 'Minimizes risk and discomfort to patients',
          ),
        ],
      ),
      EvaluationCategory(
        title: 'Communicator',
        criteria: [
          EvaluationCriterion(
            name: 'therapeuticRelationship',
            description:
                'Establishes therapeutic relationship with patients/families',
          ),
          EvaluationCriterion(
            name: 'patientInformation',
            description:
                'Delivers understandable information to patients/families',
          ),
          EvaluationCriterion(
            name: 'professionalRelationship',
            description:
                'Maintains professional relationship with other health care providers',
          ),
          EvaluationCriterion(
            name: 'counseling',
            description: 'Provides effective counseling to patients/families',
          ),
          EvaluationCriterion(
            name: 'documentation',
            description: 'Provides clear and complete records and reports',
          ),
        ],
      ),
      EvaluationCategory(
        title: 'Collaborator',
        criteria: [
          EvaluationCriterion(
            name: 'acceptsOpinions',
            description:
                'Demonstrates ability to accept, and respects opinions of others',
          ),
          EvaluationCriterion(
            name: 'teamwork',
            description: 'Work effectively in a team environment',
          ),
          EvaluationCriterion(
            name: 'consultation',
            description:
                'Consults effectively with other physician and healthcare providers',
          ),
        ],
      ),
      EvaluationCategory(
        title: 'Manager',
        criteria: [
          EvaluationCriterion(
            name: 'timeManagement',
            description: 'Manages time effectively',
          ),
          EvaluationCriterion(
            name: 'resourceAllocation',
            description: 'Allocates health care resources effectively',
          ),
          EvaluationCriterion(
            name: 'organizationWork',
            description: 'Works effectively in a health care organization',
          ),
          EvaluationCriterion(
            name: 'informationTechnology',
            description: 'Utilizes information technology effectively',
          ),
          EvaluationCriterion(
            name: 'evidenceBasedMedicine',
            description: 'Practices evidence-based medicine',
          ),
        ],
      ),
      EvaluationCategory(
        title: 'Health Advocate',
        criteria: [
          EvaluationCriterion(
            name: 'preventiveMeasures',
            description: 'Is attentive to preventive measures',
          ),
          EvaluationCriterion(
            name: 'publicHealth',
            description: 'Is attentive to issue of public health',
          ),
          EvaluationCriterion(
            name: 'patientAdvocacy',
            description: 'Advocates on behalf of patients',
          ),
          EvaluationCriterion(
            name: 'decisionMaking',
            description: 'Involve patients/families in decision making',
          ),
        ],
      ),
      EvaluationCategory(
        title: 'Scholar',
        criteria: [
          EvaluationCriterion(
            name: 'learningEvents',
            description:
                'Attends and contribute to rounds, seminars and learning events',
          ),
          EvaluationCriterion(
            name: 'feedback',
            description: 'Accepts and acts on constructive feedback',
          ),
          EvaluationCriterion(
            name: 'evidenceBasedApproach',
            description:
                'Takes an evidence-based approach to the management of problems',
          ),
          EvaluationCriterion(
            name: 'education',
            description:
                'Contributes to the education of other residents, and health care professionals',
          ),
        ],
      ),
      EvaluationCategory(
        title: 'Professional',
        criteria: [
          EvaluationCriterion(
            name: 'recognizesLimitations',
            description: 'Recognizes limitations and seeks advice when needed',
          ),
          EvaluationCriterion(
            name: 'responsibility',
            description:
                'Discharges duties and assignments responsibly and in timely manner',
          ),
          EvaluationCriterion(
            name: 'honesty',
            description: 'Report facts accurately, including own errors',
          ),
          EvaluationCriterion(
            name: 'boundaries',
            description:
                'Maintains appropriate boundaries in work and learning situations',
          ),
          EvaluationCriterion(
            name: 'punctuality',
            description:
                'Attend duties and report to work regularly (Punctuality)',
          ),
        ],
      ),
    ];
  }
}
