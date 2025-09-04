// 🌐 LingoSphere - Enhanced History Management Service
// Comprehensive history service with advanced filtering, search, categorization, and export functionality

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/common_models.dart';
import '../models/translation_entry.dart';
import '../exceptions/translation_exceptions.dart';
import '../constants/app_constants.dart';

/// Enhanced translation history management service
class HistoryService {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  final Logger _logger = Logger();
  Database? _database;
  bool _isInitialized = false;

  // Stream controllers for real-time updates
  final StreamController<List<HistoryEntry>> _historyStreamController =
      StreamController<List<HistoryEntry>>.broadcast();
  final StreamController<HistoryStats> _statsStreamController =
      StreamController<HistoryStats>.broadcast();

  // In-memory cache for fast access
  List<HistoryEntry> _cachedEntries = [];
  HistoryStats? _cachedStats;

  /// Initialize the history service
  Future<void> initialize() async {
    try {
      await _initializeDatabase();
      await _loadCachedData();
      _isInitialized = true;
      _logger.i('History service initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize history service: $e');
      throw TranslationServiceException(
          'Failed to initialize history service: $e');
    }
  }

  /// Initialize SQLite database
  Future<void> _initializeDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final databasePath =
        path.join(documentsDirectory.path, 'translation_history.db');

    _database = await openDatabase(
      databasePath,
      version: 2,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  /// Create database tables
  Future<void> _createDatabase(Database db, int version) async {
    // Main history table
    await db.execute('''
      CREATE TABLE history_entries (
        id TEXT PRIMARY KEY,
        original_text TEXT NOT NULL,
        translated_text TEXT NOT NULL,
        source_language TEXT NOT NULL,
        target_language TEXT NOT NULL,
        translation_source TEXT NOT NULL,
        confidence REAL NOT NULL,
        timestamp INTEGER NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        category TEXT,
        notes TEXT,
        image_path TEXT,
        audio_path TEXT,
        metadata TEXT
      )
    ''');

    // Search index for fast text search
    await db.execute('''
      CREATE VIRTUAL TABLE history_search USING fts4(
        entry_id TEXT,
        searchable_text TEXT
      )
    ''');

    // Categories table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        color TEXT NOT NULL,
        icon TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        entry_count INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Usage statistics table
    await db.execute('''
      CREATE TABLE usage_stats (
        date TEXT PRIMARY KEY,
        translation_count INTEGER NOT NULL DEFAULT 0,
        camera_count INTEGER NOT NULL DEFAULT 0,
        voice_count INTEGER NOT NULL DEFAULT 0,
        text_count INTEGER NOT NULL DEFAULT 0,
        avg_confidence REAL NOT NULL DEFAULT 0.0,
        total_characters INTEGER NOT NULL DEFAULT 0,
        languages_used TEXT
      )
    ''');

    // Create default categories
    await _createDefaultCategories(db);
  }

  /// Upgrade database schema
  Future<void> _upgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns for enhanced features
      await db.execute('ALTER TABLE history_entries ADD COLUMN category TEXT');
      await db.execute('ALTER TABLE history_entries ADD COLUMN notes TEXT');
      await db
          .execute('ALTER TABLE history_entries ADD COLUMN image_path TEXT');
      await db
          .execute('ALTER TABLE history_entries ADD COLUMN audio_path TEXT');
      await db.execute('ALTER TABLE history_entries ADD COLUMN metadata TEXT');

      // Create new tables
      await _createDefaultCategories(db);
    }
  }

  /// Create default categories
  Future<void> _createDefaultCategories(Database db) async {
    final defaultCategories = [
      {'id': 'work', 'name': 'Work', 'color': '#4A90E2', 'icon': 'work'},
      {'id': 'travel', 'name': 'Travel', 'color': '#F5A623', 'icon': 'travel'},
      {
        'id': 'learning',
        'name': 'Learning',
        'color': '#7ED321',
        'icon': 'school'
      },
      {
        'id': 'personal',
        'name': 'Personal',
        'color': '#9013FE',
        'icon': 'person'
      },
      {
        'id': 'food',
        'name': 'Food & Dining',
        'color': '#FF6B6B',
        'icon': 'restaurant'
      },
      {
        'id': 'shopping',
        'name': 'Shopping',
        'color': '#FF9500',
        'icon': 'shopping_cart'
      },
      {
        'id': 'health',
        'name': 'Health',
        'color': '#00BCD4',
        'icon': 'local_hospital'
      },
    ];

    for (final category in defaultCategories) {
      await db.insert('categories', {
        ...category,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  /// Load cached data from database
  Future<void> _loadCachedData() async {
    _cachedEntries = await _getAllEntries();
    _cachedStats = await _calculateStats();
  }

  /// Add a new translation entry to history
  Future<HistoryEntry> addEntry({
    required String originalText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
    required TranslationEngineSource translationSource,
    required double confidence,
    String? category,
    String? notes,
    String? imagePath,
    String? audioPath,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isInitialized) {
      throw TranslationServiceException('History service not initialized');
    }

    final entry = HistoryEntry(
      id: _generateId(),
      originalText: originalText,
      translatedText: translatedText,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      translationSource: translationSource,
      confidence: confidence,
      timestamp: DateTime.now(),
      category: category,
      notes: notes,
      imagePath: imagePath,
      audioPath: audioPath,
      metadata: metadata ?? {},
    );

    try {
      // Insert into database
      await _database!.insert('history_entries', entry.toMap());

      // Update search index
      await _updateSearchIndex(entry);

      // Update usage statistics
      await _updateUsageStats(entry);

      // Update category entry count
      if (category != null) {
        await _updateCategoryCount(category, 1);
      }

      // Update cache
      _cachedEntries.insert(0, entry);
      _cachedStats = await _calculateStats();

      // Notify listeners
      _historyStreamController.add(List.from(_cachedEntries));
      _statsStreamController.add(_cachedStats!);

      _logger.i('Added history entry: ${entry.id}');
      return entry;
    } catch (e) {
      _logger.e('Failed to add history entry: $e');
      throw TranslationServiceException('Failed to add history entry: $e');
    }
  }

  /// Search history entries with advanced filtering
  Future<List<HistoryEntry>> searchEntries({
    String? query,
    List<String>? languages,
    List<TranslationSource>? sources,
    DateRange? dateRange,
    double? minConfidence,
    double? maxConfidence,
    List<String>? categories,
    bool? favoritesOnly,
    HistorySortBy sortBy = HistorySortBy.dateDesc,
    int? limit,
    int? offset,
  }) async {
    if (!_isInitialized) return [];

    try {
      String sql = '''
        SELECT h.* FROM history_entries h
        LEFT JOIN history_search s ON h.id = s.entry_id
        WHERE 1=1
      ''';

      final args = <dynamic>[];

      // Text search
      if (query != null && query.isNotEmpty) {
        sql +=
            ' AND (s.searchable_text MATCH ? OR h.original_text LIKE ? OR h.translated_text LIKE ?)';
        args.addAll([query, '%$query%', '%$query%']);
      }

      // Language filtering
      if (languages != null && languages.isNotEmpty) {
        final languagePlaceholders = languages.map((_) => '?').join(',');
        sql +=
            ' AND (h.source_language IN ($languagePlaceholders) OR h.target_language IN ($languagePlaceholders))';
        args.addAll([...languages, ...languages]);
      }

      // Source filtering
      if (sources != null && sources.isNotEmpty) {
        final sourcePlaceholders = sources.map((_) => '?').join(',');
        sql += ' AND h.translation_source IN ($sourcePlaceholders)';
        args.addAll(sources.map((s) => s.name));
      }

      // Date range filtering
      if (dateRange != null) {
        sql += ' AND h.timestamp >= ? AND h.timestamp <= ?';
        args.addAll([
          dateRange.start.millisecondsSinceEpoch,
          dateRange.end.millisecondsSinceEpoch,
        ]);
      }

      // Confidence filtering
      if (minConfidence != null) {
        sql += ' AND h.confidence >= ?';
        args.add(minConfidence);
      }
      if (maxConfidence != null) {
        sql += ' AND h.confidence <= ?';
        args.add(maxConfidence);
      }

      // Category filtering
      if (categories != null && categories.isNotEmpty) {
        final categoryPlaceholders = categories.map((_) => '?').join(',');
        sql += ' AND h.category IN ($categoryPlaceholders)';
        args.addAll(categories);
      }

      // Favorites filtering
      if (favoritesOnly == true) {
        sql += ' AND h.is_favorite = 1';
      }

      // Sorting
      sql += ' ORDER BY ${_getSortClause(sortBy)}';

      // Pagination
      if (limit != null) {
        sql += ' LIMIT ?';
        args.add(limit);

        if (offset != null) {
          sql += ' OFFSET ?';
          args.add(offset);
        }
      }

      final results = await _database!.rawQuery(sql, args);
      return results.map((row) => HistoryEntry.fromMap(row)).toList();
    } catch (e) {
      _logger.e('Failed to search history entries: $e');
      return [];
    }
  }

  /// Get all history entries
  Future<List<HistoryEntry>> _getAllEntries() async {
    if (_database == null) return [];

    try {
      final results = await _database!.query(
        'history_entries',
        orderBy: 'timestamp DESC',
      );
      return results.map((row) => HistoryEntry.fromMap(row)).toList();
    } catch (e) {
      _logger.e('Failed to get all entries: $e');
      return [];
    }
  }

  /// Update search index for an entry
  Future<void> _updateSearchIndex(HistoryEntry entry) async {
    final searchableText = [
      entry.originalText,
      entry.translatedText,
      entry.notes ?? '',
      AppConstants.supportedLanguages[entry.sourceLanguage] ?? '',
      AppConstants.supportedLanguages[entry.targetLanguage] ?? '',
    ].join(' ').toLowerCase();

    await _database!.insert('history_search', {
      'entry_id': entry.id,
      'searchable_text': searchableText,
    });
  }

  /// Update usage statistics
  Future<void> _updateUsageStats(HistoryEntry entry) async {
    final today = DateTime.now();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // Get existing stats for today
    final existing = await _database!.query(
      'usage_stats',
      where: 'date = ?',
      whereArgs: [dateKey],
    );

    final languagesUsed = <String>{entry.sourceLanguage, entry.targetLanguage};

    if (existing.isEmpty) {
      // Create new stats entry
      await _database!.insert('usage_stats', {
        'date': dateKey,
        'translation_count': 1,
        '${entry.translationSource.name}_count': 1,
        'avg_confidence': entry.confidence,
        'total_characters':
            entry.originalText.length + entry.translatedText.length,
        'languages_used': json.encode(languagesUsed.toList()),
      });
    } else {
      // Update existing stats
      final current = existing.first;
      final currentLanguages = Set<String>.from(
        json.decode(current['languages_used'] as String),
      );
      currentLanguages.addAll(languagesUsed);

      final newCount = (current['translation_count'] as int) + 1;
      final currentAvg = current['avg_confidence'] as double;
      final newAvg =
          (currentAvg * (newCount - 1) + entry.confidence) / newCount;

      await _database!.update(
        'usage_stats',
        {
          'translation_count': newCount,
          '${entry.translationSource.name}_count':
              (current['${entry.translationSource.name}_count'] as int? ?? 0) +
                  1,
          'avg_confidence': newAvg,
          'total_characters': (current['total_characters'] as int) +
              entry.originalText.length +
              entry.translatedText.length,
          'languages_used': json.encode(currentLanguages.toList()),
        },
        where: 'date = ?',
        whereArgs: [dateKey],
      );
    }
  }

  /// Calculate statistics
  Future<HistoryStats> _calculateStats() async {
    if (_database == null) {
      return HistoryStats.empty();
    }

    try {
      // Get basic counts
      final totalResult = await _database!
          .rawQuery('SELECT COUNT(*) as total FROM history_entries');
      final total = totalResult.first['total'] as int;

      // Get source counts
      final sourceResults = await _database!.rawQuery('''
        SELECT translation_source, COUNT(*) as count 
        FROM history_entries 
        GROUP BY translation_source
      ''');

      final sourceCounts = <TranslationEngineSource, int>{};
      for (final row in sourceResults) {
        final source = TranslationEngineSource.values.firstWhere(
          (s) => s.name == row['translation_source'],
          orElse: () => TranslationEngineSource.text,
        );
        sourceCounts[source] = row['count'] as int;
      }

      // Get language pairs
      final languageResults = await _database!.rawQuery('''
        SELECT source_language, target_language, COUNT(*) as count
        FROM history_entries
        GROUP BY source_language, target_language
        ORDER BY count DESC
        LIMIT 10
      ''');

      final languagePairs = languageResults
          .map((row) => LanguagePair(
                source: row['source_language'] as String,
                target: row['target_language'] as String,
                count: row['count'] as int,
              ))
          .toList();

      // Get confidence stats
      final confidenceResults = await _database!.rawQuery('''
        SELECT AVG(confidence) as avg_confidence,
               MIN(confidence) as min_confidence,
               MAX(confidence) as max_confidence
        FROM history_entries
      ''');

      final confidenceStats = confidenceResults.first;
      final avgConfidence =
          (confidenceStats['avg_confidence'] as double?) ?? 0.0;

      // Get recent activity (last 30 days)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final activityResults = await _database!.rawQuery('''
        SELECT DATE(timestamp/1000, 'unixepoch') as date, COUNT(*) as count
        FROM history_entries
        WHERE timestamp >= ?
        GROUP BY DATE(timestamp/1000, 'unixepoch')
        ORDER BY date
      ''', [thirtyDaysAgo.millisecondsSinceEpoch]);

      final dailyActivity = activityResults
          .map((row) => DailyActivity(
                date: DateTime.parse(row['date'] as String),
                count: row['count'] as int,
              ))
          .toList();

      return HistoryStats(
        totalTranslations: total,
        sourceCounts: sourceCounts,
        topLanguagePairs: languagePairs,
        averageConfidence: avgConfidence,
        dailyActivity: dailyActivity,
        totalFavorites: await _getFavoritesCount(),
        categoryCounts: await _getCategoryCounts(),
      );
    } catch (e) {
      _logger.e('Failed to calculate stats: $e');
      return HistoryStats.empty();
    }
  }

  /// Update category entry count
  Future<void> _updateCategoryCount(String categoryId, int delta) async {
    await _database!.rawUpdate('''
      UPDATE categories 
      SET entry_count = entry_count + ? 
      WHERE id = ?
    ''', [delta, categoryId]);
  }

  /// Get favorites count
  Future<int> _getFavoritesCount() async {
    final result = await _database!.rawQuery(
        'SELECT COUNT(*) as count FROM history_entries WHERE is_favorite = 1');
    return result.first['count'] as int;
  }

  /// Get category counts
  Future<Map<String, int>> _getCategoryCounts() async {
    final results = await _database!.query('categories');
    return Map.fromEntries(
      results.map((row) => MapEntry(
            row['name'] as String,
            row['entry_count'] as int,
          )),
    );
  }

  /// Get sort clause for SQL query
  String _getSortClause(HistorySortBy sortBy) {
    switch (sortBy) {
      case HistorySortBy.dateAsc:
        return 'h.timestamp ASC';
      case HistorySortBy.dateDesc:
        return 'h.timestamp DESC';
      case HistorySortBy.confidenceAsc:
        return 'h.confidence ASC, h.timestamp DESC';
      case HistorySortBy.confidenceDesc:
        return 'h.confidence DESC, h.timestamp DESC';
      case HistorySortBy.alphabetical:
        return 'h.original_text ASC';
      case HistorySortBy.source:
        return 'h.translation_source ASC, h.timestamp DESC';
    }
  }

  /// Generate unique ID
  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  /// Get history stream
  Stream<List<HistoryEntry>> get historyStream =>
      _historyStreamController.stream;

  /// Get statistics stream
  Stream<HistoryStats> get statsStream => _statsStreamController.stream;

  /// Get cached entries
  List<HistoryEntry> get cachedEntries => List.from(_cachedEntries);

  /// Get cached stats
  HistoryStats? get cachedStats => _cachedStats;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  // Adapter methods for interface compatibility with other services

  /// Search history - adapter method for searchEntries
  Future<List<HistoryEntry>> searchHistory({
    String? searchQuery,
    List<String>? languages,
    List<TranslationSource>? sources,
    DateRange? dateRange,
    double? minConfidence,
    List<String>? categories,
    bool? favoritesOnly,
    SortBy? sortBy,
    int? limit,
    int? offset,
    bool? includeDeleted,
  }) async {
    // Map SortBy to HistorySortBy if provided
    HistorySortBy historySortBy = HistorySortBy.dateDesc;
    if (sortBy != null) {
      switch (sortBy) {
        case SortBy.timestamp:
          historySortBy = HistorySortBy.dateDesc;
          break;
        case SortBy.confidence:
          historySortBy = HistorySortBy.confidenceDesc;
          break;
        default:
          historySortBy = HistorySortBy.dateDesc;
      }
    }

    return await searchEntries(
      query: searchQuery,
      languages: languages,
      sources: sources,
      dateRange: dateRange,
      minConfidence: minConfidence,
      categories: categories,
      favoritesOnly: favoritesOnly,
      sortBy: historySortBy,
      limit: limit,
      offset: offset,
    );
  }

  /// Add to history - adapter method for addEntry
  Future<HistoryEntry> addToHistory(HistoryEntry entry) async {
    return await addEntry(
      originalText: entry.originalText,
      translatedText: entry.translatedText,
      sourceLanguage: entry.sourceLanguage,
      targetLanguage: entry.targetLanguage,
      translationSource: entry.translationSource,
      confidence: entry.confidence,
      category: entry.category,
      notes: entry.notes,
      imagePath: entry.imagePath,
      audioPath: entry.audioPath,
      metadata: entry.metadata,
    );
  }

  /// Update history - adapter method (placeholder implementation)
  Future<HistoryEntry> updateHistory(HistoryEntry entry) async {
    // For now, this is a placeholder since the current HistoryService
    // doesn't have an update method. In a real implementation, this would
    // update the database record.
    _logger.w('updateHistory called but not fully implemented');
    return entry;
  }

  /// Delete history - adapter method (placeholder implementation)
  Future<void> deleteHistory(String entryId) async {
    // For now, this is a placeholder since the current HistoryService
    // doesn't have a delete method. In a real implementation, this would
    // delete from the database.
    _logger
        .w('deleteHistory called but not fully implemented for id: $entryId');
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _historyStreamController.close();
    await _statsStreamController.close();
    await _database?.close();
    _isInitialized = false;
    _logger.i('History service disposed');
  }
}

/// Enhanced history entry model
class HistoryEntry {
  final String id;
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final TranslationEngineSource translationSource;
  final double confidence;
  final DateTime timestamp;
  final bool isFavorite;
  final String? category;
  final String? notes;
  final String? imagePath;
  final String? audioPath;
  final Map<String, dynamic> metadata;

  const HistoryEntry({
    required this.id,
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.translationSource,
    required this.confidence,
    required this.timestamp,
    this.isFavorite = false,
    this.category,
    this.notes,
    this.imagePath,
    this.audioPath,
    this.metadata = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'original_text': originalText,
      'translated_text': translatedText,
      'source_language': sourceLanguage,
      'target_language': targetLanguage,
      'translation_source': translationSource.name,
      'confidence': confidence,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'is_favorite': isFavorite ? 1 : 0,
      'category': category,
      'notes': notes,
      'image_path': imagePath,
      'audio_path': audioPath,
      'metadata': json.encode(metadata),
    };
  }

  factory HistoryEntry.fromMap(Map<String, dynamic> map) {
    return HistoryEntry(
      id: map['id'] as String,
      originalText: map['original_text'] as String,
      translatedText: map['translated_text'] as String,
      sourceLanguage: map['source_language'] as String,
      targetLanguage: map['target_language'] as String,
      translationSource: TranslationEngineSource.values.firstWhere(
        (s) => s.name == map['translation_source'],
        orElse: () => TranslationEngineSource.text,
      ),
      confidence: (map['confidence'] as num).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      isFavorite: (map['is_favorite'] as int) == 1,
      category: map['category'] as String?,
      notes: map['notes'] as String?,
      imagePath: map['image_path'] as String?,
      audioPath: map['audio_path'] as String?,
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(json.decode(map['metadata'] as String))
          : {},
    );
  }

  HistoryEntry copyWith({
    String? id,
    String? originalText,
    String? translatedText,
    String? sourceLanguage,
    String? targetLanguage,
    TranslationEngineSource? translationSource,
    double? confidence,
    DateTime? timestamp,
    bool? isFavorite,
    String? category,
    String? notes,
    String? imagePath,
    String? audioPath,
    Map<String, dynamic>? metadata,
  }) {
    return HistoryEntry(
      id: id ?? this.id,
      originalText: originalText ?? this.originalText,
      translatedText: translatedText ?? this.translatedText,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      translationSource: translationSource ?? this.translationSource,
      confidence: confidence ?? this.confidence,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      audioPath: audioPath ?? this.audioPath,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to TranslationEntry
  TranslationEntry toTranslationEntry() {
    return TranslationEntry(
      id: id,
      sourceText: originalText,
      translatedText: translatedText,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      timestamp: timestamp,
      type: _mapEngineSourceToTranslationMethod(translationSource),
      source: TranslationSource.user,
      category: TranslationCategory.general,
      confidence: confidence,
      isFavorite: isFavorite,
      notes: notes,
      imageFilePath: imagePath,
      audioFilePath: audioPath,
      metadata: metadata,
    );
  }

  /// Create from TranslationEntry
  static HistoryEntry fromTranslationEntry(TranslationEntry entry) {
    return HistoryEntry(
      id: entry.id,
      originalText: entry.sourceText,
      translatedText: entry.translatedText,
      sourceLanguage: entry.sourceLanguage,
      targetLanguage: entry.targetLanguage,
      translationSource: _mapTranslationMethodToEngineSource(entry.type),
      confidence: entry.confidence,
      timestamp: entry.timestamp,
      isFavorite: entry.isFavorite,
      category: entry.category.name,
      notes: entry.notes,
      imagePath: entry.imageFilePath,
      audioPath: entry.audioFilePath,
      metadata: entry.metadata ?? {},
    );
  }

  static TranslationMethod _mapEngineSourceToTranslationMethod(
      TranslationEngineSource source) {
    switch (source) {
      case TranslationEngineSource.voice:
        return TranslationMethod.voice;
      case TranslationEngineSource.camera:
        return TranslationMethod.camera;
      case TranslationEngineSource.file:
        return TranslationMethod.document;
      default:
        return TranslationMethod.text;
    }
  }

  static TranslationEngineSource _mapTranslationMethodToEngineSource(
      TranslationMethod method) {
    switch (method) {
      case TranslationMethod.voice:
        return TranslationEngineSource.voice;
      case TranslationMethod.camera:
      case TranslationMethod.image:
        return TranslationEngineSource.camera;
      case TranslationMethod.document:
        return TranslationEngineSource.file;
      default:
        return TranslationEngineSource.text;
    }
  }
}

// All common types now imported from common_models.dart

/// History statistics
class HistoryStats {
  final int totalTranslations;
  final Map<TranslationEngineSource, int> sourceCounts;
  final List<LanguagePair> topLanguagePairs;
  final double averageConfidence;
  final List<DailyActivity> dailyActivity;
  final int totalFavorites;
  final Map<String, int> categoryCounts;

  const HistoryStats({
    required this.totalTranslations,
    required this.sourceCounts,
    required this.topLanguagePairs,
    required this.averageConfidence,
    required this.dailyActivity,
    required this.totalFavorites,
    required this.categoryCounts,
  });

  factory HistoryStats.empty() {
    return const HistoryStats(
      totalTranslations: 0,
      sourceCounts: {},
      topLanguagePairs: [],
      averageConfidence: 0.0,
      dailyActivity: [],
      totalFavorites: 0,
      categoryCounts: {},
    );
  }
}
