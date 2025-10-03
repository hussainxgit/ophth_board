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
        _buildHeader(context, ref, params),
        const SizedBox(height: 16.0),
        _buildCommentsList(context, commentsAsync),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, CommentProviderParams params) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        children: [
          Icon(
            Icons.comment_outlined,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Comments',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => ref.read(commentProvider(params).notifier).refresh(),
            icon: Icon(
              Icons.refresh,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            tooltip: 'Refresh comments',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(BuildContext context, AsyncValue<List<CommentData>> commentsAsync) {
    return commentsAsync.when(
      data: (comments) {
        if (comments.isEmpty) {
          return _buildEmptyState(context);
        }
        
        return _buildCommentsListView(comments);
      },
      loading: () => _buildLoadingState(context),
      error: (error, stackTrace) => _buildErrorState(context, error.toString()),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No comments yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Be the first to share your thoughts!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Loading comments...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 12),
          Text(
            'Failed to load comments',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsListView(List<CommentData> comments) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: CommentItem(
            key: ValueKey(comments[index].id),
            comment: comments[index],
            collectionName: collectionName,
            documentId: documentId,
          ),
        );
      },
    );
  }
}