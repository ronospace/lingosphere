// 🌐 LingoSphere - Analytics Service
// Comprehensive analytics and usage statistics tracking service

import 'package:flutter/foundation.dart';
import '../models/translation_entry.dart';
import '../models/analytics_models.dart';

/// Time period for analytics data
enum AnalyticsPeriod {
  today,
  week,
  month,
  quarter,
  year,
  allTime,
}

/// Translation usage statistics
class TranslationStats {
  final int totalTranslations;
  final int textTranslations;
  final int voiceTranslations;
  final int cameraTranslations;
  final int favoriteTranslations;
  final double averageTranslationsPerDay;
  final List<String> topLanguages;
  final Map<String, int> languageUsage;
  final List<DailyUsage> dailyUsage;
  final Map<String, int> typeDistribution;

  TranslationStats({
    required this.totalTranslations,
    required this.textTranslations,
    required this.voiceTranslations,
    required this.cameraTranslations,
    required this.favoriteTranslations,
    required this.averageTranslationsPerDay,
    required this.topLanguages,
    required this.languageUsage,
    required this.dailyUsage,
    required this.typeDistribution,
  });
}

/// Language pair usage statistics
class LanguagePairStats {
  final String sourceLang;
  final String targetLang;
  final int count;
  final double percentage;
  final DateTime lastUsed;

  LanguagePairStats({
    required this.sourceLang,
    required this.targetLang,
    required this.count,
    required this.percentage,
    required this.lastUsed,
  });
}

/// User behavior insights
class UserInsights {
  final String mostActiveTimeOfDay;
  final List<String> preferredLanguages;
  final String mostUsedTranslationType;
  final double translationsPerDay;
  final int streak; // Days of consecutive usage
  final Map<String, double> efficiencyMetrics;
  final List<String> suggestions;

  UserInsights({
    required this.mostActiveTimeOfDay,
    required this.preferredLanguages,
    required this.mostUsedTranslationType,
    required this.translationsPerDay,
    required this.streak,
    required this.efficiencyMetrics,
    required this.suggestions,
  });
}

/// Analytics Service for tracking usage patterns and generating insights
class AnalyticsService extends ChangeNotifier {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  // Mock data - in production, this would connect to a database or analytics provider
  final List<TranslationEntry> _allTranslations = [];
  final Map<String, dynamic> _userPreferences = {};
  final Map<String, int> _featureUsage = {};
  bool _isInitialized = false;

  /// Initialize the analytics service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize analytics tracking
      // In a real implementation, this might:
      // - Set up analytics SDK (Firebase Analytics, etc.)
      // - Load user preferences
      // - Initialize feature usage tracking
      // - Set up crash reporting

      debugPrint('🔧 Initializing Analytics Service...');

      // Simulate initialization delay
      await Future.delayed(const Duration(milliseconds: 100));

      _isInitialized = true;

      debugPrint('✅ Analytics Service initialized successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Failed to initialize Analytics Service: $e');
      rethrow;
    }
  }

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  /// Get translation statistics for a specific period
  TranslationStats getTranslationStats(AnalyticsPeriod period) {
    final filteredTranslations = _getTranslationsForPeriod(period);

    // Calculate basic counts
    final totalTranslations = filteredTranslations.length;
    final textTranslations = filteredTranslations
        .where((t) => t.type == TranslationMethod.text)
        .length;
    final voiceTranslations = filteredTranslations
        .where((t) => t.type == TranslationMethod.voice)
        .length;
    final cameraTranslations = filteredTranslations
        .where((t) => t.type == TranslationMethod.camera)
        .length;
    final favoriteTranslations =
        filteredTranslations.where((t) => t.isFavorite).length;

    // Calculate daily usage
    final dailyUsage = _calculateDailyUsage(filteredTranslations, period);

    // Calculate average translations per day
    final daysInPeriod = _getDaysInPeriod(period);
    final averagePerDay =
        daysInPeriod > 0 ? totalTranslations / daysInPeriod : 0.0;

    // Calculate language usage
    final languageUsage = <String, int>{};
    for (final translation in filteredTranslations) {
      languageUsage[translation.sourceLanguage] =
          (languageUsage[translation.sourceLanguage] ?? 0) + 1;
      languageUsage[translation.targetLanguage] =
          (languageUsage[translation.targetLanguage] ?? 0) + 1;
    }

    // Get top languages
    final topLanguages = languageUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..take(5);

    // Type distribution
    final typeDistribution = {
      'text': textTranslations,
      'voice': voiceTranslations,
      'camera': cameraTranslations,
    };

    return TranslationStats(
      totalTranslations: totalTranslations,
      textTranslations: textTranslations,
      voiceTranslations: voiceTranslations,
      cameraTranslations: cameraTranslations,
      favoriteTranslations: favoriteTranslations,
      averageTranslationsPerDay: averagePerDay,
      topLanguages: topLanguages.map((e) => e.key).toList(),
      languageUsage: languageUsage,
      dailyUsage: dailyUsage,
      typeDistribution: typeDistribution,
    );
  }

  /// Get language pair statistics
  List<LanguagePairStats> getLanguagePairStats(AnalyticsPeriod period) {
    final filteredTranslations = _getTranslationsForPeriod(period);
    final pairCounts = <String, Map<String, dynamic>>{};

    // Count language pairs
    for (final translation in filteredTranslations) {
      final pairKey =
          '${translation.sourceLanguage}-${translation.targetLanguage}';
      if (pairCounts.containsKey(pairKey)) {
        pairCounts[pairKey]!['count']++;
        if (translation.timestamp.isAfter(pairCounts[pairKey]!['lastUsed'])) {
          pairCounts[pairKey]!['lastUsed'] = translation.timestamp;
        }
      } else {
        pairCounts[pairKey] = {
          'count': 1,
          'sourceLang': translation.sourceLanguage,
          'targetLang': translation.targetLanguage,
          'lastUsed': translation.timestamp,
        };
      }
    }

    final totalPairs = pairCounts.values
        .fold<int>(0, (sum, pair) => sum + pair['count'] as int);

    return pairCounts.entries.map((entry) {
      final data = entry.value;
      return LanguagePairStats(
        sourceLang: data['sourceLang'],
        targetLang: data['targetLang'],
        count: data['count'],
        percentage: totalPairs > 0 ? (data['count'] / totalPairs) * 100 : 0.0,
        lastUsed: data['lastUsed'],
      );
    }).toList()
      ..sort((a, b) => b.count.compareTo(a.count));
  }

  /// Generate user behavior insights
  UserInsights generateUserInsights() {
    final recentTranslations = _getTranslationsForPeriod(AnalyticsPeriod.month);

    // Most active time of day
    final hourCounts = <int, int>{};
    for (final translation in recentTranslations) {
      final hour = translation.timestamp.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    final mostActiveHour =
        hourCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    String mostActiveTimeOfDay;
    if (mostActiveHour < 6) {
      mostActiveTimeOfDay = 'Late Night (12-6 AM)';
    } else if (mostActiveHour < 12) {
      mostActiveTimeOfDay = 'Morning (6 AM-12 PM)';
    } else if (mostActiveHour < 18) {
      mostActiveTimeOfDay = 'Afternoon (12-6 PM)';
    } else {
      mostActiveTimeOfDay = 'Evening (6 PM-12 AM)';
    }

    // Preferred languages
    final languageUsage = <String, int>{};
    for (final translation in recentTranslations) {
      languageUsage[translation.sourceLanguage] =
          (languageUsage[translation.sourceLanguage] ?? 0) + 1;
    }

    final preferredLanguages = languageUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..take(3);

    // Most used translation type
    final typeCounts = <String, int>{};
    for (final translation in recentTranslations) {
      typeCounts[translation.type.name] =
          (typeCounts[translation.type.name] ?? 0) + 1;
    }

    final mostUsedType =
        typeCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // Calculate streak
    final streak = _calculateStreak();

    // Efficiency metrics
    final efficiencyMetrics = <String, double>{
      'favoriteRate': recentTranslations.isNotEmpty
          ? recentTranslations.where((t) => t.isFavorite).length /
              recentTranslations.length
          : 0.0,
      'diversityScore': languageUsage.length.toDouble(),
      'consistencyScore': streak.toDouble(),
    };

    // Generate suggestions
    final suggestions =
        _generateSuggestions(recentTranslations, efficiencyMetrics);

    return UserInsights(
      mostActiveTimeOfDay: mostActiveTimeOfDay,
      preferredLanguages: preferredLanguages.map((e) => e.key).toList(),
      mostUsedTranslationType: mostUsedType,
      translationsPerDay: recentTranslations.length / 30.0,
      streak: streak,
      efficiencyMetrics: efficiencyMetrics,
      suggestions: suggestions,
    );
  }

  /// Track feature usage
  void trackFeatureUsage(String feature) {
    _featureUsage[feature] = (_featureUsage[feature] ?? 0) + 1;
    notifyListeners();
  }

  /// Add translation for analytics
  void addTranslation(TranslationEntry translation) {
    _allTranslations.add(translation);
    trackFeatureUsage('translation_${translation.type.name}');
    notifyListeners();
  }

  /// Get mock data for development
  TranslationStats getMockStats() {
    final now = DateTime.now();
    final dailyUsage = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final baseCount = 10 + (index * 3);
      return DailyUsage(
        date: date,
        translations: baseCount + (index % 3 == 0 ? 5 : 0),
        textTranslations: (baseCount * 0.4).round(),
        voiceTranslations: (baseCount * 0.4).round(),
        cameraTranslations: (baseCount * 0.2).round(),
      );
    });

    return TranslationStats(
      totalTranslations: 142,
      textTranslations: 58,
      voiceTranslations: 52,
      cameraTranslations: 32,
      favoriteTranslations: 23,
      averageTranslationsPerDay: 20.3,
      topLanguages: ['es', 'fr', 'de', 'ja', 'it'],
      languageUsage: {
        'es': 45,
        'fr': 32,
        'de': 28,
        'ja': 22,
        'it': 15,
      },
      dailyUsage: dailyUsage,
      typeDistribution: {
        'text': 58,
        'voice': 52,
        'camera': 32,
      },
    );
  }

  /// Get mock language pair stats
  List<LanguagePairStats> getMockLanguagePairStats() {
    return [
      LanguagePairStats(
        sourceLang: 'en',
        targetLang: 'es',
        count: 32,
        percentage: 22.5,
        lastUsed: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      LanguagePairStats(
        sourceLang: 'fr',
        targetLang: 'en',
        count: 28,
        percentage: 19.7,
        lastUsed: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      LanguagePairStats(
        sourceLang: 'en',
        targetLang: 'fr',
        count: 24,
        percentage: 16.9,
        lastUsed: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      LanguagePairStats(
        sourceLang: 'de',
        targetLang: 'en',
        count: 20,
        percentage: 14.1,
        lastUsed: DateTime.now().subtract(const Duration(days: 1)),
      ),
      LanguagePairStats(
        sourceLang: 'ja',
        targetLang: 'en',
        count: 18,
        percentage: 12.7,
        lastUsed: DateTime.now().subtract(const Duration(hours: 8)),
      ),
    ];
  }

  /// Get mock user insights
  UserInsights getMockUserInsights() {
    return UserInsights(
      mostActiveTimeOfDay: 'Afternoon (12-6 PM)',
      preferredLanguages: ['Spanish', 'French', 'German'],
      mostUsedTranslationType: 'text',
      translationsPerDay: 4.7,
      streak: 12,
      efficiencyMetrics: {
        'favoriteRate': 0.16,
        'diversityScore': 5.0,
        'consistencyScore': 12.0,
      },
      suggestions: [
        'Try voice translation for hands-free experience',
        'Explore Japanese translations to expand your language skills',
        'Use camera translation for real-world text',
        'Set up conversation mode for real-time discussions',
      ],
    );
  }

  // Private helper methods
  List<TranslationEntry> _getTranslationsForPeriod(AnalyticsPeriod period) {
    final now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case AnalyticsPeriod.today:
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case AnalyticsPeriod.week:
        startDate = now.subtract(const Duration(days: 7));
        break;
      case AnalyticsPeriod.month:
        startDate = now.subtract(const Duration(days: 30));
        break;
      case AnalyticsPeriod.quarter:
        startDate = now.subtract(const Duration(days: 90));
        break;
      case AnalyticsPeriod.year:
        startDate = now.subtract(const Duration(days: 365));
        break;
      case AnalyticsPeriod.allTime:
        return _allTranslations;
    }

    return _allTranslations
        .where((t) => t.timestamp.isAfter(startDate))
        .toList();
  }

  List<DailyUsage> _calculateDailyUsage(
      List<TranslationEntry> translations, AnalyticsPeriod period) {
    final dailyCounts = <String, Map<String, int>>{};

    for (final translation in translations) {
      final dateKey =
          '${translation.timestamp.year}-${translation.timestamp.month}-${translation.timestamp.day}';
      dailyCounts[dateKey] ??= {'total': 0, 'text': 0, 'voice': 0, 'camera': 0};
      dailyCounts[dateKey]!['total'] = dailyCounts[dateKey]!['total']! + 1;
      dailyCounts[dateKey]![translation.type.name] =
          (dailyCounts[dateKey]![translation.type.name] ?? 0) + 1;
    }

    return dailyCounts.entries.map((entry) {
      final parts = entry.key.split('-');
      final date = DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      final counts = entry.value;

      return DailyUsage(
        date: date,
        translations: counts['total'] ?? 0,
        textTranslations: counts['text'] ?? 0,
        voiceTranslations: counts['voice'] ?? 0,
        cameraTranslations: counts['camera'] ?? 0,
      );
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  int _getDaysInPeriod(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.today:
        return 1;
      case AnalyticsPeriod.week:
        return 7;
      case AnalyticsPeriod.month:
        return 30;
      case AnalyticsPeriod.quarter:
        return 90;
      case AnalyticsPeriod.year:
        return 365;
      case AnalyticsPeriod.allTime:
        final firstTranslation = _allTranslations.isEmpty
            ? DateTime.now()
            : _allTranslations
                .reduce((a, b) => a.timestamp.isBefore(b.timestamp) ? a : b)
                .timestamp;
        return DateTime.now().difference(firstTranslation).inDays;
    }
  }

  int _calculateStreak() {
    if (_allTranslations.isEmpty) return 0;

    final sortedTranslations = _allTranslations.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    var streak = 0;
    var currentDate = DateTime.now();
    final today =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    for (var i = 0; i >= -30; i--) {
      // Check last 30 days
      final checkDate = today.add(Duration(days: i));
      final hasTranslation = sortedTranslations.any((t) {
        final tDate =
            DateTime(t.timestamp.year, t.timestamp.month, t.timestamp.day);
        return tDate.isAtSameMomentAs(checkDate);
      });

      if (hasTranslation) {
        streak++;
      } else if (i < 0) {
        // Only break streak for past days, not future
        break;
      }
    }

    return streak;
  }

  List<String> _generateSuggestions(
      List<TranslationEntry> translations, Map<String, double> metrics) {
    final suggestions = <String>[];

    // Based on type distribution
    final typeCounts = <String, int>{};
    for (final t in translations) {
      typeCounts[t.type.name] = (typeCounts[t.type.name] ?? 0) + 1;
    }

    if ((typeCounts['voice'] ?? 0) < (typeCounts['text'] ?? 0) * 0.3) {
      suggestions.add('Try voice translation for hands-free experience');
    }

    if ((typeCounts['camera'] ?? 0) < (typeCounts['text'] ?? 0) * 0.2) {
      suggestions.add('Use camera translation for real-world text');
    }

    // Based on language diversity
    if (metrics['diversityScore']! < 3) {
      suggestions.add('Explore new languages to expand your skills');
    }

    // Based on favorite rate
    if (metrics['favoriteRate']! < 0.1) {
      suggestions
          .add('Mark important translations as favorites for quick access');
    }

    // Based on consistency
    if (metrics['consistencyScore']! < 7) {
      suggestions.add('Try to translate daily to build consistency');
    }

    // Generic suggestions
    suggestions.addAll([
      'Set up conversation mode for real-time discussions',
      'Enable offline mode for translations without internet',
      'Share translations with friends and colleagues',
      'Export your translation history for backup',
    ]);

    return suggestions.take(4).toList();
  }

  /// Generate mock daily usage data for insights dashboard
  List<DailyUsage> _generateMockDailyUsage() {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final baseCount = 15 + (index * 2) + (index % 2 == 0 ? 3 : 0);
      return DailyUsage(
        date: date,
        translations: baseCount,
        textTranslations: (baseCount * 0.5).round(),
        voiceTranslations: (baseCount * 0.3).round(),
        cameraTranslations: (baseCount * 0.2).round(),
      );
    });
  }

  /// Get usage analytics for insights dashboard
  Future<UsageAnalytics> getUsageAnalytics(String period) async {
    // Mock implementation - in production this would fetch from database
    final recentTranslations = [
      RecentTranslation(
        id: '1',
        sourceText: 'Hello world',
        translatedText: 'Hola mundo',
        sourceLanguage: 'en',
        targetLanguage: 'es',
        timestamp: DateTime.now().subtract(Duration(minutes: 5)),
        confidence: 0.95,
        userId: 'user123',
        provider: 'Google',
        originalText: 'Hello world',
        method: 'text',
      ),
      RecentTranslation(
        id: '2',
        sourceText: 'Good morning',
        translatedText: 'Bonjour',
        sourceLanguage: 'en',
        targetLanguage: 'fr',
        timestamp: DateTime.now().subtract(Duration(minutes: 15)),
        confidence: 0.92,
        userId: 'user456',
        provider: 'DeepL',
        originalText: 'Good morning',
        method: 'voice',
      ),
    ];
    
    return UsageAnalytics(
      totalTranslations: 1247,
      avgTranslationTime: 1.8,
      activeUsers: 4321,
      languageUsage: {
        'Spanish': 342,
        'French': 256,
        'German': 189,
        'Italian': 143,
        'Portuguese': 98,
      },
      recentActivity: recentTranslations,
      periodStart: DateTime.now().subtract(Duration(days: 30)),
      periodEnd: DateTime.now(),
      growthRate: 12.5,
      translationsGrowth: 15.3,
      languagesUsed: 8,
      averageConfidence: 89.2,
      successRate: 97.8,
      dailyUsage: _generateMockDailyUsage(),
      recentTranslations: recentTranslations,
      peakHour: '2:00 PM',
      preferredMethod: 'Text',
      methodUsagePercentage: 65.0,
      averageSessionLength: 4.2,
    );
  }

  /// Get performance metrics for insights dashboard
  Future<PerformanceMetrics> getPerformanceMetrics(String period) async {
    // Mock implementation
    return PerformanceMetrics(
      responseTime: 245.0,
      throughput: 850.0,
      errorRate: 0.02,
      availability: 99.8,
      serviceTimes: {'translation': 180.0, 'ocr': 120.0, 'tts': 90.0},
      concurrentUsers: 78,
      memoryUsage: 68.5,
      cpuUsage: 32.1,
      measuredAt: DateTime.now(),
      averageResponseTime: 245.0,
      successRate: 97.8,
      cacheHitRate: 82.3,
      responseTimeTrend: [
        ResponseTimePoint(
          timestamp: DateTime.now().subtract(Duration(hours: 6)),
          responseTime: 250.0,
          endpoint: '/translate',
          statusCode: 200,
        ),
        ResponseTimePoint(
          timestamp: DateTime.now().subtract(Duration(hours: 4)),
          responseTime: 240.0,
          endpoint: '/translate',
          statusCode: 200,
        ),
        ResponseTimePoint(
          timestamp: DateTime.now().subtract(Duration(hours: 2)),
          responseTime: 245.0,
          endpoint: '/translate',
          statusCode: 200,
        ),
      ],
      highConfidenceRate: 78.5,
      mediumConfidenceRate: 18.2,
      lowConfidenceRate: 3.3,
    );
  }

  /// Get language usage statistics for insights dashboard
  Future<List<LanguageUsageStats>> getLanguageUsageStats(String period) async {
    // Mock implementation
    return [
      LanguageUsageStats(
        languageCode: 'es',
        languageName: 'Spanish',
        usage: 342,
        percentage: 27.4,
        trend: 5,
        lastUsed: DateTime.now().subtract(Duration(minutes: 5)),
      ),
      LanguageUsageStats(
        languageCode: 'fr',
        languageName: 'French',
        usage: 256,
        percentage: 20.5,
        trend: -2,
        lastUsed: DateTime.now().subtract(Duration(minutes: 15)),
      ),
      LanguageUsageStats(
        languageCode: 'de',
        languageName: 'German',
        usage: 189,
        percentage: 15.2,
        trend: 8,
        lastUsed: DateTime.now().subtract(Duration(hours: 2)),
      ),
      LanguageUsageStats(
        languageCode: 'it',
        languageName: 'Italian',
        usage: 143,
        percentage: 11.5,
        trend: 3,
        lastUsed: DateTime.now().subtract(Duration(hours: 4)),
      ),
      LanguageUsageStats(
        languageCode: 'pt',
        languageName: 'Portuguese',
        usage: 98,
        percentage: 7.9,
        trend: -1,
        lastUsed: DateTime.now().subtract(Duration(days: 1)),
      ),
    ];
  }

  /// Get conversation insights for insights dashboard
  Future<List<ConversationInsight>> getConversationInsights(String period) async {
    // Mock implementation
    return [
      ConversationInsight(
        id: '1',
        type: InsightType.performance,
        title: 'Translation Speed Improved',
        description: 'Average translation time decreased by 15% this week',
        impact: 0.85,
        recommendations: [
          'Continue using optimized translation models',
          'Consider enabling caching for frequent phrases'
        ],
        data: {'improvement': 15.0, 'baseline': 2.1, 'current': 1.8},
        generatedAt: DateTime.now(),
        isActionable: true,
      ),
      ConversationInsight(
        id: '2',
        type: InsightType.usage,
        title: 'Voice Translation Growth',
        description: 'Voice translations increased by 32% compared to last month',
        impact: 0.72,
        recommendations: [
          'Add more voice-enabled features',
          'Promote conversation mode to users'
        ],
        data: {'growth': 32.0, 'totalVoice': 256},
        generatedAt: DateTime.now(),
        isActionable: true,
      ),
      ConversationInsight(
        id: '3',
        type: InsightType.quality,
        title: 'High Accuracy Maintained',
        description: 'Translation accuracy remains above 95% across all languages',
        impact: 0.91,
        recommendations: [
          'Continue current quality standards',
          'Monitor emerging language pairs'
        ],
        data: {'accuracy': 95.8, 'target': 95.0},
        generatedAt: DateTime.now(),
        isActionable: false,
      ),
    ];
  }

  /// Export analytics data
  Map<String, dynamic> exportAnalyticsData(AnalyticsPeriod period) {
    final stats = getTranslationStats(period);
    final languagePairs = getLanguagePairStats(period);
    final insights = generateUserInsights();

    return {
      'period': period.toString(),
      'exportDate': DateTime.now().toIso8601String(),
      'stats': {
        'totalTranslations': stats.totalTranslations,
        'textTranslations': stats.textTranslations,
        'voiceTranslations': stats.voiceTranslations,
        'cameraTranslations': stats.cameraTranslations,
        'favoriteTranslations': stats.favoriteTranslations,
        'averageTranslationsPerDay': stats.averageTranslationsPerDay,
        'topLanguages': stats.topLanguages,
        'languageUsage': stats.languageUsage,
        'typeDistribution': stats.typeDistribution,
      },
      'languagePairs': languagePairs
          .map((pair) => {
                'sourceLang': pair.sourceLang,
                'targetLang': pair.targetLang,
                'count': pair.count,
                'percentage': pair.percentage,
                'lastUsed': pair.lastUsed.toIso8601String(),
              })
          .toList(),
      'insights': {
        'mostActiveTimeOfDay': insights.mostActiveTimeOfDay,
        'preferredLanguages': insights.preferredLanguages,
        'mostUsedTranslationType': insights.mostUsedTranslationType,
        'translationsPerDay': insights.translationsPerDay,
        'streak': insights.streak,
        'efficiencyMetrics': insights.efficiencyMetrics,
        'suggestions': insights.suggestions,
      },
      'featureUsage': _featureUsage,
    };
  }
}
