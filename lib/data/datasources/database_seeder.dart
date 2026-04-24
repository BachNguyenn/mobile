import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/kanji_card.dart';
import '../../domain/repositories/kanji_repository.dart';

class DatabaseSeeder {
  final KanjiRepository repository;

  DatabaseSeeder(this.repository);

  Future<void> seedData() async {
    final levels = ['n5', 'n4', 'n3', 'n2', 'n1'];
    
    for (final level in levels) {
      try {
        final String response = await rootBundle.loadString('assets/data/$level/kanji.json');
        final List<dynamic> data = json.decode(response);
        
        final List<KanjiCard> cards = data.map((json) {
          return KanjiCard(
            id: '${level}_${json['kanji']}',
            kanji: json['kanji'],
            meanings: (json['meanings'] as List).join(', '),
            onyomi: (json['onyomi'] as List).join(', '),
            kunyomi: (json['kunyomi'] as List).join(', '),
            jlptLevel: int.parse(level.replaceAll('n', '')),
            nextReview: DateTime.now(),
          );
        }).toList();
        
        await repository.saveAllCards(cards);
      } catch (e) {
        // Ignore seeding errors for missing files
      }
    }
  }
}
