import 'package:flutter/material.dart';
import '../model/pdf_model.dart';
import '../view/pdf_viewer_screen.dart';

class PdfController {
  final PdfModel _model = PdfModel();

  Future<void> fillAndViewForm(BuildContext context) async {
    // Example form data (replace with dynamic data from UI or other source)
    final Map<String, dynamic> formData = {
      'dob': '1998/11/10',
      'trainee_name': 'Dana Doe',
      'gender': 2, // Assuming second option (e.g., 'Female')
    };

    try {
      final outputPath = await _model.fillPdfForm(context, formData);
      // Navigate to the viewer screen with the filled PDF path
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(pdfPath: outputPath),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
