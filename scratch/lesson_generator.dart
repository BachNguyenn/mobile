
import 'dart:convert';
import 'dart:io';

void main() async {
  print('--- DEMO: MÓC NỐI DỮ LIỆU BÀI HỌC (UNIT 1) ---\n');

  // 1. Load data
  final kanjiData = json.decode(await File('assets/data/n5/kanji.json').readAsString()) as List;
  final vocabData = json.decode(await File('d:/dataset nihongo/JLPTWords.json').readAsString()) as Map<String, dynamic>;
  final grammarData = json.decode(await File('assets/data/n5/grammar.json').readAsString()) as List;

  // 2. Chọn 5 Kanji đầu tiên của N5 làm ví dụ
  final targetKanji = kanjiData.take(5).toList();
  final kanjiChars = targetKanji.map((k) => k['character'] as String).toList();
  print('1. Kanji mục tiêu: ${kanjiChars.join(', ')}');

  // 3. Tìm từ vựng liên quan (chứa ít nhất 1 trong 5 Kanji trên)
  print('\n2. Đang tìm từ vựng liên quan...');
  final relatedVocab = <Map<String, dynamic>>[];
  
  vocabData.forEach((word, details) {
    if (relatedVocab.length >= 10) return; // Lấy 10 từ thôi
    
    // Kiểm tra xem từ vựng có chứa kanji mục tiêu không
    bool containsTarget = false;
    for (var char in kanjiChars) {
      if (word.contains(char)) {
        containsTarget = true;
        break;
      }
    }

    if (containsTarget) {
      final list = details as List;
      // Chỉ lấy từ trình độ level 5 (N5)
      final n5Detail = list.firstWhere((d) => d['level'] == 5, orElse: () => null);
      if (n5Detail != null) {
        relatedVocab.add({
          'word': word,
          'reading': n5Detail['reading'],
          'kanji_used': kanjiChars.where((c) => word.contains(c)).toList(),
        });
      }
    }
  });

  for (var v in relatedVocab) {
    print('   - ${v['word']} (${v['reading']}) [Chứa: ${v['kanji_used'].join(', ')}]');
  }

  // 4. Chọn ngữ pháp (Giả lập chọn 2 mẫu đầu tiên của N5)
  print('\n3. Ngữ pháp đi kèm (N5):');
  final sampleGrammar = grammarData.take(2).toList();
  for (var g in sampleGrammar) {
    print('   - ${g['title']}: ${g['short_explanation']}');
  }

  print('\n--- KẾT QUẢ: UNIT 1 ĐÃ SẴN SÀNG ---');
}
