import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/japanese_segment.dart';
import '../../../../presentation/widgets/kanji_linker.dart';

class GrammarSegmentCard extends StatelessWidget {
  final JapaneseSegment segment;

  const GrammarSegmentCard({super.key, required this.segment});

  Color _getTypeColor() {
    final type = segment.type.toLowerCase();
    if (type.contains('danh từ')) return AppColors.waterBlue;
    if (type.contains('động từ')) return AppColors.terracotta;
    if (type.contains('trợ từ')) return AppColors.success;
    if (type.contains('tính từ')) return AppColors.sunGold;
    if (type.contains('ngữ pháp')) return AppColors.mossGreen;
    return AppColors.slateGrey;
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sp16),
      padding: const EdgeInsets.all(AppSpacing.sp16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (segment.reading.isNotEmpty)
                      Text(segment.reading, style: AppTypography.caption),
                    KanjiLinker(
                      text: segment.text,
                      style: AppTypography.kanjiDisplay.copyWith(
                        fontSize: 26,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sp12),
              if (segment.type.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sp8,
                    vertical: AppSpacing.sp4,
                  ),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXS),
                  ),
                  child: Text(
                    segment.type,
                    style: AppTypography.label.copyWith(
                      color: typeColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const Divider(height: AppSpacing.sp24),
          _InfoRow(label: 'Nghĩa', value: segment.explanation, isPrimary: true),
          if (segment.baseForm.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sp8),
            _InfoRow(label: 'Dạng gốc', value: segment.baseForm),
          ],
          if (segment.usageNote != null) ...[
            const SizedBox(height: AppSpacing.sp12),
            _NoteBox(text: segment.usageNote!),
          ],
          if (segment.example != null) ...[
            const SizedBox(height: AppSpacing.sp12),
            Text(
              'Ví dụ',
              style: AppTypography.label.copyWith(
                color: AppColors.slateMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sp4),
            Text(
              segment.example!,
              style: AppTypography.bodyS.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.slateGrey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isPrimary;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.label.copyWith(
            color: AppColors.slateMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sp4),
        Text(
          value,
          style: (isPrimary ? AppTypography.bodyMBold : AppTypography.bodyS)
              .copyWith(color: AppColors.slateGrey),
        ),
      ],
    );
  }
}

class _NoteBox extends StatelessWidget {
  final String text;

  const _NoteBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sp12),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
        border: Border.all(color: AppColors.mossGreen.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.tips_and_updates_outlined,
            size: 18,
            color: AppColors.mossGreen,
          ),
          const SizedBox(width: AppSpacing.sp8),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyS.copyWith(color: AppColors.slateGrey),
            ),
          ),
        ],
      ),
    );
  }
}
