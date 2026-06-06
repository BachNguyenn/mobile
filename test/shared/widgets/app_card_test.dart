import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/shared/widgets/app_card.dart';

void main() {
  testWidgets('uses themed card color for legacy white cards in dark mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          body: AppCard(color: AppColors.white, child: Text('Card')),
        ),
      ),
    );

    final container = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    final decoration = container.decoration! as BoxDecoration;

    expect(decoration.color, AppTheme.dark.cardColor);
  });
}
