import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/core/firebase/firebase_service.dart';

import '../../../core/models/result.dart';

class PostRepository {
  final FirestoreService _firestoreService;

  PostRepository(this._firestoreService);

  Future<Result<List<Map<String, dynamic>>>> fetchPostEntries() async {
    print('Fetching posts entries...');
    try {
      final snapshot = await _firestoreService.getCollection('posts');
      final entries = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
      return Result.success(entries);
    } catch (e) {
      return Result.error('Failed to fetch posts entries: $e');
    }
  }

  Future<Result<Map<String, dynamic>>> addPostEntry(
    Map<String, dynamic> entryData,
  ) async {
    try {
      final docRef = await _firestoreService.addDocument(
        'posts',
        entryData,
      );
      final addedEntry = {'id': docRef.id, ...entryData};
      return Result.success(addedEntry);
    } catch (e) {
      return Result.error('Failed to add posts entry: $e');
    }
  }

  Future<Result<void>> deletePostEntry(String documentId) async {
    try {
      await _firestoreService.deleteDocument('posts', documentId);
      return Result.success(null);
    } catch (e) {
      return Result.error('Failed to delete posts entry: $e');
    }
  }

  Future<Result<void>> updatePostEntry(
    String documentId,
    Map<String, dynamic> updatedData,
  ) async {
    try {
      await _firestoreService.updateDocument(
        'posts',
        documentId,
        updatedData,
      );
      return Result.success(null);
    } catch (e) {
      return Result.error('Failed to update posts entry: $e');
    }
  }
}

// posts provider
final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepository(ref.watch(firestoreServiceProvider)),
);
