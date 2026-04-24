import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF8),
      appBar: AppBar(
        title: const Text('Thống kê học tập', style: TextStyle(fontFamily: 'Serif')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatSummary(),
            const SizedBox(height: 32),
            const Text(
              'Tiến độ 7 ngày qua',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildWeeklyChart(),
            const SizedBox(height: 32),
            _buildJlptDistribution(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSummary() {
    return Row(
      children: [
        _buildStatCard('Đã học', '124', Colors.green),
        const SizedBox(width: 16),
        _buildStatCard('Đang nhớ', '86', Colors.blue),
        const SizedBox(width: 16),
        _buildStatCard('Chưa học', '1890', Colors.grey),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildBar('T2', 0.4),
          _buildBar('T3', 0.7),
          _buildBar('T4', 0.3),
          _buildBar('T5', 0.9),
          _buildBar('T6', 0.5),
          _buildBar('T7', 0.2),
          _buildBar('CN', 0.8),
        ],
      ),
    );
  }

  Widget _buildBar(String day, double percent) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 12,
          height: 140 * percent,
          decoration: BoxDecoration(
            color: const Color(0xFF8A9A5B),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildJlptDistribution() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phân bổ theo JLPT',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildJlptProgress('N5', 0.8, Colors.green),
        _buildJlptProgress('N4', 0.3, Colors.blue),
        _buildJlptProgress('N3', 0.1, Colors.orange),
        _buildJlptProgress('N2', 0.0, Colors.red),
        _buildJlptProgress('N1', 0.0, Colors.purple),
      ],
    );
  }

  Widget _buildJlptProgress(String level, double percent, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text(level, style: const TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(width: 12),
          Expanded(
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: color.withValues(alpha: 0.1),
              color: color,
              borderRadius: BorderRadius.circular(10),
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 12),
          Text('${(percent * 100).toInt()}%', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}