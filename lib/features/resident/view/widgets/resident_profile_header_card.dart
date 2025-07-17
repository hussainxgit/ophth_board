import 'package:flutter/material.dart';
import '../../model/resident.dart';

class ResidentProfileHeader extends StatelessWidget {
  final Resident resident;

  const ResidentProfileHeader({
    super.key,
    required this.resident,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Profile Image
            CircleAvatar(
              radius: 40,
              backgroundImage: resident.profileImageUrl != null
                  ? NetworkImage(resident.profileImageUrl!)
                  : null,
              child: resident.profileImageUrl == null
                  ? Icon(
                      Icons.person,
                      size: 40,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            // Resident Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resident.fullName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Year ${resident.pgy}',
                    
                  ),
                  const SizedBox(height: 4),
                  Text(
                    resident.email,
                    
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
