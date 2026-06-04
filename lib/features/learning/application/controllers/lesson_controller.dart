import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/services/app_logger.dart';
import 'package:mobile/domain/entities/lesson.dart';
import 'package:mobile/features/learning/domain/entities/quiz_question.dart';
import 'package:mobile/features/learning/domain/services/quiz_answer_normalizer.dart';
import 'package:mobile/features/learning/domain/services/lesson_question_generator.dart';
import 'package:mobile/features/kanji/domain/entities/kanji_card.dart';
import 'package:mobile/features/vocabulary/domain/entities/vocabulary.dart';
import 'package:mobile/features/grammar/domain/entities/grammar_point.dart';
import 'package:mobile/core/services/handwriting_service.dart';
import 'package:mobile/features/kanji/application/providers/kanji_repository_provider.dart';
import 'package:mobile/features/kanji/application/providers/kanji_library_provider.dart';
import 'package:mobile/features/vocabulary/application/providers/vocabulary_repository_provider.dart';
import 'package:mobile/features/vocabulary/application/providers/vocabulary_library_provider.dart';
import 'package:mobile/features/grammar/application/providers/grammar_repository_provider.dart';
import 'package:mobile/features/grammar/application/providers/grammar_library_provider.dart';
import 'package:mobile/features/home/application/providers/home_progress_provider.dart';
import 'package:mobile/features/learning/application/providers/learning_path_provider.dart';

const _unset = Object();

class LessonState {
  final List<QuizQuestion> questions;
  final int currentIndex;
  final bool isAnswerChecked;
  final bool isCorrect;
  final String? selectedAnswer;
  final String typedAnswer;
  final List<List<HandwritingPoint>> currentStrokes;
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
    this.typedAnswer = '',
    this.currentStrokes = const [],
    this.recognizedText,
    this.isFinished = false,
    this.isLoading = true,
    this.correctAnswers = 0,
  });

  double get progress =>
      questions.isEmpty ? 0 : (currentIndex + 1) / questions.length;

  LessonState copyWith({
    List<QuizQuestion>? questions,
    int? currentIndex,
    bool? isAnswerChecked,
    bool? isCorrect,
    Object? selectedAnswer = _unset,
    String? typedAnswer,
    List<List<HandwritingPoint>>? currentStrokes,
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
      selectedAnswer: selectedAnswer == _unset
          ? this.selectedAnswer
          : selectedAnswer as String?,
      typedAnswer: typedAnswer ?? this.typedAnswer,
      currentStrokes: currentStrokes ?? this.currentStrokes,
      recognizedText: recognizedText == _unset
          ? this.recognizedText
          : recognizedText as String?,
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

      final lessonKanji = allKanji
          .where((k) => arg.kanjiIds.contains(k.id))
          .toList();
      final lessonVocab = allVocab
          .where((v) => arg.vocabIds.contains(v.id))
          .toList();
      final lessonGrammar = allGrammar
          .where((g) => arg.grammarIds.contains(g.id))
          .toList();

      final questions = LessonQuestionGenerator().generate(
        lessonKanji: lessonKanji,
        lessonVocabulary: lessonVocab,
        lessonGrammar: lessonGrammar,
        allKanji: allKanji,
        allVocabulary: allVocab,
        allGrammar: allGrammar,
      );

      state = state.copyWith(questions: questions, isLoading: false);
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to initialize lesson',
        error: error,
        stackTrace: stackTrace,
      );
      state = state.copyWith(isLoading: false, questions: []);
    }
  }

  void selectAnswer(String answer) {
    if (state.isAnswerChecked) return;
    state = state.copyWith(selectedAnswer: answer);
  }

  void updateTypedAnswer(String answer) {
    if (state.isAnswerChecked) return;
    state = state.copyWith(typedAnswer: answer);
  }

  void onDrawingChanged(List<List<HandwritingPoint>> strokes) {
    if (state.isAnswerChecked) return;
    state = state.copyWith(currentStrokes: strokes);
  }

  void resetCanvas() {
    if (state.isAnswerChecked) return;
    state = state.copyWith(currentStrokes: []);
  }

  Future<void> checkAnswer() async {
    if (state.isAnswerChecked || state.questions.isEmpty) return;
    if (state.currentIndex >= state.questions.length) return;

    final currentQ = state.questions[state.currentIndex];
    bool isCorrect = false;

    if (currentQ.type == QuizType.handwriting) {
      final candidates = await ref
          .read(handwritingServiceProvider)
          .recognizeCandidates(state.currentStrokes);
      final text = candidates.isEmpty ? null : candidates.first;
      isCorrect = candidates.contains(currentQ.answer);
      state = state.copyWith(
        recognizedText: text,
        isCorrect: isCorrect,
        isAnswerChecked: true,
        correctAnswers: state.correctAnswers + (isCorrect ? 1 : 0),
      );
    } else if (currentQ.type == QuizType.grammarStudy) {
      isCorrect = true;
      state = state.copyWith(isCorrect: true, isAnswerChecked: true);
    } else if (currentQ.inputMode == QuizInputMode.typing) {
      isCorrect = QuizAnswerNormalizer.isCorrect(
        state.typedAnswer,
        currentQ.answer,
      );
      state = state.copyWith(
        isCorrect: isCorrect,
        isAnswerChecked: true,
        correctAnswers: state.correctAnswers + (isCorrect ? 1 : 0),
      );
    } else {
      isCorrect = state.selectedAnswer == currentQ.answer;
      state = state.copyWith(
        isCorrect: isCorrect,
        isAnswerChecked: true,
        correctAnswers: state.correctAnswers + (isCorrect ? 1 : 0),
      );
    }

    if (!currentQ.isScored) return;

    final payload = currentQ.payload;
    if (payload is KanjiQuizPayload) {
      await ref.read(emitKanjiStudyEventProvider)(
        payload.card.id,
        isCorrect ? 3 : 1,
      );
    } else if (payload is VocabularyQuizPayload) {
      await ref.read(emitVocabularyStudyEventProvider)(
        payload.vocabulary.id,
        isCorrect ? 3 : 1,
      );
    } else if (payload is GrammarQuizPayload) {
      await ref.read(emitGrammarStudyEventProvider)(
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
        typedAnswer: '',
        recognizedText: null,
        currentStrokes: [],
      );
    } else {
      await ref
          .read(learningPathProvider.notifier)
          .toggleLessonCompletion(arg.id);
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
