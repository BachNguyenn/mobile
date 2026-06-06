import 'package:mobile/features/sync/domain/entities/progress_sync_summary.dart';

abstract class ProgressSyncRepository {
  Future<ProgressSyncSummary> loadCloudSummary();

  Future<ProgressSyncResult> backupNow();

  Future<ProgressSyncResult> restoreFromCloud();
}
