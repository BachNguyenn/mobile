import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/domain/entities/lesson.dart';
import 'package:mobile/features/learning/domain/entities/quiz_question.dart';
import 'package:mobile/features/learning/domain/services/lesson_question_generator.dart';
import 'package:mobile/features/kanji/domain/entities/kanji_card.dart';
import 'package:mobile/features/vocabulary/domain/entities/vocabulary.dart';
import 'package:mobile/features/grammar/domain/entities/grammar_point.dart';
import 'package:mobile/core/services/handwriting_service.dart';
import 'package:mobile/features/kanji/presentation/providers/kanji_repository_provider.dart';
import 'package:mobile/features/kanji/presentation/providers/kanji_library_provider.dart';
import 'package:mobile/features/vocabulary/presentation/providers/vocabulary_repository_provider.dart';
import 'package:mobile/features/vocabulary/presentation/providers/vocabulary_library_provider.dart';
import 'package:mobile/features/grammar/presentation/providers/grammar_repository_provider.dart';
import 'package:mobile/features/grammar/presentation/providers/grammar_library_provider.dart';
import 'package:mobile/features/home/presentation/providers/home_progress_provider.dart';
import 'learning_path_provider.dart';

const _unset = Object();

class LessonState {
  final List<QuizQuestion> questions;
  final int currentIndex;
  final bool isAnswerChecked;
  final bool isCorrect;
  final String? selectedAnswer;
  final List<List<Offset>> currentStrokes;
  final String? recognizedText;
  final bool isFinished;
  final bool isLoading;
  final int correctAnswers;

  LessonState({
    this.questions = const [],
    this.currentIndex = 0,
    this.isAnswerChecked = false,
    this.isCorrect = false,
    this.selectedAnswer,
    this.currentStrokes = const [],
    this.recognizedText,
    this.isFinished = false,
    this.isLoading = true,
    this.correctAnswers = 0,
  });

  double get progress => questions.isEmpty ? 0 : (currentIndex + 1) / questions.length;

  LessonState copyWith({
    List<QuizQuestion>? questions,
    int? currentIndex,
    bool? isAnswerChecked,
    bool? isCorrect,
    Object? selectedAnswer = _unset,
    List<List<Offset>>? currentStrokes,
    Object? recognizedText = _unset,
    bool? isFinished,
    bool? isLoading,
    int? correctAnswers,
  }) {
    return LessonState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      isAnswerChecked: isAnswerChecked ?? this.isAnswerChecked,
      isCorrect: isCorrect ?? this.isCorrect,
      selectedAnswer:
          selectedAnswer == _unset ? this.selectedAnswer : selectedAnswer as String?,
      currentStrokes: currentStrokes ?? this.currentStrokes,
      recognizedText:
          recognizedText == _unset ? this.recognizedText : recognizedText as String?,
      isFinished: isFinished ?? this.isFinished,
      isLoading: isLoading ?? this.isLoading,
      correctAnswers: correctAnswers ?? this.correctAnswers,
    );
  }
}

class LessonController extends FamilyNotifier<LessonState, Lesson> {
  @override
  LessonState build(Lesson arg) {
    _initializeLesson();
    return LessonState(isLoading: true);
  }

  Future<void> _initializeLesson() async {
    try {
      final kanjiRepo = ref.read(kanjiRepositoryProvider);
      final grammarRepo = ref.read(grammarRepositoryProvider);
      final vocabRepo = ref.read(vocabularyRepositoryProvider);

      // Load data in parallel
      final results = await Future.wait([
        kanjiRepo.getAllCards(),
        vocabRepo.getAllVocabulary(),
        grammarRepo.getAllGrammarPoints(),
      ]);

      final allKanji = results[0] as List<KanjiCard>;
      final allVocab = results[1] as List<Vocabulary>;
      final allGrammar = results[2] as List<GrammarPoint>;

      final lessonKanji = allKanji.where((k) => arg.kanjiIds.contains(k.id)).toList();
      final lessonVocab = allVocab.where((v) => arg.vocabIds.contains(v.id)).toList();
      final lessonGrammar = allGrammar.where((g) => arg.grammarIds.contains(g.id)).toList();

      final questions = LessonQuestionGenerator().generate(
        lessonKanji: lessonKanji,
        lessonVocabulary: lessonVocab,
        lessonGrammar: lessonGrammar,
        allKanji: allKanji,
        allVocabulary: allVocab,
        allGrammar: allGrammar,
      );

      state = state.copyWith(
        questions: questions,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, questions: []);
    }
  }

  void selectAnswer(String answer) {
    if (state.isAnswerChecked) return;
    state = state.copyWith(selectedAnswer: answer);
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
      isCorrect = (text == currentQ.answer);
      state = state.copyWith(
        recognizedText: text,
        isCorrect: isCorrect,
        isAnswerChecked: true,
        correctAnswers: state.correctAnswers + (isCorrect ? 1 : 0),
      );
    } else if (currentQ.type == QuizType.grammarStudy) {
      isCorrect = true; // Grammar study is always "correct" when you press next
      state = state.copyWith(
        isCorrect: true,
        isAnswerChecked: true,
        correctAnswers: state.correctAnswers + 1,
      );
    } else {
      isCorrect = state.selectedAnswer == currentQ.answer;
      state = state.copyWith(
        isCorrect: isCorrect,
        isAnswerChecked: true,
        correctAnswers: state.correctAnswers + (isCorrect ? 1 : 0),
      );
    }

    final payload = currentQ.payload;
    if (payload is KanjiQuizPayload) {
      ref.read(emitKanjiStudyEventProvider)(payload.card.id, isCorrect ? 3 : 1);
    } else if (payload is VocabularyQuizPayload) {
      ref.read(emitVocabularyStudyEventProvider)(
        payload.vocabulary.id,
        isCorrect ? 3 : 1,
      );
    } else if (payload is GrammarQuizPayload) {
      ref.read(emitGrammarStudyEventProvider)(
        payload.grammarPoint.id,
        isCorrect ? 3 : 1,
      );
    }
  }

  Future<void> nextQuestion() async {
    if (state.currentIndex < state.questions.length - 1) {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        isAnswerChecked: false,
        isCorrect: false,
        selectedAnswer: null,
        recognizedText: null,
        currentStrokes: [],
      );
    } else {
      await ref.read(learningPathProvider.notifier).toggleLessonCompletion(arg.id);
      ref.invalidate(learningPathProvider);
      ref.invalidate(homeProgressProvider);
      ref.invalidate(kanjiProgressProvider);
      ref.invalidate(dueKanjiCardsProvider);
      ref.invalidate(totalDueCountProvider);
      ref.invalidate(vocabularyProgressProvider);
      ref.invalidate(grammarProgressProvider);
      state = state.copyWith(isFinished: true);
    }
  }
}

final lessonControllerProvider =
    NotifierProvider.family<LessonController, LessonState, Lesson>(
  LessonController.new,
);
