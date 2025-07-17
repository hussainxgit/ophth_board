import 'package:flutter/material.dart';
import 'package:ophth_board/features/rotation/model/rotation.dart';

import '../../../evaluations/view/resident_evaluation_form_view.dart';
import '../../../rotation/view/rotation_screen.dart';

class CurrentRotationCard extends StatelessWidget {
  final Rotation rotation;
  final String residentId;

  const CurrentRotationCard({
    super.key,
    required this.rotation,
    required this.residentId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RotationDetailsPage(rotation: rotation),
            ),
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
                'Supervisor:',
                rotation.assignedSupervisors.isEmpty
                    ? 'Not Assigned'
                    : rotation.assignedSupervisors.keys.first,
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

              const SizedBox(height: 16),
              rotation.assignedSupervisors.isNotEmpty
                  ? Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ResidentEvaluationFormView(
                                rotationId: rotation.id,
                                supervisorId:
                                    rotation.assignedSupervisors.keys.first,
                                residentId: residentId,
                              ),
                            ),
                          );
                        },
                        child: const Text('Evaluate Resident'),
                      ),
                    )
                  : Container(),
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
