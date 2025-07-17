import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/features/content_entries/model/notice_board.dart';
import 'package:ophth_board/features/content_entries/repositories/notice_board_repository.dart';
import 'package:ophth_board/core/models/result.dart';

class NoticeBoardNotifier extends StateNotifier<AsyncValue<List<NoticeBoard>>> {
  final NoticeBoardRepository _repository;

  NoticeBoardNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadNoticeBoards();
  }

  Future<void> loadNoticeBoards() async {
    state = const AsyncValue.loading();
    final result = await _repository.fetchNoticeBoardEntries();
    
    if (result.isSuccess) {
      final noticeBoards = result.data!
          .map((entry) => NoticeBoard.fromMap(entry, entry['id'] as String))
          .toList();
      state = AsyncValue.data(noticeBoards);
    } else {
      state = AsyncValue.error(
        result.errorMessage ?? 'Failed to load notice boards',
        StackTrace.current,
      );
    }
  }

  Future<Result<void>> addNoticeBoard(NoticeBoard noticeBoard) async {
    // Call your existing repository
    final result = await _repository.addNoticeBoardEntry(noticeBoard.toMap());
    noticeBoard = noticeBoard.copyWith(id: result.data!['id']);
    
    if (result.isSuccess) {
      // Update local state immediately (no refetch needed)
      state.whenData((currentList) {
        final updatedList = [...currentList, noticeBoard];
        // Sort by creation date (newest first)
        updatedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        state = AsyncValue.data(updatedList);
      });
    }
    
    return result;
  }

  Future<Result<void>> updateNoticeBoard(NoticeBoard updatedNoticeBoard) async {
    final result = await _repository.updateNoticeBoardEntry(
      updatedNoticeBoard.id,
      updatedNoticeBoard.toMap(),
    );
    
    if (result.isSuccess) {
      state.whenData((currentList) {
        final updatedList = currentList.map((notice) {
          return notice.id == updatedNoticeBoard.id ? updatedNoticeBoard : notice;
        }).toList();
        state = AsyncValue.data(updatedList);
      });
    }
    
    return result;
  }

  Future<Result<void>> deleteNoticeBoard(String id) async {
    final result = await _repository.deleteNoticeBoardEntry(id);
    
    if (result.isSuccess) {
      state.whenData((currentList) {
        final updatedList = currentList.where((notice) => notice.id != id).toList();
        state = AsyncValue.data(updatedList);
      });
    }
    
    return result;
  }

  void refresh() {
    loadNoticeBoards();
  }
}

// Provider for the notice board state
final noticeBoardProvider = StateNotifierProvider<NoticeBoardNotifier, AsyncValue<List<NoticeBoard>>>(
  (ref) => NoticeBoardNotifier(ref.watch(noticeBoardRepositoryProvider)),
);