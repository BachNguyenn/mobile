import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/kanji_card.dart';
import '../../core/services/handwriting_service.dart';
import 'kanji_library_provider.dart';

class ReviewState {
  final int currentIndex;
  final bool showAnswer;
  final List<List<Offset>> currentStrokes;
  final String? recognizedText;
  final bool isFinished;

  ReviewState({
    this.currentIndex = 0,
    this.showAnswer = false,
    this.currentStrokes = const [],
    this.recognizedText,
    this.isFinished = false,
  });

  ReviewState copyWith({
    int? currentIndex,
    bool? showAnswer,
    List<List<Offset>>? currentStrokes,
    String? recognizedText,
    bool? isFinished,
  }) {
    return ReviewState(
      currentIndex: currentIndex ?? this.currentIndex,
      showAnswer: showAnswer ?? this.showAnswer,
      currentStrokes: currentStrokes ?? this.currentStrokes,
      recognizedText: recognizedText ?? this.recognizedText,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}

class ReviewController extends FamilyNotifier<ReviewState, List<KanjiCard>> {

  @override
  ReviewState build(List<KanjiCard> arg) {
    // HandwritingService is now provided via handwritingServiceProvider
    return ReviewState();
  }

  void onDrawingChanged(List<List<Offset>> strokes) {
    state = state.copyWith(currentStrokes: strokes);
  }

  Future<void> handleCheck() async {
    final text = await ref.read(handwritingServiceProvider).recognize(state.currentStrokes);
    state = state.copyWith(
      recognizedText: text,
      showAnswer: true,
    );
  }

  void handleRating(int rating) {
    final cards = arg;
    ref.read(emitKanjiStudyEventProvider)(cards[state.currentIndex].id, rating);

    if (state.currentIndex < cards.length - 1) {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        showAnswer: false,
        recognizedText: null,
        currentStrokes: [],
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
    NotifierProvider.family<ReviewController, ReviewState, List<KanjiCard>>(
  ReviewController.new,
);
