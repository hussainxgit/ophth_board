import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/core/views/widgets/custom_bottom_sheet.dart';
import 'package:ophth_board/features/rotation/model/rotation.dart';
import '../../../rotation/view/rotation_details_screen.dart';
import '../../../supervisor/model/supervisor.dart';
import '../../../../core/firebase/firebase_service.dart';

class CurrentRotationCard extends ConsumerWidget {
  final Rotation rotation;
  final String residentId;
  final String residentName;

  const CurrentRotationCard({
    super.key,
    required this.rotation,
    required this.residentId,
    required this.residentName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          CustomBottomSheet.show(
            context: context,
            child: RotationDetailsPage(rotation: rotation),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rotation Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      rotation.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Rotation Details
              rotation.assignedSupervisors.isEmpty
                  ? _buildDetailRow('Supervisor:', 'Not Assigned')
                  : FutureBuilder<Supervisor?>(
                      future: _fetchSupervisor(ref, rotation.assignedSupervisors.first),
                      builder: (context, AsyncSnapshot<Supervisor?> snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return _buildDetailRow('Supervisor:', 'Loading...');
                        }
                        if (!snap.hasData || snap.data == null) {
                          return _buildDetailRow('Supervisor:', 'Not Assigned');
                        }
                        return _buildSupervisorDetail(context, snap.data!);
                      },
                    ),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Duration:',
                '${rotation.startDate.toLocal().toIso8601String().split('T').first} - ${rotation.endDate.toLocal().toIso8601String().split('T').first}',
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Progress:',
                'Week ${rotation.weekOfRotation} of ${rotation.totalWeeks}',
              ),

              const SizedBox(height: 16),

              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progress', style: TextStyle(fontSize: 12)),
                      Text(
                        '${rotation.calculateProgress}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: rotation.calculateProgress / 100,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 80, child: Text(label, style: TextStyle(fontSize: 14))),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildSupervisorDetail(BuildContext context, Supervisor supervisor) {
    // supervisor is expected to have firstName, lastName and possibly profileImageUrl
    final name = '${supervisor.firstName} ${supervisor.lastName}';
    final title = supervisor.workingPlace ?? '';

    return Row(
      children: [
        CircleAvatar(
          radius: 20,
      backgroundImage: supervisor.profileImageUrl != null
        ? NetworkImage(supervisor.profileImageUrl!)
              : null,
          child: supervisor.profileImageUrl == null
              ? Icon(
                  Icons.person,
                  size: 20,
                  color: Theme.of(context).colorScheme.surface,
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (title.isNotEmpty)
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<Supervisor?> _fetchSupervisor(WidgetRef ref, String supervisorId) async {
    try {
      final firestore = ref.read(firestoreServiceProvider);
      final doc = await firestore.getDocument('users', supervisorId);
      if (!doc.exists) return null;
      return Supervisor.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }
}
