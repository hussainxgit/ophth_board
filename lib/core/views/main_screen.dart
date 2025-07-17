import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/core/models/user.dart';
import 'package:ophth_board/features/content_entries/view/content_entry_list_screen.dart';
import 'package:ophth_board/features/content_entries/view/forms/announcement_form.dart';
import 'package:ophth_board/features/content_entries/view/forms/notice_board_form.dart';
import 'package:ophth_board/features/content_entries/view/forms/post_form.dart';
import 'package:ophth_board/features/resident/model/resident.dart';
import 'package:ophth_board/features/resident/view/resident_profile_screen.dart';
import 'package:ophth_board/features/supervisor/model/supervisor.dart';
import 'package:ophth_board/features/supervisor/view/supervisor_screen.dart';
import '../providers/auth_provider.dart';
import 'widgets/app_drawer.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(['Community', 'Profile'][_selectedIndex]),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddContentOptions(context),
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? const ContentEntryListScreen()
          : _buildProfileScreen(user!),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileScreen(UserCredentials user) {
    return switch (user.role) {
      UserRole.resident =>
        user is Resident
            ? ResidentProfileScreen(resident: user)
            : const Center(child: Text('Profile not available')),
      UserRole.supervisor =>
        user is Supervisor
            ? SupervisorProfileScreen(supervisor: user)
            : const Center(child: Text('Profile not available')),
      UserRole.boardDirector => const Center(
        child: Text('Board Director Dashboard'),
      ),
    };
  }

  void _showAddContentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Content',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildContentOption(
              icon: Icons.post_add,
              title: 'Add Post',
              onTap: () => _navigateTo(context, PostForm()),
            ),
            _buildContentOption(
              icon: Icons.announcement,
              title: 'Add Announcement',
              onTap: () => _navigateTo(context, AnnouncementForm()),
            ),
            _buildContentOption(
              icon: Icons.note,
              title: 'Add Notice Board',
              onTap: () =>
                  _navigateTo(context, NoticeBoardForm(noticeBoard: null)),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    ).then((_) => setState(() {}));
  }

  Widget _buildContentOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
    );
  }
}
