import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/core/firebase/firebase_service.dart';

import '../../../core/models/result.dart';

class NoticeBoardRepository {
  final FirestoreService _firestoreService;

  NoticeBoardRepository(this._firestoreService);

  Future<Result<List<Map<String, dynamic>>>> fetchNoticeBoardEntries() async {
    print('Fetching notice board entries...');
    try {
      final snapshot = await _firestoreService.getCollection('notice_board');
      final entries = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
      return Result.success(entries);
    } catch (e) {
      return Result.error('Failed to fetch notice board entries: $e');
    }
  }

  Future<Result<Map<String, dynamic>>> addNoticeBoardEntry(
    Map<String, dynamic> entryData,
  ) async {
    try {
      final docRef = await _firestoreService.addDocument(
        'notice_board',
        entryData,
      );
      final addedEntry = {'id': docRef.id, ...entryData};
      return Result.success(addedEntry);
    } catch (e) {
      return Result.error('Failed to add notice board entry: $e');
    }
  }

  Future<Result<void>> deleteNoticeBoardEntry(String documentId) async {
    try {
      await _firestoreService.deleteDocument('notice_board', documentId);
      return Result.success(null);
    } catch (e) {
      return Result.error('Failed to delete notice board entry: $e');
    }
  }

  Future<Result<void>> updateNoticeBoardEntry(
    String documentId,
    Map<String, dynamic> updatedData,
  ) async {
    try {
      await _firestoreService.updateDocument(
        'notice_board',
        documentId,
        updatedData,
      );
      return Result.success(null);
    } catch (e) {
      return Result.error('Failed to update notice board entry: $e');
    }
  }
}

// notice board provider
final noticeBoardRepositoryProvider = Provider<NoticeBoardRepository>(
  (ref) => NoticeBoardRepository(ref.watch(firestoreServiceProvider)),
);
