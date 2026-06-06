import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/analytics/domain/entities/analytics_data.dart';
import 'package:mobile/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:mobile/features/home/application/providers/home_progress_provider.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  throw UnimplementedError('analyticsRepositoryProvider must be overridden');
});

final analyticsProvider = FutureProvider<AnalyticsData>((ref) async {
  await ref.watch(homeProgressProvider.future);
  return ref.watch(analyticsRepositoryProvider).load();
});
