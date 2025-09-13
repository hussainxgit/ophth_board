import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

enum PdfFormType { evaluation, leave }

class PdfModel {
  Future<String> fillPdfForm(
    BuildContext context,
    Map<String, dynamic> formData, {
    String templateAsset = 'assets/pdf_forms/form_template.pdf',
  }) async {
    try {
      // Load the PDF document from assets
      final bytes = await DefaultAssetBundle.of(context).load(templateAsset);
      final PdfDocument document = PdfDocument(
        inputBytes: bytes.buffer.asUint8List(),
      );

      // Get the form
      PdfForm form = document.form;

      // Fill form fields based on provided data
      PdfFormFieldCollection fields = form.fields;
      for (int i = 0; i < fields.count; i++) {
        var field = fields[i];

        // Handle different field types with null checks
        if (field is PdfTextBoxField && formData.containsKey(field.name)) {
          final value = formData[field.name];
          field.text = value?.toString() ?? '';
        } else if (field is PdfRadioButtonListField &&
            formData.containsKey(field.name)) {
          final value = formData[field.name];
          if (value != null && value is int) {
            // Validate index is within bounds
            if (value >= 0 && value < field.items.count) {
              field.selectedIndex = value;
              print('Set ${field.name} to index $value');
            } else {
              print(
                'Warning: Index $value out of bounds for ${field.name} (max: ${field.items.count - 1})',
              );
            }
          }
        } else if (field is PdfCheckBoxField &&
            formData.containsKey(field.name)) {
          final value = formData[field.name];
          field.isChecked = value == true;
        }
      }

      // Save the document to a temporary file
      final directory = await getTemporaryDirectory();
      final outputPath = '${directory.path}/filled_form.pdf';
      await File(outputPath).writeAsBytes(await document.save());

      // Dispose the document
      document.dispose();

      return outputPath;
    } catch (e) {
      throw Exception('Error filling PDF form: $e');
    }
  }
}
