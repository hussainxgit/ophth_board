import 'package:flutter/material.dart';

class TagChipWidget extends StatelessWidget {
  final String tagLabel;

  const TagChipWidget({super.key, required this.tagLabel});

  @override
  Widget build(BuildContext context) {
    // Define default colors here
    const defaultBackgroundColor = Colors.blueGrey;
    const defaultTextColor = Colors.white;

    return Chip(
      label: Text(tagLabel),
      backgroundColor: defaultBackgroundColor,
      labelStyle: const TextStyle(
        color: defaultTextColor,
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide.none,
      ),
    );
  }
}
