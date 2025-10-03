import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../providers/comment_provider.dart';
import '../forms/comment_form.dart';

class CommentInputWidget extends ConsumerStatefulWidget {
  final String collectionName;
  final String documentId;

  const CommentInputWidget({
    super.key,
    required this.collectionName,
    required this.documentId,
  });

  @override
  ConsumerState<CommentInputWidget> createState() => _CommentInputWidgetState();
}

class _CommentInputWidgetState extends ConsumerState<CommentInputWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final params = CommentProviderParams(
      collectionName: widget.collectionName,
      documentId: widget.documentId,
    );

    if (currentUser == null) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Text(
              'Please sign in to comment',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (!_isExpanded) _buildCollapsedInput(context),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _isExpanded ? null : 0,
            child: _isExpanded
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildUserHeader(context, currentUser),
                        const SizedBox(height: 12),
                        CommentForm(
                          collectionName: widget.collectionName,
                          documentId: widget.documentId,
                          onCommentAdded: (comment) async {
                            final result = await ref
                                .read(commentProvider(params).notifier)
                                .addComment(comment);

                            if (result.isSuccess) {
                              setState(() {
                                _isExpanded = false;
                              });
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      result.errorMessage ?? 'Failed to add comment',
                                    ),
                                    backgroundColor: Theme.of(context).colorScheme.error,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedInput(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider)!;
    
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = true;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              backgroundImage: currentUser.profileImageUrl != null
                  ? NetworkImage(currentUser.profileImageUrl!)
                  : null,
              child: currentUser.profileImageUrl == null
                  ? Text(
                      currentUser.displayName.isNotEmpty
                          ? currentUser.displayName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Add a comment...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, currentUser) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          backgroundImage: currentUser.profileImageUrl != null
              ? NetworkImage(currentUser.profileImageUrl!)
              : null,
          child: currentUser.profileImageUrl == null
              ? Text(
                  currentUser.displayName.isNotEmpty
                      ? currentUser.displayName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Commenting as ${currentUser.displayName}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _isExpanded = false;
            });
          },
          icon: const Icon(Icons.close),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}
