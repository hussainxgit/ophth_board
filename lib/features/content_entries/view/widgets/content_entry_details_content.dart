import 'package:flutter/material.dart';
import 'tags_display.dart';

class ContentEntryDetailsContent extends StatelessWidget {
  final String details;

  const ContentEntryDetailsContent({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Notice Details'),
        const SizedBox(height: 12.0),
        Text(details, textAlign: TextAlign.justify),
      ],
    );
  }
}

// Widget for displaying tags (widgets/tags_display.dart)
class TagsDisplay extends StatelessWidget {
  final String tag;

  const TagsDisplay({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12.0),
        TagChipWidget(tagLabel: tag),
      ],
    );
  }
}
