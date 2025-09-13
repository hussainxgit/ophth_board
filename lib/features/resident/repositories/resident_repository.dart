import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_service.dart';
import '../model/resident.dart';

class ResidentRepository {
  final FirestoreService _firestoreService;
  static const String _collectionPath = 'users';

  ResidentRepository(this._firestoreService);

  Future<List<Resident>> getAllResidents() async {
    try {
      final querySnapshot = await _firestoreService.getCollectionWithQuery(
        _collectionPath,
        filters: [
          QueryFilter(
            field: 'role',
            type: FilterType.isEqualTo,
            value: 'resident',
          ),
        ],
      );
      return querySnapshot.docs
          .map((doc) => Resident.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Error fetching residents: $e';
    }
  }

  Future<List<Resident>> getResidentsById(List<String> ids) async {
    try {
      print('fetching getResidentsById with ids: $ids');

      // Handle empty list case
      if (ids.isEmpty) {
        return [];
      }

      // Use the new method that directly handles document ID queries
      final documents = await _firestoreService.getDocumentsByIds(
        _collectionPath,
        ids,
      );

      print('Found ${documents.length} residents');

      // Filter out documents that don't exist and convert to Resident objects
      final residents = documents
          .where((doc) => doc.exists)
          .map((doc) => Resident.fromFirestore(doc))
          .toList();

      print('Successfully converted ${residents.length} residents');
      return residents;
    } catch (e) {
      print('Error in getResidentsById: $e');
      throw 'Error fetching getResidentsById: $e';
    }
  }
}

final residentRepositoryProvider = Provider<ResidentRepository>((ref) {
  final firestoreService = ref.read(firestoreServiceProvider);
  return ResidentRepository(firestoreService);
});
