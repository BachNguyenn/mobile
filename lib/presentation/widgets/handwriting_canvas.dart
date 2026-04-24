import 'package:flutter/material.dart';

class HandwritingCanvas extends StatefulWidget {
  final Function(List<List<Offset>>) onDrawingChanged;
  final VoidCallback onClear;

  const HandwritingCanvas({
    super.key,
    required this.onDrawingChanged,
    required this.onClear,
  });

  @override
  State<HandwritingCanvas> createState() => HandwritingCanvasState();
}

class HandwritingCanvasState extends State<HandwritingCanvas> {
  List<List<Offset>> _strokes = [];

  void clear() {
    setState(() {
      _strokes = [];
    });
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          _strokes.add([details.localPosition]);
        });
      },
      onPanUpdate: (details) {
        setState(() {
          if (_strokes.isNotEmpty) {
            _strokes.last.add(details.localPosition);
          }
        });
        widget.onDrawingChanged(_strokes);
      },
      child: CustomPaint(
        painter: HandwritingPainter(strokes: _strokes),
        size: Size.infinite,
      ),
    );
  }
}

class HandwritingPainter extends CustomPainter {
  final List<List<Offset>> strokes;

  HandwritingPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    for (final stroke in strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant HandwritingPainter oldDelegate) => true;
}
