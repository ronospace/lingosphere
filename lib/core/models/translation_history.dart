// 🌐 LingoSphere - Translation History Models
// Models for translation history management and batch operations

import 'package:json_annotation/json_annotation.dart';
import 'translation_entry.dart';

part 'translation_history.g.dart';

/// Translation history collection model
@JsonSerializable()
class TranslationHistory {
  final String id;
  final String userId;
  final List<TranslationEntry> entries;
  final DateTime createdAt;
  final DateTime lastModified;
  final Map<String, dynamic> metadata;
  final String? name;
  final String? description;
  final bool isArchived;
  final List<String> tags;

  const TranslationHistory({
    required this.id,
    required this.userId,
    required this.entries,
    required this.createdAt,
    required this.lastModified,
    this.metadata = const {},
    this.name,
    this.description,
    this.isArchived = false,
    this.tags = const [],
  });

  /// Create translation history from JSON
  factory TranslationHistory.fromJson(Map<String, dynamic> json) =>
      _$TranslationHistoryFromJson(json);

  /// Convert translation history to JSON
  Map<String, dynamic> toJson() => _$TranslationHistoryToJson(this);

  /// Create a copy with updated fields
  TranslationHistory copyWith({
    String? id,
    String? userId,
    List<TranslationEntry>? entries,
    DateTime? createdAt,
    DateTime? lastModified,
    Map<String, dynamic>? metadata,
    String? name,
    String? description,
    bool? isArchived,
    List<String>? tags,
  }) {
    return TranslationHistory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      entries: entries ?? this.entries,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      metadata: metadata ?? this.metadata,
      name: name ?? this.name,
      description: description ?? this.description,
      isArchived: isArchived ?? this.isArchived,
      tags: tags ?? this.tags,
    );
  }

  /// Add a new entry to the history
  TranslationHistory addEntry(TranslationEntry entry) {
    final updatedEntries = List<TranslationEntry>.from(entries)..add(entry);
    return copyWith(
      entries: updatedEntries,
      lastModified: DateTime.now(),
    );
  }

  /// Remove an entry from the history
  TranslationHistory removeEntry(String entryId) {
    final updatedEntries = entries.where((e) => e.id != entryId).toList();
    return copyWith(
      entries: updatedEntries,
      lastModified: DateTime.now(),
    );
  }

  /// Update an existing entry
  TranslationHistory updateEntry(TranslationEntry updatedEntry) {
    final updatedEntries =
        entries.map((e) => e.id == updatedEntry.id ? updatedEntry : e).toList();
    return copyWith(
      entries: updatedEntries,
      lastModified: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslationHistory &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'TranslationHistory(id: $id, entries: ${entries.length})';

  /// Get total number of entries
  int get entryCount => entries.length;

  /// Get total character count across all entries
  int get totalCharacters => entries.totalCharacters;

  /// Get entries from last 24 hours
  List<TranslationEntry> get recentEntries {
    final oneDayAgo = DateTime.now().subtract(const Duration(days: 1));
    return entries
        .where((entry) => entry.timestamp.isAfter(oneDayAgo))
        .toList();
  }

  /// Get favorite entries
  List<TranslationEntry> get favoriteEntries => entries.favorites;

  /// Get entries by translation method
  List<TranslationEntry> entriesByMethod(TranslationMethod method) {
    return entries.filterByMethod(method);
  }

  /// Get entries by language pair
  List<TranslationEntry> entriesByLanguagePair(String source, String target) {
    return entries.filterByLanguagePair(source, target);
  }

  /// Get entries within date range
  List<TranslationEntry> entriesByDateRange(DateTime start, DateTime end) {
    return entries.filterByDateRange(start, end);
  }

  /// Get language pairs used in this history
  Set<String> get languagePairs {
    return entries.map((e) => e.languagePair).toSet();
  }

  /// Get all source languages used
  Set<String> get sourceLanguages {
    return entries.map((e) => e.sourceLanguage).toSet();
  }

  /// Get all target languages used
  Set<String> get targetLanguages {
    return entries.map((e) => e.targetLanguage).toSet();
  }

  /// Get entries sorted by newest first
  List<TranslationEntry> get entriesByNewest => entries.sortByNewest();

  /// Get entries sorted by confidence
  List<TranslationEntry> get entriesByConfidence => entries.sortByConfidence();

  /// Check if history is empty
  bool get isEmpty => entries.isEmpty;

  /// Check if history has entries
  bool get isNotEmpty => entries.isNotEmpty;

  /// Get display name for the history
  String get displayName => name ?? 'Translation History ${id.substring(0, 8)}';

  /// Get formatted last modified time
  String get formattedLastModified {
    final now = DateTime.now();
    final diff = now.difference(lastModified);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${lastModified.day}/${lastModified.month}/${lastModified.year}';
    }
  }

  // Properties for UI compatibility (when used as individual entry)
  // These delegate to the most recent entry or provide collection-level info

  /// Timestamp of the most recent entry or creation time
  DateTime get timestamp =>
      entries.isEmpty ? createdAt : entries.last.timestamp;

  /// Whether any entry in this history is favorite
  bool get isFavorite => entries.any((e) => e.isFavorite);

  /// Average confidence of all entries
  double get confidence {
    if (entries.isEmpty) return 0.0;
    return entries.map((e) => e.confidence).reduce((a, b) => a + b) /
        entries.length;
  }

  /// Usage count (number of entries in this history)
  int get usageCount => entries.length;

  /// Combined notes from all entries
  String? get notes {
    final allNotes = entries
        .where((e) => e.notes != null && e.notes!.isNotEmpty)
        .map((e) => e.notes!)
        .toList();
    return allNotes.isEmpty ? null : allNotes.join('\n');
  }

  /// Original text from the most recent entry
  String get originalText => entries.isEmpty ? '' : entries.last.sourceText;

  /// Translated text from the most recent entry
  String get translatedText =>
      entries.isEmpty ? '' : entries.last.translatedText;

  /// Source language from the most recent entry
  String get sourceLanguage =>
      entries.isEmpty ? '' : entries.last.sourceLanguage;

  /// Target language from the most recent entry
  String get targetLanguage =>
      entries.isEmpty ? '' : entries.last.targetLanguage;

  /// Translation source from the most recent entry
  String get translationSource =>
      entries.isEmpty ? 'unknown' : entries.last.type.name;
}

/// History query model for search and filtering
@JsonSerializable()
class HistoryQuery {
  final String? searchText;
  final List<String>? sourceLanguages;
  final List<String>? targetLanguages;
  final List<TranslationMethod>? methods;
  final List<TranslationCategory>? categories;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minConfidence;
  final double? maxConfidence;
  final bool? isFavorite;
  final bool? hasMedia;
  final List<String>? tags;
  final int? limit;
  final int? offset;
  final SortBy? sortBy;
  final SortOrder? sortOrder;

  const HistoryQuery({
    this.searchText,
    this.sourceLanguages,
    this.targetLanguages,
    this.methods,
    this.categories,
    this.startDate,
    this.endDate,
    this.minConfidence,
    this.maxConfidence,
    this.isFavorite,
    this.hasMedia,
    this.tags,
    this.limit,
    this.offset,
    this.sortBy,
    this.sortOrder,
  });

  /// Create history query from JSON
  factory HistoryQuery.fromJson(Map<String, dynamic> json) =>
      _$HistoryQueryFromJson(json);

  /// Convert history query to JSON
  Map<String, dynamic> toJson() => _$HistoryQueryToJson(this);

  /// Create a copy with updated fields
  HistoryQuery copyWith({
    String? searchText,
    List<String>? sourceLanguages,
    List<String>? targetLanguages,
    List<TranslationMethod>? methods,
    List<TranslationCategory>? categories,
    DateTime? startDate,
    DateTime? endDate,
    double? minConfidence,
    double? maxConfidence,
    bool? isFavorite,
    bool? hasMedia,
    List<String>? tags,
    int? limit,
    int? offset,
    SortBy? sortBy,
    SortOrder? sortOrder,
  }) {
    return HistoryQuery(
      searchText: searchText ?? this.searchText,
      sourceLanguages: sourceLanguages ?? this.sourceLanguages,
      targetLanguages: targetLanguages ?? this.targetLanguages,
      methods: methods ?? this.methods,
      categories: categories ?? this.categories,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      minConfidence: minConfidence ?? this.minConfidence,
      maxConfidence: maxConfidence ?? this.maxConfidence,
      isFavorite: isFavorite ?? this.isFavorite,
      hasMedia: hasMedia ?? this.hasMedia,
      tags: tags ?? this.tags,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// Check if query has any filters
  bool get hasFilters {
    return searchText != null ||
        sourceLanguages != null ||
        targetLanguages != null ||
        methods != null ||
        categories != null ||
        startDate != null ||
        endDate != null ||
        minConfidence != null ||
        maxConfidence != null ||
        isFavorite != null ||
        hasMedia != null ||
        tags != null;
  }

  /// Check if query is empty
  bool get isEmpty => !hasFilters;

  @override
  String toString() => 'HistoryQuery(filters: ${hasFilters ? 'yes' : 'none'})';
}

/// Sort options for history queries
enum SortBy {
  timestamp,
  confidence,
  sourceLanguage,
  targetLanguage,
  characterCount,
  method,
}

/// Sort order for history queries
enum SortOrder {
  ascending,
  descending,
}

/// Batch operation result
@JsonSerializable()
class BatchOperationResult {
  final int successCount;
  final int errorCount;
  final List<String> errors;
  final DateTime timestamp;
  final String operationType;

  const BatchOperationResult({
    required this.successCount,
    required this.errorCount,
    required this.errors,
    required this.timestamp,
    required this.operationType,
  });

  /// Create batch operation result from JSON
  factory BatchOperationResult.fromJson(Map<String, dynamic> json) =>
      _$BatchOperationResultFromJson(json);

  /// Convert batch operation result to JSON
  Map<String, dynamic> toJson() => _$BatchOperationResultToJson(this);

  /// Get total operations count
  int get totalCount => successCount + errorCount;

  /// Check if operation was successful
  bool get isSuccess => errorCount == 0;

  /// Get success rate as percentage
  double get successRate {
    if (totalCount == 0) return 0.0;
    return (successCount / totalCount) * 100;
  }

  @override
  String toString() =>
      'BatchOperationResult($operationType: $successCount/$totalCount success)';
}
