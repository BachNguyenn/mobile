import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';

class HandwritingPoint {
  final Offset offset;
  final int timestamp;

  const HandwritingPoint({required this.offset, required this.timestamp});
}

final handwritingServiceProvider = Provider((ref) {
  final service = HandwritingService();
  ref.onDispose(() => service.dispose());
  return service;
});

class HandwritingService {
  static const _languageCode = 'ja';

  final DigitalInkRecognizer _recognizer = DigitalInkRecognizer(
    languageCode: _languageCode,
  );
  final DigitalInkRecognizerModelManager _modelManager =
      DigitalInkRecognizerModelManager();

  bool _isModelReady = false;

  Future<String?> recognize(List<List<HandwritingPoint>> strokes) async {
    final candidates = await recognizeCandidates(strokes);
    return candidates.isEmpty ? null : candidates.first;
  }

  Future<List<String>> recognizeCandidates(
    List<List<HandwritingPoint>> strokes,
  ) async {
    if (strokes.isEmpty) return const [];
    if (!await _ensureModelReady()) return const [];

    final ink = Ink();
    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;

      final inkStroke = Stroke();
      for (final point in stroke) {
        inkStroke.points.add(
          StrokePoint(
            x: point.offset.dx,
            y: point.offset.dy,
            t: point.timestamp,
          ),
        );
      }
      ink.strokes.add(inkStroke);
    }

    if (ink.strokes.isEmpty) return const [];

    try {
      final candidates = await _recognizer.recognize(ink);
      return candidates.map((candidate) => candidate.text).toList();
    } catch (e) {
      // Handwriting recognition error - failing silently or could use a logger
    }
    return const [];
  }

  Future<bool> _ensureModelReady() async {
    if (_isModelReady) return true;

    try {
      final isDownloaded = await _modelManager.isModelDownloaded(_languageCode);
      _isModelReady =
          isDownloaded || await _modelManager.downloadModel(_languageCode);
      return _isModelReady;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _recognizer.close();
  }
}
