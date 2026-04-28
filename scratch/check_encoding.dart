import 'dart:io';

void main() async {
  final file = File('d:/dataset nihongo/vocab_unzipped/jlpt_vocab.csv');
  if (!await file.exists()) {
    print('File không tồn tại!');
    return;
  }

  final bytes = await file.readAsBytes();
  print('Tổng số byte: ${bytes.length}');
  
  // In 100 byte đầu tiên dạng Hex
  print('100 byte đầu tiên:');
  final hex = bytes.take(100).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
  print(hex);
  
  // Thử giải mã một vài đoạn chứa tiếng Nhật (sau dòng header)
  // Dòng 1: Original,Furigana,English,JLPT Level (khoảng 35 bytes)
  // Hãy xem các byte sau đó.
}
