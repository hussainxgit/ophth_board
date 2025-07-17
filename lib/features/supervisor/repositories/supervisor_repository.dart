import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/features/supervisor/model/supervisor.dart';

import '../../../core/firebase/firebase_service.dart';

class SupervisorRepository {
  final FirestoreService _firestoreService;
  static const String _collectionPath = 'users';

  SupervisorRepository(this._firestoreService);

  Future<List<Supervisor>> getActiveSupervisors() async {
    try {
      final querySnapshot = await _firestoreService.getCollectionWithQuery(
        _collectionPath,
        filters: [
          QueryFilter(
            field: 'role',
            type: FilterType.isEqualTo,
            value: 'supervisor',
          ),
          QueryFilter(
            field: 'isActive',
            type: FilterType.isEqualTo,
            value: true,
          ),
        ],
      );
      return querySnapshot.docs.map((doc) {
        return Supervisor.fromFirestore(doc);
      }).toList();
    } catch (e) {
      throw 'Error fetching active supervisors: $e';
    }
  }
}

final supervisorRepositoryProvider = Provider<SupervisorRepository>((ref) {
  final firestoreService = ref.read(firestoreServiceProvider);
  return SupervisorRepository(firestoreService);
});
