import 'package:flutter/material.dart';

class SignatureCanvas extends StatefulWidget {
  final String? initialSvgData;
  final Function(String svgData)? onSignatureChanged;
  final Color strokeColor;
  final double strokeWidth;

  const SignatureCanvas({
    super.key,
    this.initialSvgData,
    this.onSignatureChanged,
    this.strokeColor = Colors.black,
    this.strokeWidth = 2.0,
  });

  @override
  State<SignatureCanvas> createState() => SignatureCanvasState();
}

class SignatureCanvasState extends State<SignatureCanvas> {
  final List<List<Offset>> _strokes = [];
  final List<Offset> _currentStroke = [];
  
  @override
  void initState() {
    super.initState();
    if (widget.initialSvgData != null) {
      _loadFromSvgData(widget.initialSvgData!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      color: Colors.grey[50],
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: CustomPaint(
          painter: SignaturePainter(
            strokes: _strokes,
            currentStroke: _currentStroke,
            strokeColor: widget.strokeColor,
            strokeWidth: widget.strokeWidth,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    
    setState(() {
      _currentStroke.clear();
      _currentStroke.add(localPosition);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    
    setState(() {
      _currentStroke.add(localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      if (_currentStroke.isNotEmpty) {
        _strokes.add(List.from(_currentStroke));
        _currentStroke.clear();
        _notifySignatureChanged();
      }
    });
  }

  void clear() {
    setState(() {
      _strokes.clear();
      _currentStroke.clear();
    });
    _notifySignatureChanged();
  }

  void undo() {
    setState(() {
      if (_strokes.isNotEmpty) {
        _strokes.removeLast();
      }
    });
    _notifySignatureChanged();
  }

  bool get isEmpty => _strokes.isEmpty && _currentStroke.isEmpty;

  String _generateSvgData() {
    if (_strokes.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.write('<svg xmlns="http://www.w3.org/2000/svg" width="400" height="200" viewBox="0 0 400 200">');
    
    for (final stroke in _strokes) {
      if (stroke.length < 2) continue;
      
      buffer.write('<path d="M${stroke.first.dx},${stroke.first.dy}');
      for (int i = 1; i < stroke.length; i++) {
        buffer.write(' L${stroke[i].dx},${stroke[i].dy}');
      }
      buffer.write('" stroke="${_colorToHex(widget.strokeColor)}" stroke-width="${widget.strokeWidth}" fill="none" stroke-linecap="round" stroke-linejoin="round"/>');
    }
    
    buffer.write('</svg>');
    return buffer.toString();
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }

  void _loadFromSvgData(String svgData) {
    // This is a simplified SVG parser for our specific format
    // In a production app, you might want to use a proper SVG parsing library
    _strokes.clear();
    
    final pathRegex = RegExp(r'<path d="([^"]*)"');
    final matches = pathRegex.allMatches(svgData);
    
    for (final match in matches) {
      final pathData = match.group(1);
      if (pathData != null) {
        final stroke = _parsePathData(pathData);
        if (stroke.isNotEmpty) {
          _strokes.add(stroke);
        }
      }
    }
    
    setState(() {});
  }

  List<Offset> _parsePathData(String pathData) {
    final stroke = <Offset>[];
    final commands = pathData.split(RegExp(r'[ML]')).where((s) => s.isNotEmpty);
    
    for (final command in commands) {
      final coords = command.split(',');
      if (coords.length == 2) {
        final x = double.tryParse(coords[0]);
        final y = double.tryParse(coords[1]);
        if (x != null && y != null) {
          stroke.add(Offset(x, y));
        }
      }
    }
    
    return stroke;
  }

  void _notifySignatureChanged() {
    if (widget.onSignatureChanged != null) {
      widget.onSignatureChanged!(_generateSvgData());
    }
  }
}

class SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final Color strokeColor;
  final double strokeWidth;

  SignaturePainter({
    required this.strokes,
    required this.currentStroke,
    required this.strokeColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Draw completed strokes
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke, paint);
    }

    // Draw current stroke
    if (currentStroke.isNotEmpty) {
      _drawStroke(canvas, currentStroke, paint);
    }
  }

  void _drawStroke(Canvas canvas, List<Offset> stroke, Paint paint) {
    if (stroke.length < 2) return;

    final path = Path();
    path.moveTo(stroke.first.dx, stroke.first.dy);
    
    for (int i = 1; i < stroke.length; i++) {
      path.lineTo(stroke[i].dx, stroke[i].dy);
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}