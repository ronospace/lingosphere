// 🌐 LingoSphere - Translation History Integration
// Integration layer to connect existing translation services with the new history system

import 'package:flutter/foundation.dart';
import '../models/translation_history.dart';
import '../models/translation_entry.dart';
import '../models/common_models.dart';
import 'offline_sync_service.dart';
import 'history_service.dart';

/// Integration service that wraps existing translation functionality
/// and automatically handles history tracking and offline sync
class TranslationHistoryIntegration {
  final OfflineSyncService _syncService;
  final HistoryService _historyService;

  TranslationHistoryIntegration({
    required OfflineSyncService syncService,
    required HistoryService historyService,
  })  : _syncService = syncService,
        _historyService = historyService;

  /// Record a translation in history with automatic sync
  Future<void> recordTranslation({
    required String originalText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
    required double confidence,
    String? source,
    String? category,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Create a TranslationEntry
      final translationEntry = TranslationEntry(
        id: _generateId(),
        sourceText: originalText,
        translatedText: translatedText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        confidence: confidence,
        timestamp: DateTime.now(),
        type: _mapSourceToTranslationMethod(source ?? 'text'),
        source: TranslationSource.user,
        category: _mapStringToCategory(category),
        metadata: metadata,
        isFavorite: false,
      );

      // Create a TranslationHistory collection with single entry
      final historyItem = TranslationHistory(
        id: _generateId(),
        userId: 'default-user', // TODO: Get from user session
        entries: [translationEntry],
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
        metadata: metadata ?? {},
      );

      // Use offline sync service to handle the addition
      // This ensures the item is added locally and queued for sync if offline
      await _syncService.addHistoryItem(historyItem);

      debugPrint(
          '📝 Translation recorded in history: ${originalText.substring(0, originalText.length > 20 ? 20 : originalText.length)}...');
    } catch (e) {
      debugPrint('❌ Failed to record translation in history: $e');
      // Don't rethrow - we don't want translation failures due to history issues
    }
  }

  /// Record a camera OCR translation
  Future<void> recordCameraTranslation({
    required String originalText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
    required double confidence,
    String? category,
  }) async {
    await recordTranslation(
      originalText: originalText,
      translatedText: translatedText,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      confidence: confidence,
      source: 'camera',
      category: category,
      metadata: {
        'detectionMethod': 'ocr',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Record a voice translation
  Future<void> recordVoiceTranslation({
    required String originalText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
    required double confidence,
    String? category,
    Duration? audioDuration,
  }) async {
    await recordTranslation(
      originalText: originalText,
      translatedText: translatedText,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      confidence: confidence,
      source: 'voice',
      category: category,
      metadata: {
        'audioDuration': audioDuration?.inMilliseconds,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Record a text translation
  Future<void> recordTextTranslation({
    required String originalText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
    required double confidence,
    String? category,
  }) async {
    await recordTranslation(
      originalText: originalText,
      translatedText: translatedText,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      confidence: confidence,
      source: 'text',
      category: category,
      metadata: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Record an image translation
  Future<void> recordImageTranslation({
    required String originalText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
    required double confidence,
    String? category,
    String? imagePath,
  }) async {
    await recordTranslation(
      originalText: originalText,
      translatedText: translatedText,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      confidence: confidence,
      source: 'image',
      category: category,
      metadata: {
        'imagePath': imagePath,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Record a file translation
  Future<void> recordFileTranslation({
    required String originalText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
    required double confidence,
    String? category,
    String? fileName,
    String? fileType,
  }) async {
    await recordTranslation(
      originalText: originalText,
      translatedText: translatedText,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      confidence: confidence,
      source: 'file',
      category: category,
      metadata: {
        'fileName': fileName,
        'fileType': fileType,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Update usage count for a repeated translation
  Future<void> incrementUsageCount(String translationId) async {
    try {
      // Search for existing translation
      final existingTranslations = await _historyService.searchHistory(
        searchQuery: translationId,
      );

      if (existingTranslations.isNotEmpty) {
        final existing = existingTranslations.first;
        // Convert to TranslationEntry and back to create updated TranslationHistory
        final translationEntry = existing.toTranslationEntry();
        final updatedHistory = TranslationHistory(
          id: existing.id,
          userId: 'default-user',
          entries: [translationEntry],
          createdAt: existing.timestamp,
          lastModified: DateTime.now(),
          metadata: existing.metadata,
        );

        await _syncService.updateHistoryItem(updatedHistory);
        debugPrint('🔄 Translation entry updated');
      }
    } catch (e) {
      debugPrint('❌ Failed to increment usage count: $e');
    }
  }

  /// Find similar existing translations to avoid duplicates
  Future<TranslationHistory?> findSimilarTranslation({
    required String originalText,
    required String sourceLanguage,
    required String targetLanguage,
    double similarityThreshold = 0.8,
  }) async {
    try {
      // Search for translations with the same language pair
      final existingTranslations = await _historyService.searchHistory(
        languages: [sourceLanguage, targetLanguage],
      );

      // Find similar translations using basic text similarity
      // Note: Converting HistoryEntry to TranslationHistory for comparison
      for (final historyEntry in existingTranslations) {
        final similarity = _calculateTextSimilarity(
          originalText.toLowerCase().trim(),
          historyEntry.originalText.toLowerCase().trim(),
        );

        if (similarity >= similarityThreshold) {
          // Convert to TranslationHistory for return
          final translationEntry = historyEntry.toTranslationEntry();
          return TranslationHistory(
            id: historyEntry.id,
            userId: 'default-user',
            entries: [translationEntry],
            createdAt: historyEntry.timestamp,
            lastModified: historyEntry.timestamp,
            metadata: historyEntry.metadata,
          );
        }
      }

      return null;
    } catch (e) {
      debugPrint('❌ Failed to find similar translation: $e');
      return null;
    }
  }

  /// Smart recording that checks for duplicates and updates usage count
  Future<void> smartRecordTranslation({
    required String originalText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
    required double confidence,
    String? source,
    String? category,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Check for similar existing translation
      final similar = await findSimilarTranslation(
        originalText: originalText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );

      if (similar != null) {
        // Update existing translation usage count and metadata
        await incrementUsageCount(similar.id);
        debugPrint('🔄 Updated existing similar translation');
      } else {
        // Record as new translation
        await recordTranslation(
          originalText: originalText,
          translatedText: translatedText,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
          confidence: confidence,
          source: source,
          category: category,
          metadata: metadata,
        );
        debugPrint('➕ Recorded new translation');
      }
    } catch (e) {
      debugPrint('❌ Failed to smart record translation: $e');
    }
  }

  /// Toggle favorite status for a translation
  Future<void> toggleFavorite(String translationId) async {
    try {
      final translations = await _historyService.searchHistory(
        searchQuery: translationId,
      );

      if (translations.isNotEmpty) {
        final historyEntry = translations.first;
        final translationEntry = historyEntry.toTranslationEntry();
        final updatedEntry = translationEntry.copyWith(
          isFavorite: !translationEntry.isFavorite,
        );
        final updatedHistory = TranslationHistory(
          id: historyEntry.id,
          userId: 'default-user',
          entries: [updatedEntry],
          createdAt: historyEntry.timestamp,
          lastModified: DateTime.now(),
          metadata: historyEntry.metadata,
        );

        await _syncService.updateHistoryItem(updatedHistory);
        debugPrint('⭐ Translation favorite status toggled');
      }
    } catch (e) {
      debugPrint('❌ Failed to toggle favorite: $e');
    }
  }

  /// Add notes to a translation
  Future<void> addNotes(String translationId, String notes) async {
    try {
      final translations = await _historyService.searchHistory(
        searchQuery: translationId,
      );

      if (translations.isNotEmpty) {
        final historyEntry = translations.first;
        final translationEntry = historyEntry.toTranslationEntry();
        final updatedEntry = translationEntry.copyWith(
          notes: notes.isEmpty ? null : notes,
        );
        final updatedHistory = TranslationHistory(
          id: historyEntry.id,
          userId: 'default-user',
          entries: [updatedEntry],
          createdAt: historyEntry.timestamp,
          lastModified: DateTime.now(),
          metadata: historyEntry.metadata,
        );

        await _syncService.updateHistoryItem(updatedHistory);
        debugPrint('📝 Translation notes updated');
      }
    } catch (e) {
      debugPrint('❌ Failed to add notes: $e');
    }
  }

  /// Update category for a translation
  Future<void> updateCategory(String translationId, String? category) async {
    try {
      final translations = await _historyService.searchHistory(
        searchQuery: translationId,
      );

      if (translations.isNotEmpty) {
        final historyEntry = translations.first;
        final translationEntry = historyEntry.toTranslationEntry();
        final updatedEntry = translationEntry.copyWith(
          category: _mapStringToCategory(category),
        );
        final updatedHistory = TranslationHistory(
          id: historyEntry.id,
          userId: 'default-user',
          entries: [updatedEntry],
          createdAt: historyEntry.timestamp,
          lastModified: DateTime.now(),
          metadata: historyEntry.metadata,
        );

        await _syncService.updateHistoryItem(updatedHistory);
        debugPrint('🏷️ Translation category updated');
      }
    } catch (e) {
      debugPrint('❌ Failed to update category: $e');
    }
  }

  /// Delete a translation
  Future<void> deleteTranslation(String translationId) async {
    try {
      await _syncService.deleteHistoryItem(translationId);
      debugPrint('🗑️ Translation deleted');
    } catch (e) {
      debugPrint('❌ Failed to delete translation: $e');
    }
  }

  /// Get recent translations for quick access
  Future<List<TranslationHistory>> getRecentTranslations({
    int limit = 10,
    String? sourceLanguage,
    String? targetLanguage,
  }) async {
    try {
      final historyEntries = await _historyService.searchHistory(
        languages: sourceLanguage != null || targetLanguage != null
            ? [
                if (sourceLanguage != null) sourceLanguage,
                if (targetLanguage != null) targetLanguage
              ]
            : null,
        limit: limit,
      );

      // Convert HistoryEntry list to TranslationHistory list
      final translationHistories = <TranslationHistory>[];
      for (final entry in historyEntries) {
        final translationEntry = entry.toTranslationEntry();
        translationHistories.add(TranslationHistory(
          id: entry.id,
          userId: 'default-user',
          entries: [translationEntry],
          createdAt: entry.timestamp,
          lastModified: entry.timestamp,
          metadata: entry.metadata,
        ));
      }

      return translationHistories;
    } catch (e) {
      debugPrint('❌ Failed to get recent translations: $e');
      return [];
    }
  }

  /// Get favorite translations
  Future<List<TranslationHistory>> getFavoriteTranslations() async {
    try {
      final allHistoryEntries = await _historyService.searchHistory(
        favoritesOnly: true,
      );

      // Convert HistoryEntry list to TranslationHistory list
      final translationHistories = <TranslationHistory>[];
      for (final entry in allHistoryEntries) {
        final translationEntry = entry.toTranslationEntry();
        translationHistories.add(TranslationHistory(
          id: entry.id,
          userId: 'default-user',
          entries: [translationEntry],
          createdAt: entry.timestamp,
          lastModified: entry.timestamp,
          metadata: entry.metadata,
        ));
      }

      return translationHistories;
    } catch (e) {
      debugPrint('❌ Failed to get favorite translations: $e');
      return [];
    }
  }

  /// Get translation statistics
  Future<Map<String, dynamic>> getTranslationStatistics() async {
    try {
      final allHistoryEntries = await _historyService.searchHistory();

      if (allHistoryEntries.isEmpty) {
        return {
          'totalTranslations': 0,
          'averageConfidence': 0.0,
          'mostUsedLanguagePair': null,
          'favoriteCount': 0,
        };
      }

      // Calculate statistics
      final totalConfidence =
          allHistoryEntries.fold<double>(0, (sum, t) => sum + t.confidence);
      final averageConfidence = totalConfidence / allHistoryEntries.length;

      final languagePairs = <String, int>{};
      for (final t in allHistoryEntries) {
        final pair = '${t.sourceLanguage}-${t.targetLanguage}';
        languagePairs[pair] = (languagePairs[pair] ?? 0) + 1;
      }

      final mostUsedPair = languagePairs.isNotEmpty
          ? languagePairs.entries.reduce((a, b) => a.value > b.value ? a : b)
          : null;

      return {
        'totalTranslations': allHistoryEntries.length,
        'averageConfidence': averageConfidence,
        'mostUsedLanguagePair': mostUsedPair?.key,
        'favoriteCount': allHistoryEntries.where((t) => t.isFavorite).length,
        'sourceCounts': _getHistorySourceCounts(allHistoryEntries),
        'languagePairCounts': languagePairs,
      };
    } catch (e) {
      debugPrint('❌ Failed to get translation statistics: $e');
      return {};
    }
  }

  /// Calculate basic text similarity (simplified Jaccard similarity)
  double _calculateTextSimilarity(String text1, String text2) {
    if (text1.isEmpty && text2.isEmpty) return 1.0;
    if (text1.isEmpty || text2.isEmpty) return 0.0;

    final words1 = text1.split(' ').toSet();
    final words2 = text2.split(' ').toSet();

    final intersection = words1.intersection(words2);
    final union = words1.union(words2);

    return union.isNotEmpty ? intersection.length / union.length : 0.0;
  }

  /// Generate unique ID for translations
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        DateTime.now().microsecond.toString();
  }

  /// Get source type counts from TranslationHistory list
  Map<String, int> _getSourceCounts(List<TranslationHistory> translations) {
    final counts = <String, int>{};
    for (final translation in translations) {
      if (translation.entries.isNotEmpty) {
        final source = translation.entries.first.type.name;
        counts[source] = (counts[source] ?? 0) + 1;
      }
    }
    return counts;
  }

  /// Get source type counts from HistoryEntry list
  Map<String, int> _getHistorySourceCounts(List<HistoryEntry> historyEntries) {
    final counts = <String, int>{};
    for (final entry in historyEntries) {
      final source = entry.translationSource.name;
      counts[source] = (counts[source] ?? 0) + 1;
    }
    return counts;
  }

  /// Map source string to TranslationMethod enum
  TranslationMethod _mapSourceToTranslationMethod(String source) {
    switch (source.toLowerCase()) {
      case 'voice':
        return TranslationMethod.voice;
      case 'camera':
      case 'image':
        return TranslationMethod.camera;
      case 'file':
      case 'document':
        return TranslationMethod.document;
      default:
        return TranslationMethod.text;
    }
  }

  /// Map category string to TranslationCategory enum
  TranslationCategory _mapStringToCategory(String? category) {
    if (category == null) return TranslationCategory.general;

    switch (category.toLowerCase()) {
      case 'business':
        return TranslationCategory.business;
      case 'travel':
        return TranslationCategory.travel;
      case 'education':
      case 'learning':
        return TranslationCategory.education;
      case 'medical':
      case 'health':
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

/// Mixin for translation services to easily integrate history tracking
mixin TranslationHistoryMixin {
  TranslationHistoryIntegration? _historyIntegration;

  /// Initialize history integration
  void initializeHistoryIntegration({
    required OfflineSyncService syncService,
    required HistoryService historyService,
  }) {
    _historyIntegration = TranslationHistoryIntegration(
      syncService: syncService,
      historyService: historyService,
    );
  }

  /// Get history integration instance
  TranslationHistoryIntegration get historyIntegration {
    if (_historyIntegration == null) {
      throw Exception(
          'History integration not initialized. Call initializeHistoryIntegration() first.');
    }
    return _historyIntegration!;
  }

  /// Record translation result automatically
  Future<void> recordTranslationResult({
    required String originalText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
    required double confidence,
    String? source,
    String? category,
    Map<String, dynamic>? metadata,
  }) async {
    if (_historyIntegration != null) {
      await _historyIntegration!.smartRecordTranslation(
        originalText: originalText,
        translatedText: translatedText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        confidence: confidence,
        source: source,
        category: category,
        metadata: metadata,
      );
    }
  }
}
