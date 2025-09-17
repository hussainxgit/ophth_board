import 'package:flutter/material.dart';
import 'package:ophth_board/features/rotation/model/rotation.dart';

import '../../../../core/views/widgets/custom_bottom_sheet.dart';
import '../../../rotation/view/rotation_details_screen.dart';

class SupervisorActiveRotationCard extends StatelessWidget {
  final Rotation rotation;

  const SupervisorActiveRotationCard({super.key, required this.rotation});

  @override
  Widget build(BuildContext context) {
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
}
