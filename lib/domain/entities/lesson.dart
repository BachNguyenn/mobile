import 'package:equatable/equatable.dart';

enum LessonType { lesson, quiz }

class Lesson extends Equatable {
  final String id;
  final String title;
  final List<String> kanjiIds;
  final List<String> vocabIds;
  final List<String> grammarIds;
  final bool isCompleted;
  final bool isUnlocked;
  final LessonType type;
  final int level;

  const Lesson({
    required this.id,
    required this.title,
    this.kanjiIds = const [],
    this.vocabIds = const [],
    this.grammarIds = const [],
    this.isCompleted = false,
    this.isUnlocked = false,
    this.type = LessonType.lesson,
    this.level = 5,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        kanjiIds,
        vocabIds,
        grammarIds,
        isCompleted,
        isUnlocked,
        type,
        level,
      ];

  Lesson copyWith({
    String? id,
    String? title,
    List<String>? kanjiIds,
    List<String>? vocabIds,
    List<String>? grammarIds,
    bool? isCompleted,
    bool? isUnlocked,
    LessonType? type,
    int? level,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      kanjiIds: kanjiIds ?? this.kanjiIds,
      vocabIds: vocabIds ?? this.vocabIds,
      grammarIds: grammarIds ?? this.grammarIds,
      isCompleted: isCompleted ?? this.isCompleted,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      type: type ?? this.type,
      level: level ?? this.level,
    );
  }
}