import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/services/nlp_service.dart';

void main() {
  group('GrammarParserService.parseOllamaResponse', () {
    late GrammarParserService service;

    setUp(() {
      service = GrammarParserService();
    });

    test('parses a valid JSON array from an Ollama response', () {
      final responseBody = jsonEncode({
        'response': jsonEncode([
          {
            'text': '私',
            'reading': 'わたし',
            'type': 'Đại từ',
            'baseForm': '私',
            'explanation': 'Tôi',
            'example': '私は学生です。 - Tôi là học sinh.',
            'usageNote': 'Dùng trong ngữ cảnh trung tính.',
          },
        ]),
      });

      final segments = service.parseOllamaResponse(responseBody);

      expect(segments, hasLength(1));
      expect(segments.first.text, '私');
      expect(segments.first.reading, 'わたし');
      expect(segments.first.explanation, 'Tôi');
    });

    test('parses JSON when Ollama adds text before and after the array', () {
      final responseBody = jsonEncode({
        'response': '''
Đây là kết quả:
[
  {
    "text": "へ",
    "reading": "へ",
    "type": "Trợ từ",
    "baseForm": "へ",
    "explanation": "Chỉ hướng đi",
    "example": null,
    "usageNote": null
  }
]
Cảm ơn.
''',
      });

      final segments = service.parseOllamaResponse(responseBody);

      expect(segments, hasLength(1));
      expect(segments.first.text, 'へ');
      expect(segments.first.example, isNull);
    });

    test('throws a friendly exception for malformed JSON output', () {
      final responseBody = jsonEncode({'response': 'Không có JSON ở đây'});

      expect(
        () => service.parseOllamaResponse(responseBody),
        throwsA(isA<AiTutorException>()),
      );
    });

    test('accepts missing optional fields and list values', () {
      final responseBody = jsonEncode({
        'response': jsonEncode([
          {
            'text': '学校',
            'reading': 'がっこう',
            'type': 'Danh từ',
            'baseForm': '学校',
            'explanation': ['trường học', 'nhà trường'],
          },
        ]),
      });

      final segments = service.parseOllamaResponse(responseBody);

      expect(segments.single.explanation, 'trường học, nhà trường');
      expect(segments.single.example, isNull);
      expect(segments.single.usageNote, isNull);
    });
  });
}
