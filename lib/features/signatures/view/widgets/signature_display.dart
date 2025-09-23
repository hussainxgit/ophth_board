import 'package:flutter/material.dart';

class SignatureDisplay extends StatelessWidget {
  final String? svgData;
  final double? width;
  final double? height;
  final BoxFit fit;

  const SignatureDisplay({
    super.key,
    this.svgData,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    if (svgData == null || svgData!.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.draw_outlined,
                color: Colors.grey,
                size: 24,
              ),
              SizedBox(height: 4),
              Text(
                'No signature',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(8),
      child: CustomPaint(
        painter: SvgSignaturePainter(svgData: svgData!),
        size: Size(width ?? double.infinity, height ?? double.infinity),
      ),
    );
  }
}

class SvgSignaturePainter extends CustomPainter {
  final String svgData;

  SvgSignaturePainter({required this.svgData});

  @override
  void paint(Canvas canvas, Size size) {
    // Parse the SVG data and draw the signature
    final paths = _parseSvgPaths(svgData);
    
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Scale the signature to fit the available space
    final scaleX = size.width / 400; // Original canvas width
    final scaleY = size.height / 200; // Original canvas height
    final scale = (scaleX < scaleY ? scaleX : scaleY) * 0.8; // Leave some padding

    canvas.save();
    canvas.translate(
      (size.width - 400 * scale) / 2,
      (size.height - 200 * scale) / 2,
    );
    canvas.scale(scale);

    for (final path in paths) {
      canvas.drawPath(path, paint);
    }

    canvas.restore();
  }

  List<Path> _parseSvgPaths(String svgData) {
    final paths = <Path>[];
    final pathRegex = RegExp(r'<path d="([^"]*)"');
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
    final path = Path();
    final commands = pathData.split(RegExp(r'(?=[ML])'));
    
    for (final command in commands) {
      if (command.isEmpty) continue;
      
      final type = command[0];
      final coords = command.substring(1).split(RegExp(r'[,\s]+'))
          .where((s) => s.isNotEmpty)
          .map((s) => double.tryParse(s))
          .where((n) => n != null)
          .cast<double>()
          .toList();

      if (coords.length >= 2) {
        if (type == 'M') {
          path.moveTo(coords[0], coords[1]);
        } else if (type == 'L') {
          path.lineTo(coords[0], coords[1]);
        }
      }
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is SvgSignaturePainter && 
           oldDelegate.svgData != svgData;
  }
}