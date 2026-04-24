import 'package:flutter/material.dart';
import '../../domain/entities/kanji_card.dart';

class ReviewScreen extends StatefulWidget {
  final List<KanjiCard> cards;

  const ReviewScreen({super.key, required this.cards});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _currentIndex = 0;
  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Không có thẻ nào để ôn tập')),
      );
    }

    final card = widget.cards[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF8),
      appBar: AppBar(
        title: Text('Ôn tập (${_currentIndex + 1}/${widget.cards.length})'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      card.kanji,
                      style: const TextStyle(fontSize: 120, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 40),
                    if (_showAnswer) ...[
                      Text(
                        card.meanings,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text('On: ${card.onyomi}'),
                      Text('Kun: ${card.kunyomi}'),
                    ] else
                      const Text('Nhấn để xem đáp án', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            if (!_showAnswer)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => setState(() => _showAnswer = true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C3E50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Xem đáp án'),
                ),
              )
            else
              Row(
                children: [
                  _buildReviewButton('Lại', Colors.red, 1),
                  const SizedBox(width: 12),
                  _buildReviewButton('Khó', Colors.orange, 2),
                  const SizedBox(width: 12),
                  _buildReviewButton('Tốt', Colors.green, 3),
                  const SizedBox(width: 12),
                  _buildReviewButton('Dễ', Colors.blue, 4),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewButton(String label, Color color, int rating) {
    return Expanded(
      child: SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: () => _handleRating(rating),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(label),
        ),
      ),
    );
  }

  void _handleRating(int rating) {
    if (_currentIndex < widget.cards.length - 1) {
      setState(() {
        _currentIndex++;
        _showAnswer = false;
      });
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hoàn thành bài học!')),
      );
    }
  }
}