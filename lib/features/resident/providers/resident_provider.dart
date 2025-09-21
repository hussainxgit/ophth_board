import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart'; // Add this import

import '../model/resident.dart';
import '../repositories/resident_repository.dart';

// Create a custom class that properly implements equality for the list parameter
class ResidentIdList {
  final List<String> ids;

  const ResidentIdList(this.ids);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ResidentIdList) return false;
    return const ListEquality().equals(ids, other.ids);
  }

  @override
  int get hashCode => const ListEquality().hash(ids);
}

// Updated provider using the custom class
final getResidentsByIdProvider =
    FutureProvider.family<List<Resident>, ResidentIdList>((
      ref,
      residentIdList,
    ) async {
      final repository = ref.watch(residentRepositoryProvider);
      return repository.getResidentsById(residentIdList.ids);
    });
final getResidentByIdProvider =
    FutureProvider.family<Resident?, String>((ref, residentId) async {
  final repository = ref.watch(residentRepositoryProvider);
  return repository.getResidentById(residentId);
});
