import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_page_background.dart';
import '../providers/grammar_analysis_controller.dart';
import '../widgets/grammar_segment_card.dart';

class GrammarAnalysisScreen extends ConsumerStatefulWidget {
  const GrammarAnalysisScreen({super.key});

  @override
  ConsumerState<GrammarAnalysisScreen> createState() =>
      _GrammarAnalysisScreenState();
}

class _GrammarAnalysisScreenState extends ConsumerState<GrammarAnalysisScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _analyze() {
    ref
        .read(grammarAnalysisControllerProvider.notifier)
        .analyze(_controller.text);
  }

  void _clear() {
    _controller.clear();
    ref.read(grammarAnalysisControllerProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(grammarAnalysisControllerProvider);
    final canSubmit = _controller.text.trim().isNotEmpty && !state.isLoading;

    ref.listen(grammarAnalysisControllerProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('AI Tutor tiếng Nhật', style: AppTypography.headingM),
        backgroundColor: AppColors.cream.withValues(alpha: 0.94),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.slateGrey,
        actions: [
          if (_controller.text.isNotEmpty || state.segments.isNotEmpty)
            IconButton(
              tooltip: 'Xóa nội dung',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: state.isLoading ? null : _clear,
            ),
        ],
      ),
      body: AppPageBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.sp24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              _TutorInputCard(
                controller: _controller,
                isLoading: state.isLoading,
                canSubmit: canSubmit,
                onChanged: () => setState(() {}),
                onSubmit: _analyze,
              ),
              const SizedBox(height: AppSpacing.sp20),
              _AnalysisContent(state: state),
            ],
          ),
        ),
      ),
    );
  }
}

class _TutorInputCard extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final bool canSubmit;
  final VoidCallback onChanged;
  final VoidCallback onSubmit;

  const _TutorInputCard({
    required this.controller,
    required this.isLoading,
    required this.canSubmit,
    required this.onChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sp16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.mossGreen.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.psychology_rounded,
                    color: AppColors.mossGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sp12),
                Expanded(
                  child: Text(
                    'Nhập câu cần phân tích',
                    style: AppTypography.bodyMBold.copyWith(
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sp12),
            TextField(
              controller: controller,
              enabled: !isLoading,
              maxLines: 4,
              minLines: 3,
              textInputAction: TextInputAction.newline,
              onChanged: (_) => onChanged(),
              decoration: InputDecoration(
                hintText: 'Ví dụ: 私は昨日学校へ行きました。',
                hintStyle: AppTypography.bodyM.copyWith(
                  color: AppColors.slateMuted,
                ),
                filled: true,
                fillColor: AppColors.cream,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                  borderSide: BorderSide(
                    color: AppColors.mossGreen.withValues(alpha: 0.18),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                  borderSide: BorderSide(
                    color: AppColors.mossGreen.withValues(alpha: 0.18),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                  borderSide: const BorderSide(color: AppColors.mossGreen),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sp12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: canSubmit ? onSubmit : null,
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome_rounded, size: 18),
                label: Text(isLoading ? 'Đang phân tích' : 'Phân tích'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.mossGreen,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.slateLight.withValues(
                    alpha: 0.45,
                  ),
                  disabledForegroundColor: AppColors.slateMuted,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sp16,
                    vertical: AppSpacing.sp12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalysisContent extends StatelessWidget {
  final GrammarAnalysisState state;

  const _AnalysisContent({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const SizedBox(
        height: 160,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.mossGreen),
        ),
      );
    }

    if (state.error != null && state.segments.isEmpty) {
      return _TutorMessage(
        icon: Icons.cloud_off_rounded,
        title: 'Chưa kết nối được AI Tutor',
        message: state.error!,
      );
    }

    if (state.segments.isEmpty) {
      return const _TutorMessage(
        icon: Icons.travel_explore_rounded,
        title: 'Sẵn sàng phân tích',
        message:
            'Nhập một câu tiếng Nhật để AI Tutor tách nghĩa, cách đọc và ghi chú ngữ pháp.',
      );
    }

    return Column(
      children: [
        for (final segment in state.segments)
          GrammarSegmentCard(segment: segment),
      ],
    );
  }
}

class _TutorMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _TutorMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        border: Border.all(color: AppColors.mossGreen.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sp20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: AppColors.mossGreen),
            const SizedBox(height: AppSpacing.sp12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.headingS.copyWith(color: AppColors.ink),
            ),
            const SizedBox(height: AppSpacing.sp8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyM,
            ),
          ],
        ),
      ),
    );
  }
}
