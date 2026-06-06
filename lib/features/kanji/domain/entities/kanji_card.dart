import 'package:equatable/equatable.dart';
import 'dart:convert';
import '../../../../core/srs/srs_item.dart';

class KanjiCard extends Equatable implements SrsItem {
  @override
  final String id;
  final String kanji;
  final String meanings;
  final String onyomi;
  final String kunyomi;
  final String? strokeData;
  final int jlptLevel;
  final String radicalsJson;
  final String? mnemonic;
  final String relatedWordsJson;
  final String strokePathsJson;
  final int? strokeCount;
  final int? grade;
  final int? frequency;
  final int? radicalNumber;
  final String radicalNamesJson;
  final String nanoriJson;
  final String variantsJson;
  final String queryCodesJson;

  // SRS data
  @override
  final double stability;
  @override
  final double difficulty;
  @override
  final DateTime? lastReview;
  @override
  final DateTime nextReview;
  @override
  final int reps;
  @override
  final int lapses;
  @override
  final int state; // 0: New, 1: Learning, 2: Review, 3: Relearning

  const KanjiCard({
    required this.id,
    required this.kanji,
    required this.meanings,
    required this.onyomi,
    required this.kunyomi,
    this.strokeData,
    this.jlptLevel = 5,
    this.radicalsJson = '[]',
    this.mnemonic,
    this.relatedWordsJson = '[]',
    this.strokePathsJson = '[]',
    this.strokeCount,
    this.grade,
    this.frequency,
    this.radicalNumber,
    this.radicalNamesJson = '[]',
    this.nanoriJson = '[]',
    this.variantsJson = '[]',
    this.queryCodesJson = '[]',
    this.stability = 0.0,
    this.difficulty = 0.0,
    this.lastReview,
    required this.nextReview,
    this.reps = 0,
    this.lapses = 0,
    this.state = 0,
  });

  List<String> get radicals => _decodeStringList(radicalsJson);
  List<String> get relatedWords => _decodeStringList(relatedWordsJson);
  List<String> get strokePaths => _decodeStringList(
    strokePathsJson == '[]' && strokeData != null
        ? strokeData!
        : strokePathsJson,
  );
  List<String> get radicalNames => _decodeStringList(radicalNamesJson);
  List<String> get nanori => _decodeStringList(nanoriJson);
  List<String> get variants => _decodeStringList(variantsJson);
  List<String> get queryCodes => _decodeStringList(queryCodesJson);

  @override
  List<Object?> get props => [
    id,
    kanji,
    meanings,
    onyomi,
    kunyomi,
    strokeData,
    jlptLevel,
    radicalsJson,
    mnemonic,
    relatedWordsJson,
    strokePathsJson,
    strokeCount,
    grade,
    frequency,
    radicalNumber,
    radicalNamesJson,
    nanoriJson,
    variantsJson,
    queryCodesJson,
    stability,
    difficulty,
    lastReview,
    nextReview,
    reps,
    lapses,
    state,
  ];

  KanjiCard copyWith({
    String? id,
    String? kanji,
    String? meanings,
    String? onyomi,
    String? kunyomi,
    String? strokeData,
    int? jlptLevel,
    String? radicalsJson,
    String? mnemonic,
    String? relatedWordsJson,
    String? strokePathsJson,
    int? strokeCount,
    int? grade,
    int? frequency,
    int? radicalNumber,
    String? radicalNamesJson,
    String? nanoriJson,
    String? variantsJson,
    String? queryCodesJson,
    double? stability,
    double? difficulty,
    DateTime? lastReview,
    DateTime? nextReview,
    int? reps,
    int? lapses,
    int? state,
  }) {
    return KanjiCard(
      id: id ?? this.id,
      kanji: kanji ?? this.kanji,
      meanings: meanings ?? this.meanings,
      onyomi: onyomi ?? this.onyomi,
      kunyomi: kunyomi ?? this.kunyomi,
      strokeData: strokeData ?? this.strokeData,
      jlptLevel: jlptLevel ?? this.jlptLevel,
      radicalsJson: radicalsJson ?? this.radicalsJson,
      mnemonic: mnemonic ?? this.mnemonic,
      relatedWordsJson: relatedWordsJson ?? this.relatedWordsJson,
      strokePathsJson: strokePathsJson ?? this.strokePathsJson,
      strokeCount: strokeCount ?? this.strokeCount,
      grade: grade ?? this.grade,
      frequency: frequency ?? this.frequency,
      radicalNumber: radicalNumber ?? this.radicalNumber,
      radicalNamesJson: radicalNamesJson ?? this.radicalNamesJson,
      nanoriJson: nanoriJson ?? this.nanoriJson,
      variantsJson: variantsJson ?? this.variantsJson,
      queryCodesJson: queryCodesJson ?? this.queryCodesJson,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      lastReview: lastReview ?? this.lastReview,
      nextReview: nextReview ?? this.nextReview,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      state: state ?? this.state,
    );
  }

  static List<String> _decodeStringList(String value) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is! List) return const [];
      return decoded
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }
}
