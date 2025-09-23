import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/firebase/firebase_service.dart';
import '../../../core/models/result.dart';
import '../model/signature.dart';

class SignatureRepository {
  final FirestoreService _firestoreService;
  
  static const String _collectionPath = 'signatures';

  SignatureRepository(this._firestoreService);

  /// Get all signatures for a specific user
  Stream<List<Signature>> getUserSignatures(String userId) {
    return _firestoreService
        .getCollectionStreamWithQuery(
          _collectionPath,
          filters: [
            QueryFilter(
              field: 'userId',
              type: FilterType.isEqualTo,
              value: userId,
            ),
          ],
          orderBy: [
            QueryOrder(
              field: 'createdAt',
              descending: true,
            ),
          ],
        )
        .map((snapshot) => snapshot.docs
            .map((doc) => Signature.fromFirestore(doc))
            .toList());
  }

  /// Get a specific signature by ID
  Future<Result<Signature?>> getSignatureById(String signatureId) async {
    try {
      final doc = await _firestoreService.getDocument(
        _collectionPath,
        signatureId,
      );
      
      if (doc.exists) {
        return Result.success(Signature.fromFirestore(doc));
      }
      return Result.success(null);
    } on FirebaseException catch (e) {
      return Result.error('Failed to get signature: ${e.message}');
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  /// Get user's signature (only one per user)
  Future<Result<Signature?>> getUserSignature(String userId) async {
    try {
      final query = await _firestoreService.getCollectionWithQuery(
        _collectionPath,
        filters: [
          QueryFilter(
            field: 'userId',
            type: FilterType.isEqualTo,
            value: userId,
          ),
        ],
        limit: 1,
      );
      
      if (query.docs.isNotEmpty) {
        return Result.success(Signature.fromFirestore(query.docs.first));
      }
      return Result.success(null);
    } on FirebaseException catch (e) {
      return Result.error('Failed to get signature: ${e.message}');
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  /// Create or update user's signature (only one per user)
  Future<Result<String>> createOrUpdateSignature({
    required String userId,
    required String svgData,
  }) async {
    try {
      // Check if user already has a signature
      final existingSignatureResult = await getUserSignature(userId);
      
      if (existingSignatureResult.isSuccess && existingSignatureResult.data != null) {
        // Update existing signature
        final existingSignature = existingSignatureResult.data!;
        await _firestoreService.updateDocument(
          _collectionPath,
          existingSignature.id,
          {
            'signatureStoragePath': svgData,
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          },
        );
        return Result.success(existingSignature.id);
      } else {
        // Create new signature
        final signature = Signature(
          id: '', // Will be set by Firestore
          userId: userId,
          signatureStoragePath: svgData,
          createdAt: DateTime.now(),
        );

        final docRef = await _firestoreService.addDocument(
          _collectionPath,
          signature.toFirestore(),
        );

        return Result.success(docRef.id);
      }
    } on FirebaseException catch (e) {
      return Result.error('Failed to save signature: ${e.message}');
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  /// Delete user's signature
  Future<Result<void>> deleteUserSignature(String userId) async {
    try {
      final signatureResult = await getUserSignature(userId);
      if (signatureResult.isSuccess && signatureResult.data != null) {
        await _firestoreService.deleteDocument(_collectionPath, signatureResult.data!.id);
      }
      return Result.success(null);
    } on FirebaseException catch (e) {
      return Result.error('Failed to delete signature: ${e.message}');
    } catch (e) {
      return Result.error('An unexpected error occurred: $e');
    }
  }

  /// Check if user has a signature
  Future<Result<bool>> hasSignature(String userId) async {
    try {
      final result = await getUserSignature(userId);
      return Result.success(result.isSuccess && result.data != null);
    } catch (e) {
      return Result.error('Failed to check signature: $e');
    }
  }
}