import 'dart:convert';
import 'dart:io';

void main() async {
  final file = File('assets/data/n5/kanji.json');
  final content = await file.readAsString(encoding: utf8);
  final data = jsonDecode(content);
  
  if (data is List && data.isNotEmpty) {
    print('Chữ Kanji đầu tiên: ${data[0]['character']}');
    print('Nghĩa: ${data[0]['meanings']}');
  }
}
