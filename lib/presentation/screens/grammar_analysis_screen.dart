import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../providers/grammar_analysis_controller.dart';
import '../widgets/grammar/grammar_segment_card.dart';

class GrammarAnalysisScreen extends ConsumerStatefulWidget {
  const GrammarAnalysisScreen({super.key});

  @override
  ConsumerState<GrammarAnalysisScreen> createState() => _GrammarAnalysisScreenState();
}

class _GrammarAnalysisScreenState extends ConsumerState<GrammarAnalysisScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(grammarAnalysisControllerProvider);
    final controller = ref.read(grammarAnalysisControllerProvider.notifier);

    // Listen for errors
    ref.listen(grammarAnalysisControllerProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${next.error}')),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Text('Phân tích Ngữ pháp', style: AppTypography.headingM),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.slateGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.sp24),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Nhập câu tiếng Nhật cần phân tích...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                  borderSide: BorderSide(color: AppColors.mossGreen.withValues(alpha: 0.2)),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send_rounded, color: AppColors.mossGreen),
                  onPressed: () => controller.analyze(_controller.text),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sp24),
            if (state.isLoading)
              const Center(child: CircularProgressIndicator(color: AppColors.mossGreen))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: state.segments.length,
                  itemBuilder: (context, index) => GrammarSegmentCard(segment: state.segments[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
