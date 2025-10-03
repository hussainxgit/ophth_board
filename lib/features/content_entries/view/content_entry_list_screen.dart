import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/features/content_entries/view/widgets/content_list_header.dart';
import '../model/content_entry.dart';
import '../providers/announcements_provider.dart';
import '../providers/notice_board_provider.dart';
import '../providers/posts_provider.dart';
import 'widgets/content_entry_list_card.dart';

class ContentEntryListScreen extends ConsumerStatefulWidget {
  const ContentEntryListScreen({super.key});

  @override
  ConsumerState<ContentEntryListScreen> createState() =>
      _ContentEntryListScreenState();
}

class _ContentEntryListScreenState
    extends ConsumerState<ContentEntryListScreen> {
  Future<void> _handleRefresh() async {
    // Refresh all content types
    ref.read(noticeBoardProvider.notifier).refresh();
    // Add other provider refreshes here as they become available
    // ref.read(recentPostsProvider.notifier).refresh();
    ref.read(announcementProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildContentSection(
                  contentType: ContentType.post,
                  title: 'Recent Posts',
                  icon: Icons.post_add,
                ),
                const SizedBox(height: 24),
                _buildContentSection(
                  contentType: ContentType.announcement,
                  title: 'Announcements',
                  icon: Icons.campaign,
                ),
                const SizedBox(height: 24),
                _buildContentSection(
                  contentType: ContentType.noticeBoard,
                  title: 'Notice Board',
                  icon: Icons.notifications,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection({
    required ContentType contentType,
    required String title,
    required IconData icon,
  }) {
    switch (contentType) {
      case ContentType.post:
        return _buildRecentPostsSection(title, icon);
      case ContentType.announcement:
        return _buildAnnouncementsSection(title, icon);
      case ContentType.noticeBoard:
        return _buildNoticeBoardSection(title, icon);
    }
  }

  Widget _buildRecentPostsSection(String title, IconData icon) {
    final recentPostsProvider = ref.watch(postProvider);

    return recentPostsProvider.when(
      data: (post) => _buildContentList(
        title: title,
        icon: icon,
        items: post,
        onViewAll: () => _navigateToViewAll(ContentType.post),
      ),
      loading: () => _buildLoadingSection(title, icon),
      error: (error, stackTrace) => _buildErrorSection(
        title: title,
        icon: icon,
        error: error,
        onRetry: () => ref.read(noticeBoardProvider.notifier).refresh(),
      ),
    );
  }

  Widget _buildNoticeBoardSection(String title, IconData icon) {
    final noticeBoardState = ref.watch(noticeBoardProvider);

    return noticeBoardState.when(
      data: (noticeBoards) => _buildContentList(
        title: title,
        icon: icon,
        items: noticeBoards,
        onViewAll: () => _navigateToViewAll(ContentType.noticeBoard),
      ),
      loading: () => _buildLoadingSection(title, icon),
      error: (error, stackTrace) => _buildErrorSection(
        title: title,
        icon: icon,
        error: error,
        onRetry: () => ref.read(noticeBoardProvider.notifier).refresh(),
      ),
    );
  }

  Widget _buildAnnouncementsSection(String title, IconData icon) {
    final announcementsState = ref.watch(announcementProvider);

    return announcementsState.when(
      data: (announcements) => _buildContentList(
        title: title,
        icon: icon,
        items: announcements
            .cast<dynamic>(), // Cast to dynamic to satisfy the generic type
        onViewAll: () => _navigateToViewAll(ContentType.noticeBoard),
      ),
      loading: () => _buildLoadingSection(title, icon),
      error: (error, stackTrace) => _buildErrorSection(
        title: title,
        icon: icon,
        error: error,
        onRetry: () => ref.read(announcementProvider.notifier).refresh(),
      ),
    );
  }

  Widget _buildContentList({
    required String title,
    required IconData icon,
    required List<dynamic> items, // Use dynamic to accommodate different types
    required VoidCallback onViewAll,
  }) {
    if (items.isEmpty) {
      return _buildEmptySection(title, icon);
    }

    // Show only first 3 items in the list view
    final displayItems = items.take(3).toList();

    return Column(
      children: [
        ContentListHeader(
          icon: icon,
          title: title,
          buttonLabel: '',
          onTap: onViewAll,
        ),
        ...displayItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: ContentEntryListCard(item: item),
          ),
        ),
        if (items.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextButton(
              onPressed: onViewAll,
              child: Text('View ${items.length - 3} more'),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptySection(String title, IconData icon) {
    return Column(
      children: [
        ContentListHeader(
          icon: icon,
          title: title,
          buttonLabel: '',
          onTap: () => _navigateToViewAll(_getContentTypeFromTitle(title)),
        ),
        SizedBox(
          height: 150,

          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32),
                const SizedBox(height: 8),
                Text('No $title found', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingSection(String title, IconData icon) {
    return Column(
      children: [
        ContentListHeader(
          icon: icon,
          title: title,
          buttonLabel: '',
          onTap: () {},
        ),
        SizedBox(
          height: 150,

          child: const Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }

  Widget _buildErrorSection({
    required String title,
    required IconData icon,
    required Object error,
    required VoidCallback onRetry,
  }) {
    return Column(
      children: [
        ContentListHeader(
          icon: icon,
          title: title,
          buttonLabel: '',
          onTap: () {},
        ),
        SizedBox(
          height: 150,

          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 32, color: Colors.red[400]),
                const SizedBox(height: 8),
                Text(
                  'Error loading $title',
                  style: TextStyle(fontSize: 14, color: Colors.red[600]),
                ),
                const SizedBox(height: 8),
                TextButton(onPressed: onRetry, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      ],
    );
  }

  ContentType _getContentTypeFromTitle(String title) {
    switch (title.toLowerCase()) {
      case 'recent posts':
        return ContentType.post;
      case 'announcements':
        return ContentType.announcement;
      case 'notice board':
        return ContentType.noticeBoard;
      default:
        return ContentType.post;
    }
  }

  void _navigateToViewAll(ContentType contentType) {
    switch (contentType) {
      case ContentType.post:
        // Navigator.push(context, MaterialPageRoute(builder: (context) => RecentPostsDetailScreen()));
        break;
      case ContentType.announcement:
        // Navigator.push(context, MaterialPageRoute(builder: (context) => AnnouncementsDetailScreen()));
        break;
      case ContentType.noticeBoard:
        // Navigator.push(context, MaterialPageRoute(builder: (context) => NoticeBoardDetailScreen()));
        break;
    }

    // Temporary debug print
    print('Navigate to $contentType ');
  }
}
