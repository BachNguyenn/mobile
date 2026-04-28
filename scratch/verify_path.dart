import 'dart:convert';
import 'dart:io';

void main() async {
  final file = File('assets/data/unified_path.json');
  final content = await file.readAsString(encoding: utf8);
  final data = jsonDecode(content);
  
  if (data is List && data.isNotEmpty) {
    print('Bài học đầu tiên: ${data[0]['title']}');
    print('Loại: ${data[0]['type']}');
    print('Số Kanji: ${data[0]['kanjiIds']?.length}');
    print('Số Vocab: ${data[0]['vocabIds']?.length}');
  }
}
