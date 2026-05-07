import 'dart:convert';
import 'dart:io';

/// Local-only enrichment merger.
///
/// Expected optional inputs:
/// - enrichment/vocabulary_enrichment.json
/// - enrichment/kanji_enrichment.json
///
/// Each input may be either a list of records or a map keyed by word/kanji/id.
/// This script never downloads data. It only merges local files into
/// assets/data/n*/vocabulary.json and assets/data/n*/kanji.json.
Future<void> main(List<String> args) async {
  final root = Directory.current;
  final assetsDir = Directory('${root.path}/assets/data');
  final enrichmentDir = Directory('${root.path}/enrichment');

  if (!await assetsDir.exists()) {
    stderr.writeln('Missing assets/data directory.');
    exitCode = 1;
    return;
  }

  final vocabEnrichment = await _loadEnrichment(
    File('${enrichmentDir.path}/vocabulary_enrichment.json'),
    keyFields: const ['id', 'word'],
  );
  final kanjiEnrichment = await _loadEnrichment(
    File('${enrichmentDir.path}/kanji_enrichment.json'),
    keyFields: const ['id', 'character', 'kanji'],
  );

  var changedFiles = 0;
  for (final level in ['n5', 'n4', 'n3', 'n2', 'n1']) {
    changedFiles += await _mergeFile(
      file: File('${assetsDir.path}/$level/vocabulary.json'),
      enrichment: vocabEnrichment,
      keyFields: const ['id', 'word'],
      allowedFields: const [
        'example_sentences',
        'image_url',
        'pitch_accent',
        'part_of_speech',
      ],
    );
    changedFiles += await _mergeFile(
      file: File('${assetsDir.path}/$level/kanji.json'),
      enrichment: kanjiEnrichment,
      keyFields: const ['id', 'character', 'kanji'],
      allowedFields: const ['radicals', 'mnemonic', 'related_words'],
    );
  }

  stdout.writeln(
    'Content enrichment merge complete. Changed files: $changedFiles',
  );
}

Future<Map<String, Map<String, dynamic>>> _loadEnrichment(
  File file, {
  required List<String> keyFields,
}) async {
  if (!await file.exists()) return {};

  final decoded = jsonDecode(await file.readAsString());
  if (decoded is Map) {
    return decoded.map(
      (key, value) =>
          MapEntry(key.toString(), Map<String, dynamic>.from(value as Map)),
    );
  }

  if (decoded is List) {
    final result = <String, Map<String, dynamic>>{};
    for (final item in decoded) {
      if (item is! Map) continue;
      final record = Map<String, dynamic>.from(item);
      final key = _firstKey(record, keyFields);
      if (key != null) result[key] = record;
    }
    return result;
  }

  return {};
}

Future<int> _mergeFile({
  required File file,
  required Map<String, Map<String, dynamic>> enrichment,
  required List<String> keyFields,
  required List<String> allowedFields,
}) async {
  if (enrichment.isEmpty || !await file.exists()) return 0;

  final decoded = jsonDecode(await file.readAsString());
  if (decoded is! List) return 0;

  var changed = false;
  final output = <Map<String, dynamic>>[];
  for (final item in decoded) {
    final record = Map<String, dynamic>.from(item as Map);
    final key = _firstKey(record, keyFields);
    final extra = key == null ? null : enrichment[key];
    if (extra != null) {
      for (final field in allowedFields) {
        if (extra.containsKey(field) && extra[field] != null) {
          record[field] = extra[field];
          changed = true;
        }
      }
    }
    output.add(record);
  }

  if (!changed) return 0;

  const encoder = JsonEncoder.withIndent('  ');
  await file.writeAsString('${encoder.convert(output)}\n');
  return 1;
}

String? _firstKey(Map<String, dynamic> record, List<String> keyFields) {
  for (final field in keyFields) {
    final value = record[field]?.toString().trim();
    if (value != null && value.isNotEmpty) return value;
  }
  return null;
}
