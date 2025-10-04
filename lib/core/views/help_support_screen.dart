import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Quick Actions Section
          _buildSectionHeader('Quick Actions'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text('Call Support'),
              subtitle: const Text('Speak directly with our support team'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _launchPhone(),
            ),
          ),
          const SizedBox(height: 24),
          // FAQ Section
          _buildSectionHeader('Frequently Asked Questions'),
          _buildFAQCard(
            'How do I update my profile information?',
            'Go to Settings > My Profile to edit your personal information, contact details, and professional details.',
          ),
          _buildFAQCard(
            'How do I view my evaluations?',
            'Access the Evaluations section from the main menu to view all your completed and pending evaluations.',
          ),
          _buildFAQCard(
            'How do I change the app theme?',
            'Go to Settings > Theme & Appearance to customize the app\'s color scheme and appearance.',
          ),
          _buildFAQCard(
            'How do I view my rotation schedule?',
            'Check the Rotations section from the main menu to see your current and upcoming rotations.',
          ),

          const SizedBox(height: 24),

          // App Information Section
          _buildSectionHeader('App Information'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info, color: Colors.indigo),
              title: const Text('About App'),
              subtitle: const Text('Version information and details'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showAboutDialog(context),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.description, color: Colors.purple),
              title: const Text('Terms of Service'),
              subtitle: const Text('Read our terms and conditions'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showComingSoon(context),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.privacy_tip, color: Colors.teal),
              title: const Text('Privacy Policy'),
              subtitle: const Text('Learn how we protect your data'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showComingSoon(context),
            ),
          ),        
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildFAQCard(String question, String answer) {
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.help_outline, color: Colors.blue),
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // void _launchEmail() async {
  //   final Uri emailUri = Uri(
  //     scheme: 'mailto',
  //     path: 'support@ophthboard.com',
  //     query: 'subject=Support Request - Ophth Board App',
  //   );

  //   try {
  //     if (await canLaunchUrl(emailUri)) {
  //       await launchUrl(emailUri);
  //     }
  //   } catch (e) {
  //     // Handle error silently or show a snackbar
  //   }
  // }

  void _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+96562228494');

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    } catch (e) {
      // Handle error silently or show a snackbar
    }
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Kuwait Ophthalmology Board',
      applicationVersion: '0.7.0',
      applicationIcon: const Icon(
        Icons.medical_services,
        size: 48,
        color: Colors.blue,
      ),
      children: [
        const Text(
          'A comprehensive ophthalmology residency management application designed to streamline resident and supervisor workflows.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Features include:\n• Rotation management\n• Leave requests\n• Evaluations\n• Announcements\n• Profile management',
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: const Text(
          'This feature is currently under development and will be available in a future update.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
