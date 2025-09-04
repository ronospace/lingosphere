// 🌐 LingoSphere - Translation Entry Models
// Core data models for translation entries and history

import 'package:json_annotation/json_annotation.dart';

part 'translation_entry.g.dart';

/// Translation method type
enum TranslationMethod {
  text,
  voice,
  camera,
  image,
  document,
}

/// Translation source for analytics
enum TranslationSource {
  user,
  api,
  cache,
  offline,
}

/// Translation category for organization
enum TranslationCategory {
  general,
  business,
  travel,
  education,
  medical,
  legal,
  technical,
  personal,
}

/// Main translation entry model
@JsonSerializable()
class TranslationEntry {
  final String id;
  final String sourceText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime timestamp;
  final TranslationMethod type;
  final TranslationSource source;
  final TranslationCategory category;
  final double confidence;
  final bool isFavorite;
  final Map<String, dynamic>? metadata;
  final String? audioFilePath;
  final String? imageFilePath;
  final List<String>? tags;
  final String? notes;
  final bool isOffline;
  final int? characterCount;

  const TranslationEntry({
    required this.id,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.timestamp,
    required this.type,
    this.source = TranslationSource.user,
    this.category = TranslationCategory.general,
    this.confidence = 1.0,
    this.isFavorite = false,
    this.metadata,
    this.audioFilePath,
    this.imageFilePath,
    this.tags,
    this.notes,
    this.isOffline = false,
    this.characterCount,
  });

  /// Create translation entry from JSON
  factory TranslationEntry.fromJson(Map<String, dynamic> json) =>
      _$TranslationEntryFromJson(json);

  /// Convert translation entry to JSON
  Map<String, dynamic> toJson() => _$TranslationEntryToJson(this);

  /// Create a copy with updated fields
  TranslationEntry copyWith({
    String? id,
    String? sourceText,
    String? translatedText,
    String? sourceLanguage,
    String? targetLanguage,
    DateTime? timestamp,
    TranslationMethod? type,
    TranslationSource? source,
    TranslationCategory? category,
    double? confidence,
    bool? isFavorite,
    Map<String, dynamic>? metadata,
    String? audioFilePath,
    String? imageFilePath,
    List<String>? tags,
    String? notes,
    bool? isOffline,
    int? characterCount,
  }) {
    return TranslationEntry(
      id: id ?? this.id,
      sourceText: sourceText ?? this.sourceText,
      translatedText: translatedText ?? this.translatedText,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      source: source ?? this.source,
      category: category ?? this.category,
      confidence: confidence ?? this.confidence,
      isFavorite: isFavorite ?? this.isFavorite,
      metadata: metadata ?? this.metadata,
      audioFilePath: audioFilePath ?? this.audioFilePath,
      imageFilePath: imageFilePath ?? this.imageFilePath,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      isOffline: isOffline ?? this.isOffline,
      characterCount: characterCount ?? this.characterCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslationEntry &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'TranslationEntry(id: $id, source: $sourceLanguage->$targetLanguage)';

  /// Get character count (calculated if not stored)
  int get actualCharacterCount => characterCount ?? sourceText.length;

  /// Check if entry has media files
  bool get hasMedia => audioFilePath != null || imageFilePath != null;

  /// Get display title for the entry
  String get displayTitle {
    if (sourceText.length <= 50) return sourceText;
    return '${sourceText.substring(0, 47)}...';
  }

  /// Get confidence percentage as integer
  int get confidencePercentage => (confidence * 100).round();

  /// Check if entry is recent (within last 24 hours)
  bool get isRecent => DateTime.now().difference(timestamp).inHours < 24;

  /// Get formatted timestamp
  String get formattedTimestamp {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  /// Get language pair string
  String get languagePair => '$sourceLanguage → $targetLanguage';
}

/// Extension methods for collections
extension TranslationEntryList on List<TranslationEntry> {
  /// Filter by date range
  List<TranslationEntry> filterByDateRange(DateTime start, DateTime end) {
    return where((entry) =>
            entry.timestamp.isAfter(start) && entry.timestamp.isBefore(end))
        .toList();
  }

  /// Filter by translation method
  List<TranslationEntry> filterByMethod(TranslationMethod method) {
    return where((entry) => entry.type == method).toList();
  }

  /// Filter by language pair
  List<TranslationEntry> filterByLanguagePair(String source, String target) {
    return where((entry) =>
            entry.sourceLanguage == source && entry.targetLanguage == target)
        .toList();
  }

  /// Filter favorites only
  List<TranslationEntry> get favorites {
    return where((entry) => entry.isFavorite).toList();
  }

  /// Sort by timestamp (newest first)
  List<TranslationEntry> sortByNewest() {
    final sorted = List<TranslationEntry>.from(this);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted;
  }

  /// Sort by confidence (highest first)
  List<TranslationEntry> sortByConfidence() {
    final sorted = List<TranslationEntry>.from(this);
    sorted.sort((a, b) => b.confidence.compareTo(a.confidence));
    return sorted;
  }

  /// Get total character count
  int get totalCharacters {
    return fold(0, (sum, entry) => sum + entry.actualCharacterCount);
  }

  /// Group by date
  Map<DateTime, List<TranslationEntry>> groupByDate() {
    final grouped = <DateTime, List<TranslationEntry>>{};
    for (final entry in this) {
      final date = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );
      grouped.putIfAbsent(date, () => []).add(entry);
    }
    return grouped;
  }

  /// Group by language pair
  Map<String, List<TranslationEntry>> groupByLanguagePair() {
    final grouped = <String, List<TranslationEntry>>{};
    for (final entry in this) {
      final pair = entry.languagePair;
      grouped.putIfAbsent(pair, () => []).add(entry);
    }
    return grouped;
  }
}
