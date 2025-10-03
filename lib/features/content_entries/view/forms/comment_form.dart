import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/core/providers/auth_provider.dart';
import '../../model/comment_data.dart';

class CommentForm extends ConsumerStatefulWidget {
  final String collectionName;
  final String documentId;
  final Function(CommentData) onCommentAdded;
  final CommentData? editingComment;

  const CommentForm({
    super.key,
    required this.collectionName,
    required this.documentId,
    required this.onCommentAdded,
    this.editingComment,
  });

  @override
  ConsumerState<CommentForm> createState() => _CommentFormState();
}

class _CommentFormState extends ConsumerState<CommentForm> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.editingComment != null) {
      _commentController.text = widget.editingComment!.text;
    }
    // Auto-focus for new comments
    if (widget.editingComment == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextInput(context),
          const SizedBox(height: 12),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildTextInput(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: _commentController,
        focusNode: _focusNode,
        maxLines: null,
        minLines: 3,
        maxLength: 500,
        decoration: InputDecoration(
          hintText: widget.editingComment != null 
              ? 'Edit your comment...' 
              : 'Share your thoughts...',
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          counterStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        style: Theme.of(context).textTheme.bodyMedium,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter a comment';
          }
          if (value.trim().length < 2) {
            return 'Comment must be at least 2 characters long';
          }
          return null;
        },
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.editingComment != null) ...[
          TextButton(
            onPressed: _isSubmitting ? null : () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
        ],
        FilledButton.icon(
          onPressed: _isSubmitting ? null : _submitComment,
          icon: _isSubmitting
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                )
              : Icon(
                  widget.editingComment != null ? Icons.save : Icons.send,
                  size: 18,
                ),
          label: Text(
            _isSubmitting
                ? (widget.editingComment != null ? 'Updating...' : 'Posting...')
                : (widget.editingComment != null ? 'Update' : 'Post'),
          ),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  Future<void> _submitComment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final currentUser = ref.read(currentUserProvider)!;
      final now = DateTime.now().toIso8601String();
      
      final comment = CommentData(
        id: widget.editingComment?.id ?? now, // Use timestamp as ID for new comments
        name: currentUser.displayName,
        userId: currentUser.id,
        text: _commentController.text.trim(),
        dateTime: widget.editingComment?.dateTime ?? now,
        avatarUrl: currentUser.profileImageUrl,
        editedAt: widget.editingComment != null ? now : null,
        isEdited: widget.editingComment != null,
      );

      widget.onCommentAdded(comment);

      if (widget.editingComment == null) {
        _commentController.clear();
        _focusNode.unfocus();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.editingComment != null
                  ? 'Comment updated successfully!'
                  : 'Comment posted successfully!',
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );

        if (widget.editingComment != null) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${widget.editingComment != null ? 'update' : 'post'} comment: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}