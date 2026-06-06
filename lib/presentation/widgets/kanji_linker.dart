import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/kanji/application/providers/kanji_repository_provider.dart';
import 'package:mobile/features/kanji/presentation/screens/kanji_detail_screen.dart';

class KanjiLinker extends ConsumerStatefulWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow overflow;
  final TextAlign textAlign;

  const KanjiLinker({
    super.key,
    required this.text,
    this.style,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.textAlign = TextAlign.start,
  });

  @override
  ConsumerState<KanjiLinker> createState() => _KanjiLinkerState();
}

class _KanjiLinkerState extends ConsumerState<KanjiLinker> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();
    final matches = RegExp(r'[\u4e00-\u9faf]').allMatches(widget.text);
    if (matches.isEmpty) {
      return Text(
        widget.text,
        style: widget.style,
        maxLines: widget.maxLines,
        overflow: widget.overflow,
        textAlign: widget.textAlign,
      );
    }

    final resolvedMossGreen = AppColors.resolve(AppColors.mossGreen, context);
    final defaultColor = Theme.of(context).colorScheme.onSurface;
    final spans = <InlineSpan>[];
    var lastMatchEnd = 0;

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(text: widget.text.substring(lastMatchEnd, match.start)),
        );
      }

      final kanjiChar = widget.text.substring(match.start, match.end);
      final recognizer = TapGestureRecognizer()
        ..onTap = () => _openKanji(context, kanjiChar);
      _recognizers.add(recognizer);

      spans.add(
        TextSpan(
          text: kanjiChar,
          recognizer: recognizer,
          style: (widget.style ?? const TextStyle()).copyWith(
            color: resolvedMossGreen,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
            decorationColor: resolvedMossGreen.withValues(alpha: 0.3),
          ),
        ),
      );
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < widget.text.length) {
      spans.add(TextSpan(text: widget.text.substring(lastMatchEnd)));
    }

    return Text.rich(
      TextSpan(
        style: widget.style ?? TextStyle(color: defaultColor, fontSize: 16),
        children: spans,
      ),
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      textAlign: widget.textAlign,
    );
  }

  Future<void> _openKanji(BuildContext context, String kanjiChar) async {
    final repo = ref.read(kanjiRepositoryProvider);
    final kanjiCard = await repo.getCardByKanji(kanjiChar);
    if (kanjiCard != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => KanjiDetailScreen(kanji: kanjiCard)),
      );
      return;
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Chưa có dữ liệu cho $kanjiChar')));
  }
}
