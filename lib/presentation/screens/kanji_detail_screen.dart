import 'package:flutter/material.dart';
import '../../domain/entities/kanji_card.dart';

class KanjiDetailScreen extends StatelessWidget {
  final KanjiCard kanji;

  const KanjiDetailScreen({super.key, required this.kanji});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF8), // Rice Paper
      appBar: AppBar(
        title: Text(kanji.kanji, style: const TextStyle(fontFamily: 'Serif')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF2C3E50),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    kanji.kanji,
                    style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildSection('Ý nghĩa', kanji.meanings, Icons.translate),
            const SizedBox(height: 20),
            _buildSection('Âm Onyomi', kanji.onyomi, Icons.record_voice_over),
            const SizedBox(height: 20),
            _buildSection('Âm Kunyomi', kanji.kunyomi, Icons.record_voice_over_outlined),
            const SizedBox(height: 20),
            _buildSection('Trình độ JLPT', 'N${kanji.jlptLevel}', Icons.stairs),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF8A9A5B)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            content,
            style: const TextStyle(fontSize: 18, color: Color(0xFF34495E)),
          ),
        ),
      ],
    );
  }
}