import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/core/models/user.dart';
import 'package:ophth_board/core/providers/auth_provider.dart';
import 'package:ophth_board/features/rotation/model/rotation.dart';
import 'package:ophth_board/features/rotation/providers/rotation_provider.dart';
import '../../../core/views/widgets/custom_bottom_sheet.dart';
import 'forms/create_rotation_form.dart';
import 'widgets/rotation_list_card.dart';
import 'rotation_details_screen.dart';

class RotationListScreen extends ConsumerWidget {
  const RotationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    final provider = currentUser?.role == UserRole.supervisor
        ? supervisorActiveRotationsProvider(currentUser!.id)
        : residentRotationsProvider(currentUser!.id);

    final rotationsAsync = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Rotations'),
        actions: [
          currentUser.role == UserRole.supervisor
              ? IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    CustomBottomSheet.show(
                      context: context,
                      child: const CreateRotationForm(),
                      backgroundColor: Colors.white,
                      borderRadius: 20,
                      showDragHandle: true,
                    );
                  },
                )
              : const SizedBox.shrink(),
        ],
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          rotationsAsync.when(
            data: (rotations) => rotations.isNotEmpty
                ? Column(
                    children: rotations.map((Rotation rotation) {
                      return RotationListCard(
                        rotation: rotation,
                        onView: () {
                          CustomBottomSheet.show(
                            context: context,
                            child: RotationDetailsPage(rotation: rotation),
                            backgroundColor: Colors.white,
                            borderRadius: 20,
                            showDragHandle: true,
                          );
                        },
                      );
                    }).toList(),
                  )
                : const Center(
                    child: Text(
                      'No rotations found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text(
              'Error fetching rotations: $err',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
