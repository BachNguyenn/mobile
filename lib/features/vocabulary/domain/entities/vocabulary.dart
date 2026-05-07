import 'package:equatable/equatable.dart';
import 'dart:convert';
import 'package:mobile/core/srs/srs_item.dart';

class VocabularyExample extends Equatable {
  final String text;
  final String reading;
  final String meaning;

  const VocabularyExample({
    required this.text,
    this.reading = '',
    this.meaning = '',
  });

  factory VocabularyExample.fromJson(Object? json) {
    if (json is String) {
      return VocabularyExample(text: json);
    }
    if (json is Map) {
      return VocabularyExample(
        text: json['text']?.toString() ?? json['jp']?.toString() ?? '',
        reading:
            json['reading']?.toString() ?? json['romaji']?.toString() ?? '',
        meaning: json['meaning']?.toString() ?? json['en']?.toString() ?? '',
      );
    }
    return const VocabularyExample(text: '');
  }

  Map<String, String> toJson() => {
    'text': text,
    if (reading.isNotEmpty) 'reading': reading,
    if (meaning.isNotEmpty) 'meaning': meaning,
  };

  @override
  List<Object?> get props => [text, reading, meaning];
}

class Vocabulary extends Equatable implements SrsItem {
  @override
  final String id;
  final String word;
  final String reading;
  final String meaning;
  final int jlptLevel;
  final String exampleSentencesJson;
  final String? imageUrl;
  final String? pitchAccent;
  final String? partOfSpeech;
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
  final int state;

  const Vocabulary({
    required this.id,
    required this.word,
    required this.reading,
    required this.meaning,
    this.jlptLevel = 5,
    this.exampleSentencesJson = '[]',
    this.imageUrl,
    this.pitchAccent,
    this.partOfSpeech,
    this.stability = 0.0,
    this.difficulty = 0.0,
    this.lastReview,
    required this.nextReview,
    this.reps = 0,
    this.lapses = 0,
    this.state = 0,
  });

  List<VocabularyExample> get exampleSentences {
    try {
      final decoded = jsonDecode(exampleSentencesJson);
      if (decoded is! List) return const [];
      return decoded
          .map(VocabularyExample.fromJson)
          .where((example) => example.text.trim().isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Vocabulary copyWith({
    String? id,
    String? word,
    String? reading,
    String? meaning,
    int? jlptLevel,
    String? exampleSentencesJson,
    String? imageUrl,
    String? pitchAccent,
    String? partOfSpeech,
    double? stability,
    double? difficulty,
    DateTime? lastReview,
    DateTime? nextReview,
    int? reps,
    int? lapses,
    int? state,
  }) {
    return Vocabulary(
      id: id ?? this.id,
      word: word ?? this.word,
      reading: reading ?? this.reading,
      meaning: meaning ?? this.meaning,
      jlptLevel: jlptLevel ?? this.jlptLevel,
      exampleSentencesJson: exampleSentencesJson ?? this.exampleSentencesJson,
      imageUrl: imageUrl ?? this.imageUrl,
      pitchAccent: pitchAccent ?? this.pitchAccent,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      lastReview: lastReview ?? this.lastReview,
      nextReview: nextReview ?? this.nextReview,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      state: state ?? this.state,
    );
  }

  @override
  List<Object?> get props => [
    id,
    word,
    reading,
    meaning,
    jlptLevel,
    exampleSentencesJson,
    imageUrl,
    pitchAccent,
    partOfSpeech,
    stability,
    difficulty,
    lastReview,
    nextReview,
    reps,
    lapses,
    state,
  ];
}
