import 'package:equatable/equatable.dart';

class Sentence extends Equatable {
  final String id;
  final String text;
  final String reading;
  final String meaning;
  final int jlptLevel;
  final String sourceGrammarId;
  final String? sourceGrammarTitle;

  const Sentence({
    required this.id,
    required this.text,
    required this.reading,
    required this.meaning,
    required this.jlptLevel,
    required this.sourceGrammarId,
    this.sourceGrammarTitle,
  });

  @override
  List<Object?> get props => [
    id,
    text,
    reading,
    meaning,
    jlptLevel,
    sourceGrammarId,
    sourceGrammarTitle,
  ];
}
