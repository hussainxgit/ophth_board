import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/comment_data.dart';
import '../../providers/comment_provider.dart';
import 'comment_item.dart';

class CommentsList extends ConsumerWidget {
  final String collectionName;
  final String documentId;
  final List<CommentData>? initialComments; // For backward compatibility

  const CommentsList({
    super.key,
    required this.collectionName,
    required this.documentId,
    this.initialComments,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = CommentProviderParams(
      collectionName: collectionName,
      documentId: documentId,
    );
    final commentsAsync = ref.watch(commentProvider(params));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Comments',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => ref.read(commentProvider(params).notifier).refresh(),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        commentsAsync.when(
          data: (comments) {
            if (comments.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No comments yet. Be the first to comment!',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }
            
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                return CommentItem(
                  comment: comments[index],
                  collectionName: collectionName,
                  documentId: documentId,
                );
              },
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Error loading comments: $error',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => ref.read(commentProvider(params).notifier).refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}