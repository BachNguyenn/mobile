import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/kanji_library_provider.dart';
import 'kanji_detail_screen.dart';

class KanjiLibraryScreen extends ConsumerWidget {
  const KanjiLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(kanjiSearchResultsProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF8), // Rice Paper
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: const Color(0xFF8A9A5B), // Moss Green
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Thư viện Kanji',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Serif',
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8A9A5B), Color(0xFF6B8E23)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.white),
                onPressed: () => _showFilterDialog(context, ref),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) => ref.read(kanjiSearchQueryProvider.notifier).state = value,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm theo Hán tự, nghĩa hoặc cách đọc...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF8A9A5B)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
              ),
            ),
          ),
          searchResults.when(
            data: (kanjis) {
              if (kanjis.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text('Không tìm thấy chữ Kanji nào.'),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final kanji = kanjis[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => KanjiDetailScreen(kanji: kanji),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                kanji.kanji,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                kanji.meanings.split(',').first,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: kanjis.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(child: Text('Lỗi: $err')),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lọc theo trình độ JLPT'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption(context, ref, null, 'Tất cả'),
            _buildFilterOption(context, ref, 5, 'N5'),
            _buildFilterOption(context, ref, 4, 'N4'),
            _buildFilterOption(context, ref, 3, 'N3'),
            _buildFilterOption(context, ref, 2, 'N2'),
            _buildFilterOption(context, ref, 1, 'N1'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(BuildContext context, WidgetRef ref, int? level, String label) {
    final currentFilter = ref.watch(kanjiJlptFilterProvider);
    return ListTile(
      title: Text(label),
      trailing: currentFilter == level ? const Icon(Icons.check, color: Color(0xFF8A9A5B)) : null,
      onTap: () {
        ref.read(kanjiJlptFilterProvider.notifier).state = level;
        Navigator.pop(context);
      },
    );
  }
}

// Dummy MainCenter replacement if needed, but it should be MainAxisAlignment.center
