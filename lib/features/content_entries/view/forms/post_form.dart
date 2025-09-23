import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/core/models/result.dart';
import 'package:ophth_board/core/views/widgets/async_loading_button.dart';
import 'package:ophth_board/core/providers/auth_provider.dart';
import 'package:ophth_board/core/models/user.dart';
import 'package:ophth_board/features/content_entries/model/content_entry.dart';
import 'package:ophth_board/features/content_entries/model/post.dart';
import 'package:ophth_board/features/content_entries/providers/posts_provider.dart';

class PostForm extends ConsumerStatefulWidget {
  final Post? post; // For editing existing post

  const PostForm({super.key, this.post});

  @override
  ConsumerState<PostForm> createState() => _PostFormState();
}

class _PostFormState extends ConsumerState<PostForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _authorController = TextEditingController();
  final _authorIdController = TextEditingController();
  final _tagsController = TextEditingController();

  ContentStatus _selectedStatus = ContentStatus.draft;

  UserCredentials? get _currentUser => ref.read(authProvider).user;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.post != null) {
      _titleController.text = widget.post!.title;
      _contentController.text = widget.post!.content;
      _authorController.text = widget.post!.author;
      _authorIdController.text = widget.post!.authorId;
      _tagsController.text = widget.post!.tags.join(', ');
      _selectedStatus = widget.post!.status;
    } else {
      // Pre-fill for new post using current user
      final user = _currentUser;
      if (user != null) {
        _authorController.text = user.displayName;
        _authorIdController.text = user.id;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _authorController.dispose();
    _authorIdController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  List<String> _parseTagsFromString(String tagsString) {
    return tagsString
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  Future<Result<void>> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return Result.error('Please correct the form errors.');
    }

    try {
      final postsNotifier = ref.read(postProvider.notifier);
      final tags = _parseTagsFromString(_tagsController.text);

      final post = Post(
        id: widget.post?.id ?? '', // Firestore will generate ID if empty
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        authorId: _authorIdController.text.trim(),
        author: _authorController.text.trim(),
        createdAt: widget.post?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        status: _selectedStatus,
        tags: tags,
      );

      Result<void> result;

      if (widget.post != null) {
        result = await postsNotifier.updatePost(post);
        if (result.isSuccess) {
          if (mounted) Navigator.of(context).pop();
          return Result.success(null);
        } else {
          return Result.error(result.errorMessage ?? 'Failed to update post');
        }
      } else {
        result = await postsNotifier.addPost(post);
        if (result.isSuccess) {
          if (mounted) Navigator.of(context).pop();
          return Result.success(null);
        } else {
          return Result.error(result.errorMessage ?? 'Failed to create post');
        }
      }
    } catch (e) {
      return Result.error('Error submitting form: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post != null ? 'Edit Post' : 'Create Post'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildContentField(),
              const SizedBox(height: 16),
              _buildTagsField(),
              const SizedBox(height: 16),
              _buildStatusDropdown(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Title',
        hintText: 'Enter post title',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.title),
        filled: false, // Default, or set based on theme
        fillColor: null, // Default
      ),
      readOnly: false, // Title is always editable
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Title is required';
        }
        if (value.trim().length < 3) {
          return 'Title must be at least 3 characters';
        }
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildContentField() {
    return TextFormField(
      controller: _contentController,
      decoration: const InputDecoration(
        labelText: 'Content',
        hintText: 'Enter post content',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
        alignLabelWithHint: true,
      ),
      maxLines: 8,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Content is required';
        }
        if (value.trim().length < 10) {
          return 'Content must be at least 10 characters';
        }
        return null;
      },
      textInputAction: TextInputAction.newline,
    );
  }

  Widget _buildTagsField() {
    return TextFormField(
      controller: _tagsController,
      decoration: const InputDecoration(
        labelText: 'Tags',
        hintText: 'Enter tags separated by commas (e.g., research, case-study)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.tag),
        helperText: 'Separate multiple tags with commas',
      ),
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<ContentStatus>(
      value: _selectedStatus,
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.flag),
      ),
      items: ContentStatus.values.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(_getStatusDisplayName(status)),
        );
      }).toList(),
      onChanged: (ContentStatus? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedStatus = newValue;
          });
        }
      },
    );
  }

  String _getStatusDisplayName(ContentStatus status) {
    switch (status) {
      case ContentStatus.draft:
        return 'Draft';
      case ContentStatus.published:
        return 'Published';
      case ContentStatus.archived:
        return 'Archived';
      case ContentStatus.pendingReview:
        return 'Pending Review';
    }
  }

  Widget _buildSubmitButton() {
    return AsyncGenericButton(
      text: widget.post != null ? 'Update Post' : 'Create Post',
      onPressed: _submitForm,
      onSuccess: (result) {
        _showSuccessMessage(
          widget.post != null
              ? 'Post updated successfully!'
              : 'Post created successfully!',
        );
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      onError: (error) {
        _showErrorMessage('Error: $error');
      },
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
