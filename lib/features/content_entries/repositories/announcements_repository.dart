import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_service.dart';
import '../../../core/models/result.dart';

class AnnouncementsRepository {
  final FirestoreService _firestoreService;

  AnnouncementsRepository(this._firestoreService);

  Future<Result<List<Map<String, dynamic>>>> fetchAnnouncementsEntries() async {
    print('Fetching announcements entries...');
    try {
      final snapshot = await _firestoreService.getCollection('announcements');
      final entries = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
      return Result.success(entries);
    } catch (e) {
      return Result.error('Failed to announcements entries: $e');
    }
  }

  Future<Result<Map<String, dynamic>>> addAnnouncementsEntry(
    Map<String, dynamic> entryData,
  ) async {
    try {
      final docRef = await _firestoreService.addDocument(
        'announcements',
        entryData,
      );
      final addedEntry = {'id': docRef.id, ...entryData};
      return Result.success(addedEntry);
    } catch (e) {
      return Result.error('Failed to add announcements entry: $e');
    }
  }

  Future<Result<void>> deleteAnnouncementsEntry(String documentId) async {
    try {
      await _firestoreService.deleteDocument('announcements', documentId);
      return Result.success(null);
    } catch (e) {
      return Result.error('Failed to delete announcements entry: $e');
    }
  }

  Future<Result<void>> updateAnnouncementsEntry(
    String documentId,
    Map<String, dynamic> updatedData,
  ) async {                            
    try {
      await _firestoreService.updateDocument(
        'announcements',
        documentId,
        updatedData,
      );
      return Result.success(null);
    } catch (e) {
      return Result.error('Failed to update announcements entry: $e');
    }
  }
}

// notice board provider
final announcementsProvider = Provider<AnnouncementsRepository>(
  (ref) => AnnouncementsRepository(ref.watch(firestoreServiceProvider)),
);
