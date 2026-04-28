import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/kanji_card.dart';

class KanjiDetailScreen extends StatelessWidget {
  final KanjiCard kanji;

  const KanjiDetailScreen({super.key, required this.kanji});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.mossGreen,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.mossGradient,
                ),
                child: Center(
                  child: Hero(
                    tag: 'kanji_${kanji.kanji}',
                    child: Text(
                      kanji.kanji,
                      style: AppTypography.kanjiDisplay.copyWith(
                        fontSize: 100,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sp24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(),
                  const SizedBox(height: AppSpacing.sp32),
                  _buildInfoCard(
                    'Ý nghĩa',
                    kanji.meanings,
                    Icons.translate_rounded,
                    AppColors.waterBlue,
                  ),
                  const SizedBox(height: AppSpacing.sp16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          'Onyomi',
                          kanji.onyomi,
                          Icons.record_voice_over_rounded,
                          AppColors.terracotta,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sp16),
                      Expanded(
                        child: _buildInfoCard(
                          'Kunyomi',
                          kanji.kunyomi,
                          Icons.record_voice_over_outlined,
                          AppColors.mossGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sp32),
                  Text(
                    'Ghi chú ôn tập',
                    style: AppTypography.headingS,
                  ),
                  const SizedBox(height: AppSpacing.sp12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.sp16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                      border: Border.all(color: AppColors.slateLight.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      'Lần ôn tập tiếp theo: ${_formatDate(kanji.nextReview)}',
                      style: AppTypography.bodyM.copyWith(color: AppColors.slateGrey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trình độ',
              style: AppTypography.labelS.copyWith(color: AppColors.slateMuted),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.mossGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusS),
              ),
              child: Text(
                'JLPT N${kanji.jlptLevel}',
                style: AppTypography.bodyMBold.copyWith(color: AppColors.mossGreen),
              ),
            ),
          ],
        ),
        _buildStatCircle('Sẻ chia', Icons.share_rounded),
      ],
    );
  }

  Widget _buildStatCircle(String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.slateLight.withValues(alpha: 0.2)),
          ),
          child: Icon(icon, size: 20, color: AppColors.slateGrey),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTypography.labelS.copyWith(color: AppColors.slateMuted)),
      ],
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon, Color themeColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sp20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: themeColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: themeColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTypography.bodyMBold.copyWith(color: themeColor),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp12),
          Text(
            content.isEmpty ? '---' : content,
            style: AppTypography.bodyL.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}