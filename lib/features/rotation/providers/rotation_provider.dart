import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/rotation.dart';
import '../repositories/rotation_repository.dart';

/// Notifier responsible for managing the list of rotations for a specific resident.
class ResidentRotationsNotifier
    extends StateNotifier<AsyncValue<List<Rotation>>> {
  final RotationRepository _rotationRepository;
  final String _residentId;

  ResidentRotationsNotifier(this._rotationRepository, this._residentId)
    : super(const AsyncValue.loading()) {
    _fetchRotations();
  }

  Future<void> _fetchRotations() async {
    state = const AsyncValue.loading();
    try {
      final rotations = await _rotationRepository.getRotationsForResident(
        _residentId,
      );
      state = AsyncValue.data(rotations);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Refetches the rotations for the resident.
  Future<void> refresh() async {
    await _fetchRotations();
  }
}

/// Provider for [ResidentRotationsNotifier].
final residentRotationsProvider =
    StateNotifierProvider.family<
      ResidentRotationsNotifier,
      AsyncValue<List<Rotation>>,
      String
    >((ref, residentId) {
      final repository = ref.watch(rotationRepositoryProvider);
      return ResidentRotationsNotifier(repository, residentId);
    });

/// Provider to get the current rotation for a specific resident.
final currentRotationProvider = FutureProvider.family<Rotation?, String>((
  ref,
  residentId,
) async {
  print('Provider Fetching current rotation for resident: $residentId');
  final repository = ref.watch(rotationRepositoryProvider);
  return repository.getCurrentRotation(residentId);
});

/// Provider to get upcoming rotations for a specific resident.
final upcomingRotationsProvider = FutureProvider.family<List<Rotation>, String>(
  (ref, residentId) async {
    final repository = ref.watch(rotationRepositoryProvider);
    return repository.getUpcomingRotations(residentId);
  },
);

/// Provider to get past rotations for a specific resident.
final pastRotationsProvider = FutureProvider.family<List<Rotation>, String>((
  ref,
  residentId,
) async {
  final repository = ref.watch(rotationRepositoryProvider);
  return repository.getPastRotations(residentId);
});

/// Provider to get all rotations as a stream.
final allRotationsStreamProvider = StreamProvider<List<Rotation>>((ref) {
  final repository = ref.watch(rotationRepositoryProvider);
  return repository.getRotationsStream();
});

/// Provider to fetch all active rotations for supervisor
final supervisorActiveRotationsProvider =
    FutureProvider.family<List<Rotation>, String>((ref, superviorId) async {
      final repository = ref.watch(rotationRepositoryProvider);
      return repository.getSupervisorActiveRotations(superviorId);
    });
