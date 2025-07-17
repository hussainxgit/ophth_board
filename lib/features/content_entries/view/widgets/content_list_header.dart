import 'package:flutter/material.dart';

class ContentListHeader extends StatelessWidget {
  /// A header widget for the content list.
  final String title;
  final String buttonLabel;
  final VoidCallback? onTap;
  final IconData? icon;
  const ContentListHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.buttonLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon),
            const SizedBox(width: 8.0),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        TextButton(onPressed: onTap, child: Text(buttonLabel)),
      ],
    );
  }
}
