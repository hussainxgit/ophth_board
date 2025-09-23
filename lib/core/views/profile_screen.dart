import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../../features/signatures/view/widgets/signature_picker.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _civilIdController = TextEditingController();
  final _fileNumberController = TextEditingController();
  final _workingPlaceController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _civilIdController.dispose();
    _fileNumberController.dispose();
    _workingPlaceController.dispose();
    super.dispose();
  }

  void _initializeUserData() {
    final user = ref.read(authProvider).user;
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _phoneController.text = user.phoneNumber ?? '';
      _civilIdController.text = user.civilId;
      _fileNumberController.text = user.fileNumber ?? '';
      _workingPlaceController.text = user.workingPlace ?? '';
    }

    // User signature is now handled directly by SignaturePicker
    // No need to preload it
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit),
            ),
          if (_isEditing) ...[
            TextButton(
              onPressed: _isLoading ? null : _cancelEditing,
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              _buildProfileHeader(user),
              const SizedBox(height: 32),

              // Basic Information Section
              _buildSectionHeader('Basic Information'),
              const SizedBox(height: 16),
              _buildBasicInfoFields(),
              const SizedBox(height: 32),

              // Contact Information Section
              _buildSectionHeader('Contact Information'),
              const SizedBox(height: 16),
              _buildContactInfoFields(),
              const SizedBox(height: 32),

              // Work Information Section
              _buildSectionHeader('Work Information'),
              const SizedBox(height: 16),
              _buildWorkInfoFields(),
              const SizedBox(height: 32),

              // Signature Section
              _buildSectionHeader('Digital Signature'),
              const SizedBox(height: 16),
              _buildSignatureSection(),
              const SizedBox(height: 32),

              // Account Information Section
              _buildSectionHeader('Account Information'),
              const SizedBox(height: 16),
              _buildAccountInfoSection(user),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserCredentials user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withOpacity(0.2),
            backgroundImage: user.profileImageUrl != null
                ? NetworkImage(user.profileImageUrl!)
                : null,
            child: user.profileImageUrl == null
                ? Text(
                    '${user.firstName[0]}${user.lastName[0]}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            user.fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _getRoleDisplayName(user.role),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildBasicInfoFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _civilIdController,
          decoration: const InputDecoration(
            labelText: 'Civil ID',
            border: OutlineInputBorder(),
          ),
          enabled: _isEditing,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your civil ID';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildContactInfoFields() {
    return TextFormField(
      controller: _phoneController,
      decoration: const InputDecoration(
        labelText: 'Phone Number',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.phone),
      ),
      enabled: _isEditing,
      keyboardType: TextInputType.phone,
    );
  }

  Widget _buildWorkInfoFields() {
    return Column(
      children: [
        TextFormField(
          controller: _fileNumberController,
          decoration: const InputDecoration(
            labelText: 'File Number',
            border: OutlineInputBorder(),
          ),
          enabled: _isEditing,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _workingPlaceController,
          decoration: const InputDecoration(
            labelText: 'Working Place',
            border: OutlineInputBorder(),
          ),
          enabled: _isEditing,
        ),
      ],
    );
  }

  Widget _buildSignatureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your digital signature will be used in official documents and forms.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        SignaturePicker(
          label: 'My Signature',
          hintText: 'Create your signature to use in documents and forms',
        ),
      ],
    );
  }

  Widget _buildAccountInfoSection(UserCredentials user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildInfoRow('Email', user.email),
          const Divider(),
          _buildInfoRow('Account Created', _formatDate(user.createdAt)),
          const Divider(),
          _buildInfoRow('Last Updated', _formatDate(user.updatedAt)),
          const Divider(),
          _buildInfoRow('Account Status', user.isActive ? 'Active' : 'Inactive'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.resident:
        return 'Resident';
      case UserRole.supervisor:
        return 'Supervisor';
      case UserRole.boardDirector:
        return 'Board Director';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
    });
    _initializeUserData();
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement profile update logic
      // This would typically involve calling an auth service method
      // to update the user's profile information

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}