import 'package:flutter/material.dart';
import '../../model/supervisor.dart';

class SupervisorProfileHeader extends StatelessWidget {
  final Supervisor supervisor;

  const SupervisorProfileHeader({super.key, required this.supervisor});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Profile Image
            CircleAvatar(
              radius: 40,
              backgroundImage: supervisor.profileImageUrl != null
                  ? NetworkImage(supervisor.profileImageUrl!)
                  : null,
              child: supervisor.profileImageUrl == null
                  ? Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(width: 16),
            // Supervisor Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    supervisor.fullName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    supervisor.role.name[0].toUpperCase() +
                        supervisor.role.name.substring(1),
                  ),
                  const SizedBox(height: 4),
                  Text(supervisor.email),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
