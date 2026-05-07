abstract final class QuizAnswerNormalizer {
  static bool isCorrect(String input, String answer) {
    final normalizedInput = normalize(input);
    final normalizedAnswer = normalize(answer);
    if (_isAscii(normalizedInput) && _isAscii(normalizedAnswer)) {
      return normalizedInput.toLowerCase() == normalizedAnswer.toLowerCase();
    }
    return normalizedInput == normalizedAnswer;
  }

  static String normalize(String value) {
    return value
        .replaceAll('\u3000', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static bool _isAscii(String value) =>
      value.codeUnits.every((unit) => unit < 128);
}
