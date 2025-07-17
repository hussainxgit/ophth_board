import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/features/content_entries/model/post.dart';
import 'package:ophth_board/core/models/result.dart';
import '../repositories/posts_repository.dart';

class PostNotifier
    extends StateNotifier<AsyncValue<List<Post>>> {
  final PostRepository _repository;

  PostNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadPosts();
  }

  Future<void> loadPosts() async {
    state = const AsyncValue.loading();
    final result = await _repository.fetchPostEntries();

    if (result.isSuccess) {
      final announcements = result.data!
          .map((entry) => Post.fromJson(entry, id: entry['id']))
          .toList();
      state = AsyncValue.data(announcements);
    } else {
      state = AsyncValue.error(
        result.errorMessage ?? 'Failed to load announcements',
        StackTrace.current,
      );
    }
  }

  Future<Result<void>> addPost(Post post) async {
    // Call your existing repository
    final result = await _repository.addPostEntry(
      post.toJson(),
    );
    post = post.copyWith(id: result.data!['id']);

    if (result.isSuccess) {
      // Update local state immediately (no refetch needed)
      state.whenData((currentList) {
        final updatedList = [...currentList, post];
        // Sort by creation date (newest first)
        state = AsyncValue.data(updatedList);
      });
    }
    return result;
  }

  Future<Result<void>> updatePost(
    Post updatedPost,
  ) async {
    final result = await _repository.updatePostEntry(
      updatedPost.id,
      updatedPost.toJson(),
    );

    if (result.isSuccess) {
      state.whenData((currentList) {
        final updatedList = currentList.map((ann) {
          return ann.id == updatedPost.id ? updatedPost : ann;
        }).toList();
        state = AsyncValue.data(updatedList);
      });
    }

    return result;
  }

  Future<Result<void>> deletePost(String id) async {
    final result = await _repository.deletePostEntry(id);

    if (result.isSuccess) {
      state.whenData((currentList) {
        final updatedList = currentList.where((ann) => ann.id != id).toList();
        state = AsyncValue.data(updatedList);
      });
    }
    return result;
  }

  void refresh() {
    loadPosts();
  }
}

// Provider for the post state
final postProvider =
    StateNotifierProvider<PostNotifier, AsyncValue<List<Post>>>(
      (ref) => PostNotifier(ref.watch(postRepositoryProvider)),
    );
