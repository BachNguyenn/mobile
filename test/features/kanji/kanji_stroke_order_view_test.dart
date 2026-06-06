import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/kanji/presentation/widgets/kanji_stroke_order_view.dart';

void main() {
  testWidgets('renders stroke animation controls when paths exist', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: SingleChildScrollView(
            child: KanjiStrokeOrderView(
              strokePaths: ['M0,0 L20,20'],
              strokeCount: 1,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Th\u1ee9 t\u1ef1 n\u00e9t'), findsOneWidget);
    expect(find.text('1 n\u00e9t'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    expect(find.byIcon(Icons.replay_rounded), findsOneWidget);
  });

  testWidgets('renders fallback when stroke paths are missing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: SingleChildScrollView(
            child: KanjiStrokeOrderView(strokePaths: [], strokeCount: 6),
          ),
        ),
      ),
    );

    expect(find.text('Th\u1ee9 t\u1ef1 n\u00e9t'), findsOneWidget);
    expect(find.text('6 n\u00e9t'), findsOneWidget);
    expect(
      find.text('Ch\u01b0a c\u00f3 path n\u00e9t. T\u1ed5ng s\u1ed1 n\u00e9t: 6.'),
      findsOneWidget,
    );
  });
}
