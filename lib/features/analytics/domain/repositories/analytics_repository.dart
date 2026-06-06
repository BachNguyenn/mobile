import 'package:mobile/features/analytics/domain/entities/analytics_data.dart';

abstract class AnalyticsRepository {
  Future<AnalyticsData> load();
}
