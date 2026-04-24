import 'package:equatable/equatable.dart';

class Lesson extends Equatable {
  final String id;
  final String title;
  final List<String> kanjiIds;
  final bool isCompleted;
  final bool isUnlocked;

  const Lesson({
    required this.id,
    required this.title,
    required this.kanjiIds,
    this.isCompleted = false,
    this.isUnlocked = false,
  });

  @override
  List<Object?> get props => [id, title, kanjiIds, isCompleted, isUnlocked];

  Lesson copyWith({
    String? id,
    String? title,
    List<String>? kanjiIds,
    bool? isCompleted,
    bool? isUnlocked,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      kanjiIds: kanjiIds ?? this.kanjiIds,
      isCompleted: isCompleted ?? this.isCompleted,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}