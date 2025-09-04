// 🌐 LingoSphere - Smart Filtering System
// Advanced filtering controller and state management for translation history

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/services/history_service.dart';
import '../../../core/models/translation_history.dart' hide SortBy;
import '../../../core/models/common_models.dart';

/// Translation source types for filtering
enum TranslationSource {
  camera,
  voice,
  text,
  image,
  file,
}

/// Filter state for managing all active filters
class HistoryFilterState {
  final String searchQuery;
  final DateRange? dateRange;
  final RangeValues confidenceRange;
  final List<String> sourceLanguages;
  final List<String> targetLanguages;
  final List<TranslationSource> sources;
  final bool showFavoritesOnly;
  final HistorySortBy sortBy;
  final List<String> categories;
  final double? minWordCount;
  final double? maxWordCount;
  final bool includeDeleted;

  const HistoryFilterState({
    this.searchQuery = '',
    this.dateRange,
    this.confidenceRange = const RangeValues(0.0, 1.0),
    this.sourceLanguages = const [],
    this.targetLanguages = const [],
    this.sources = const [],
    this.showFavoritesOnly = false,
    this.sortBy = HistorySortBy.dateDesc,
    this.categories = const [],
    this.minWordCount,
    this.maxWordCount,
    this.includeDeleted = false,
  });

  HistoryFilterState copyWith({
    String? searchQuery,
    DateRange? dateRange,
    RangeValues? confidenceRange,
    List<String>? sourceLanguages,
    List<String>? targetLanguages,
    List<TranslationSource>? sources,
    bool? showFavoritesOnly,
    HistorySortBy? sortBy,
    List<String>? categories,
    double? minWordCount,
    double? maxWordCount,
    bool? includeDeleted,
  }) {
    return HistoryFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      dateRange: dateRange ?? this.dateRange,
      confidenceRange: confidenceRange ?? this.confidenceRange,
      sourceLanguages: sourceLanguages ?? this.sourceLanguages,
      targetLanguages: targetLanguages ?? this.targetLanguages,
      sources: sources ?? this.sources,
      showFavoritesOnly: showFavoritesOnly ?? this.showFavoritesOnly,
      sortBy: sortBy ?? this.sortBy,
      categories: categories ?? this.categories,
      minWordCount: minWordCount ?? this.minWordCount,
      maxWordCount: maxWordCount ?? this.maxWordCount,
      includeDeleted: includeDeleted ?? this.includeDeleted,
    );
  }

  bool get hasActiveFilters {
    return searchQuery.isNotEmpty ||
        dateRange != null ||
        confidenceRange != const RangeValues(0.0, 1.0) ||
        sourceLanguages.isNotEmpty ||
        targetLanguages.isNotEmpty ||
        sources.isNotEmpty ||
        showFavoritesOnly ||
        categories.isNotEmpty ||
        minWordCount != null ||
        maxWordCount != null ||
        includeDeleted;
  }

  int get activeFilterCount {
    int count = 0;
    if (searchQuery.isNotEmpty) count++;
    if (dateRange != null) count++;
    if (confidenceRange != const RangeValues(0.0, 1.0)) count++;
    if (sourceLanguages.isNotEmpty) count++;
    if (targetLanguages.isNotEmpty) count++;
    if (sources.isNotEmpty) count++;
    if (showFavoritesOnly) count++;
    if (categories.isNotEmpty) count++;
    if (minWordCount != null || maxWordCount != null) count++;
    if (includeDeleted) count++;
    return count;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryFilterState &&
          runtimeType == other.runtimeType &&
          searchQuery == other.searchQuery &&
          dateRange == other.dateRange &&
          confidenceRange == other.confidenceRange &&
          listEquals(sourceLanguages, other.sourceLanguages) &&
          listEquals(targetLanguages, other.targetLanguages) &&
          listEquals(sources, other.sources) &&
          showFavoritesOnly == other.showFavoritesOnly &&
          sortBy == other.sortBy &&
          listEquals(categories, other.categories) &&
          minWordCount == other.minWordCount &&
          maxWordCount == other.maxWordCount &&
          includeDeleted == other.includeDeleted;

  @override
  int get hashCode => Object.hash(
        searchQuery,
        dateRange,
        confidenceRange,
        Object.hashAll(sourceLanguages),
        Object.hashAll(targetLanguages),
        Object.hashAll(sources),
        showFavoritesOnly,
        sortBy,
        Object.hashAll(categories),
        minWordCount,
        maxWordCount,
        includeDeleted,
      );
}

/// Smart filtering controller for managing filter state and operations
class SmartFilterController extends ChangeNotifier {
  final HistoryService _historyService;

  HistoryFilterState _filterState = const HistoryFilterState();
  List<HistoryEntry> _filteredResults = [];
  List<HistoryEntry> _allHistory = [];
  bool _isLoading = false;
  String? _error;

  // Filter suggestions and analytics
  Map<String, int> _languagePairCounts = {};
  Map<TranslationSource, int> _sourceCounts = {};
  Map<String, int> _categoryCounts = {};
  List<String> _recentSearches = [];
  List<String> _suggestedQueries = [];

  SmartFilterController(this._historyService) {
    _loadInitialData();
  }

  // Getters
  HistoryFilterState get filterState => _filterState;
  List<HistoryEntry> get filteredResults => _filteredResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, int> get languagePairCounts => _languagePairCounts;
  Map<TranslationSource, int> get sourceCounts => _sourceCounts;
  Map<String, int> get categoryCounts => _categoryCounts;
  List<String> get recentSearches => _recentSearches;
  List<String> get suggestedQueries => _suggestedQueries;

  /// Load initial history data and build analytics
  Future<void> _loadInitialData() async {
    try {
      _isLoading = true;
      notifyListeners();

      _allHistory = await _historyService.searchHistory();
      _buildAnalytics();
      _generateSuggestions();
      await _applyFilters();

      _error = null;
    } catch (e) {
      _error = 'Failed to load history: $e';
      debugPrint('SmartFilterController error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Build analytics from history data
  void _buildAnalytics() {
    _languagePairCounts.clear();
    _sourceCounts.clear();
    _categoryCounts.clear();

    for (final history in _allHistory) {
      // Language pair counts
      final pair = '${history.sourceLanguage}-${history.targetLanguage}';
      _languagePairCounts[pair] = (_languagePairCounts[pair] ?? 0) + 1;

      // Source counts
      final source = _getTranslationSource(history.translationSource.name);
      _sourceCounts[source] = (_sourceCounts[source] ?? 0) + 1;

      // Category counts
      if (history.category?.isNotEmpty == true) {
        _categoryCounts[history.category!] =
            (_categoryCounts[history.category!] ?? 0) + 1;
      }
    }
  }

  /// Generate search suggestions based on history
  void _generateSuggestions() {
    _suggestedQueries.clear();

    // Most common words from translations
    final wordFrequency = <String, int>{};
    for (final history in _allHistory) {
      final words = history.originalText.toLowerCase().split(RegExp(r'\W+'));
      for (final word in words) {
        if (word.length > 3) {
          wordFrequency[word] = (wordFrequency[word] ?? 0) + 1;
        }
      }
    }

    // Top 10 most frequent words as suggestions
    final sortedWords = wordFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    _suggestedQueries = sortedWords.take(10).map((e) => e.key).toList();
  }

  /// Update search query and add to recent searches
  Future<void> updateSearchQuery(String query) async {
    if (query != _filterState.searchQuery) {
      _filterState = _filterState.copyWith(searchQuery: query);

      if (query.isNotEmpty && !_recentSearches.contains(query)) {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 10) {
          _recentSearches = _recentSearches.take(10).toList();
        }
      }

      await _applyFilters();
    }
  }

  /// Update date range filter
  Future<void> updateDateRange(DateRange? dateRange) async {
    if (dateRange != _filterState.dateRange) {
      _filterState = _filterState.copyWith(dateRange: dateRange);
      await _applyFilters();
    }
  }

  /// Update confidence range filter
  Future<void> updateConfidenceRange(RangeValues range) async {
    if (range != _filterState.confidenceRange) {
      _filterState = _filterState.copyWith(confidenceRange: range);
      await _applyFilters();
    }
  }

  /// Update source languages filter
  Future<void> updateSourceLanguages(List<String> languages) async {
    if (!listEquals(languages, _filterState.sourceLanguages)) {
      _filterState = _filterState.copyWith(sourceLanguages: languages);
      await _applyFilters();
    }
  }

  /// Update target languages filter
  Future<void> updateTargetLanguages(List<String> languages) async {
    if (!listEquals(languages, _filterState.targetLanguages)) {
      _filterState = _filterState.copyWith(targetLanguages: languages);
      await _applyFilters();
    }
  }

  /// Update translation sources filter
  Future<void> updateSources(List<TranslationSource> sources) async {
    if (!listEquals(sources, _filterState.sources)) {
      _filterState = _filterState.copyWith(sources: sources);
      await _applyFilters();
    }
  }

  /// Toggle favorites filter
  Future<void> toggleFavoritesOnly() async {
    _filterState = _filterState.copyWith(
        showFavoritesOnly: !_filterState.showFavoritesOnly);
    await _applyFilters();
  }

  /// Update sort order
  Future<void> updateSortBy(HistorySortBy sortBy) async {
    if (sortBy != _filterState.sortBy) {
      _filterState = _filterState.copyWith(sortBy: sortBy);
      await _applyFilters();
    }
  }

  /// Update categories filter
  Future<void> updateCategories(List<String> categories) async {
    if (!listEquals(categories, _filterState.categories)) {
      _filterState = _filterState.copyWith(categories: categories);
      await _applyFilters();
    }
  }

  /// Update word count range filter
  Future<void> updateWordCountRange(double? min, double? max) async {
    if (min != _filterState.minWordCount || max != _filterState.maxWordCount) {
      _filterState =
          _filterState.copyWith(minWordCount: min, maxWordCount: max);
      await _applyFilters();
    }
  }

  /// Clear all filters
  Future<void> clearAllFilters() async {
    _filterState = const HistoryFilterState();
    await _applyFilters();
  }

  /// Apply current filters to history data
  Future<void> _applyFilters() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Get filtered results from service using named parameters
      _filteredResults = await _historyService.searchHistory(
        searchQuery: _filterState.searchQuery.isNotEmpty
            ? _filterState.searchQuery
            : null,
        dateRange: _filterState.dateRange,
        minConfidence: _filterState.confidenceRange.start,
        languages: [
          ..._filterState.sourceLanguages,
          ..._filterState.targetLanguages
        ].isNotEmpty
            ? [..._filterState.sourceLanguages, ..._filterState.targetLanguages]
            : null,
        categories:
            _filterState.categories.isNotEmpty ? _filterState.categories : null,
        favoritesOnly: _filterState.showFavoritesOnly,
        sortBy: _mapHistorySortByToSortBy(_filterState.sortBy),
      );

      // Apply additional client-side filters
      _filteredResults = _filteredResults.where((history) {
        // Favorites filter
        if (_filterState.showFavoritesOnly && !history.isFavorite) {
          return false;
        }

        // Source filter
        if (_filterState.sources.isNotEmpty) {
          final source = _getTranslationSource(history.translationSource.name);
          if (!_filterState.sources.contains(source)) {
            return false;
          }
        }

        // Word count filter
        if (_filterState.minWordCount != null ||
            _filterState.maxWordCount != null) {
          final wordCount =
              history.originalText.split(RegExp(r'\W+')).length.toDouble();
          if (_filterState.minWordCount != null &&
              wordCount < _filterState.minWordCount!) {
            return false;
          }
          if (_filterState.maxWordCount != null &&
              wordCount > _filterState.maxWordCount!) {
            return false;
          }
        }

        return true;
      }).toList();

      _error = null;
    } catch (e) {
      _error = 'Failed to apply filters: $e';
      debugPrint('Filter application error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Map HistorySortBy to SortBy
  SortBy _mapHistorySortByToSortBy(HistorySortBy historySortBy) {
    switch (historySortBy) {
      case HistorySortBy.dateAsc:
      case HistorySortBy.dateDesc:
        return SortBy.timestamp;
      case HistorySortBy.confidenceAsc:
      case HistorySortBy.confidenceDesc:
        return SortBy.confidence;
      case HistorySortBy.alphabetical:
        return SortBy.sourceLanguage;
      case HistorySortBy.source:
        return SortBy.method;
    }
  }

  /// Convert string source to enum
  TranslationSource _getTranslationSource(String source) {
    switch (source.toLowerCase()) {
      case 'camera':
      case 'ocr':
        return TranslationSource.camera;
      case 'voice':
      case 'speech':
        return TranslationSource.voice;
      case 'image':
        return TranslationSource.image;
      case 'file':
        return TranslationSource.file;
      default:
        return TranslationSource.text;
    }
  }

  /// Get filter suggestions based on current state
  List<String> getFilterSuggestions() {
    final suggestions = <String>[];

    // Language suggestions
    if (_filterState.sourceLanguages.isEmpty) {
      suggestions.addAll(_languagePairCounts.keys
          .map((pair) => pair.split('-').first)
          .toSet()
          .take(5));
    }

    // Category suggestions
    if (_filterState.categories.isEmpty) {
      suggestions.addAll(_categoryCounts.keys.take(3));
    }

    // Recent searches
    suggestions.addAll(_recentSearches.take(3));

    return suggestions.take(10).toList();
  }

  /// Get quick filter presets
  List<HistoryFilterState> getQuickFilterPresets() {
    return [
      // Today's translations
      _filterState.copyWith(
        dateRange: DateRange(
          start: DateTime.now().copyWith(hour: 0, minute: 0, second: 0),
          end: DateTime.now(),
        ),
      ),

      // High confidence only
      _filterState.copyWith(
        confidenceRange: const RangeValues(0.8, 1.0),
      ),

      // Favorites only
      _filterState.copyWith(
        showFavoritesOnly: true,
      ),

      // Camera translations
      _filterState.copyWith(
        sources: [TranslationSource.camera],
      ),

      // Recent (last 7 days)
      _filterState.copyWith(
        dateRange: DateRange(
          start: DateTime.now().subtract(const Duration(days: 7)),
          end: DateTime.now(),
        ),
      ),
    ];
  }

  /// Refresh data and rebuild analytics
  Future<void> refresh() async {
    await _loadInitialData();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
