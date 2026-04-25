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
        return value.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).join(', ');
      }
      return value.toString();
    }

    return JapaneseSegment(
      text: json['text'] ?? '',
      reading: json['reading'] ?? '',
      type: json['type'] ?? '',
      baseForm: json['baseForm'] ?? '',
      explanation: formatValue(json['explanation']),
      example: json['example'],
      usageNote: json['usageNote'],
    );
  }
}
