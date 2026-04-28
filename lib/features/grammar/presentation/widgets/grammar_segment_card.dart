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
    if (type.contains('danh từ')) return Colors.blue;
    if (type.contains('động từ')) return Colors.red;
    if (type.contains('trợ từ')) return Colors.green;
    if (type.contains('tính từ')) return Colors.orange;
    return AppColors.slateGrey;
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor();
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sp16),
      padding: const EdgeInsets.all(AppSpacing.sp16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(segment.reading, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  KanjiLinker(
                    text: segment.text,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  segment.type,
                  style: TextStyle(color: typeColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Text('Nghĩa: ${segment.explanation}', style: AppTypography.bodyMBold),
          const SizedBox(height: 4),
          Text('Nguyên mẫu: ${segment.baseForm}', style: AppTypography.bodyS),
          if (segment.usageNote != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppColors.mossGreen),
                  const SizedBox(width: 8),
                  Expanded(child: Text(segment.usageNote!, style: AppTypography.bodyS)),
                ],
              ),
            ),
          ],
          if (segment.example != null) ...[
            const SizedBox(height: 8),
            Text('Ví dụ: ${segment.example!}', 
                style: AppTypography.bodyS.copyWith(fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }
}
