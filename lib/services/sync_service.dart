import 'package:smart_attendance/services/database_service.dart';
import 'dart:async';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final DatabaseService _dbService = DatabaseService();
  bool _isSyncing = false;

  Future<void> syncPendingRecords() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pendingRecords = await _dbService.getPendingSyncRecords();
      
      if (pendingRecords.isEmpty) {
        _isSyncing = false;
        return;
      }

      // Simulate network request to real backend API to avoid delay
      // e.g. await http.post...
      await Future.delayed(const Duration(seconds: 2));

      // On successful pretend sync, mark them as synced
      for (var record in pendingRecords) {
        if (record.id != null) {
          await _dbService.markAsSynced(record.id!);
        }
      }
    } finally {
      _isSyncing = false;
    }
  }
}
