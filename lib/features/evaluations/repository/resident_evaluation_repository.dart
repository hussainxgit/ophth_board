import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/features/evaluations/model/resident_evaluation/resident_evaluation.dart';

import '../../../core/firebase/firebase_service.dart';

class ResidentEvaluationRepository {
  final FirestoreService _firestoreService;
  static const String _collectionPath = 'resident_evaluations';

  ResidentEvaluationRepository(this._firestoreService);

  Future<void> saveEvaluation(ResidentEvaluation evaluation) async {
    try {
      // Assuming you have a collection named 'resident_evaluations'
      await _firestoreService.addDocument(_collectionPath, evaluation.toJson());
    } catch (e) {
      // Handle errors, e.g., log them or throw a custom exception
      print('Error saving evaluation: $e');
      rethrow;
    }
  }

  Future<ResidentEvaluation?> getEvaluationById(String id) async {
    try {
      final docSnapshot = await _firestoreService.getDocument(
        _collectionPath,
        id,
      );
      if (docSnapshot.exists) {
        return ResidentEvaluation.fromFirebase(docSnapshot);
      }
      return null;
    } catch (e) {
      print('Error fetching evaluation: $e');
      rethrow;
    }
  }

  Future<void> updateEvaluation(
    String id,
    ResidentEvaluation evaluation,
  ) async {
    try {
      await _firestoreService.updateDocument(
        _collectionPath,
        id,
        evaluation.toJson(),
      );
    } catch (e) {
      print('Error updating evaluation: $e');
      rethrow;
    }
  }

  Future<void> deleteEvaluation(String id) async {
    try {
      await _firestoreService.deleteDocument(_collectionPath, id);
    } catch (e) {
      print('Error deleting evaluation: $e');
      rethrow;
    }
  }

  Future<List<ResidentEvaluation>> getAllEvaluationsForRotation(
    String rotationId,
  ) async {
    try {
      final querySnapshot = await _firestoreService.getCollectionWithQuery(
        _collectionPath,
        filters: [
          QueryFilter(
            field: 'rotationId',
            type: FilterType.isEqualTo,
            value: rotationId,
          ),
        ],
      );
      return querySnapshot.docs
          .map((doc) => ResidentEvaluation.fromFirebase(doc))
          .toList();
    } catch (e) {
      print('Error fetching evaluations: $e');
      rethrow;
    }
  }
}

final residentEvaluationRepositoryProvider =
    Provider<ResidentEvaluationRepository>((ref) {
      final firestoreService = ref.read(firestoreServiceProvider);
      return ResidentEvaluationRepository(firestoreService);
    });
