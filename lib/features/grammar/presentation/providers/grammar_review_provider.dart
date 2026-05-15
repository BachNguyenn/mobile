import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/services/app_logger.dart';
import 'package:mobile/features/grammar/domain/entities/grammar_point.dart';
import 'package:mobile/features/grammar/presentation/providers/grammar_library_provider.dart';

class GrammarReviewDeck extends Equatable {
  final List<GrammarPoint> items;
  final List<GrammarPoint> allGrammar;

  const GrammarReviewDeck({required this.items, required this.allGrammar});

  @override
  List<Object?> get props => [items, allGrammar];
}

class GrammarReviewQuestion extends Equatable {
  final GrammarPoint grammar;
  final String prompt;
  final String answer;
  final List<String> options;
  final GrammarExample? example;
  final String? hint;
  final String? explanation;

  const GrammarReviewQuestion({
    required this.grammar,
    required this.prompt,
    required this.answer,
    required this.options,
    this.example,
    this.hint,
    this.explanation,
  });

  @override
  List<Object?> get props => [
    grammar,
    prompt,
    answer,
    options,
    example,
    hint,
    explanation,
  ];
}

class GrammarReviewState {
  final List<GrammarReviewQuestion> questions;
  final int currentIndex;
  final String? selectedAnswer;
  final bool isAnswerChecked;
  final bool isCorrect;
  final bool isFinished;
  final bool isSubmitting;
  final String? errorMessage;
  final Set<String> submittedGrammarIds;

  const GrammarReviewState({
    this.questions = const [],
    this.currentIndex = 0,
    this.selectedAnswer,
    this.isAnswerChecked = false,
    this.isCorrect = false,
    this.isFinished = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.submittedGrammarIds = const {},
  });

  GrammarReviewQuestion? get currentQuestion {
    if (questions.isEmpty || currentIndex >= questions.length) return null;
    return questions[currentIndex];
  }

  double get progress =>
      questions.isEmpty ? 0 : (currentIndex + 1) / questions.length;

  GrammarReviewState copyWith({
    List<GrammarReviewQuestion>? questions,
    int? currentIndex,
    String? selectedAnswer,
    bool clearSelectedAnswer = false,
    bool? isAnswerChecked,
    bool? isCorrect,
    bool? isFinished,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    Set<String>? submittedGrammarIds,
  }) {
    return GrammarReviewState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswer: clearSelectedAnswer
          ? null
          : selectedAnswer ?? this.selectedAnswer,
      isAnswerChecked: isAnswerChecked ?? this.isAnswerChecked,
      isCorrect: isCorrect ?? this.isCorrect,
      isFinished: isFinished ?? this.isFinished,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      submittedGrammarIds: submittedGrammarIds ?? this.submittedGrammarIds,
    );
  }
}

class GrammarReviewQuestionGenerator {
  const GrammarReviewQuestionGenerator();

  List<GrammarReviewQuestion> generate({
    required List<GrammarPoint> items,
    required List<GrammarPoint> allGrammar,
  }) {
    final pool = allGrammar.isEmpty ? items : allGrammar;
    return items
        .map(
          (grammar) => GrammarReviewQuestion(
            grammar: grammar,
            prompt: _promptFor(grammar),
            answer: _answerFor(grammar),
            options: _optionsFor(grammar, pool),
            example: grammar.examples.isNotEmpty
                ? grammar.examples.first
                : null,
            hint: grammar.formation.trim().isEmpty
                ? null
                : 'Cấu trúc: ${grammar.formation}',
            explanation: _explanationFor(grammar),
          ),
        )
        .where((question) => question.answer.trim().isNotEmpty)
        .toList();
  }

  String _promptFor(GrammarPoint grammar) {
    if (grammar.examples.isNotEmpty && grammar.examples.first.jp.isNotEmpty) {
      return 'Trong câu này, mẫu ${grammar.title} đang diễn tả ý nào?';
    }
    if (grammar.formation.trim().isNotEmpty) {
      return 'Mẫu ${grammar.title} có cách dùng/cấu trúc nào phù hợp?';
    }
    return 'Mẫu ${grammar.title} dùng để diễn tả ý nào?';
  }

  String _answerFor(GrammarPoint grammar) {
    final candidates = [
      grammar.shortExplanation,
      grammar.longExplanation,
      grammar.formation,
      grammar.title,
    ];
    return candidates.firstWhere(
      (value) => value.trim().isNotEmpty,
      orElse: () => '',
    );
  }

  List<String> _optionsFor(GrammarPoint grammar, List<GrammarPoint> pool) {
    final answer = _answerFor(grammar);
    final distractors = <String>[];

    for (final candidate in pool) {
      final option = _answerFor(candidate);
      if (option.trim().isEmpty || option == answer) continue;
      if (distractors.contains(option)) continue;
      distractors.add(option);
      if (distractors.length == 3) break;
    }

    final options = [...distractors];
    final insertAt = options.isEmpty
        ? 0
        : grammar.id.length % (options.length + 1);
    options.insert(insertAt, answer);
    return options;
  }

  String? _explanationFor(GrammarPoint grammar) {
    final parts = <String>[
      if (grammar.shortExplanation.trim().isNotEmpty)
        'Ý nghĩa: ${grammar.shortExplanation}',
      if (grammar.formation.trim().isNotEmpty) 'Cấu trúc: ${grammar.formation}',
      if (grammar.longExplanation.trim().isNotEmpty) grammar.longExplanation,
    ];
    return parts.isEmpty ? null : parts.join('\n\n');
  }
}

class GrammarReviewController
    extends FamilyNotifier<GrammarReviewState, GrammarReviewDeck> {
  @override
  GrammarReviewState build(GrammarReviewDeck arg) {
    final questions = const GrammarReviewQuestionGenerator().generate(
      items: arg.items,
      allGrammar: arg.allGrammar,
    );
    return GrammarReviewState(questions: questions);
  }

  void selectAnswer(String answer) {
    if (state.isAnswerChecked || state.isSubmitting) return;
    state = state.copyWith(selectedAnswer: answer, clearError: true);
  }

  void checkAnswer() {
    final question = state.currentQuestion;
    if (question == null || state.isAnswerChecked) return;
    final selected = state.selectedAnswer;
    if (selected == null) return;

    state = state.copyWith(
      isAnswerChecked: true,
      isCorrect: selected == question.answer,
      clearError: true,
    );
  }

  Future<void> rateCurrent(int rating) async {
    final question = state.currentQuestion;
    if (question == null || !state.isAnswerChecked || state.isSubmitting) {
      return;
    }

    final grammarId = question.grammar.id;
    if (state.submittedGrammarIds.contains(grammarId)) {
      _advance();
      return;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      await ref.read(emitGrammarStudyEventProvider)(grammarId, rating);
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to submit grammar review rating',
        error: error,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Không thể lưu kết quả ôn tập. Vui lòng thử lại.',
      );
      return;
    }

    final submitted = {...state.submittedGrammarIds, grammarId};
    state = state.copyWith(
      isSubmitting: false,
      submittedGrammarIds: submitted,
      clearError: true,
    );
    _advance();
  }

  void _advance() {
    if (state.currentIndex < state.questions.length - 1) {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        selectedAnswer: null,
        clearSelectedAnswer: true,
        isAnswerChecked: false,
        isCorrect: false,
        isSubmitting: false,
        clearError: true,
      );
      return;
    }

    state = state.copyWith(isFinished: true, isSubmitting: false);
  }
}

final grammarReviewControllerProvider =
    NotifierProvider.family<
      GrammarReviewController,
      GrammarReviewState,
      GrammarReviewDeck
    >(GrammarReviewController.new);
