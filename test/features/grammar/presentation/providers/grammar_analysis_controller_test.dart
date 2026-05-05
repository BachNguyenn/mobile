import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/services/nlp_service.dart';
import 'package:mobile/domain/entities/japanese_segment.dart';
import 'package:mobile/features/grammar/presentation/providers/grammar_analysis_controller.dart';

void main() {
  group('GrammarAnalysisController', () {
    test('does not call the AI service for an empty sentence', () async {
      final service = _FakeTutorService(result: const []);
      final container = _containerWith(service);
      addTearDown(container.dispose);

      await container
          .read(grammarAnalysisControllerProvider.notifier)
          .analyze('   ');

      expect(service.calls, 0);
      expect(
        container.read(grammarAnalysisControllerProvider).segments,
        isEmpty,
      );
    });

    test('updates state with segments after a successful analysis', () async {
      final service = _FakeTutorService(
        result: [
          JapaneseSegment(
            text: '私',
            reading: 'わたし',
            type: 'Đại từ',
            baseForm: '私',
            explanation: 'Tôi',
          ),
        ],
      );
      final container = _containerWith(service);
      addTearDown(container.dispose);

      await container
          .read(grammarAnalysisControllerProvider.notifier)
          .analyze(' 私 ');

      final state = container.read(grammarAnalysisControllerProvider);
      expect(service.calls, 1);
      expect(service.lastSentence, '私');
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.lastQuery, '私');
      expect(state.segments.single.text, '私');
    });

    test('stores the service error and stops loading', () async {
      final service = _FakeTutorService(
        error: const AiTutorException('Không kết nối được Ollama'),
      );
      final container = _containerWith(service);
      addTearDown(container.dispose);

      await container
          .read(grammarAnalysisControllerProvider.notifier)
          .analyze('私は学生です。');

      final state = container.read(grammarAnalysisControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.error, 'Không kết nối được Ollama');
      expect(state.segments, isEmpty);
    });
  });
}

ProviderContainer _containerWith(JapaneseTutorService service) {
  return ProviderContainer(
    overrides: [grammarParserServiceProvider.overrideWithValue(service)],
  );
}

class _FakeTutorService implements JapaneseTutorService {
  final List<JapaneseSegment> result;
  final Object? error;
  int calls = 0;
  String? lastSentence;

  _FakeTutorService({this.result = const [], this.error});

  @override
  Future<List<JapaneseSegment>> parse(String sentence) async {
    calls += 1;
    lastSentence = sentence;
    final error = this.error;
    if (error != null) throw error;
    return result;
  }
}
