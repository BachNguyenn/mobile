import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/kanji_card.dart';
import '../../core/services/handwriting_service.dart';
import 'kanji_library_provider.dart';
import 'learning_path_provider.dart';

enum QuizType { meaning, kanji, handwriting }

class QuizQuestion {
  final KanjiCard targetCard;
  final QuizType type;
  final List<KanjiCard> options;

  QuizQuestion({required this.targetCard, required this.type, this.options = const []});
}

class LessonState {
  final List<QuizQuestion> questions;
  final int currentIndex;
  final bool isAnswerChecked;
  final bool isCorrect;
  final String? selectedAnswerId;
  final List<List<Offset>> currentStrokes;
  final String? recognizedText;
  final bool isFinished;

  LessonState({
    this.questions = const [],
    this.currentIndex = 0,
    this.isAnswerChecked = false,
    this.isCorrect = false,
    this.selectedAnswerId,
    this.currentStrokes = const [],
    this.recognizedText,
    this.isFinished = false,
  });

  double get progress => questions.isEmpty ? 0 : (currentIndex + 1) / questions.length;

  LessonState copyWith({
    List<QuizQuestion>? questions,
    int? currentIndex,
    bool? isAnswerChecked,
    bool? isCorrect,
    String? selectedAnswerId,
    List<List<Offset>>? currentStrokes,
    String? recognizedText,
    bool? isFinished,
  }) {
    return LessonState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      isAnswerChecked: isAnswerChecked ?? this.isAnswerChecked,
      isCorrect: isCorrect ?? this.isCorrect,
      selectedAnswerId: selectedAnswerId ?? this.selectedAnswerId,
      currentStrokes: currentStrokes ?? this.currentStrokes,
      recognizedText: recognizedText ?? this.recognizedText,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}

class LessonController extends FamilyNotifier<LessonState, Lesson> {

  @override
  LessonState build(Lesson arg) {
    
    // HandwritingService is now provided via handwritingServiceProvider
    
    // Initialize questions when data is available
    final allKanji = ref.watch(kanjiListProvider).value ?? [];
    if (allKanji.isNotEmpty) {
      _generateQuestions(allKanji);
    }
    
    return LessonState();
  }

  void _generateQuestions(List<KanjiCard> allKanji) {
    if (state.questions.isNotEmpty) return; // Already generated

    final lessonKanji = allKanji.where((k) => arg.kanjiIds.contains(k.id)).toList();
    if (lessonKanji.isEmpty) return;

    final random = Random();
    final questions = <QuizQuestion>[];
    
    // Shuffle all kanji once to use for distractors
    final shuffledAll = List<KanjiCard>.from(allKanji)..shuffle(random);

    for (final kanji in lessonKanji) {
      // Helper to get 3 distractors
      List<KanjiCard> getDistractors() {
        return shuffledAll
            .where((k) => k.id != kanji.id)
            .take(3)
            .toList();
      }

      // Meaning Quiz
      var options = [kanji, ...getDistractors()]..shuffle(random);
      questions.add(QuizQuestion(targetCard: kanji, type: QuizType.meaning, options: options));

      // Kanji Quiz
      options = [kanji, ...getDistractors()]..shuffle(random);
      questions.add(QuizQuestion(targetCard: kanji, type: QuizType.kanji, options: options));

      // Handwriting Quiz
      questions.add(QuizQuestion(targetCard: kanji, type: QuizType.handwriting));
    }

    questions.shuffle(random);
    
    // Use Future.microtask to avoid state update during build
    Future.microtask(() {
      state = state.copyWith(questions: questions);
    });
  }

  void selectAnswer(String selectedId) {
    if (state.isAnswerChecked) return;
    state = state.copyWith(selectedAnswerId: selectedId);
  }

  void onDrawingChanged(List<List<Offset>> strokes) {
    if (state.isAnswerChecked) return;
    state = state.copyWith(currentStrokes: strokes);
  }

  void resetCanvas() {
    if (state.isAnswerChecked) return;
    state = state.copyWith(currentStrokes: []);
  }

  void checkAnswer() async {
    if (state.isAnswerChecked) return;
    
    final currentQ = state.questions[state.currentIndex];
    bool isCorrect = false;

    if (currentQ.type == QuizType.handwriting) {
      final text = await ref.read(handwritingServiceProvider).recognize(state.currentStrokes);
      isCorrect = (text == currentQ.targetCard.kanji);
      state = state.copyWith(
        recognizedText: text,
        isCorrect: isCorrect,
        isAnswerChecked: true,
      );
      ref.read(emitKanjiStudyEventProvider)(currentQ.targetCard.id, isCorrect ? 4 : 1);
    } else {
      isCorrect = state.selectedAnswerId == currentQ.targetCard.id;
      state = state.copyWith(
        isCorrect: isCorrect,
        isAnswerChecked: true,
      );
      ref.read(emitKanjiStudyEventProvider)(currentQ.targetCard.id, isCorrect ? 3 : 1);
    }
  }

  void nextQuestion() {
    if (state.currentIndex < state.questions.length - 1) {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        isAnswerChecked: false,
        isCorrect: false,
        selectedAnswerId: null,
        recognizedText: null,
        currentStrokes: [],
      );
    } else {
      ref.read(learningPathProvider.notifier).toggleLessonCompletion(arg.id);
      state = state.copyWith(isFinished: true);
    }
  }
}

final lessonControllerProvider =
    NotifierProvider.family<LessonController, LessonState, Lesson>(
  LessonController.new,
);
