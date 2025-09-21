import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import '../model/supervisor.dart';
import '../../../core/firebase/firebase_service.dart';

class SupervisorIdList {
  final List<String> ids;
  const SupervisorIdList(this.ids);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SupervisorIdList) return false;
    return const ListEquality().equals(ids, other.ids);
  }

  @override
  int get hashCode => const ListEquality().hash(ids);
}

final getSupervisorsByIdProvider =
    FutureProvider.family<List<Supervisor>, SupervisorIdList>((ref, ids) async {
  final firestore = ref.watch(firestoreServiceProvider);
  final docs = await firestore.getDocumentsByIds('users', ids.ids);
  return docs.map((d) => Supervisor.fromFirestore(d)).toList();
});
