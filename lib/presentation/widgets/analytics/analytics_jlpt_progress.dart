import 'package:flutter/material.dart';

class AnalyticsJlptProgress extends StatelessWidget {
  final Map<String, double> progress;

  const AnalyticsJlptProgress({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phân bổ theo JLPT',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _JlptProgressRow(level: 'N5', percent: progress['N5'] ?? 0, color: Colors.green),
        _JlptProgressRow(level: 'N4', percent: progress['N4'] ?? 0, color: Colors.blue),
        _JlptProgressRow(level: 'N3', percent: progress['N3'] ?? 0, color: Colors.orange),
        _JlptProgressRow(level: 'N2', percent: progress['N2'] ?? 0, color: Colors.red),
        _JlptProgressRow(level: 'N1', percent: progress['N1'] ?? 0, color: Colors.purple),
      ],
    );
  }
}

class _JlptProgressRow extends StatelessWidget {
  final String level;
  final double percent;
  final Color color;

  const _JlptProgressRow({
    required this.level,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              level,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
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
