import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../domain/entities/japanese_segment.dart';

abstract class JapaneseTutorService {
  Future<List<JapaneseSegment>> parse(String sentence);
}

final grammarParserServiceProvider = Provider<JapaneseTutorService>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return GrammarParserService(client: client);
});

class AiTutorException implements Exception {
  final String message;

  const AiTutorException(this.message);

  @override
  String toString() => message;
}

class GrammarParserService implements JapaneseTutorService {
  static const String _defaultBaseUrl = 'http://10.0.2.2:11434';
  static const String _defaultModelName = 'llama3.2:1b';

  final http.Client _client;

  GrammarParserService({http.Client? client})
    : _client = client ?? http.Client();

  @override
  Future<List<JapaneseSegment>> parse(String sentence) async {
    final normalizedSentence = sentence.trim();
    if (normalizedSentence.isEmpty) return [];

    final baseUrl = const String.fromEnvironment(
      'OLLAMA_BASE_URL',
      defaultValue: _defaultBaseUrl,
    );
    final modelName = const String.fromEnvironment(
      'OLLAMA_MODEL',
      defaultValue: _defaultModelName,
    );

    final prompt =
        '''
Bạn là AI Tutor tiếng Nhật cho người học JLPT nói tiếng Việt.
Nhiệm vụ của bạn là phân tích câu tiếng Nhật thành các từ/cụm từ (token) chi tiết, đúng ngữ pháp.

Phân tích câu: "$normalizedSentence"

YÊU CẦU BẮT BUỘC:
- Tách riêng các từ (ví dụ: "私" và "は" phải tách riêng, KHÔNG gộp thành "私は").
- Phân loại chính xác "type" (Đại từ, Trợ từ, Danh từ, Động từ, Tính từ, Ngữ pháp, v.v.).
- Nghĩa tiếng Việt phải chính xác, không tự bịa định nghĩa.
- Trả về ĐÚNG 1 mảng JSON Array, KHÔNG bọc trong markdown (như ```json), KHÔNG kèm văn bản nào khác.

SCHEMA CHO MỖI ITEM:
{
  "text": "chữ gốc (chia nhỏ)",
  "reading": "cách đọc hiragana (rỗng nếu không có kanji)",
  "type": "loại từ (Danh từ, Động từ, Trợ từ, v.v.)",
  "baseForm": "dạng nguyên mẫu (nếu bị chia)",
  "explanation": "nghĩa tiếng Việt ngắn gọn",
  "example": "1 ví dụ tiếng Nhật có dịch (có thể null)",
  "usageNote": "lưu ý ngữ pháp (có thể null)"
}

VÍ DỤ NẾU CÂU LÀ "私は学校へ行きました":
[
  {
    "text": "私",
    "reading": "わたし",
    "type": "Đại từ",
    "baseForm": "",
    "explanation": "Tôi",
    "example": null,
    "usageNote": null
  },
  {
    "text": "は",
    "reading": "わ",
    "type": "Trợ từ",
    "baseForm": "",
    "explanation": "Trợ từ chỉ chủ đề câu",
    "example": null,
    "usageNote": "Đọc là 'wa' khi làm trợ từ"
  },
  {
    "text": "学校",
    "reading": "がっこう",
    "type": "Danh từ",
    "baseForm": "",
    "explanation": "Trường học",
    "example": null,
    "usageNote": null
  },
  {
    "text": "へ",
    "reading": "え",
    "type": "Trợ từ",
    "baseForm": "",
    "explanation": "Trợ từ chỉ hướng di chuyển",
    "example": null,
    "usageNote": "Đọc là 'e' khi làm trợ từ"
  },
  {
    "text": "行きました",
    "reading": "いきました",
    "type": "Động từ",
    "baseForm": "行く",
    "explanation": "Đã đi",
    "example": null,
    "usageNote": "Thể quá khứ lịch sự (mashita) của 行く"
  }
]

Bây giờ, hãy phân tích câu sau và CHỈ trả về JSON array: "$normalizedSentence"
''';

    try {
      final uri = Uri.parse(baseUrl).resolve('/api/generate');
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': modelName,
              'prompt': prompt,
              'stream': false,
              'options': {'temperature': 0.1},
            }),
          )
          .timeout(const Duration(seconds: 90));

      if (response.statusCode != 200) {
        throw AiTutorException(
          'Ollama phản hồi lỗi ${response.statusCode}. Hãy kiểm tra server và model.',
        );
      }

      return parseOllamaResponse(response.body);
    } on AiTutorException {
      rethrow;
    } catch (e) {
      throw AiTutorException(
        'Không thể kết nối AI Tutor. Hãy kiểm tra:\n'
        '1. Ollama đã chạy chưa?\n'
        '2. OLLAMA_BASE_URL truyền qua --dart-define có đúng IP máy tính không?\n'
        '3. Đã set OLLAMA_HOST=0.0.0.0 chưa?\n'
        'Chi tiết lỗi: $e',
      );
    }
  }

  List<JapaneseSegment> parseOllamaResponse(String responseBody) {
    final dynamic decodedBody;
    try {
      decodedBody = jsonDecode(responseBody);
    } catch (_) {
      throw const AiTutorException('Phản hồi Ollama không đúng định dạng.');
    }

    if (decodedBody is! Map<String, dynamic>) {
      throw const AiTutorException('Phản hồi Ollama không đúng định dạng.');
    }

    final output = decodedBody['response']?.toString() ?? '';
    if (output.trim().isEmpty) {
      throw const AiTutorException('AI Tutor không trả về nội dung phân tích.');
    }

    final jsonText = _extractJsonArray(output);
    if (jsonText == null) {
      throw const AiTutorException('AI Tutor không trả về JSON array hợp lệ.');
    }

    final dynamic decodedSegments;
    try {
      decodedSegments = jsonDecode(jsonText);
    } catch (_) {
      throw const AiTutorException('AI Tutor trả về JSON chưa hợp lệ.');
    }

    if (decodedSegments is! List) {
      throw const AiTutorException('Kết quả phân tích không phải JSON array.');
    }

    final segments = decodedSegments
        .whereType<Map<String, dynamic>>()
        .map(JapaneseSegment.fromJson)
        .where((segment) => segment.text.trim().isNotEmpty)
        .toList();

    if (segments.isEmpty) {
      throw const AiTutorException('AI Tutor chưa phân tích được câu này.');
    }

    return segments;
  }

  String? _extractJsonArray(String output) {
    final start = output.indexOf('[');
    final end = output.lastIndexOf(']');
    if (start == -1 || end == -1 || end <= start) return null;
    return output.substring(start, end + 1);
  }
}
