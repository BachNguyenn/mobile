
import 'dart:convert';
import 'dart:io';

void main() async {
  final csvFile = File('d:/dataset nihongo/vocab_unzipped/jlpt_vocab.csv');
  
  print('--- Đang chuyển đổi Từ vựng từ CSV sang JSON ---');

  // Đọc file với encoding Latin1 để tránh lỗi UTF-8 nếu file là Shift-JIS hoặc UTF-16
  // Sau đó chúng ta sẽ thử decode lại các chuỗi.
  // Tuy nhiên, cách tốt nhất là thử đọc trực tiếp bằng UTF-8 trước.
  List<String> lines;
  try {
    lines = await csvFile.readAsLines(encoding: utf8);
  } catch (e) {
    print('Thử nghiệm mã hóa Latin1 do UTF-8 thất bại...');
    lines = await csvFile.readAsLines(encoding: latin1);
  }

  if (lines.isEmpty) return;

  // Bỏ dòng header
  final header = lines.first;
  final dataLines = lines.skip(1);

  final Map<String, List<Map<String, dynamic>>> groupedVocab = {
    'N1': [], 'N2': [], 'N3': [], 'N4': [], 'N5': []
  };

  int count = 0;
  for (var line in dataLines) {
    // Tách CSV đơn giản (có xử lý dấu ngoặc kép nếu cần)
    // Cấu trúc: Original,Furigana,English,JLPT Level
    final parts = line.split(',');
    if (parts.length < 4) continue;

    final word = parts[0].trim();
    final reading = parts[1].trim();
    final level = parts.last.trim(); // N1, N2...
    
    // English có thể chứa dấu phẩy nên chúng ta lấy phần ở giữa
    final english = parts.sublist(2, parts.length - 1).join(',').replaceAll('"', '').trim();

    if (groupedVocab.containsKey(level)) {
      groupedVocab[level]!.add({
        'word': word,
        'reading': reading,
        'meaning': english,
      });
      count++;
    }
  }

  // Xuất ra các thư mục
  for (var level in groupedVocab.keys) {
    final folderName = level.toLowerCase();
    final directory = Directory('assets/data/$folderName');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final jsonFile = File('assets/data/$folderName/vocabulary.json');
    await jsonFile.writeAsString(jsonEncode(groupedVocab[level]));
    print('Đã tạo: ${jsonFile.path} (${groupedVocab[level]!.length} từ)');
  }

  print('\nHoàn thành! Tổng cộng $count từ vựng đã được xử lý.');
}
