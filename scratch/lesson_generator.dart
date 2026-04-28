import 'dart:convert';
import 'dart:io';

void main() async {
  print('--- Đang tạo Lộ trình học tích hợp (Unified Learning Path) ---');

  final List<Map<String, dynamic>> fullPath = [];
  
  final levels = [5, 4, 3];

  for (var level in levels) {
    print('Đang xử lý N$level...');
    final kanjiFile = File('assets/data/n$level/kanji.json');
    final vocabFile = File('assets/data/n$level/vocabulary.json');
    final grammarFile = File('assets/data/n$level/grammar.json');

    if (!await kanjiFile.exists() || !await vocabFile.exists() || !await grammarFile.exists()) {
      print('Bỏ qua N$level do thiếu file dữ liệu.');
      continue;
    }

    final List<dynamic> kanjiData = jsonDecode(await kanjiFile.readAsString(encoding: utf8));
    final List<dynamic> vocabData = jsonDecode(await vocabFile.readAsString(encoding: utf8));
    final List<dynamic> grammarData = jsonDecode(await grammarFile.readAsString(encoding: utf8));

    int kanjiIdx = 0;
    int grammarIdx = 0;
    int lessonCount = 1;

    while (kanjiIdx < kanjiData.length) {
      final currentKanji = kanjiData.skip(kanjiIdx).take(5).toList();
      final kanjiChars = currentKanji.map((k) => k['character'] as String).toList();
      final kanjiIds = kanjiChars.map((c) => 'n${level}_$c').toList();

      final relatedVocab = vocabData.where((v) {
        final word = v['word'] as String;
        return kanjiChars.any((char) => word.contains(char));
      }).take(12).toList();

      final vocabIds = relatedVocab.map((v) => 'n${level}_${v['word']}').toList();

      final currentGrammar = grammarData.skip(grammarIdx).take(2).toList();
      final grammarIds = currentGrammar.map((g) => 'n${level}_${g['title']}').toList();

      fullPath.add({
        'id': 'lesson_n${level}_$lessonCount',
        'title': 'Bài $lessonCount (N$level)',
        'type': 'lesson',
        'level': level,
        'kanjiIds': kanjiIds,
        'vocabIds': vocabIds,
        'grammarIds': grammarIds,
      });

      if (lessonCount % 5 == 0) {
        fullPath.add({
          'id': 'milestone_n${level}_${lessonCount ~/ 5}',
          'title': 'Kiểm tra định kỳ ${lessonCount ~/ 5}',
          'type': 'quiz',
          'level': level,
          'lessonRange': [lessonCount - 4, lessonCount],
        });
      }

      kanjiIdx += 5;
      grammarIdx += 2;
      if (grammarIdx >= grammarData.length) grammarIdx = 0;
      lessonCount++;
    }
  }

  final outputFile = File('assets/data/unified_path.json');
  const encoder = JsonEncoder.withIndent('  ');
  await outputFile.writeAsString(encoder.convert(fullPath), encoding: utf8);

  print('\nThành công! Đã tạo lộ trình với ${fullPath.length} nodes tại ${outputFile.path}');
}
