import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/comment_provider.dart';
import '../forms/comment_form.dart';

class CommentInputWidget extends ConsumerWidget {
  final String collectionName;
  final String documentId;

  const CommentInputWidget({
    super.key,
    required this.collectionName,
    required this.documentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = CommentProviderParams(
      collectionName: collectionName,
      documentId: documentId,
    );

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: CommentForm(
        collectionName: collectionName,
        documentId: documentId,
        onCommentAdded: (comment) async {
          final result = await ref
              .read(commentProvider(params).notifier)
              .addComment(comment);

          if (!result.isSuccess) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result.errorMessage ?? 'Failed to add comment'),
                ),
              );
            }
          }
        },
      ),
    );
  }
}
