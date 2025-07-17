import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PdfModel {
  Future<String> fillPdfForm(
    BuildContext context,
    Map<String, dynamic> formData,
  ) async {
    try {
      // Load the PDF document from assets
      final bytes = await DefaultAssetBundle.of(
        context,
      ).load('assets/pdf_forms/form_template.pdf');
      final PdfDocument document = PdfDocument(
        inputBytes: bytes.buffer.asUint8List(),
      );

      // Get the form
      PdfForm form = document.form;

      // Fill form fields based on provided data
      PdfFormFieldCollection fields = form.fields;
      for (int i = 0; i < fields.count; i++) {
        var field = fields[i];
        print('Field Name: ${field.name}, type: ${field.runtimeType} items: $field');
        if (field is PdfTextBoxField && formData.containsKey(field.name)) {
          field.text = formData[field.name] as String;
        } else if (field is PdfRadioButtonListField &&
            formData.containsKey(field.name)) {
          field.selectedIndex = formData[field.name] as int;
        } else if (field is PdfCheckBoxField &&
            formData.containsKey(field.name)) {
          field.isChecked = formData[field.name] as bool;
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
