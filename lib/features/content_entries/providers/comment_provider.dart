import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/result.dart';
import '../model/comment_data.dart';
import '../repositories/comment_repository.dart';

class CommentNotifier extends StateNotifier<AsyncValue<List<CommentData>>> {
  final CommentRepository _repository;
  final String collectionName;
  final String documentId;

  CommentNotifier(this._repository, this.collectionName, this.documentId)
    : super(const AsyncValue.loading()) {
    loadComments();
  }

  Future<void> loadComments() async {
    state = const AsyncValue.loading();
    final result = await _repository.getComments(collectionName, documentId);

    if (result.isSuccess) {
      final comments = result.data!
          .map((entry) => CommentData.fromMap(entry))
          .toList();
      state = AsyncValue.data(comments);
    } else {
      state = AsyncValue.error(result.errorMessage!, StackTrace.current);
    }
  }

  Future<Result<void>> addComment(CommentData comment) async {
    final result = await _repository.addComment(
      collectionName,
      documentId,
      comment,
    );

    if (result.isSuccess) {
      // Update local state immediately
      state.whenData((currentComments) {
        final updatedComments = [comment, ...currentComments];
        state = AsyncValue.data(updatedComments);
      });
    }

    return result;
  }

  Future<Result<void>> updateComment(CommentData updatedComment) async {
    final result = await _repository.updateComment(
      collectionName,
      documentId,
      updatedComment,
    );

    if (result.isSuccess) {
      state.whenData((currentComments) {
        final updatedComments = currentComments.map((comment) {
          return comment.dateTime == updatedComment.dateTime ? updatedComment : comment;
        }).toList();
        state = AsyncValue.data(updatedComments);
      });
    }

    return result;
  }

  Future<Result<void>> deleteComment(String dateTime) async {
    final result = await _repository.deleteComment(
      collectionName,
      documentId,
      dateTime,
    );

    if (result.isSuccess) {
      state.whenData((currentComments) {
        final updatedComments = currentComments
            .where((comment) => comment.dateTime != dateTime)
            .toList();
        state = AsyncValue.data(updatedComments);
      });
    }

    return result;
  }

  void refresh() {
    loadComments();
  }
}

// Updated parameter class to hold both collection and document info
class CommentProviderParams {
  final String collectionName;
  final String documentId;

  const CommentProviderParams({
    required this.collectionName,
    required this.documentId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommentProviderParams &&
          runtimeType == other.runtimeType &&
          collectionName == other.collectionName &&
          documentId == other.documentId;

  @override
  int get hashCode => collectionName.hashCode ^ documentId.hashCode;
}

// Provider family to create comment providers for different content entries
final commentProvider =
    StateNotifierProvider.family<
      CommentNotifier,
      AsyncValue<List<CommentData>>,
      CommentProviderParams
    >((ref, params) {
      final repository = ref.read(commentRepositoryProvider);
      return CommentNotifier(
        repository,
        params.collectionName,
        params.documentId,
      );
    });

// Convenience provider for getting comments stream
final commentStreamProvider =
    StreamProvider.family<List<CommentData>, CommentProviderParams>((
      ref,
      params,
    ) {
      final repository = ref.read(commentRepositoryProvider);
      return repository.getCommentsStream(
        params.collectionName,
        params.documentId,
      );
    });
