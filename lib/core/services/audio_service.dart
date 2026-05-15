import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AudioService {
  final FlutterTts _tts;
  bool _configured = false;

  AudioService({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  Future<void> speakJapanese(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    await _configure();
    await _tts.stop();
    await _tts.speak(trimmed);
  }

  Future<void> stop() => _tts.stop();

  Future<void> _configure() async {
    if (_configured) return;
    await _tts.setLanguage('ja-JP');
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    _configured = true;
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(service.stop);
  return service;
});
