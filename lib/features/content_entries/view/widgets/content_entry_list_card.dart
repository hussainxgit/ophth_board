import 'package:flutter/material.dart';
import 'package:ophth_board/features/content_entries/view/content_entry_screen.dart';

import '../../model/content_entry.dart';

class ContentEntryListCard extends StatelessWidget {
  final ContentEntry item;

  const ContentEntryListCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ContentEntryScreen(item: item),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16.0),
                  const SizedBox(width: 4.0),
                  Text(item.author),
                  const SizedBox(width: 16.0),
                  Icon(Icons.calendar_today_outlined, size: 14.0),
                  const SizedBox(width: 4.0),
                  Text(
                    item.createdAt.toLocal().toString().split(
                      ' ',
                    )[0], // Display date only
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
            ],
          ),
        ),
      ),
    );
  }
}
