import 'package:equatable/equatable.dart';

class Vocabulary extends Equatable {
  final String id;
  final String word;
  final String reading;
  final String meaning;
  final int jlptLevel;

  const Vocabulary({
    required this.id,
    required this.word,
    required this.reading,
    required this.meaning,
    this.jlptLevel = 5,
  });

  @override
  List<Object?> get props => [id, word, reading, meaning, jlptLevel];
}
