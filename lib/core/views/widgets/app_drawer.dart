import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/features/leave_request/view/leave_list_screen.dart';
import 'package:ophth_board/features/rotation/view/rotation_list_screen.dart';
import '../../../features/evaluations/view/evaluation_list_screen.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../settings_screen.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  void _navigateTo(BuildContext context, Widget destination) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    return Drawer(
      child: Column(
        children: [
          _buildHeader(context, user!),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.home,
                  title: 'Home',
                  isSelected: true,
                  onTap: () => Navigator.pop(context),
                ),
                // const Divider(height: 1, thickness: 1),
                // _buildMenuItem(
                //   context,
                //   icon: Icons.calendar_today,
                //   title: 'Schedule',
                //   onTap: () => Navigator.pop(context),
                // ),
                _buildMenuItem(
                  context,
                  icon: Icons.rotate_right,
                  title: 'Rotations',
                  onTap: () => _navigateTo(context, RotationListScreen()),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.check_circle,
                  title: 'Evaluations',
                  onTap: () => {_navigateTo(context, EvaluationListScreen())},
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.flight_takeoff,
                  title: 'Leave Requests',
                  onTap: () => _navigateTo(context, LeaveListScreen()),
                ),

                const Divider(height: 1, thickness: 1),
                _buildMenuItem(
                  context,
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () => _navigateTo(context, const SettingsScreen()),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.help,
                  title: 'Help & Support',
                  onTap: () => Navigator.pop(context),
                ),
                const Divider(height: 1, thickness: 1),
                _buildMenuItem(
                  context,
                  icon: Icons.logout,
                  title: 'Sign Out',
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(authProvider.notifier).signOut();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserCredentials user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.person,
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.displayName,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.role.name,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 24),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? Theme.of(context).colorScheme.surface : null,
      selectedTileColor: isSelected ? Theme.of(context).primaryColor : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      onTap: onTap,
    );
  }
}
