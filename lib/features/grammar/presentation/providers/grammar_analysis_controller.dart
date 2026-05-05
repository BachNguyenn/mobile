import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/nlp_service.dart';
import '../../../../domain/entities/japanese_segment.dart';

const _unset = Object();

class GrammarAnalysisState {
  final List<JapaneseSegment> segments;
  final bool isLoading;
  final String? error;
  final String lastQuery;

  GrammarAnalysisState({
    this.segments = const [],
    this.isLoading = false,
    this.error,
    this.lastQuery = '',
  });

  GrammarAnalysisState copyWith({
    List<JapaneseSegment>? segments,
    bool? isLoading,
    Object? error = _unset,
    String? lastQuery,
  }) {
    return GrammarAnalysisState(
      segments: segments ?? this.segments,
      isLoading: isLoading ?? this.isLoading,
      error: error == _unset ? this.error : error as String?,
      lastQuery: lastQuery ?? this.lastQuery,
    );
  }
}

class GrammarAnalysisController
    extends AutoDisposeNotifier<GrammarAnalysisState> {
  late final JapaneseTutorService _parser;

  @override
  GrammarAnalysisState build() {
    _parser = ref.read(grammarParserServiceProvider);
    return GrammarAnalysisState();
  }

  Future<void> analyze(String sentence) async {
    final query = sentence.trim();
    if (query.isEmpty || state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null, lastQuery: query);
    try {
      final results = await _parser.parse(query);
      state = state.copyWith(segments: results, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clear() {
    state = GrammarAnalysisState();
  }
}

final grammarAnalysisControllerProvider =
    NotifierProvider.autoDispose<
      GrammarAnalysisController,
      GrammarAnalysisState
    >(GrammarAnalysisController.new);
