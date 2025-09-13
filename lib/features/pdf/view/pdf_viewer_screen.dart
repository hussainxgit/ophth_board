import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfPath;
  final String? title;
  final String? filenamePrefix;

  const PdfViewerScreen({
    super.key,
    required this.pdfPath,
    this.title,
    this.filenamePrefix,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'PDF Viewer'),
        actions: [
          // Share button
          IconButton(icon: const Icon(Icons.share), onPressed: _shareFile),
          // Download button
          IconButton(
            icon: _isDownloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            onPressed: _isDownloading ? null : _downloadFile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: AbsorbPointer(
            child: GestureDetector(
              onTap: () {},
              onDoubleTap: () {},
              onLongPress: () {},
              onPanStart: (_) {},
              onPanUpdate: (_) {},
              onPanEnd: (_) {},
              child: SfPdfViewer.file(
                File(widget.pdfPath),
                canShowPaginationDialog: false,
                canShowScrollHead: false,
                canShowScrollStatus: false,
                enableTextSelection: false,
                enableDocumentLinkAnnotation: false,
                enableHyperlinkNavigation: false,
                canShowPasswordDialog: false,
                interactionMode: PdfInteractionMode.pan,
                initialZoomLevel: 1.0,
                enableDoubleTapZooming: false,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _shareFile() async {
    try {
      final file = File(widget.pdfPath);
      if (await file.exists()) {
        final subject = widget.filenamePrefix ?? 'form';
        final text = 'Please find the attached ${widget.title ?? 'form'}.';
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(widget.pdfPath)],
            subject: subject,
            text: text,
          ),
        );
      } else {
        _showMessage('File not found');
      }
    } catch (e) {
      _showMessage('Error sharing file: $e');
    }
  }

  Future<void> _downloadFile() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      // Request storage permission
      final permission = await _requestStoragePermission();
      if (!permission) {
        _showMessage('Storage permission required to download');
        return;
      }

      // Get downloads directory
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          downloadsDir = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      if (downloadsDir == null) {
        _showMessage('Unable to access downloads directory');
        return;
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${widget.filenamePrefix ?? 'form'}_$timestamp.pdf';
      final downloadPath = '${downloadsDir.path}/$fileName';

      // Copy file to downloads
      final sourceFile = File(widget.pdfPath);
      await sourceFile.copy(downloadPath);

      _showMessage(
        'PDF downloaded to: ${Platform.isIOS ? 'Files app' : 'Downloads folder'}',
      );
    } catch (e) {
      _showMessage('Download failed: $e');
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isIOS) {
      return true; // iOS handles permissions differently
    }

    // For Android
    if (await Permission.storage.isGranted) {
      return true;
    }

    // Request permission for Android 10 and below
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 29) {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
      // Android 11+ doesn't need storage permission for Downloads folder
      return true;
    }

    return false;
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
      );
    }
  }
}
