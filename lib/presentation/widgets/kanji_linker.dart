import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/kanji_library_provider.dart';
import '../screens/kanji_detail_screen.dart';
import '../../core/theme/app_colors.dart';

/// Một widget tự động tìm các ký tự Kanji trong chuỗi [text]
/// và biến chúng thành link có thể nhấn được để xem chi tiết.
class KanjiLinker extends ConsumerWidget {
  final String text;
  final TextStyle? style;

  const KanjiLinker({super.key, required this.text, this.style});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Regex cho dải Kanji chuẩn: [一-龯]
    final regex = RegExp(r'[\u4e00-\u9faf]');
    final matches = regex.allMatches(text);
    
    if (matches.isEmpty) {
      return Text(text, style: style);
    }

    final List<InlineSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      // Thêm phần text bình thường trước Kanji
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }

      // Thêm Kanji dưới dạng WidgetSpan (để có thể GestureDetector)
      final kanjiChar = text.substring(match.start, match.end);
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: GestureDetector(
            onTap: () async {
              final repo = ref.read(kanjiRepositoryProvider);
              final kanjiCard = await repo.getCardByKanji(kanjiChar);
              if (kanjiCard != null && context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => KanjiDetailScreen(kanji: kanjiCard)),
                );
              }
            },
            child: Text(
              kanjiChar,
              style: (style ?? const TextStyle()).copyWith(
                color: AppColors.mossGreen,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.mossGreen.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      );
      lastMatchEnd = match.end;
    }

    // Thêm phần text còn lại sau Kanji cuối cùng
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return RichText(
      text: TextSpan(
        style: style ?? const TextStyle(color: Color(0xFF2C3E50), fontSize: 16),
        children: spans,
      ),
    );
  }
}
