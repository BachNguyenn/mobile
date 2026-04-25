import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analytics_provider.dart';
import '../widgets/analytics/analytics_stat_card.dart';
import '../widgets/analytics/analytics_weekly_chart.dart';
import '../widgets/analytics/analytics_jlpt_progress.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF8),
      appBar: AppBar(
        title: const Text('Thống kê học tập', style: TextStyle(fontFamily: 'Serif')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: analyticsAsync.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnalyticsStatCard(label: 'Đã học', value: data.learned.toString(), color: Colors.green),
                  const SizedBox(width: 16),
                  AnalyticsStatCard(label: 'Đang nhớ', value: data.remembering.toString(), color: Colors.blue),
                  const SizedBox(width: 16),
                  AnalyticsStatCard(label: 'Chưa học', value: data.notLearned.toString(), color: Colors.grey),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Tiến độ 7 ngày qua',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              AnalyticsWeeklyChart(weeklyData: data.weeklyData),
              const SizedBox(height: 32),
              AnalyticsJlptProgress(progress: data.jlptProgress),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }
}