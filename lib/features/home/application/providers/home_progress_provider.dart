import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/bootstrap/database_initializer_provider.dart';
import 'package:mobile/core/models/progress_models.dart';
import 'package:mobile/features/home/domain/repositories/home_progress_repository.dart';

final homeProgressRepositoryProvider = Provider<HomeProgressRepository>((ref) {
  throw UnimplementedError('homeProgressRepositoryProvider must be overridden');
});

final homeProgressProvider = FutureProvider<HomeProgress>((ref) async {
  await ref.watch(databaseInitializerProvider.future);
  return ref.watch(homeProgressRepositoryProvider).loadProgress();
});
