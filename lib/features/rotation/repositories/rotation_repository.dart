import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/core/utils/boali_date_extenstions.dart';

import '../../../core/firebase/firebase_service.dart';
import '../model/rotation.dart';

class RotationRepository {
  final FirestoreService _firestoreService;
  static const String _collectionPath = 'rotations';

  RotationRepository(this._firestoreService);

  // Method to get all rotations from Firestore
  Future<List<Rotation>> getAllRotations() async {
    try {
      final querySnapshot = await _firestoreService.getCollection(
        _collectionPath,
      );
      return querySnapshot.docs
          .map((doc) => Rotation.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Error fetching rotations: $e';
    }
  }

  // Method to get a stream of all rotations
  Stream<List<Rotation>> getRotationsStream() {
    try {
      return _firestoreService
          .getCollectionStream(_collectionPath)
          .map(
            (querySnapshot) => querySnapshot.docs
                .map((doc) => Rotation.fromFirestore(doc))
                .toList(),
          );
    } catch (e) {
      throw 'Error streaming rotations: $e';
    }
  }

  // Method to get the current rotation for a given resident
  Future<Rotation?> getCurrentRotation(String residentId) async {
    try {
      final rotations = await getAllRotations();
      final now = DateTime.now();

      return rotations
          .where(
            (rotation) =>
                rotation.assignedResidents.contains(residentId) &&
                rotation.startDate.isBefore(now) &&
                rotation.endDate.isAfter(now),
          )
          .firstOrNull;
    } catch (e) {
      return null;
    }
  }

  // Method to get upcoming, current, and past rotations for a given resident
  Future<List<Rotation>> getRotationsForResident(String residentId) async {
    try {
      final rotations = await getAllRotations();
    return rotations
      .where((rotation) => rotation.assignedResidents.contains(residentId))
      .toList();
    } catch (e) {
      throw 'Error fetching rotations for resident: $e';
    }
  }

  Future<List<Rotation>> getUpcomingRotations(String residentId) async {
    try {
      final rotations = await getAllRotations();
      final now = DateTime.now();

    return rotations
      .where(
      (rotation) =>
        rotation.assignedResidents.contains(residentId) &&
        rotation.startDate.isAfter(now),
      )
      .toList();
    } catch (e) {
      throw 'Error fetching upcoming rotations: $e';
    }
  }

  Future<List<Rotation>> getPastRotations(String residentId) async {
    try {
      final rotations = await getAllRotations();
      final now = DateTime.now();

    return rotations
      .where(
      (rotation) =>
        rotation.assignedResidents.contains(residentId) &&
        rotation.endDate.isBefore(now),
      )
      .toList();
    } catch (e) {
      throw 'Error fetching past rotations: $e';
    }
  }

  // Method to add a new rotation
  Future<DocumentReference> addRotation(Rotation rotation) async {
    try {
      return await _firestoreService.addDocument(
        _collectionPath,
        rotation.toFirestore(),
      );
    } catch (e) {
      throw 'Error adding rotation: $e';
    }
  }

  // Method to update a rotation
  Future<void> updateRotation(String rotationId, Rotation rotation) async {
    try {
      await _firestoreService.updateDocument(
        _collectionPath,
        rotationId,
        rotation.toFirestore(),
      );
    } catch (e) {
      throw 'Error updating rotation: $e';
    }
  }

  // Method to delete a rotation
  Future<void> deleteRotation(String rotationId) async {
    try {
      await _firestoreService.deleteDocument(_collectionPath, rotationId);
    } catch (e) {
      throw 'Error deleting rotation: $e';
    }
  }

  Future<List<Rotation>> getSupervisorActiveRotations(
    String superviorId,
  ) async {
    try {
      final rotations = await getAllRotations();
    return rotations
      .where(
      (rotation) =>
        rotation.assignedSupervisors.contains(superviorId) &&
        rotation.startDate.isStarted(),
      )
      .toList();
    } catch (e) {
      throw 'Error fetching supervisor active rotations: $e';
    }
  }


}

final rotationRepositoryProvider = Provider<RotationRepository>((ref) {
  final firestoreService = ref.read(firestoreServiceProvider);
  return RotationRepository(firestoreService);
});
