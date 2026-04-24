import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/learning_path_provider.dart';
import '../../domain/entities/lesson.dart';
import 'lesson_detail_screen.dart';

class LearningPathScreen extends ConsumerWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessons = ref.watch(learningPathProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF8), // Washi paper
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: const Color(0xFFFDFCF8),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Lộ trình học tập',
                style: TextStyle(
                  color: Color(0xFF2C3E50),
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final lesson = lessons[index];
                  final isLast = index == lessons.length - 1;
                  
                  return _buildLessonNode(context, ref, lesson, isLast);
                },
                childCount: lessons.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonNode(BuildContext context, WidgetRef ref, Lesson lesson, bool isLast) {
    return Column(
      children: [
        Row(
          children: [
            // Left side: Lesson Node
            _buildNodeIcon(lesson),
            const SizedBox(width: 24),
            // Right side: Lesson Info
            Expanded(
              child: GestureDetector(
                onTap: lesson.isUnlocked 
                    ? () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (_) => LessonDetailScreen(lesson: lesson))
                        );
                      }
                    : null,
                child: Opacity(
                  opacity: lesson.isUnlocked ? 1.0 : 0.5,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                        Text(
                          lesson.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${lesson.kanjiIds.length} Kanji',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (!isLast)
          Container(
            height: 60,
            margin: const EdgeInsets.only(left: 20),
            child: CustomPaint(
              painter: PathDashedLinePainter(
                color: lesson.isCompleted ? const Color(0xFF8A9A5B) : Colors.grey.shade300,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNodeIcon(Lesson lesson) {
    Color color = Colors.grey.shade300;
    IconData icon = Icons.lock_outline;

    if (lesson.isCompleted) {
      color = const Color(0xFF8A9A5B);
      icon = Icons.check_circle;
    } else if (lesson.isUnlocked) {
      color = const Color(0xFFE67E22);
      icon = Icons.play_circle_filled;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class PathDashedLinePainter extends CustomPainter {
  final Color color;
  PathDashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashHeight = 5;
    const dashSpace = 5;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}