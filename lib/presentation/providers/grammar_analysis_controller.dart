import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/nlp_service.dart';
import '../../domain/entities/japanese_segment.dart';

class GrammarAnalysisState {
  final List<JapaneseSegment> segments;
  final bool isLoading;
  final String? error;

  GrammarAnalysisState({
    this.segments = const [],
    this.isLoading = false,
    this.error,
  });

  GrammarAnalysisState copyWith({
    List<JapaneseSegment>? segments,
    bool? isLoading,
    String? error,
  }) {
    return GrammarAnalysisState(
      segments: segments ?? this.segments,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class GrammarAnalysisController extends AutoDisposeNotifier<GrammarAnalysisState> {
  late final GrammarParserService _parser;

  @override
  GrammarAnalysisState build() {
    _parser = GrammarParserService();
    return GrammarAnalysisState();
  }

  Future<void> analyze(String sentence) async {
    if (sentence.trim().isEmpty) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await _parser.parse(sentence);
      state = state.copyWith(segments: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clear() {
    state = GrammarAnalysisState();
  }
}

final grammarAnalysisControllerProvider =
    NotifierProvider.autoDispose<GrammarAnalysisController, GrammarAnalysisState>(
  GrammarAnalysisController.new,
);
