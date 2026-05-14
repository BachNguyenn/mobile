import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/learning/presentation/providers/learning_path_provider.dart';

class PlacementTestScreen extends ConsumerStatefulWidget {
  const PlacementTestScreen({super.key});

  @override
  ConsumerState<PlacementTestScreen> createState() =>
      _PlacementTestScreenState();
}

class _PlacementTestScreenState extends ConsumerState<PlacementTestScreen> {
  int _index = 0;
  int _score = 0;

  @override
  Widget build(BuildContext context) {
    final question = _questions[_index];
    final progress = (_index + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Kiểm tra năng lực')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.sp24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: progress,
              color: AppColors.mossGreen,
              backgroundColor: AppColors.creamDark,
              minHeight: 10,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: AppSpacing.sp20),
            Text(
              'Câu ${_index + 1}/${_questions.length}',
              style: AppTypography.bodyM.copyWith(color: AppColors.slateGrey),
            ),
            const SizedBox(height: AppSpacing.sp12),
            Text(question.prompt, style: AppTypography.headingS),
            const SizedBox(height: AppSpacing.sp20),
            ...question.options.map((option) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sp12),
                child: OutlinedButton(
                  onPressed: () => _onSelect(option),
                  child: Text(option, textAlign: TextAlign.center),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _onSelect(String option) {
    final question = _questions[_index];
    if (option == question.answer) {
      _score += question.weight;
    }

    if (_index < _questions.length - 1) {
      setState(() {
        _index += 1;
      });
      return;
    }

    final level = _recommendLevel(_score);
    ref.read(selectedLevelProvider.notifier).state = level;
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đề xuất trình độ'),
        content: Text('Bạn nên bắt đầu từ JLPT N$level.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Bắt đầu học'),
          ),
        ],
      ),
    );
  }

  int _recommendLevel(int score) {
    if (score >= 20) return 2;
    if (score >= 14) return 3;
    if (score >= 8) return 4;
    return 5;
  }
}

class _PlacementQuestion {
  final String prompt;
  final List<String> options;
  final String answer;
  final int weight;

  const _PlacementQuestion({
    required this.prompt,
    required this.options,
    required this.answer,
    required this.weight,
  });
}

const _questions = <_PlacementQuestion>[
  _PlacementQuestion(
    prompt: 'Chọn nghĩa của 「食べる」',
    options: ['Uống', 'Ăn', 'Đi', 'Ngủ'],
    answer: 'Ăn',
    weight: 2,
  ),
  _PlacementQuestion(
    prompt: 'Dạng quá khứ lịch sự của 「行く」 là gì?',
    options: ['行きます', '行った', '行きました', '行くでした'],
    answer: '行きました',
    weight: 3,
  ),
  _PlacementQuestion(
    prompt: 'Trợ từ nào chỉ chủ đề câu?',
    options: ['を', 'に', 'は', 'で'],
    answer: 'は',
    weight: 2,
  ),
  _PlacementQuestion(
    prompt: 'Chọn cách đọc của 「勉強」',
    options: ['べんきょう', 'べんぎょう', 'めんきょう', 'べんこう'],
    answer: 'べんきょう',
    weight: 3,
  ),
  _PlacementQuestion(
    prompt: 'Mẫu 「〜なければならない」 nghĩa là gì?',
    options: ['Không được', 'Phải', 'Có thể', 'Muốn'],
    answer: 'Phải',
    weight: 4,
  ),
  _PlacementQuestion(
    prompt: 'Chọn câu tự nhiên nhất:',
    options: ['日本語が話せます。', '日本語を話せます。', '日本語に話せます。', '日本語で話せます。'],
    answer: '日本語が話せます。',
    weight: 3,
  ),
];
