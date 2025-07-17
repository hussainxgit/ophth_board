import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/core/views/widgets/async_loading_button.dart';
import 'package:ophth_board/features/content_entries/model/notice_board.dart';
import 'package:ophth_board/features/content_entries/model/content_entry.dart';

import '../../../../core/models/result.dart';
import '../../providers/notice_board_provider.dart';

class NoticeBoardForm extends ConsumerStatefulWidget {
  final NoticeBoard? noticeBoard; // For editing existing notice

  const NoticeBoardForm({super.key, this.noticeBoard});

  @override
  ConsumerState<NoticeBoardForm> createState() => _NoticeBoardFormState();
}

class _NoticeBoardFormState extends ConsumerState<NoticeBoardForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _authorController = TextEditingController();
  final _tagsController = TextEditingController();

  ContentStatus _selectedStatus = ContentStatus.draft;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.noticeBoard != null) {
      _titleController.text = widget.noticeBoard!.title;
      _contentController.text = widget.noticeBoard!.content;
      _authorController.text = widget.noticeBoard!.author;
      _tagsController.text = widget.noticeBoard!.tags.join(', ');
      _selectedStatus = widget.noticeBoard!.status;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _authorController.dispose();
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Use provider instead of direct repository access
      final noticeBoardNotifier = ref.read(noticeBoardProvider.notifier);
      final tags = _parseTagsFromString(_tagsController.text);

      final noticeBoard = NoticeBoard(
        id: widget.noticeBoard?.id ?? '',
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        author: _authorController.text.trim(),
        createdAt: widget.noticeBoard?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        tags: tags,
        status: _selectedStatus,
        comments: widget.noticeBoard?.comments ?? [],
      );

      Result<void> result;

      if (widget.noticeBoard != null) {
        // Update existing notice through provider
        result = await noticeBoardNotifier.updateNoticeBoard(noticeBoard);
        if (result.isSuccess) {
          _showSuccessMessage('Notice board updated successfully!');
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        } else {
          _showErrorMessage(
            result.errorMessage ?? 'Failed to update notice board',
          );
        }
      } else {
        // Create new notice through provider
        result = await noticeBoardNotifier.addNoticeBoard(noticeBoard);
        if (result.isSuccess) {
          _showSuccessMessage('Notice board created successfully!');
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        } else {
          _showErrorMessage(
            result.errorMessage ?? 'Failed to create notice board',
          );
        }
      }
    } catch (e) {
      _showErrorMessage('Error submitting form: $e');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.noticeBoard != null ? 'Edit Notice' : 'Create Notice',
        ),
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
              _buildAuthorField(),
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
      decoration: const InputDecoration(
        labelText: 'Title',
        hintText: 'Enter notice title',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.title),
      ),
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

  Widget _buildAuthorField() {
    return TextFormField(
      controller: _authorController,
      decoration: const InputDecoration(
        labelText: 'Author',
        hintText: 'Enter author name',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Author is required';
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
        hintText: 'Enter notice content',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
        alignLabelWithHint: true,
      ),
      maxLines: 6,
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
        hintText: 'Enter tags separated by commas (e.g., urgent, announcement)',
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
      default:
        return 'Unknown';
    }
  }

  Widget _buildSubmitButton() {
    return AsyncLoadingButton(
      buttonText: widget.noticeBoard != null
          ? 'Update Notice'
          : 'Create Notice',
      onPressed: _submitForm,
      successMessage: widget.noticeBoard != null
          ? 'Notice board updated successfully!'
          : 'Notice board created successfully!',
      errorMessage: 'Error submitting form. Please try again.',
    );
  }
}
