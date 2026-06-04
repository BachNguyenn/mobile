import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/services/app_logger.dart';
import 'package:mobile/core/services/handwriting_service.dart';
import 'package:mobile/features/grammar/application/providers/grammar_library_provider.dart';
import 'package:mobile/features/kanji/application/providers/kanji_library_provider.dart';
import 'package:mobile/features/learning/domain/services/quiz_answer_normalizer.dart';
import 'package:mobile/features/review/domain/entities/review_item.dart';
import 'package:mobile/features/review/application/providers/study_event_provider.dart';
import 'package:mobile/features/vocabulary/application/providers/vocabulary_library_provider.dart';

class ReviewState {
  final int currentIndex;
  final bool showAnswer;
  final List<List<HandwritingPoint>> currentStrokes;
  final String? recognizedText;
  final String? selectedChoice;
  final String typedAnswer;
  final bool isFinished;
  final bool isSubmitting;
  final String? errorMessage;

  ReviewState({
    this.currentIndex = 0,
    this.showAnswer = false,
    this.currentStrokes = const [],
    this.recognizedText,
    this.selectedChoice,
    this.typedAnswer = '',
    this.isFinished = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  ReviewState copyWith({
    int? currentIndex,
    bool? showAnswer,
    List<List<HandwritingPoint>>? currentStrokes,
    String? recognizedText,
    String? selectedChoice,
    String? typedAnswer,
    bool? isFinished,
    bool? isSubmitting,
    String? errorMessage,
    bool clearAnswerData = false,
    bool clearError = false,
  }) {
    return ReviewState(
      currentIndex: currentIndex ?? this.currentIndex,
      showAnswer: showAnswer ?? this.showAnswer,
      currentStrokes: currentStrokes ?? this.currentStrokes,
      recognizedText: clearAnswerData
          ? null
          : recognizedText ?? this.recognizedText,
      selectedChoice: clearAnswerData
          ? null
          : selectedChoice ?? this.selectedChoice,
      typedAnswer: clearAnswerData ? '' : typedAnswer ?? this.typedAnswer,
      isFinished: isFinished ?? this.isFinished,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class ReviewController extends FamilyNotifier<ReviewState, List<ReviewItem>> {
  @override
  ReviewState build(List<ReviewItem> arg) {
    return ReviewState();
  }

  void onDrawingChanged(List<List<HandwritingPoint>> strokes) {
    state = state.copyWith(currentStrokes: strokes);
  }

  void selectChoice(String choice) {
    if (state.showAnswer) return;
    state = state.copyWith(selectedChoice: choice);
  }

  void setTypedAnswer(String value) {
    if (state.showAnswer) return;
    state = state.copyWith(typedAnswer: value);
  }

  Future<void> handleCheck() async {
    if (arg.isEmpty || state.currentIndex >= arg.length) return;
    final item = arg[state.currentIndex];
    String? text;
    if (item.usesHandwriting) {
      text = await ref
          .read(handwritingServiceProvider)
          .recognize(state.currentStrokes);
    } else if (state.typedAnswer.trim().isNotEmpty) {
      text = state.typedAnswer.trim();
    } else {
      text = state.selectedChoice;
    }
    state = state.copyWith(
      recognizedText: text,
      showAnswer: true,
      clearError: true,
    );
  }

  bool get isTypedAnswerCorrect {
    if (arg.isEmpty || state.currentIndex >= arg.length) return false;
    final item = arg[state.currentIndex];
    return QuizAnswerNormalizer.isCorrect(state.typedAnswer, item.answer);
  }

  Future<void> handleRating(int rating) async {
    final items = arg;
    if (items.isEmpty || state.currentIndex >= items.length) return;
    if (state.isSubmitting) return;

    final item = items[state.currentIndex];
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      switch (item.type) {
        case ReviewItemType.kanji:
          await ref.read(emitKanjiStudyEventProvider)(item.id, rating);
          break;
        case ReviewItemType.vocabulary:
          await ref.read(emitVocabularyStudyEventProvider)(item.id, rating);
          break;
        case ReviewItemType.grammar:
          await ref.read(emitGrammarStudyEventProvider)(item.id, rating);
          break;
        case ReviewItemType.sentence:
          ref.read(emitSentenceStudyEventProvider)(item.id);
          break;
      }
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to submit review rating',
        error: error,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Không thể lưu kết quả ôn tập. Vui lòng thử lại.',
      );
      return;
    }

    if (state.currentIndex < items.length - 1) {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        showAnswer: false,
        currentStrokes: [],
        isSubmitting: false,
        clearAnswerData: true,
        clearError: true,
      );
    } else {
      state = state.copyWith(isSubmitting: false, isFinished: true);
    }
  }

  void resetCanvas() {
    state = state.copyWith(currentStrokes: []);
  }
}

final reviewControllerProvider =
    NotifierProvider.family<ReviewController, ReviewState, List<ReviewItem>>(
      ReviewController.new,
    );
