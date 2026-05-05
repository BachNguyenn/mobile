import 'package:flutter/material.dart';
import 'package:mobile/core/services/handwriting_service.dart';
import 'package:mobile/core/theme/app_colors.dart';

class HandwritingCanvas extends StatefulWidget {
  final ValueChanged<List<List<HandwritingPoint>>> onDrawingChanged;
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
  List<List<HandwritingPoint>> _strokes = [];

  void clear() {
    setState(() {
      _strokes = [];
    });
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _strokes.add([_pointFrom(details.localPosition)]);
          });
          widget.onDrawingChanged(_copyStrokes());
        },
        onPanUpdate: (details) {
          setState(() {
            if (_strokes.isNotEmpty) {
              _strokes.last.add(_pointFrom(details.localPosition));
            }
          });
          widget.onDrawingChanged(_copyStrokes());
        },
        onPanEnd: (_) {
          widget.onDrawingChanged(_copyStrokes());
        },
        child: CustomPaint(
          painter: HandwritingPainter(
            strokes: _strokes,
            pointCount: _strokes.fold(0, (sum, s) => sum + s.length),
          ),
          size: Size.infinite,
        ),
      ),
    );
  }

  HandwritingPoint _pointFrom(Offset offset) {
    return HandwritingPoint(
      offset: offset,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  List<List<HandwritingPoint>> _copyStrokes() {
    return _strokes.map((stroke) => List<HandwritingPoint>.of(stroke)).toList();
  }
}

class HandwritingPainter extends CustomPainter {
  final List<List<HandwritingPoint>> strokes;
  final int pointCount;

  HandwritingPainter({required this.strokes, required this.pointCount});

  @override
  void paint(Canvas canvas, Size size) {
    _drawGuides(canvas, size);

    final paint = Paint()
      ..color = Colors.black87
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    for (final stroke in strokes) {
      if (stroke.length == 1) {
        canvas.drawCircle(stroke.first.offset, 2.0, paint);
        continue;
      }

      final path = Path()
        ..moveTo(stroke.first.offset.dx, stroke.first.offset.dy);
      for (int i = 1; i < stroke.length - 1; i++) {
        final current = stroke[i].offset;
        final next = stroke[i + 1].offset;
        final midpoint = Offset(
          (current.dx + next.dx) / 2,
          (current.dy + next.dy) / 2,
        );
        path.quadraticBezierTo(
          current.dx,
          current.dy,
          midpoint.dx,
          midpoint.dy,
        );
      }

      final last = stroke.last.offset;
      path.lineTo(last.dx, last.dy);
      canvas.drawPath(path, paint);
    }
  }

  void _drawGuides(Canvas canvas, Size size) {
    final guidePaint = Paint()
      ..color = AppColors.slateLight.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      guidePaint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      guidePaint,
    );

    final diagonalPaint = Paint()
      ..color = AppColors.slateLight.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset.zero,
      Offset(size.width, size.height),
      diagonalPaint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(0, size.height),
      diagonalPaint,
    );
  }

  @override
  bool shouldRepaint(covariant HandwritingPainter oldDelegate) {
    return oldDelegate.pointCount != pointCount ||
        oldDelegate.strokes.length != strokes.length;
  }
}
