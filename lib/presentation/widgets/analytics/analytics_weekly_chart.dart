import 'package:flutter/material.dart';

class AnalyticsWeeklyChart extends StatelessWidget {
  final List<double> weeklyData;

  const AnalyticsWeeklyChart({super.key, required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

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
        children: List.generate(days.length, (index) {
          return _Bar(day: days[index], percent: weeklyData[index]);
        }),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String day;
  final double percent;

  const _Bar({required this.day, required this.percent});

  @override
  Widget build(BuildContext context) {
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
}
