import 'package:flutter/material.dart';

class ResidentLeaveScreen extends StatelessWidget {
  const ResidentLeaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Requests'),
      ),
      body: Center(
        child: Text(
          'This feature is under development.',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}