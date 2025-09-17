import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/core/providers/auth_provider.dart';
import 'package:ophth_board/core/views/widgets/async_loading_button.dart';
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
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.editingComment != null) {
      _commentController.text = widget.editingComment!.text;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final comment = CommentData(
        name: ref.read(currentUserProvider)!.displayName,
        text: _commentController.text.trim(),
        dateTime:
            widget.editingComment?.dateTime ?? DateTime.now().toIso8601String(),
        avatarUrl: widget.editingComment?.avatarUrl,
      );

      widget.onCommentAdded(comment);

      if (widget.editingComment == null) {
        _commentController.clear();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.editingComment != null
                  ? 'Comment updated successfully!'
                  : 'Comment added successfully!',
            ),
          ),
        );

        if (widget.editingComment != null) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error submitting comment: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.editingComment == null) const SizedBox(height: 16),
          TextFormField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Your Comment',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.comment),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a comment';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AsyncGenericButton(
            text: widget.editingComment != null ? 'Update Comment' : 'Add Comment',
            onPressed: _submitComment,
            enabled: !_isSubmitting,
            loadingWidget: const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
