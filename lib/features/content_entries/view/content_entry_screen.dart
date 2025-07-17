import 'package:flutter/material.dart';
import 'package:ophth_board/features/content_entries/model/content_entry.dart';
import 'widgets/comment_input_field.dart';
import 'package:ophth_board/features/content_entries/model/content_entry_type_extension.dart';
import 'widgets/comments_list.dart';
import 'widgets/content_entry_details_content.dart';
import 'widgets/content_entry_header_card.dart';

class ContentEntryScreen extends StatelessWidget {
  final ContentEntry? item;

  const ContentEntryScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // Debug prints to help identify the issue
    debugPrint('ContentEntryScreen build called');
    debugPrint('Item is null: ${item == null}');
    if (item != null) {
      debugPrint('Item title: ${item!.title}');
      debugPrint('Item content: ${item!.content}');
    }

    return Scaffold(
      appBar: _buildAppBar(context),
      body: item == null ? _buildEmptyState() : _buildContent(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () => _handleBackNavigation(context),
      ),
      title: Text(item?.type.displayName ?? 'Content Details'),
      actions: item != null ? [_buildShareButton()] : null,
    );
  }

  Widget _buildShareButton() {
    return IconButton(
      icon: const Icon(Icons.share_outlined),
      onPressed: _handleShare,
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text('No notice data available.', style: TextStyle(fontSize: 16)),
    );
  }

  Widget _buildContent() {
    final noticeItem = item!;
    final collectionName = noticeItem.type.collectionName;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ContentEntryHeaderCard(
                  title: noticeItem.title,
                  author: noticeItem.author,
                  date: _formatDate(noticeItem.createdAt),
                ),
                const SizedBox(height: 24.0),
                ContentEntryDetailsContent(details: noticeItem.content),
                const SizedBox(height: 24.0),
                CommentsList(
                  collectionName: collectionName,
                  documentId: noticeItem.id,
                ),
              ],
            ),
          ),
        ),
        CommentInputWidget(
          collectionName: collectionName,
          documentId: noticeItem.id,
        ),
      ],
    );
  }

  String _formatDate(DateTime dateTime) {
    return dateTime.toLocal().toString().split(' ')[0];
  }

  void _handleBackNavigation(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _handleShare() {
    // TODO: Implement share functionality
    debugPrint('Share button pressed');
  }
}
