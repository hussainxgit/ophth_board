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
      print('=== Processing PDF Form Fields ===');
      print('Total fields found: ${fields.count}');
      
      for (int i = 0; i < fields.count; i++) {
        var field = fields[i];
        print('Field $i: name="${field.name}", type=${field.runtimeType}');

        // Handle signature fields specially
        if ((field.name == 'resident_signature' || field.name == 'supervisor_resident' || field.name == 'supervisor_signature') && 
            formData.containsKey(field.name)) {
          print('Found signature field: ${field.name}');
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

      print('=== Finished Processing PDF Form Fields ===');

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

  /// Debug helper: returns the names of all form fields in the given PDF template.
  Future<List<String>> listPdfFormFields(
    BuildContext context, {
    String templateAsset = 'assets/pdf_forms/form_template.pdf',
  }) async {
    try {
      final bytes = await DefaultAssetBundle.of(context).load(templateAsset);
      final PdfDocument document = PdfDocument(
        inputBytes: bytes.buffer.asUint8List(),
      );

      final PdfForm form = document.form;
      final PdfFormFieldCollection fields = form.fields;
      final List<String> names = [];
      for (int i = 0; i < fields.count; i++) {
        final field = fields[i];
        names.add(field.name ?? '<unnamed_field_$i>');
      }

      document.dispose();
      return names;
    } catch (e) {
      print('Error listing PDF form fields: $e');
      return [];
    }
  }

  Future<void> _handleSignatureField(
    PdfDocument document, 
    PdfField field, 
    dynamic signatureSvgData,
  ) async {
    if (signatureSvgData == null || signatureSvgData.isEmpty) {
      print('No signature data provided for field: ${field.name}');
      return;
    }

    try {
      print('Processing signature field: ${field.name}');
      print('Signature SVG data preview: ${signatureSvgData.toString().substring(0, signatureSvgData.toString().length > 200 ? 200 : signatureSvgData.toString().length)}...');
      
      // Convert SVG data to image bytes
      final imageBytes = await _convertSvgToImage(signatureSvgData);
      if (imageBytes == null) {
        print('Failed to convert SVG to image for field: ${field.name}');
        return;
      }
      
      print('Successfully converted SVG to image (${imageBytes.length} bytes)');
      
      // Get field bounds
      final bounds = field.bounds;
      print('Field bounds: ${bounds.toString()}');
      
      // Find the correct page for this signature field
      PdfPage? targetPage;
      
      // Try to get the page from the field directly if possible
      if (field is PdfSignatureField && field.page != null) {
        targetPage = field.page!;
        print('Found signature field on its designated page');
      } else {
        // Fallback: use the first page (most signature fields are on the first page)
        if (document.pages.count > 0) {
          targetPage = document.pages[0];
          print('Using first page as fallback for signature field');
        }
      }
      
      if (targetPage != null) {
        // Draw signature image on the page
        final PdfBitmap image = PdfBitmap(imageBytes);
        
        print('Drawing signature at bounds: ${bounds.toString()}');
        print('Page size: ${targetPage.size}');
        
        // Clear the signature field background (optional)
        try {
          final clearPaint = PdfSolidBrush(PdfColor(255, 255, 255)); // White background
          targetPage.graphics.drawRectangle(brush: clearPaint, bounds: bounds);
          print('Cleared signature field background');
        } catch (e) {
          print('Could not clear signature field background: $e');
        }
        
        // Try using field bounds directly first
        try {
          targetPage.graphics.drawImage(image, bounds);
          print('Successfully drew signature using field bounds directly');
        } catch (e) {
          print('Direct field bounds failed, trying manual positioning: $e');
          
          // Fallback: Manual coordinate calculation
          // PDF coordinates are from bottom-left, field bounds might be from top-left
          final pageHeight = targetPage.size.height;
          final adjustedY = pageHeight - bounds.top - bounds.height;
          
          final adjustedBounds = Rect.fromLTWH(
            bounds.left,
            adjustedY,
            bounds.width,
            bounds.height,
          );
          
          print('Adjusted bounds: ${adjustedBounds.toString()}');
          targetPage.graphics.drawImage(image, adjustedBounds);
          print('Successfully drew signature using adjusted coordinates');
        }
      } else {
        print('No suitable page found for signature field');
      }
    } catch (e) {
      print('Error handling signature field ${field.name}: $e');
    }
  }

  Future<Uint8List?> _convertSvgToImage(String svgData) async {
    try {
      print('Converting SVG to image...');
      
      // Parse SVG paths similar to how SignatureDisplay does it
      final paths = _parseSvgPaths(svgData);
      print('Extracted ${paths.length} paths from SVG data');
      
      if (paths.isEmpty) {
        print('No paths found in SVG data');
        return null;
      }

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
      
      final result = byteData?.buffer.asUint8List();
      print('Successfully converted SVG to ${result?.length ?? 0} byte PNG');
      return result;
    } catch (e) {
      print('Error converting SVG to image: $e');
      return null;
    }
  }

  List<Path> _parseSvgPaths(String svgData) {
    final List<Path> paths = [];
    
    print('Parsing SVG data: ${svgData.substring(0, svgData.length > 500 ? 500 : svgData.length)}...');
    
    // Extract path data from SVG using regex - match the format used by SignatureDisplay
    final pathRegex = RegExp(r'<path d="([^"]*)"');
    final matches = pathRegex.allMatches(svgData);
    
    print('Found ${matches.length} path matches in SVG');
    
    for (final match in matches) {
      final pathData = match.group(1);
      print('Processing path data: $pathData');
      if (pathData != null) {
        final path = _parsePathData(pathData);
        if (path != null) {
          paths.add(path);
          print('Successfully parsed path');
        } else {
          print('Failed to parse path data: $pathData');
        }
      }
    }
    
    return paths;
  }

  Path? _parsePathData(String pathData) {
    try {
      final path = Path();
      
      // Split the path data by commands, similar to SignatureDisplay implementation
      final commands = pathData.split(RegExp(r'(?=[ML])'));
      
      print('Path has ${commands.length} commands');
      
      for (final command in commands) {
        if (command.isEmpty) continue;
        
        final type = command[0];
        final coords = command.substring(1).trim();
              
        if (type == 'M') {
          // Move to - handle single coordinate pair
          final parts = coords.split(',');
          if (parts.length >= 2) {
            final x = double.tryParse(parts[0]) ?? 0;
            final y = double.tryParse(parts[1]) ?? 0;
            path.moveTo(x, y);
          }
        } else if (type == 'L') {
          // Line to - handle multiple coordinate pairs separated by spaces
          final coordinatePairs = coords.split(' ').where((s) => s.isNotEmpty);
          for (final coordPair in coordinatePairs) {
            final parts = coordPair.split(',');
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
      print('Error parsing path data "$pathData": $e');
      return null;
    }
  }
}
