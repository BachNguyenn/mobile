enum LearningGoal { jlpt, conversation, reading }

extension LearningGoalX on LearningGoal {
  String get label {
    switch (this) {
      case LearningGoal.jlpt:
        return 'Thi JLPT';
      case LearningGoal.conversation:
        return 'Giao tiếp';
      case LearningGoal.reading:
        return 'Đọc hiểu';
    }
  }
}
