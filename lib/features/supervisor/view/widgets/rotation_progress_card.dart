import 'package:flutter/material.dart';
import 'package:ophth_board/core/utils/boali_date_extenstions.dart';

import '../../../rotation/model/rotation.dart';

class RotationProgressCard extends StatelessWidget {
  final List<Rotation> rotations;

  const RotationProgressCard({super.key, required this.rotations});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: rotations
              .map((rotation) => rotationWidget(rotation))
              .toList(),
        ),
      ),
    );
  }

  Widget rotationWidget(Rotation rotation) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                rotation.title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                rotation.startDate.formattedDate,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: rotation.calculateProgress / 100,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
          ),
        ],
      ),
    );
  }
}
