import 'dart:ui';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';

class HandwritingService {
  final DigitalInkRecognizer _recognizer = DigitalInkRecognizer(languageCode: 'ja');

  Future<String?> recognize(List<List<Offset>> strokes) async {
    if (strokes.isEmpty) return null;

    final ink = Ink();
    for (final stroke in strokes) {
      final inkStroke = Stroke();
      for (final point in stroke) {
        // Trying StrokePoint as a common variation in ML Kit SDKs
        inkStroke.points.add(StrokePoint(
          x: point.dx, 
          y: point.dy, 
          t: DateTime.now().millisecondsSinceEpoch
        ));
      }
      ink.strokes.add(inkStroke);
    }

    try {
      final candidates = await _recognizer.recognize(ink);
      if (candidates.isNotEmpty) {
        return candidates.first.text;
      }
    } catch (e) {
      // Handwriting recognition error - failing silently or could use a logger
    }
    return null;
  }

  void dispose() {
    _recognizer.close();
  }
}
