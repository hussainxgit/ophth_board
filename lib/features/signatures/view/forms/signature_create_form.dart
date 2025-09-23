import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/signature.dart';
import '../../providers/signature_provider.dart';
import '../widgets/signature_canvas.dart';

class SignatureCreateForm extends ConsumerStatefulWidget {
  final Signature? existingSignature; // For editing existing signature

  const SignatureCreateForm({
    super.key,
    this.existingSignature,
  });

  @override
  ConsumerState<SignatureCreateForm> createState() => _SignatureCreateFormState();
}

class _SignatureCreateFormState extends ConsumerState<SignatureCreateForm> {
  final _signatureCanvasKey = GlobalKey<SignatureCanvasState>();
  
  String? _svgData;

  @override
  void initState() {
    super.initState();
    if (widget.existingSignature != null) {
      _svgData = widget.existingSignature!.signatureStoragePath;
    }
  }

  @override
  Widget build(BuildContext context) {
    final operationsState = ref.watch(signatureOperationsProvider);
    final isEditing = widget.existingSignature != null;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          isEditing ? 'Edit Your Signature' : 'Create Your Signature',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Instruction text
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            border: Border.all(color: Colors.blue.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'How to create your signature:',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '• Use your finger or stylus to draw your signature\n'
                                '• Draw naturally as you would on paper\n'
                                '• You can clear and redraw if needed\n'
                                '• This will be your only signature for all documents',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.blue.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Signature canvas
                        Text(
                          'Draw Your Signature',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SignatureCanvas(
                            key: _signatureCanvasKey,
                            initialSvgData: _svgData,
                            onSignatureChanged: (svgData) {
                              _svgData = svgData;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Canvas controls
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  _signatureCanvasKey.currentState?.clear();
                                  _svgData = null;
                                },
                                icon: const Icon(Icons.clear),
                                label: const Text('Clear'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  _signatureCanvasKey.currentState?.undo();
                                },
                                icon: const Icon(Icons.undo),
                                label: const Text('Undo'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Error message
                        if (operationsState.error != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              border: Border.all(color: Colors.red.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              operationsState.error!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),

                        // Save button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: operationsState.isLoading ? null : _saveSignature,
                            child: operationsState.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(isEditing ? 'Update Signature' : 'Save Signature'),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _saveSignature() async {
    if (_svgData == null || _svgData!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please draw your signature'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final operationsNotifier = ref.read(signatureOperationsProvider.notifier);

    final result = await operationsNotifier.createOrUpdateSignature(
      svgData: _svgData!,
    );

    if (result.isSuccess && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existingSignature != null
              ? 'Signature updated successfully' 
              : 'Signature created successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}