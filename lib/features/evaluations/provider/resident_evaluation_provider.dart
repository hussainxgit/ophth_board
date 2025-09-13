import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/features/evaluations/model/resident_evaluation/resident_evaluation.dart';
import 'package:ophth_board/features/evaluations/model/resident_evaluation/resident_evaluation_enums.dart';
import 'package:ophth_board/features/evaluations/repository/resident_evaluation_repository.dart';

import '../model/resident_evaluation/evaluation_category.dart';
import '../model/resident_evaluation/evaluation_criterion.dart';

// Define a StateNotifier for our evaluation state
class ResidentEvaluationNotifier
    extends StateNotifier<ResidentEvaluationState> {
  final ResidentEvaluationRepository _repository;

  ResidentEvaluationNotifier(this._repository)
    : super(ResidentEvaluationState.initial());

  void createNewEvaluation() {
    state = ResidentEvaluationState(
      currentEvaluation: ResidentEvaluation.initial(),
      isLoading: false,
      errorMessage: null,
    );
  }

  Future<void> loadEvaluation(String evaluationId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final evaluation = await _repository.getEvaluationById(evaluationId);
      state = state.copyWith(currentEvaluation: evaluation, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  void updateEvaluationField<T>(T value, String fieldName) {
    if (state.currentEvaluation == null) return;

    ResidentEvaluation updatedEvaluation = state.currentEvaluation!;

    // Using copyWith for a more robust update
    if (fieldName == 'rotationId') {
      updatedEvaluation = updatedEvaluation.copyWith(
        rotationId: value as String,
      );
    } else if (fieldName == 'supervisorId') {
      updatedEvaluation = updatedEvaluation.copyWith(
        supervisorId: value as String,
      );
    } else if (fieldName == 'residentId') {
      updatedEvaluation = updatedEvaluation.copyWith(
        residentId: value as String,
      );
    } else if (fieldName == 'trainingLevel') {
      updatedEvaluation = updatedEvaluation.copyWith(
        trainingLevel: value as TrainingLevel,
      );
    } else if (fieldName == 'trainingType') {
      updatedEvaluation = updatedEvaluation.copyWith(
        trainingType: value as TrainingType,
      );
    } else if (fieldName == 'overallCompetence') {
      updatedEvaluation = updatedEvaluation.copyWith(
        overallCompetence: value as EvaluationScore,
      );
    } else if (fieldName == 'additionalComments') {
      updatedEvaluation = updatedEvaluation.copyWith(
        additionalComments: value as String,
      );
    } else if (fieldName == 'residentName') {
      updatedEvaluation = updatedEvaluation.copyWith(
        residentName: value as String,
      );}

    // Add more fields as needed

    state = state.copyWith(currentEvaluation: updatedEvaluation);
  }

  void updateCategoryScore(
    int categoryIndex,
    int criterionIndex,
    EvaluationScore score,
  ) {
    if (state.currentEvaluation != null &&
        state.currentEvaluation!.categories.length > categoryIndex &&
        state.currentEvaluation!.categories[categoryIndex].criteria.length >
            criterionIndex) {
      final List<EvaluationCategory> updatedCategories = List.from(
        state.currentEvaluation!.categories,
      );
      final EvaluationCategory categoryToUpdate =
          updatedCategories[categoryIndex];
      final List<EvaluationCriterion> updatedCriteria = List.from(
        categoryToUpdate.criteria,
      );

      updatedCriteria[criterionIndex] = updatedCriteria[criterionIndex]
          .copyWith(score: score);
      updatedCategories[categoryIndex] = categoryToUpdate.copyWith(
        criteria: updatedCriteria,
      );

      state = state.copyWith(
        currentEvaluation: state.currentEvaluation!.copyWith(
          categories: updatedCategories,
        ),
      );
    }
  }

  Future<bool> saveEvaluation() async {
    if (state.currentEvaluation == null ||
        !state.currentEvaluation!.isValidForSubmission) {
      state = state.copyWith(errorMessage: 'Please fill all required fields.');
      return false;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.saveEvaluation(state.currentEvaluation!);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
      return false;
    }
  }
}

// Define the state class
class ResidentEvaluationState {
  final ResidentEvaluation? currentEvaluation;
  final bool isLoading;
  final String? errorMessage;

  ResidentEvaluationState({
    this.currentEvaluation,
    this.isLoading = false,
    this.errorMessage,
  });

  factory ResidentEvaluationState.initial() {
    return ResidentEvaluationState(
      currentEvaluation:
          null, // Or ResidentEvaluation() if you want to start with a new one
      isLoading: false,
      errorMessage: null,
    );
  }

  ResidentEvaluationState copyWith({
    ResidentEvaluation? currentEvaluation,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ResidentEvaluationState(
      currentEvaluation: currentEvaluation ?? this.currentEvaluation,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Create a provider
final residentEvaluationProvider =
    StateNotifierProvider<ResidentEvaluationNotifier, ResidentEvaluationState>((
      ref,
    ) {
      final repository = ref.read(residentEvaluationRepositoryProvider);
      return ResidentEvaluationNotifier(repository);
    });

final getAllEvaluationsForRotationProvider =
    FutureProvider.family<List<ResidentEvaluation>, String>((
      ref,
      rotationId,
    ) async {
      final repository = ref.read(residentEvaluationRepositoryProvider);
      return repository.getAllEvaluationsForRotation(rotationId);
    });
    
/// Provider to fetch resident evaluation
final supervisorActiveRotationsProviderForResidents = FutureProvider.family<ResidentEvaluation?, String>((
  ref,
  evaluationId,
) async {
  print('Provider Fetching evaluation: $evaluationId');
  final repository = ref.watch(residentEvaluationRepositoryProvider);
  return repository.getEvaluationById(evaluationId);
});

// get evaluations for a resident
final getAllEvaluationsForResidentProvider =
    FutureProvider.family<List<ResidentEvaluation>, String>((
      ref,
      residentId,
    ) async {
      final repository = ref.read(residentEvaluationRepositoryProvider);
      return repository.getAllEvaluationsForResident(residentId);
    });