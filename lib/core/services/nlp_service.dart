import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/entities/japanese_segment.dart';

class GrammarParserService {
  Future<List<JapaneseSegment>> parse(String sentence) async {
    if (sentence.trim().isEmpty) return [];

    final baseUrl = dotenv.env['OLLAMA_BASE_URL'] ?? 'http://10.0.2.2:11434';
    final modelName = dotenv.env['OLLAMA_MODEL'] ?? 'llama3.2';

    final prompt = '''
    Bạn là một chuyên gia ngôn ngữ học tiếng Nhật. Hãy phân tích hình thái học và ngữ pháp của câu tiếng Nhật sau: "$sentence"
    Trả về kết quả duy nhất dưới dạng JSON array của các objects. Mỗi object gồm:
    - text: phần chữ gốc
    - reading: cách đọc hiragana
    - type: loại từ (Danh từ, Động từ, Trợ từ,...)
    - baseForm: dạng nguyên mẫu
    - explanation: nghĩa tiếng Việt
    - example: một ví dụ ngắn khác dùng từ này (nếu có)
    - usageNote: lưu ý sắc thái ngữ pháp (nếu có)

    CHỈ TRẢ VỀ JSON, KHÔNG GIẢI THÍCH THÊM.
    ''';

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': modelName,
          'prompt': prompt,
          'stream': false,
          'options': {'temperature': 0.1},
        }),
      ).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String output = data['response'] ?? '';
        
        // Trích xuất JSON từ response (phòng trường hợp AI thêm văn bản ngoài JSON)
        final jsonMatch = RegExp(r'\[.*\]', dotAll: true).firstMatch(output);
        if (jsonMatch != null) {
          final List<dynamic> list = jsonDecode(jsonMatch.group(0)!);
          return list.map((item) => JapaneseSegment.fromJson(item)).toList();
        }
      }
    } catch (e) {
      // Handle Ollama error
      throw Exception('Lỗi kết nối AI: $e');
    }
    return [];
  }
}
