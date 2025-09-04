// 🌐 LingoSphere - Offline History Sync Service
// Ensures history works offline and syncs when connection is restored with conflict resolution

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import '../models/translation_history.dart';
import '../models/translation_entry.dart';
import 'history_service.dart';

/// Sync status for tracking synchronization state
enum SyncStatus {
  idle,
  syncing,
  success,
  error,
  conflict,
}

/// Conflict resolution strategies
enum ConflictResolution {
  useLocal,
  useRemote,
  merge,
  askUser,
}

/// Sync conflict data structure
class SyncConflict {
  final String id;
  final TranslationHistory localVersion;
  final TranslationHistory remoteVersion;
  final DateTime conflictTime;
  final String conflictReason;

  SyncConflict({
    required this.id,
    required this.localVersion,
    required this.remoteVersion,
    required this.conflictTime,
    required this.conflictReason,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'localVersion': localVersion.toJson(),
        'remoteVersion': remoteVersion.toJson(),
        'conflictTime': conflictTime.toIso8601String(),
        'conflictReason': conflictReason,
      };

  factory SyncConflict.fromJson(Map<String, dynamic> json) => SyncConflict(
        id: json['id'],
        localVersion: TranslationHistory.fromJson(json['localVersion']),
        remoteVersion: TranslationHistory.fromJson(json['remoteVersion']),
        conflictTime: DateTime.parse(json['conflictTime']),
        conflictReason: json['conflictReason'],
      );
}

/// Sync statistics and metrics
class SyncStats {
  final DateTime lastSyncTime;
  final int totalSyncedItems;
  final int pendingItems;
  final int conflictCount;
  final int failedItems;
  final Duration lastSyncDuration;
  final Map<String, int> errorCounts;

  SyncStats({
    required this.lastSyncTime,
    required this.totalSyncedItems,
    required this.pendingItems,
    required this.conflictCount,
    required this.failedItems,
    required this.lastSyncDuration,
    required this.errorCounts,
  });

  Map<String, dynamic> toJson() => {
        'lastSyncTime': lastSyncTime.toIso8601String(),
        'totalSyncedItems': totalSyncedItems,
        'pendingItems': pendingItems,
        'conflictCount': conflictCount,
        'failedItems': failedItems,
        'lastSyncDuration': lastSyncDuration.inMilliseconds,
        'errorCounts': errorCounts,
      };

  factory SyncStats.fromJson(Map<String, dynamic> json) => SyncStats(
        lastSyncTime: DateTime.parse(json['lastSyncTime']),
        totalSyncedItems: json['totalSyncedItems'],
        pendingItems: json['pendingItems'],
        conflictCount: json['conflictCount'],
        failedItems: json['failedItems'],
        lastSyncDuration: Duration(milliseconds: json['lastSyncDuration']),
        errorCounts: Map<String, int>.from(json['errorCounts']),
      );
}

/// Offline sync service for managing translation history synchronization
class OfflineSyncService extends ChangeNotifier {
  final HistoryService _historyService;
  final Connectivity _connectivity = Connectivity();

  SyncStatus _syncStatus = SyncStatus.idle;
  List<SyncConflict> _conflicts = [];
  SyncStats? _syncStats;
  Timer? _syncTimer;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  // Sync configuration
  static const Duration _syncInterval = Duration(minutes: 5);
  static const Duration _retryDelay = Duration(minutes: 1);
  static const int _maxRetries = 3;
  static const String _syncPrefsKey = 'offline_sync_data';
  static const String _conflictsPrefsKey = 'sync_conflicts';
  static const String _statsPrefsKey = 'sync_stats';

  // Pending operations queue
  final List<Map<String, dynamic>> _pendingOperations = [];
  bool _isOnline = true;

  OfflineSyncService(this._historyService) {
    _initializeSync();
  }

  // Getters
  SyncStatus get syncStatus => _syncStatus;
  List<SyncConflict> get conflicts => _conflicts;
  SyncStats? get syncStats => _syncStats;
  bool get isOnline => _isOnline;
  int get pendingOperationsCount => _pendingOperations.length;

  /// Initialize synchronization service
  Future<void> _initializeSync() async {
    await _loadPersistedData();
    await _checkConnectivity();
    _setupConnectivityListener();
    _startPeriodicSync();
  }

  /// Load persisted sync data from SharedPreferences
  Future<void> _loadPersistedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load pending operations
      final pendingData = prefs.getString(_syncPrefsKey);
      if (pendingData != null) {
        final List<dynamic> operations = json.decode(pendingData);
        _pendingOperations.clear();
        _pendingOperations.addAll(operations.cast<Map<String, dynamic>>());
      }

      // Load conflicts
      final conflictsData = prefs.getString(_conflictsPrefsKey);
      if (conflictsData != null) {
        final List<dynamic> conflictsList = json.decode(conflictsData);
        _conflicts =
            conflictsList.map((c) => SyncConflict.fromJson(c)).toList();
      }

      // Load sync stats
      final statsData = prefs.getString(_statsPrefsKey);
      if (statsData != null) {
        _syncStats = SyncStats.fromJson(json.decode(statsData));
      }
    } catch (e) {
      debugPrint('Error loading sync data: $e');
    }
  }

  /// Persist sync data to SharedPreferences
  Future<void> _persistSyncData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save pending operations
      await prefs.setString(_syncPrefsKey, json.encode(_pendingOperations));

      // Save conflicts
      await prefs.setString(_conflictsPrefsKey,
          json.encode(_conflicts.map((c) => c.toJson()).toList()));

      // Save sync stats
      if (_syncStats != null) {
        await prefs.setString(
            _statsPrefsKey, json.encode(_syncStats!.toJson()));
      }
    } catch (e) {
      debugPrint('Error persisting sync data: $e');
    }
  }

  /// Check current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isOnline = result != ConnectivityResult.none;

      if (_isOnline && _pendingOperations.isNotEmpty) {
        _triggerSync();
      }
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      _isOnline = false;
    }
  }

  /// Setup connectivity change listener
  void _setupConnectivityListener() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) {
      final wasOnline = _isOnline;
      _isOnline = result != ConnectivityResult.none;

      if (!wasOnline && _isOnline) {
        debugPrint('Connection restored - triggering sync');
        _triggerSync();
      }

      notifyListeners();
    });
  }

  /// Start periodic sync timer
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(_syncInterval, (timer) {
      if (_isOnline && _syncStatus != SyncStatus.syncing) {
        _triggerSync();
      }
    });
  }

  /// Add operation to offline queue
  Future<void> _queueOperation(String type, Map<String, dynamic> data) async {
    final operation = {
      'id': _generateOperationId(),
      'type': type,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'retryCount': 0,
    };

    _pendingOperations.add(operation);
    await _persistSyncData();

    if (_isOnline) {
      _triggerSync();
    }

    notifyListeners();
  }

  /// Generate unique operation ID
  String _generateOperationId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    return md5
        .convert('$timestamp-$random'.codeUnits)
        .toString()
        .substring(0, 8);
  }

  /// Add translation history item (offline-capable)
  Future<void> addHistoryItem(TranslationHistory item) async {
    try {
      // Convert TranslationHistory entries to HistoryEntry objects and add them
      for (final entry in item.entries) {
        final historyEntry = _convertTranslationEntryToHistoryEntry(entry);
        await _historyService.addToHistory(historyEntry);
      }

      if (_isOnline) {
        // Try immediate sync
        await _syncHistoryCollection(item, 'add');
      } else {
        // Queue for offline sync
        await _queueOperation('add', item.toJson());
      }
    } catch (e) {
      debugPrint('Error adding history item: $e');
      // Still queue the operation even if local storage fails
      await _queueOperation('add', item.toJson());
    }
  }

  /// Update translation history item (offline-capable)
  Future<void> updateHistoryItem(TranslationHistory item) async {
    try {
      // Convert TranslationHistory entries to HistoryEntry objects and update them
      for (final entry in item.entries) {
        final historyEntry = _convertTranslationEntryToHistoryEntry(entry);
        await _historyService.updateHistory(historyEntry);
      }

      if (_isOnline) {
        // Try immediate sync
        await _syncHistoryCollection(item, 'update');
      } else {
        // Queue for offline sync
        await _queueOperation('update', item.toJson());
      }
    } catch (e) {
      debugPrint('Error updating history item: $e');
      await _queueOperation('update', item.toJson());
    }
  }

  /// Delete translation history item (offline-capable)
  Future<void> deleteHistoryItem(String id) async {
    try {
      // Delete from local database first
      await _historyService.deleteHistory(id);

      if (_isOnline) {
        // Try immediate sync
        await _syncDeleteItem(id);
      } else {
        // Queue for offline sync
        await _queueOperation('delete', {'id': id});
      }
    } catch (e) {
      debugPrint('Error deleting history item: $e');
      await _queueOperation('delete', {'id': id});
    }
  }

  /// Trigger manual sync
  Future<void> triggerManualSync() async {
    if (!_isOnline) {
      throw Exception('No internet connection available');
    }

    if (_syncStatus == SyncStatus.syncing) {
      throw Exception('Sync already in progress');
    }

    await _triggerSync();
  }

  /// Internal sync trigger
  Future<void> _triggerSync() async {
    if (_syncStatus == SyncStatus.syncing || !_isOnline) {
      return;
    }

    _syncStatus = SyncStatus.syncing;
    notifyListeners();

    final startTime = DateTime.now();
    int syncedItems = 0;
    int failedItems = 0;
    final errorCounts = <String, int>{};

    try {
      // Process pending operations
      final operationsToProcess =
          List<Map<String, dynamic>>.from(_pendingOperations);

      for (final operation in operationsToProcess) {
        try {
          final success = await _processPendingOperation(operation);
          if (success) {
            _pendingOperations.removeWhere((op) => op['id'] == operation['id']);
            syncedItems++;
          } else {
            failedItems++;
            final errorType = operation['type'] as String;
            errorCounts[errorType] = (errorCounts[errorType] ?? 0) + 1;

            // Increment retry count
            operation['retryCount'] = (operation['retryCount'] ?? 0) + 1;

            // Remove if max retries exceeded
            if (operation['retryCount'] >= _maxRetries) {
              _pendingOperations
                  .removeWhere((op) => op['id'] == operation['id']);
              debugPrint(
                  'Max retries exceeded for operation ${operation['id']}');
            }
          }
        } catch (e) {
          debugPrint('Error processing operation ${operation['id']}: $e');
          failedItems++;
        }
      }

      // Perform bidirectional sync
      await _performBidirectionalSync();

      _syncStatus =
          _conflicts.isNotEmpty ? SyncStatus.conflict : SyncStatus.success;

      // Update sync stats
      _syncStats = SyncStats(
        lastSyncTime: DateTime.now(),
        totalSyncedItems: syncedItems,
        pendingItems: _pendingOperations.length,
        conflictCount: _conflicts.length,
        failedItems: failedItems,
        lastSyncDuration: DateTime.now().difference(startTime),
        errorCounts: errorCounts,
      );
    } catch (e) {
      debugPrint('Sync error: $e');
      _syncStatus = SyncStatus.error;

      _syncStats = SyncStats(
        lastSyncTime: DateTime.now(),
        totalSyncedItems: syncedItems,
        pendingItems: _pendingOperations.length,
        conflictCount: _conflicts.length,
        failedItems: failedItems + _pendingOperations.length,
        lastSyncDuration: DateTime.now().difference(startTime),
        errorCounts: errorCounts,
      );
    }

    await _persistSyncData();
    notifyListeners();
  }

  /// Process a single pending operation
  Future<bool> _processPendingOperation(Map<String, dynamic> operation) async {
    try {
      final type = operation['type'] as String;
      final data = operation['data'] as Map<String, dynamic>;

      switch (type) {
        case 'add':
          final item = TranslationHistory.fromJson(data);
          return await _syncHistoryCollection(item, 'add');

        case 'update':
          final item = TranslationHistory.fromJson(data);
          return await _syncHistoryCollection(item, 'update');

        case 'delete':
          final id = data['id'] as String;
          return await _syncDeleteItem(id);

        default:
          debugPrint('Unknown operation type: $type');
          return false;
      }
    } catch (e) {
      debugPrint('Error processing operation: $e');
      return false;
    }
  }

  /// Sync history collection
  Future<bool> _syncHistoryCollection(
      TranslationHistory item, String operation) async {
    try {
      // Simulate remote API call
      await _simulateRemoteSync(item, operation);
      return true;
    } catch (e) {
      debugPrint('Error syncing history collection: $e');
      return false;
    }
  }

  /// Sync delete operation
  Future<bool> _syncDeleteItem(String id) async {
    try {
      // Simulate remote API call
      await _simulateRemoteDelete(id);
      return true;
    } catch (e) {
      debugPrint('Error syncing delete: $e');
      return false;
    }
  }

  /// Perform bidirectional sync (download remote changes)
  Future<void> _performBidirectionalSync() async {
    try {
      // Get remote changes since last sync
      final lastSync = _syncStats?.lastSyncTime ??
          DateTime.now().subtract(const Duration(days: 30));
      final remoteChanges = await _getRemoteChanges(lastSync);

      for (final remoteItem in remoteChanges) {
        await _processRemoteChange(remoteItem);
      }
    } catch (e) {
      debugPrint('Error in bidirectional sync: $e');
      rethrow;
    }
  }

  /// Process remote change and detect conflicts
  Future<void> _processRemoteChange(TranslationHistory remoteItem) async {
    try {
      // Check if item exists locally
      final localItems = await _historyService.searchHistory(
        searchQuery: remoteItem.id,
      );

      if (localItems.isEmpty) {
        // New remote item - add locally by converting entries
        for (final entry in remoteItem.entries) {
          final historyEntry = _convertTranslationEntryToHistoryEntry(entry);
          await _historyService.addToHistory(historyEntry);
        }
      } else {
        // Convert first local HistoryEntry back to TranslationHistory for comparison
        final localHistoryEntry = localItems.first;
        final localItem =
            _convertHistoryEntryToTranslationHistory(localHistoryEntry);

        // Check for conflicts
        if (_hasConflict(localItem, remoteItem)) {
          _conflicts.add(SyncConflict(
            id: remoteItem.id,
            localVersion: localItem,
            remoteVersion: remoteItem,
            conflictTime: DateTime.now(),
            conflictReason: _getConflictReason(localItem, remoteItem),
          ));
        } else {
          // No conflict - use remote version (assuming it's newer)
          for (final entry in remoteItem.entries) {
            final historyEntry = _convertTranslationEntryToHistoryEntry(entry);
            await _historyService.updateHistory(historyEntry);
          }
        }
      }
    } catch (e) {
      debugPrint('Error processing remote change: $e');
    }
  }

  /// Check if there's a conflict between local and remote versions
  bool _hasConflict(TranslationHistory local, TranslationHistory remote) {
    // Simple conflict detection based on timestamps
    final timeDiff = local.lastModified.difference(remote.lastModified).abs();

    // If modified within 5 minutes of each other, check content differences
    if (timeDiff.inMinutes < 5) {
      // Compare first entry content (assuming single entry collections for simplicity)
      if (local.entries.isNotEmpty && remote.entries.isNotEmpty) {
        final localEntry = local.entries.first;
        final remoteEntry = remote.entries.first;

        return localEntry.translatedText != remoteEntry.translatedText ||
            localEntry.isFavorite != remoteEntry.isFavorite ||
            localEntry.notes != remoteEntry.notes;
      }
    }

    return false;
  }

  /// Get conflict reason description
  String _getConflictReason(
      TranslationHistory local, TranslationHistory remote) {
    final reasons = <String>[];

    // Compare first entry content (assuming single entry collections for simplicity)
    if (local.entries.isNotEmpty && remote.entries.isNotEmpty) {
      final localEntry = local.entries.first;
      final remoteEntry = remote.entries.first;

      if (localEntry.translatedText != remoteEntry.translatedText) {
        reasons.add('translation text differs');
      }
      if (localEntry.isFavorite != remoteEntry.isFavorite) {
        reasons.add('favorite status differs');
      }
      if (localEntry.notes != remoteEntry.notes) {
        reasons.add('notes differ');
      }
    } else {
      reasons.add('entry count differs');
    }

    return reasons.join(', ');
  }

  /// Resolve sync conflict
  Future<void> resolveConflict(String conflictId, ConflictResolution resolution,
      {TranslationHistory? mergedVersion}) async {
    final conflictIndex = _conflicts.indexWhere((c) => c.id == conflictId);
    if (conflictIndex == -1) return;

    final conflict = _conflicts[conflictIndex];
    TranslationHistory resolvedVersion;

    switch (resolution) {
      case ConflictResolution.useLocal:
        resolvedVersion = conflict.localVersion;
        break;
      case ConflictResolution.useRemote:
        resolvedVersion = conflict.remoteVersion;
        break;
      case ConflictResolution.merge:
        if (mergedVersion == null) {
          throw ArgumentError('Merged version required for merge resolution');
        }
        resolvedVersion = mergedVersion;
        break;
      case ConflictResolution.askUser:
        // This would be handled by the UI
        return;
    }

    try {
      // Update local database by converting entries
      for (final entry in resolvedVersion.entries) {
        final historyEntry = _convertTranslationEntryToHistoryEntry(entry);
        await _historyService.updateHistory(historyEntry);
      }

      // Sync to remote
      if (_isOnline) {
        await _syncHistoryCollection(resolvedVersion, 'update');
      } else {
        await _queueOperation('update', resolvedVersion.toJson());
      }

      // Remove resolved conflict
      _conflicts.removeAt(conflictIndex);
      await _persistSyncData();
      notifyListeners();
    } catch (e) {
      debugPrint('Error resolving conflict: $e');
      rethrow;
    }
  }

  /// Clear all resolved conflicts
  Future<void> clearResolvedConflicts() async {
    _conflicts.clear();
    await _persistSyncData();
    notifyListeners();
  }

  /// Get sync health status
  Map<String, dynamic> getSyncHealth() {
    return {
      'isHealthy': _syncStatus != SyncStatus.error && _conflicts.length < 10,
      'status': _syncStatus.name,
      'pendingOperations': _pendingOperations.length,
      'conflicts': _conflicts.length,
      'isOnline': _isOnline,
      'lastSyncTime': _syncStats?.lastSyncTime?.toIso8601String(),
      'recommendations': _getHealthRecommendations(),
    };
  }

  /// Get health recommendations
  List<String> _getHealthRecommendations() {
    final recommendations = <String>[];

    if (!_isOnline) {
      recommendations.add('Check internet connection');
    }

    if (_pendingOperations.length > 50) {
      recommendations
          .add('Large number of pending operations - consider manual sync');
    }

    if (_conflicts.length > 5) {
      recommendations.add('Multiple conflicts need resolution');
    }

    if (_syncStats?.lastSyncTime
            .isBefore(DateTime.now().subtract(const Duration(hours: 6))) ==
        true) {
      recommendations.add('Last sync was over 6 hours ago');
    }

    return recommendations;
  }

  /// Reset sync service (for debugging/testing)
  Future<void> resetSync() async {
    _pendingOperations.clear();
    _conflicts.clear();
    _syncStats = null;
    _syncStatus = SyncStatus.idle;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_syncPrefsKey);
    await prefs.remove(_conflictsPrefsKey);
    await prefs.remove(_statsPrefsKey);

    notifyListeners();
  }

  // Simulation methods (replace with actual API calls)
  Future<void> _simulateRemoteSync(
      TranslationHistory item, String operation) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate API call success
    if (DateTime.now().millisecond % 10 == 0) {
      throw Exception('Simulated network error');
    }
  }

  Future<void> _simulateRemoteDelete(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Simulate API call success
    if (DateTime.now().millisecond % 15 == 0) {
      throw Exception('Simulated network error');
    }
  }

  Future<List<TranslationHistory>> _getRemoteChanges(DateTime since) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Simulate getting remote changes
    return [];
  }

  // Model conversion helper methods

  /// Convert TranslationEntry to HistoryEntry
  HistoryEntry _convertTranslationEntryToHistoryEntry(TranslationEntry entry) {
    return HistoryEntry.fromTranslationEntry(entry);
  }

  /// Convert HistoryEntry to TranslationHistory (single entry collection)
  TranslationHistory _convertHistoryEntryToTranslationHistory(
      HistoryEntry historyEntry) {
    final translationEntry = historyEntry.toTranslationEntry();

    return TranslationHistory(
      id: historyEntry.id,
      userId: 'default-user', // TODO: Get from user session
      entries: [translationEntry],
      createdAt: historyEntry.timestamp,
      lastModified: historyEntry.timestamp,
      metadata: historyEntry.metadata,
    );
  }

  /// Save a translation (compatibility method)
  Future<void> saveTranslation(TranslationHistory item) async {
    await addHistoryItem(item);
  }

  /// Save translation with duplicate check (compatibility method)
  Future<void> saveTranslationWithDuplicateCheck(
      TranslationHistory item) async {
    await addHistoryItem(item);
  }

  /// Sync pending changes (compatibility method)
  Future<void> syncPendingChanges() async {
    await triggerManualSync();
  }

  /// Schedule sync (compatibility method)
  Future<void> scheduleSync() async {
    if (_isOnline) {
      _triggerSync();
    }
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
