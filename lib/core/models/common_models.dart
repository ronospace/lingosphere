// 🌐 LingoSphere - Common Models
// Shared data models and enums to prevent conflicts across the application

/// Translation engine source (what HistoryService uses)
/// This represents HOW the translation was performed
enum TranslationEngineSource {
  text,
  voice,
  camera,
  file,
  manual,
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

/// History sorting options (internal to HistoryService)
enum HistorySortBy {
  dateAsc,
  dateDesc,
  confidenceAsc,
  confidenceDesc,
  alphabetical,
  source,
}

/// Date range helper for filtering
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({
    required this.start,
    required this.end,
  });

  /// Create date range from JSON
  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
    );
  }

  /// Convert date range to JSON
  Map<String, dynamic> toJson() {
    return {
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    };
  }

  /// Get duration of the range
  Duration get duration => end.difference(start);

  /// Check if date is within range
  bool contains(DateTime date) {
    return date.isAfter(start) && date.isBefore(end);
  }

  /// Create range for today
  static DateRange today() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return DateRange(start: start, end: end);
  }

  /// Create range for this week
  static DateRange thisWeek() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(start.year, start.month, start.day);
    final end = weekStart.add(const Duration(days: 7));
    return DateRange(start: weekStart, end: end);
  }

  /// Create range for this month
  static DateRange thisMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    return DateRange(start: start, end: end);
  }

  /// Create range for last 30 days
  static DateRange last30Days() {
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 30));
    return DateRange(start: start, end: end);
  }

  @override
  String toString() {
    return '${start.toIso8601String().split('T')[0]} - ${end.toIso8601String().split('T')[0]}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}

/// Language pair statistics
class LanguagePair {
  final String source;
  final String target;
  final int count;

  const LanguagePair({
    required this.source,
    required this.target,
    required this.count,
  });

  @override
  String toString() => '$source → $target ($count)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguagePair &&
          runtimeType == other.runtimeType &&
          source == other.source &&
          target == other.target &&
          count == other.count;

  @override
  int get hashCode => source.hashCode ^ target.hashCode ^ count.hashCode;
}

/// Daily activity statistics
class DailyActivity {
  final DateTime date;
  final int count;

  const DailyActivity({
    required this.date,
    required this.count,
  });

  @override
  String toString() =>
      'DailyActivity(${date.toIso8601String().split('T')[0]}: $count)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyActivity &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          count == other.count;

  @override
  int get hashCode => date.hashCode ^ count.hashCode;
}

/// Batch operation result
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
  factory BatchOperationResult.fromJson(Map<String, dynamic> json) {
    return BatchOperationResult(
      successCount: json['successCount'] as int,
      errorCount: json['errorCount'] as int,
      errors: List<String>.from(json['errors'] as List),
      timestamp: DateTime.parse(json['timestamp'] as String),
      operationType: json['operationType'] as String,
    );
  }

  /// Convert batch operation result to JSON
  Map<String, dynamic> toJson() {
    return {
      'successCount': successCount,
      'errorCount': errorCount,
      'errors': errors,
      'timestamp': timestamp.toIso8601String(),
      'operationType': operationType,
    };
  }

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
      'BatchOperationResult($operationType: $successCount/$totalCount successful)';
}
