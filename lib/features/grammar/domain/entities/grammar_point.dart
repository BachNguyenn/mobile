import 'package:equatable/equatable.dart';

class GrammarPoint extends Equatable {
  final String id;
  final String title;
  final String shortExplanation;
  final String longExplanation;
  final String formation;
  final List<GrammarExample> examples;
  final int jlptLevel;
  final bool isLearned;

  const GrammarPoint({
    required this.id,
    required this.title,
    required this.shortExplanation,
    required this.longExplanation,
    required this.formation,
    required this.examples,
    this.jlptLevel = 5,
    this.isLearned = false,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        shortExplanation,
        longExplanation,
        formation,
        examples,
        jlptLevel,
        isLearned
      ];
}

class GrammarExample extends Equatable {
  final String jp;
  final String romaji;
  final String en;

  const GrammarExample({
    required this.jp,
    required this.romaji,
    required this.en,
  });

  @override
  List<Object?> get props => [jp, romaji, en];
}
