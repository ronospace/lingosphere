// 🌐 LingoSphere - Translation History Integration Service
// Unified service for managing translation history with offline sync

import 'dart:async';
import '../../../core/models/translation_entry.dart';
import '../../../core/models/translation_history.dart' hide SortBy;
import '../../../core/models/common_models.dart';
import '../../../core/services/history_service.dart';
import '../../../core/services/offline_sync_service.dart';

/// Service that integrates history management with offline sync
class TranslationHistoryIntegration {
  final HistoryService _historyService;
  final OfflineSyncService _offlineSyncService;

  TranslationHistoryIntegration(this._historyService, this._offlineSyncService);

  /// Simple save translation method for basic use
  Future<bool> saveTranslation(TranslationEntry entry) async {
    try {
      // Convert TranslationEntry to HistoryEntry for storage
      final historyEntry = HistoryEntry(
        id: entry.id,
        originalText: entry.sourceText,
        translatedText: entry.translatedText,
        sourceLanguage: entry.sourceLanguage,
        targetLanguage: entry.targetLanguage,
        translationSource: _mapTranslationMethodToEngineSource(entry.type),
        confidence: entry.confidence,
        timestamp: entry.timestamp,
        isFavorite: entry.isFavorite,
        category: entry.category?.name,
        notes: entry.notes,
        imagePath: entry.imageFilePath,
        audioPath: entry.audioFilePath,
        metadata: entry.metadata ?? {},
      );

      await _historyService.addToHistory(historyEntry);
      _offlineSyncService.triggerManualSync(); // Sync in background
      return true;
    } catch (e) {
      print('Error saving translation: $e');
      return false;
    }
  }

  /// Save translation with automatic duplicate checking and sync
  Future<bool> saveTranslationWithDuplicateCheck(TranslationEntry entry) async {
    try {
      // Check for duplicates within last 5 minutes with same source text
      final recentEntries = await _historyService.searchHistory(
        searchQuery: entry.sourceText,
        dateRange: DateRange(
          start: DateTime.now().subtract(const Duration(minutes: 5)),
          end: DateTime.now(),
        ),
        languages: [entry.sourceLanguage, entry.targetLanguage],
        limit: 1,
      );

      // If exact duplicate exists, skip saving
      if (recentEntries.isNotEmpty) {
        print('Duplicate translation found, skipping save');
        return true;
      }

      // Save new entry using simple save method
      return await saveTranslation(entry);
    } catch (e) {
      print('Error saving translation with duplicate check: $e');
      return false;
    }
  }

  /// Get translation history with smart filtering
  Future<List<TranslationEntry>> getFilteredHistory({
    String? searchQuery,
    List<TranslationMethod>? methods,
    List<String>? languages,
    DateRange? dateRange,
    int limit = 50,
  }) async {
    final historyEntries = await _historyService.searchHistory(
      searchQuery: searchQuery,
      dateRange: dateRange,
      languages: languages,
      limit: limit,
      sortBy: SortBy.timestamp,
    );

    // Convert HistoryEntry objects to TranslationEntry objects
    return historyEntries
        .map((historyEntry) =>
            _convertHistoryEntryToTranslationEntry(historyEntry))
        .toList();
  }

  /// Get recent translations (last 24 hours)
  Future<List<TranslationEntry>> getRecentTranslations() async {
    return await getFilteredHistory(
      dateRange: DateRange(
        start: DateTime.now().subtract(const Duration(days: 1)),
        end: DateTime.now(),
      ),
      limit: 20,
    );
  }

  /// Get favorite translations
  Future<List<TranslationEntry>> getFavoriteTranslations() async {
    final historyEntries = await _historyService.searchHistory(
      favoritesOnly: true,
      limit: 100,
      sortBy: SortBy.timestamp,
    );

    return historyEntries
        .map((historyEntry) =>
            _convertHistoryEntryToTranslationEntry(historyEntry))
        .toList();
  }

  /// Toggle favorite status of a translation
  Future<bool> toggleFavorite(String entryId, bool isFavorite) async {
    try {
      final entries = await _historyService.searchHistory(
        searchQuery: entryId,
        limit: 1,
      );

      if (entries.isEmpty) return false;

      final entry = entries.first;
      final updatedEntry = entry.copyWith(isFavorite: isFavorite);

      await _historyService.updateHistory(updatedEntry);
      _offlineSyncService.triggerManualSync();
      return true;
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  /// Delete translation entry
  Future<bool> deleteTranslation(String entryId) async {
    try {
      await _historyService.deleteHistory(entryId);
      _offlineSyncService.triggerManualSync();
      return true;
    } catch (e) {
      print('Error deleting translation: $e');
      return false;
    }
  }

  /// Get translation statistics
  Future<Map<String, dynamic>> getTranslationStats() async {
    try {
      final allHistoryEntries = await _historyService.searchHistory(
        limit: 10000, // Get all entries
      );

      // Convert to TranslationEntry for processing
      final allEntries = allHistoryEntries
          .map((historyEntry) =>
              _convertHistoryEntryToTranslationEntry(historyEntry))
          .toList();

      final totalTranslations = allEntries.length;
      final totalCharacters = allEntries.fold<int>(
        0,
        (sum, entry) => sum + entry.actualCharacterCount,
      );

      final languagePairs = <String, int>{};
      final methodCounts = <TranslationMethod, int>{};

      for (final entry in allEntries) {
        final pair = entry.languagePair;
        languagePairs[pair] = (languagePairs[pair] ?? 0) + 1;
        methodCounts[entry.type] = (methodCounts[entry.type] ?? 0) + 1;
      }

      final favorites = allEntries.where((e) => e.isFavorite).length;
      final recentCount = allEntries.where((e) => e.isRecent).length;

      return {
        'totalTranslations': totalTranslations,
        'totalCharacters': totalCharacters,
        'favorites': favorites,
        'recentCount': recentCount,
        'languagePairs': languagePairs,
        'methodCounts': methodCounts.map(
          (k, v) => MapEntry(k.toString(), v),
        ),
        'averageConfidence': allEntries.isEmpty
            ? 0.0
            : allEntries.fold<double>(
                  0.0,
                  (sum, entry) => sum + entry.confidence,
                ) /
                allEntries.length,
      };
    } catch (e) {
      print('Error getting translation stats: $e');
      return {};
    }
  }

  /// Get sync status
  Map<String, dynamic> getSyncStatus() {
    return {
      'isOnline': _offlineSyncService.isOnline,
      'syncStatus': _offlineSyncService.syncStatus.toString(),
      'pendingOperations': _offlineSyncService.pendingOperationsCount,
      'conflicts': _offlineSyncService.conflicts.length,
      'lastSync': _offlineSyncService.syncStats?.lastSyncTime.toIso8601String(),
    };
  }

  /// Force sync with server
  Future<bool> forcSync() async {
    try {
      await _offlineSyncService.triggerManualSync();
      return true;
    } catch (e) {
      print('Error forcing sync: $e');
      return false;
    }
  }

  /// Get conflicted entries that need user resolution
  List<SyncConflict> getConflicts() {
    return _offlineSyncService.conflicts;
  }

  /// Resolve sync conflict
  Future<bool> resolveConflict(
      String conflictId, ConflictResolution resolution) async {
    try {
      await _offlineSyncService.resolveConflict(conflictId, resolution);
      return true;
    } catch (e) {
      print('Error resolving conflict: $e');
      return false;
    }
  }

  /// Stream of translation updates
  /// Note: Basic implementation - in a real app this would be a proper stream
  Stream<List<TranslationEntry>> get translationStream async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 5));
      yield await getRecentTranslations();
    }
  }

  /// Stream of sync status updates
  /// Note: Basic implementation - in a real app this would be a proper stream
  Stream<SyncStatus> get syncStatusStream async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 2));
      yield _offlineSyncService.syncStatus;
    }
  }

  /// Helper method to convert TranslationMethod to TranslationEngineSource
  TranslationEngineSource _mapTranslationMethodToEngineSource(
      TranslationMethod method) {
    switch (method) {
      case TranslationMethod.text:
        return TranslationEngineSource.text;
      case TranslationMethod.voice:
        return TranslationEngineSource.voice;
      case TranslationMethod.camera:
        return TranslationEngineSource.camera;
      case TranslationMethod.image:
        return TranslationEngineSource.camera;
      case TranslationMethod.document:
        return TranslationEngineSource.file;
    }
  }

  /// Helper method to convert HistoryEntry to TranslationEntry
  TranslationEntry _convertHistoryEntryToTranslationEntry(
      HistoryEntry historyEntry) {
    return TranslationEntry(
      id: historyEntry.id,
      sourceText: historyEntry.originalText,
      translatedText: historyEntry.translatedText,
      sourceLanguage: historyEntry.sourceLanguage,
      targetLanguage: historyEntry.targetLanguage,
      timestamp: historyEntry.timestamp,
      type: _mapEngineSourceToTranslationMethod(historyEntry.translationSource),
      source: TranslationSource.user,
      category: _mapCategoryStringToEnum(historyEntry.category) ??
          TranslationCategory.general,
      confidence: historyEntry.confidence,
      isFavorite: historyEntry.isFavorite,
      metadata: historyEntry.metadata,
      audioFilePath: historyEntry.audioPath,
      imageFilePath: historyEntry.imagePath,
      notes: historyEntry.notes,
      isOffline: false,
      characterCount: historyEntry.originalText.length,
    );
  }

  /// Helper method to convert TranslationEngineSource to TranslationMethod
  TranslationMethod _mapEngineSourceToTranslationMethod(
      TranslationEngineSource source) {
    switch (source) {
      case TranslationEngineSource.text:
        return TranslationMethod.text;
      case TranslationEngineSource.voice:
        return TranslationMethod.voice;
      case TranslationEngineSource.camera:
        return TranslationMethod.camera;
      case TranslationEngineSource.file:
        return TranslationMethod.document;
      case TranslationEngineSource.manual:
        return TranslationMethod.text;
    }
  }

  /// Helper method to convert category string to enum
  TranslationCategory? _mapCategoryStringToEnum(String? category) {
    if (category == null) return null;

    switch (category.toLowerCase()) {
      case 'general':
        return TranslationCategory.general;
      case 'business':
        return TranslationCategory.business;
      case 'travel':
        return TranslationCategory.travel;
      case 'education':
        return TranslationCategory.education;
      case 'medical':
        return TranslationCategory.medical;
      case 'legal':
        return TranslationCategory.legal;
      case 'technical':
        return TranslationCategory.technical;
      case 'personal':
        return TranslationCategory.personal;
      default:
        return TranslationCategory.general;
    }
  }
}
