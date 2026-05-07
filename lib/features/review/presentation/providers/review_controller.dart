import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/services/handwriting_service.dart';
import 'package:mobile/features/grammar/presentation/providers/grammar_library_provider.dart';
import 'package:mobile/features/kanji/presentation/providers/kanji_library_provider.dart';
import 'package:mobile/features/learning/domain/services/quiz_answer_normalizer.dart';
import 'package:mobile/features/review/domain/entities/review_item.dart';
import 'package:mobile/features/review/presentation/providers/study_event_provider.dart';
import 'package:mobile/features/vocabulary/presentation/providers/vocabulary_library_provider.dart';

class ReviewState {
  final int currentIndex;
  final bool showAnswer;
  final List<List<HandwritingPoint>> currentStrokes;
  final String? recognizedText;
  final String? selectedChoice;
  final String typedAnswer;
  final bool isFinished;

  ReviewState({
    this.currentIndex = 0,
    this.showAnswer = false,
    this.currentStrokes = const [],
    this.recognizedText,
    this.selectedChoice,
    this.typedAnswer = '',
    this.isFinished = false,
  });

  ReviewState copyWith({
    int? currentIndex,
    bool? showAnswer,
    List<List<HandwritingPoint>>? currentStrokes,
    String? recognizedText,
    String? selectedChoice,
    String? typedAnswer,
    bool? isFinished,
    bool clearAnswerData = false,
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
    state = state.copyWith(recognizedText: text, showAnswer: true);
  }

  bool get isTypedAnswerCorrect {
    final item = arg[state.currentIndex];
    return QuizAnswerNormalizer.isCorrect(state.typedAnswer, item.answer);
  }

  void handleRating(int rating) {
    final items = arg;
    final item = items[state.currentIndex];
    switch (item.type) {
      case ReviewItemType.kanji:
        ref.read(emitKanjiStudyEventProvider)(item.id, rating);
        break;
      case ReviewItemType.vocabulary:
        ref.read(emitVocabularyStudyEventProvider)(item.id, rating);
        break;
      case ReviewItemType.grammar:
        ref.read(emitGrammarStudyEventProvider)(item.id, rating);
        break;
      case ReviewItemType.sentence:
        ref.read(emitSentenceStudyEventProvider)(item.id);
        break;
    }

    if (state.currentIndex < items.length - 1) {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        showAnswer: false,
        currentStrokes: [],
        clearAnswerData: true,
      );
    } else {
      state = state.copyWith(isFinished: true);
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
