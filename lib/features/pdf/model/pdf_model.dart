import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';

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

        // Handle signature fields specially
        if ((field.name == 'resident_signature' || field.name == 'supervisor_signature') && 
            formData.containsKey(field.name)) {
          await _handleSignatureField(document, field, formData[field.name]);
          continue;
        }

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

  Future<void> _handleSignatureField(
    PdfDocument document, 
    PdfField field, 
    dynamic signatureSvgData,
  ) async {
    if (signatureSvgData == null || signatureSvgData.isEmpty) return;

    try {
      // Convert SVG data to image bytes
      final imageBytes = await _convertSvgToImage(signatureSvgData);
      if (imageBytes == null) return;
      
      // Get field bounds
      final bounds = field.bounds;
      
      // Find the page containing this field (assume first page for now)
      if (document.pages.count > 0) {
        final targetPage = document.pages[0];
        
        // Draw signature image on the page
        final PdfBitmap image = PdfBitmap(imageBytes);
        targetPage.graphics.drawImage(
          image,
          Rect.fromLTWH(
            bounds.left,
            bounds.top,
            bounds.width,
            bounds.height,
          ),
        );
      }
    } catch (e) {
      print('Error handling signature field: $e');
    }
  }

  Future<Uint8List?> _convertSvgToImage(String svgData) async {
    try {
      // Parse SVG paths similar to how SignatureDisplay does it
      final paths = _parseSvgPaths(svgData);
      if (paths.isEmpty) return null;

      // Create a picture recorder to draw the signature
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      
      // Set up paint for signature
      final paint = Paint()
        ..color = Colors.black
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      // Draw all paths
      for (final path in paths) {
        canvas.drawPath(path, paint);
      }

      // Convert to image
      final picture = recorder.endRecording();
      final image = await picture.toImage(400, 200); // Standard signature size
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      picture.dispose();
      image.dispose();
      
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Error converting SVG to image: $e');
      return null;
    }
  }

  List<Path> _parseSvgPaths(String svgData) {
    final List<Path> paths = [];
    
    // Extract path data from SVG using regex
    final pathRegex = RegExp(r'd="([^"]*)"');
    final matches = pathRegex.allMatches(svgData);
    
    for (final match in matches) {
      final pathData = match.group(1);
      if (pathData != null) {
        final path = _parsePathData(pathData);
        if (path != null) {
          paths.add(path);
        }
      }
    }
    
    return paths;
  }

  Path? _parsePathData(String pathData) {
    try {
      final path = Path();
      final commands = pathData.split(RegExp(r'(?=[MLZ])'));
      
      for (final command in commands) {
        if (command.isEmpty) continue;
        
        final type = command[0];
        final coords = command.substring(1).trim();
        
        if (type == 'M') {
          // Move to
          final parts = coords.split(',');
          if (parts.length >= 2) {
            final x = double.tryParse(parts[0]) ?? 0;
            final y = double.tryParse(parts[1]) ?? 0;
            path.moveTo(x, y);
          }
        } else if (type == 'L') {
          // Line to
          final lines = coords.split(' ');
          for (final line in lines) {
            final parts = line.split(',');
            if (parts.length >= 2) {
              final x = double.tryParse(parts[0]) ?? 0;
              final y = double.tryParse(parts[1]) ?? 0;
              path.lineTo(x, y);
            }
          }
        }
      }
      
      return path;
    } catch (e) {
      print('Error parsing path data: $e');
      return null;
    }
  }
}
