import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/lesson.dart';
import '../providers/kanji_library_provider.dart';
import 'review_screen.dart';

class LessonDetailScreen extends ConsumerWidget {
  final Lesson lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allKanji = ref.watch(kanjiListProvider).value ?? [];
    final lessonKanji = allKanji.where((k) => lesson.kanjiIds.contains(k.id)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF8),
      appBar: AppBar(
        title: Text(lesson.title, style: const TextStyle(fontFamily: 'Serif')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: lessonKanji.length,
              itemBuilder: (context, index) {
                final kanji = lessonKanji[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Text(
                      kanji.kanji,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    title: Text(kanji.meanings, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('On: ${kanji.onyomi}\nKun: ${kanji.kunyomi}'),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewScreen(cards: lessonKanji),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8A9A5B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Bắt đầu học', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}