import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/signature.dart';
import '../../providers/signature_provider.dart';
import '../forms/signature_create_form.dart';
import 'signature_display.dart';

class SignaturePicker extends ConsumerWidget {
  final String? label;
  final String? hintText;

  const SignaturePicker({
    super.key,
    this.label,
    this.hintText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signatureAsyncValue = ref.watch(userSignatureProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
        ],
        
        signatureAsyncValue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorWidget(context, ref),
          data: (signature) => _buildSignaturePicker(context, ref, signature),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(height: 8),
          Text(
            'Error loading signature',
            style: TextStyle(color: Colors.red.shade700),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.invalidate(userSignatureProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSignaturePicker(
    BuildContext context,
    WidgetRef ref,
    Signature? signature,
  ) {
    if (signature == null) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Signature display
        Container(
          width: double.infinity,
          height: 100,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.blue.shade50,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'My Signature',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showDeleteConfirmation(context, ref),
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              Expanded(
                child: SignatureDisplay(
                  svgData: signature.signatureStoragePath,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showCreateSignatureForm(context, signature),
                icon: const Icon(Icons.edit),
                label: const Text('Edit Signature'),
              ),
            ),
          ],
        ),

        if (hintText != null) ...[
          const SizedBox(height: 8),
          Text(
            hintText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.draw_outlined,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No signature available',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your signature to use in documents',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showCreateSignatureForm(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Signature'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Signature'),
        content: const Text(
          'Are you sure you want to delete your signature? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(signatureOperationsProvider.notifier).deleteUserSignature();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCreateSignatureForm(BuildContext context, [Signature? existingSignature]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SignatureCreateForm(
        existingSignature: existingSignature,
      ),
    );
  }
}