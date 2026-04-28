import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/lesson.dart';
import '../../features/kanji/domain/entities/kanji_card.dart';
import '../../features/vocabulary/domain/entities/vocabulary.dart';
import '../../features/grammar/domain/entities/grammar_point.dart';
import '../../core/services/handwriting_service.dart';
import '../../features/kanji/presentation/providers/kanji_repository_provider.dart';
import '../../features/kanji/presentation/providers/kanji_library_provider.dart';
import '../../features/vocabulary/presentation/providers/vocabulary_repository_provider.dart';
import '../../features/grammar/presentation/providers/grammar_repository_provider.dart';
import 'learning_path_provider.dart';

enum QuizType { 
  meaning, 
  kanji, 
  handwriting,
  vocabMeaning,
  vocabReading,
  grammarStudy 
}

class QuizQuestion {
  final String id;
  final QuizType type;
  final String prompt;
  final String answer;
  final List<String> options;
  final dynamic originalData; // KanjiCard, Vocabulary, or GrammarPoint

  QuizQuestion({
    required this.id,
    required this.type,
    required this.prompt,
    required this.answer,
    this.options = const [],
    this.originalData,
  });
}

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
  });

  double get progress => questions.isEmpty ? 0 : (currentIndex + 1) / questions.length;

  LessonState copyWith({
    List<QuizQuestion>? questions,
    int? currentIndex,
    bool? isAnswerChecked,
    bool? isCorrect,
    String? selectedAnswer,
    List<List<Offset>>? currentStrokes,
    String? recognizedText,
    bool? isFinished,
    bool? isLoading,
  }) {
    return LessonState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      isAnswerChecked: isAnswerChecked ?? this.isAnswerChecked,
      isCorrect: isCorrect ?? this.isCorrect,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      currentStrokes: currentStrokes ?? this.currentStrokes,
      recognizedText: recognizedText ?? this.recognizedText,
      isFinished: isFinished ?? this.isFinished,
      isLoading: isLoading ?? this.isLoading,
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

      _generateInterleavedQuestions(lessonKanji, lessonVocab, lessonGrammar, allKanji, allVocab);
    } catch (e) {
      debugPrint('Error initializing lesson: $e');
      state = state.copyWith(isLoading: false, questions: []);
    }
  }

  void _generateInterleavedQuestions(
    List<KanjiCard> kanjiList,
    List<Vocabulary> vocabList,
    List<GrammarPoint> grammarList,
    List<KanjiCard> allKanji,
    List<Vocabulary> allVocab,
  ) {
    final random = Random();
    final questions = <QuizQuestion>[];

    final allKanjiMeanings = allKanji.map((k) => k.meanings).where((m) => m.isNotEmpty).toList();
    final allVocabMeanings = allVocab.map((v) => v.meaning).where((m) => m.isNotEmpty).toList();
    final allReadings = allVocab.map((v) => v.reading).where((r) => r.isNotEmpty).toList();

    // 1. Add Grammar points first (Study phase)
    for (var grammar in grammarList) {
      questions.add(QuizQuestion(
        id: grammar.id,
        type: QuizType.grammarStudy,
        prompt: grammar.title,
        answer: '',
        originalData: grammar,
      ));
    }

    // 2. Interleave Kanji and Related Vocab
    final usedVocabIds = <String>{};

    for (var kanji in kanjiList) {
      // Kanji Meanings
      final meaningOptions = _getDistractors(kanji.meanings, allKanjiMeanings, random);
      questions.add(QuizQuestion(
        id: kanji.id,
        type: QuizType.meaning,
        prompt: kanji.kanji,
        answer: kanji.meanings,
        options: (meaningOptions..add(kanji.meanings))..shuffle(random),
        originalData: kanji,
      ));

      // Handwriting
      questions.add(QuizQuestion(
        id: kanji.id,
        type: QuizType.handwriting,
        prompt: kanji.meanings,
        answer: kanji.kanji,
        originalData: kanji,
      ));

      // Find related vocab for THIS kanji
      final relatedVocab = vocabList.where((v) => v.word.contains(kanji.kanji)).toList();
      for (var vocab in relatedVocab) {
        if (!usedVocabIds.contains(vocab.id)) {
          _addVocabQuestions(questions, vocab, allVocabMeanings, allReadings, random);
          usedVocabIds.add(vocab.id);
        }
      }
    }

    // 3. Add remaining vocabulary that wasn't tied to a specific lesson kanji
    final remainingVocab = vocabList.where((v) => !usedVocabIds.contains(v.id)).toList();
    for (var vocab in remainingVocab) {
      _addVocabQuestions(questions, vocab, allVocabMeanings, allReadings, random);
    }
    
    // Shuffle all questions to mix grammar, kanji, and vocabulary
    questions.shuffle(random);

    state = state.copyWith(
      questions: questions,
      isLoading: false,
    );
  }

  void _addVocabQuestions(
    List<QuizQuestion> questions, 
    Vocabulary vocab, 
    List<String> allVocabMeanings, 
    List<String> allReadings,
    Random random
  ) {
    // Vocab Meaning
    final vocabOptions = _getDistractors(vocab.meaning, allVocabMeanings, random);
    questions.add(QuizQuestion(
      id: vocab.id,
      type: QuizType.vocabMeaning,
      prompt: vocab.word,
      answer: vocab.meaning,
      options: (vocabOptions..add(vocab.meaning))..shuffle(random),
      originalData: vocab,
    ));

    // Vocab Reading (if it has one and it's different from word)
    if (vocab.reading.isNotEmpty && vocab.reading != vocab.word) {
      final filteredReadings = allReadings.where((r) => r != vocab.reading).toList();
      final readingOptions = _getDistractors(vocab.reading, filteredReadings, random);
      
      questions.add(QuizQuestion(
        id: vocab.id,
        type: QuizType.vocabReading,
        prompt: vocab.word,
        answer: vocab.reading,
        options: (readingOptions..add(vocab.reading))..shuffle(random),
        originalData: vocab,
      ));
    }
  }

  List<String> _getDistractors(String correct, List<String> all, Random random) {
    if (all.length <= 4) return all.where((s) => s != correct).toList();
    
    final distractors = <String>{};
    int attempts = 0;
    while (distractors.length < 3 && attempts < 20) {
      attempts++;
      final candidate = all[random.nextInt(all.length)];
      if (candidate != correct && candidate.isNotEmpty) {
        distractors.add(candidate);
      }
    }
    return distractors.toList();
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
      );
    } else if (currentQ.type == QuizType.grammarStudy) {
      isCorrect = true; // Grammar study is always "correct" when you press next
      state = state.copyWith(isCorrect: true, isAnswerChecked: true);
    } else {
      isCorrect = state.selectedAnswer == currentQ.answer;
      state = state.copyWith(
        isCorrect: isCorrect,
        isAnswerChecked: true,
      );
    }

    // Log study event if it's a kanji
    if (currentQ.originalData is KanjiCard) {
      ref.read(emitKanjiStudyEventProvider)(currentQ.id, isCorrect ? 3 : 1);
    }
  }

  void nextQuestion() {
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
      ref.read(learningPathProvider.notifier).toggleLessonCompletion(arg.id);
      state = state.copyWith(isFinished: true);
    }
  }
}

final lessonControllerProvider =
    NotifierProvider.family<LessonController, LessonState, Lesson>(
  LessonController.new,
);
