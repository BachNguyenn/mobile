class JapaneseSegment {
  final String text;
  final String reading;
  final String type;
  final String baseForm;
  final String explanation;
  final String? example;
  final String? usageNote;

  JapaneseSegment({
    required this.text,
    required this.reading,
    required this.type,
    required this.baseForm,
    required this.explanation,
    this.example,
    this.usageNote,
  });

  factory JapaneseSegment.fromJson(Map<String, dynamic> json) {
    String formatValue(dynamic value) {
      if (value == null) return '';
      if (value is List) {
        return value
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .join(', ');
      }
      return value.toString().trim();
    }

    String? formatOptional(dynamic value) {
      final formatted = formatValue(value);
      return formatted.isEmpty ? null : formatted;
    }

    return JapaneseSegment(
      text: formatValue(json['text']),
      reading: formatValue(json['reading']),
      type: formatValue(json['type']),
      baseForm: formatValue(json['baseForm']),
      explanation: formatValue(json['explanation']),
      example: formatOptional(json['example']),
      usageNote: formatOptional(json['usageNote']),
    );
  }
}
