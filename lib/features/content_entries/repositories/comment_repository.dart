import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/firebase/firebase_service.dart';
import '../../../core/models/result.dart';
import '../model/comment_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentRepository {
  final FirestoreService _firestoreService;

  CommentRepository(this._firestoreService);

  Future<Result<void>> addComment(
    String collectionName,
    String documentId,
    CommentData comment,
  ) async {
    try {
      await _firestoreService.updateDocument(collectionName, documentId, {
        'comments': FieldValue.arrayUnion([comment.toMap()]),
      });

      return Result.success(null);
    } catch (e) {
      return Result.error('Failed to add comment: $e');
    }
  }

  Future<Result<void>> updateComment(
    String collectionName,
    String documentId,
    CommentData updatedComment,
  ) async {
    try {
      final doc = await _firestoreService.getDocument(
        collectionName,
        documentId,
      );

      if (!doc.exists) {
        return Result.error('Document not found');
      }

      final data = doc.data() as Map<String, dynamic>;
      final comments = List<Map<String, dynamic>>.from(data['comments'] ?? []);

      // Find and update the comment
      final commentIndex = comments.indexWhere(
        (comment) => comment['id'] == updatedComment.id,
      );
      if (commentIndex == -1) {
        return Result.error('Comment not found');
      }

      // Update the comment with edit timestamp
      final editedComment = updatedComment.copyWith(
        editedAt: DateTime.now().toIso8601String(),
        isEdited: true,
      );
      
      comments[commentIndex] = editedComment.toMap();

      await _firestoreService.updateDocument(collectionName, documentId, {
        'comments': comments,
      });

      return Result.success(null);
    } catch (e) {
      return Result.error('Failed to update comment: $e');
    }
  }

  Future<Result<void>> deleteComment(
    String collectionName,
    String documentId,
    String commentId,
  ) async {
    try {
      final doc = await _firestoreService.getDocument(
        collectionName,
        documentId,
      );

      if (!doc.exists) {
        return Result.error('Document not found');
      }

      final data = doc.data() as Map<String, dynamic>;
      final comments = List<Map<String, dynamic>>.from(data['comments'] ?? []);

      // Remove the comment with the specified ID
      comments.removeWhere((comment) => comment['id'] == commentId);

      await _firestoreService.updateDocument(collectionName, documentId, {
        'comments': comments,
      });

      return Result.success(null);
    } catch (e) {
      return Result.error('Failed to delete comment: $e');
    }
  }

  Future<Result<List<Map<String, dynamic>>>> getComments(
    String collectionName,
    String documentId,
  ) async {
    try {
      print('collectionName: $collectionName, documentId: $documentId');

      final doc = await _firestoreService.getDocument(
        collectionName,
        documentId,
      );

      if (!doc.exists) {
        return Result.error('Document not found');
      }

      final data = doc.data() as Map<String, dynamic>;
      final commentsData = List<Map<String, dynamic>>.from(
        data['comments'] ?? [],
      );
      commentsData.sort(
        (a, b) => DateTime.parse(b['dateTime']).compareTo(
          DateTime.parse(a['dateTime']),
        ),
      );


      return Result.success(commentsData);
    } catch (e) {
      return Result.error('Failed to fetch comments: $e');
    }
  }

  Stream<List<CommentData>> getCommentsStream(
    String collectionName,
    String documentId,
  ) {
    return _firestoreService.getDocumentStream(collectionName, documentId).map((
      snapshot,
    ) {
      if (!snapshot.exists) {
        return <CommentData>[];
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final commentsData = List<Map<String, dynamic>>.from(
        data['comments'] ?? [],
      );

      final comments = commentsData
          .map(
            (commentMap) =>
                CommentData.fromMap(commentMap),
          )
          .toList();

      // Sort by creation date (newest first)
      comments.sort(
        (a, b) =>
            DateTime.parse(b.dateTime).compareTo(DateTime.parse(a.dateTime)),
      );

      return comments;
    });
  }
}

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  final firestoreService = ref.read(firestoreServiceProvider);
  return CommentRepository(firestoreService);
});
