import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/features/content_entries/model/announcement.dart';
import 'package:ophth_board/core/models/result.dart';

import '../repositories/announcements_repository.dart';

class AnnouncementNotifier
    extends StateNotifier<AsyncValue<List<Announcement>>> {
  final AnnouncementsRepository _repository;

  AnnouncementNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadAnnouncements();
  }

  Future<void> loadAnnouncements() async {
    state = const AsyncValue.loading();
    final result = await _repository.fetchAnnouncementsEntries();

    if (result.isSuccess) {
      final announcements = result.data!
          .map((entry) => Announcement.fromMap(entry, entry['id'] as String))
          .toList();
      state = AsyncValue.data(announcements);
    } else {
      state = AsyncValue.error(
        result.errorMessage ?? 'Failed to load announcements',
        StackTrace.current,
      );
    }
  }

  Future<Result<void>> addAnnouncement(Announcement announcement) async {
    // Call your existing repository
    final result = await _repository.addAnnouncementsEntry(announcement.toMap());
    announcement = announcement.copyWith(id: result.data!['id']);

    if (result.isSuccess) {
      // Update local state immediately (no refetch needed)
      state.whenData((currentList) {
        final updatedList = [...currentList, announcement];
        // Sort by creation date (newest first)
        updatedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        state = AsyncValue.data(updatedList);
      });
    }
    return result;
  }

  Future<Result<void>> updateAnnouncement(
    Announcement updatedAnnouncement,
  ) async {
    final result = await _repository.updateAnnouncementsEntry(
      updatedAnnouncement.id,
      updatedAnnouncement.toMap(),
    );

    if (result.isSuccess) {
      state.whenData((currentList) {
        final updatedList = currentList.map((ann) {
          return ann.id == updatedAnnouncement.id ? updatedAnnouncement : ann;
        }).toList();
        state = AsyncValue.data(updatedList);
      });
    }

    return result;
  }

  Future<Result<void>> deleteAnnouncement(String id) async {
    final result = await _repository.deleteAnnouncementsEntry(id);

    if (result.isSuccess) {
      state.whenData((currentList) {
        final updatedList = currentList.where((ann) => ann.id != id).toList();
        state = AsyncValue.data(updatedList);
      });
    }
    return result;
  }

  void refresh() {
    loadAnnouncements();
  }
}

// Provider for the announcement state
final announcementProvider =
    StateNotifierProvider<AnnouncementNotifier, AsyncValue<List<Announcement>>>(
      (ref) => AnnouncementNotifier(ref.watch(announcementsProvider)),
    );
