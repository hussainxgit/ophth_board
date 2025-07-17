import 'package:flutter/material.dart';

class ContentEntryHeaderCard extends StatelessWidget {
  final String title;
  final String author;
  final String date;

  const ContentEntryHeaderCard({
    super.key,
    required this.title,
    required this.author,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),

      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Icon(
              Icons.campaign_outlined,
              size: 30.0,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16.0),
                    const SizedBox(width: 4.0),
                    Text(author),
                    const SizedBox(width: 16.0),
                    const Icon(Icons.calendar_today_outlined, size: 14.0),
                    const SizedBox(width: 4.0),
                    Text(date),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
