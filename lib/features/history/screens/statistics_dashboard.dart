// 🌐 LingoSphere - Translation Statistics Dashboard
// Analytics showing usage patterns, languages, accuracy trends, and productivity metrics

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/services/history_service.dart';
import '../../../core/models/translation_history.dart';
import '../../../core/models/common_models.dart';

/// Statistics data models
class TranslationStats {
  final int totalTranslations;
  final int todayTranslations;
  final int thisWeekTranslations;
  final int thisMonthTranslations;
  final double averageConfidence;
  final String mostUsedSourceLanguage;
  final String mostUsedTargetLanguage;
  final Map<String, int> languagePairCounts;
  final Map<TranslationEngineSource, int> sourceCounts;
  final Map<String, int> dailyActivity;
  final Map<String, int> categoryDistribution;
  final List<double> confidenceTrend;
  final Map<String, double> productivityMetrics;
  final int favoriteCount;
  final double averageWordLength;

  TranslationStats({
    required this.totalTranslations,
    required this.todayTranslations,
    required this.thisWeekTranslations,
    required this.thisMonthTranslations,
    required this.averageConfidence,
    required this.mostUsedSourceLanguage,
    required this.mostUsedTargetLanguage,
    required this.languagePairCounts,
    required this.sourceCounts,
    required this.dailyActivity,
    required this.categoryDistribution,
    required this.confidenceTrend,
    required this.productivityMetrics,
    required this.favoriteCount,
    required this.averageWordLength,
  });
}

/// Statistics dashboard screen
class StatisticsDashboard extends StatefulWidget {
  final HistoryService historyService;

  const StatisticsDashboard({
    super.key,
    required this.historyService,
  });

  @override
  State<StatisticsDashboard> createState() => _StatisticsDashboardState();
}

class _StatisticsDashboardState extends State<StatisticsDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  TranslationStats? _stats;
  bool _isLoading = true;
  String? _error;
  DateRange _selectedPeriod = DateRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Use the searchHistory method with individual parameters
      final history = await widget.historyService.searchHistory(
        dateRange: _selectedPeriod,
        limit: 10000, // Get all entries within the period
      );
      final allHistory = await widget.historyService.searchHistory(
        limit: 10000, // Get all entries
      );

      _stats = await _buildStatistics(history, allHistory);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load statistics: $e';
      });
    }
  }

  Future<TranslationStats> _buildStatistics(
    List<HistoryEntry> periodHistory,
    List<HistoryEntry> allHistory,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    // Count translations by period
    final todayCount =
        allHistory.where((h) => h.timestamp.isAfter(today)).length;
    final weekCount =
        allHistory.where((h) => h.timestamp.isAfter(weekStart)).length;
    final monthCount =
        allHistory.where((h) => h.timestamp.isAfter(monthStart)).length;

    // Calculate average confidence
    final totalConfidence =
        periodHistory.fold<double>(0, (sum, h) => sum + h.confidence);
    final avgConfidence =
        periodHistory.isNotEmpty ? totalConfidence / periodHistory.length : 0.0;

    // Language pair analysis
    final languagePairs = <String, int>{};
    final sourceLangCounts = <String, int>{};
    final targetLangCounts = <String, int>{};

    for (final h in periodHistory) {
      final pair = '${h.sourceLanguage}-${h.targetLanguage}';
      languagePairs[pair] = (languagePairs[pair] ?? 0) + 1;
      sourceLangCounts[h.sourceLanguage] =
          (sourceLangCounts[h.sourceLanguage] ?? 0) + 1;
      targetLangCounts[h.targetLanguage] =
          (targetLangCounts[h.targetLanguage] ?? 0) + 1;
    }

    final mostUsedSource = sourceLangCounts.isNotEmpty
        ? sourceLangCounts.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key
        : 'N/A';
    final mostUsedTarget = targetLangCounts.isNotEmpty
        ? targetLangCounts.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key
        : 'N/A';

    // Source type analysis
    final sourceCounts = <TranslationEngineSource, int>{};
    for (final h in periodHistory) {
      final source = h.translationSource;
      sourceCounts[source] = (sourceCounts[source] ?? 0) + 1;
    }

    // Daily activity
    final dailyActivity = <String, int>{};
    for (final h in periodHistory) {
      final day =
          '${h.timestamp.year}-${h.timestamp.month.toString().padLeft(2, '0')}-${h.timestamp.day.toString().padLeft(2, '0')}';
      dailyActivity[day] = (dailyActivity[day] ?? 0) + 1;
    }

    // Category distribution
    final categories = <String, int>{};
    for (final h in periodHistory) {
      if (h.category != null) {
        categories[h.category!] = (categories[h.category!] ?? 0) + 1;
      }
    }

    // Confidence trend (last 7 days)
    final confidenceTrend = <double>[];
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayTranslations = allHistory
          .where((h) =>
              h.timestamp.isAfter(dayStart) && h.timestamp.isBefore(dayEnd))
          .toList();

      final dayAvgConfidence = dayTranslations.isNotEmpty
          ? dayTranslations.fold<double>(0, (sum, h) => sum + h.confidence) /
              dayTranslations.length
          : 0.0;

      confidenceTrend.add(dayAvgConfidence);
    }

    // Productivity metrics
    final totalWords = periodHistory.fold<int>(
        0, (sum, h) => sum + h.originalText.split(RegExp(r'\W+')).length);
    final avgWordLength =
        periodHistory.isNotEmpty ? totalWords / periodHistory.length : 0.0;

    final productivityMetrics = {
      'translationsPerDay': periodHistory.length / 30.0,
      'averageWordLength': avgWordLength,
      'favoriteRate': periodHistory.isNotEmpty
          ? periodHistory.where((h) => h.isFavorite).length /
              periodHistory.length
          : 0.0,
      'highConfidenceRate': periodHistory.isNotEmpty
          ? periodHistory.where((h) => h.confidence > 0.8).length /
              periodHistory.length
          : 0.0,
    };

    final favoriteCount = periodHistory.where((h) => h.isFavorite).length;

    return TranslationStats(
      totalTranslations: periodHistory.length,
      todayTranslations: todayCount,
      thisWeekTranslations: weekCount,
      thisMonthTranslations: monthCount,
      averageConfidence: avgConfidence,
      mostUsedSourceLanguage: mostUsedSource,
      mostUsedTargetLanguage: mostUsedTarget,
      languagePairCounts: languagePairs,
      sourceCounts: sourceCounts,
      dailyActivity: dailyActivity,
      categoryDistribution: categories,
      confidenceTrend: confidenceTrend,
      productivityMetrics: productivityMetrics,
      favoriteCount: favoriteCount,
      averageWordLength: avgWordLength,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Translation Statistics',
          style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.gray900,
        iconTheme: const IconThemeData(color: AppTheme.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _showPeriodSelector,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.vibrantGreen,
          unselectedLabelColor: AppTheme.gray400,
          indicatorColor: AppTheme.vibrantGreen,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Languages'),
            Tab(text: 'Activity'),
            Tab(text: 'Trends'),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.vibrantGreen),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppTheme.errorRed, size: 64),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: AppTheme.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStatistics,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.vibrantGreen,
              ),
              child:
                  const Text('Retry', style: TextStyle(color: AppTheme.white)),
            ),
          ],
        ),
      );
    }

    if (_stats == null) {
      return const Center(
        child: Text(
          'No statistics available',
          style: TextStyle(color: AppTheme.gray400, fontSize: 16),
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildLanguagesTab(),
        _buildActivityTab(),
        _buildTrendsTab(),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Summary cards
          _buildSummaryCards(),
          const SizedBox(height: 24),

          // Confidence gauge
          _buildConfidenceGauge(),
          const SizedBox(height: 24),

          // Source distribution
          _buildSourceDistribution(),
          const SizedBox(height: 24),

          // Productivity metrics
          _buildProductivityMetrics(),
        ],
      ),
    );
  }

  Widget _buildLanguagesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Top language pairs
          _buildTopLanguagePairs(),
          const SizedBox(height: 24),

          // Language distribution pie chart
          _buildLanguageDistribution(),
          const SizedBox(height: 24),

          // Category breakdown
          _buildCategoryBreakdown(),
        ],
      ),
    );
  }

  Widget _buildActivityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Daily activity chart
          _buildDailyActivityChart(),
          const SizedBox(height: 24),

          // Activity heatmap
          _buildActivityHeatmap(),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Confidence trend
          _buildConfidenceTrend(),
          const SizedBox(height: 24),

          // Usage patterns
          _buildUsagePatterns(),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total',
            _stats!.totalTranslations.toString(),
            Icons.translate,
            AppTheme.vibrantGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Today',
            _stats!.todayTranslations.toString(),
            Icons.today,
            AppTheme.twitterBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'This Week',
            _stats!.thisWeekTranslations.toString(),
            Icons.calendar_view_week,
            AppTheme.vibrantOrange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Favorites',
            _stats!.favoriteCount.toString(),
            Icons.favorite,
            AppTheme.errorRed,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.gray900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: AppTheme.gray400,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceGauge() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.gray900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Average Confidence',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 80,
                startDegreeOffset: -90,
                sections: [
                  PieChartSectionData(
                    color: AppTheme.vibrantGreen,
                    value: _stats!.averageConfidence * 100,
                    title: '',
                    radius: 20,
                  ),
                  PieChartSectionData(
                    color: AppTheme.gray600,
                    value: (1 - _stats!.averageConfidence) * 100,
                    title: '',
                    radius: 20,
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Text(
              '${(_stats!.averageConfidence * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                color: AppTheme.vibrantGreen,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceDistribution() {
    final sources = _stats!.sourceCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.gray900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Translation Sources',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...sources.map((entry) => _buildSourceItem(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildSourceItem(TranslationEngineSource source, int count) {
    final total = _stats!.totalTranslations;
    final percentage = total > 0 ? (count / total) * 100 : 0.0;

    Color color;
    IconData icon;
    String label;

    switch (source) {
      case TranslationEngineSource.camera:
        color = AppTheme.vibrantGreen;
        icon = Icons.camera_alt;
        label = 'Camera';
        break;
      case TranslationEngineSource.voice:
        color = AppTheme.twitterBlue;
        icon = Icons.mic;
        label = 'Voice';
        break;
      case TranslationEngineSource.file:
        color = AppTheme.errorRed;
        icon = Icons.insert_drive_file;
        label = 'File';
        break;
      case TranslationEngineSource.text:
        color = AppTheme.gray400;
        icon = Icons.text_fields;
        label = 'Text';
        break;
      case TranslationEngineSource.manual:
        color = AppTheme.vibrantOrange;
        icon = Icons.edit;
        label = 'Manual';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: AppTheme.white, fontSize: 14),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: AppTheme.gray700,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildProductivityMetrics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.gray900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Productivity Metrics',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Daily Average',
                  _stats!.productivityMetrics['translationsPerDay']!
                      .toStringAsFixed(1),
                  Icons.trending_up,
                  AppTheme.vibrantGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricItem(
                  'Avg Words',
                  _stats!.averageWordLength.toStringAsFixed(1),
                  Icons.text_snippet,
                  AppTheme.twitterBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Favorite Rate',
                  '${(_stats!.productivityMetrics['favoriteRate']! * 100).toStringAsFixed(1)}%',
                  Icons.favorite,
                  AppTheme.errorRed,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricItem(
                  'High Confidence',
                  '${(_stats!.productivityMetrics['highConfidenceRate']! * 100).toStringAsFixed(1)}%',
                  Icons.star,
                  AppTheme.vibrantOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.gray400,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTopLanguagePairs() {
    final topPairs = _stats!.languagePairCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final displayPairs = topPairs.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.gray900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Language Pairs',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...displayPairs.asMap().entries.map((entry) {
            final index = entry.key;
            final pair = entry.value;
            final colors = [
              AppTheme.vibrantGreen,
              AppTheme.twitterBlue,
              AppTheme.vibrantOrange,
              AppTheme.errorRed,
              AppTheme.gray400,
            ];

            return _buildLanguagePairItem(
              pair.key,
              pair.value,
              colors[index % colors.length],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLanguagePairItem(String pair, int count, Color color) {
    final parts = pair.split('-');
    final percentage = _stats!.totalTranslations > 0
        ? (count / _stats!.totalTranslations) * 100
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${parts[0].toUpperCase()} → ${parts[1].toUpperCase()}',
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count translations (${percentage.toStringAsFixed(1)}%)',
                  style: const TextStyle(
                    color: AppTheme.gray400,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDistribution() {
    // Placeholder for pie chart - would implement with fl_chart
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.gray900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Most Used Languages',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildLanguageItem(
                  'Source',
                  _stats!.mostUsedSourceLanguage,
                  AppTheme.vibrantGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildLanguageItem(
                  'Target',
                  _stats!.mostUsedTargetLanguage,
                  AppTheme.twitterBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageItem(String type, String language, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            type,
            style: const TextStyle(
              color: AppTheme.gray400,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            language.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    final categories = _stats!.categoryDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.gray900,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'No categories found',
          style: TextStyle(color: AppTheme.gray400),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.gray900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...categories
              .take(5)
              .map((entry) => _buildCategoryItem(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String category, int count) {
    final percentage = _stats!.totalTranslations > 0
        ? (count / _stats!.totalTranslations) * 100
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              category,
              style: const TextStyle(color: AppTheme.white, fontSize: 14),
            ),
          ),
          Text(
            '$count (${percentage.toStringAsFixed(1)}%)',
            style: const TextStyle(color: AppTheme.gray400, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyActivityChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.gray900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Activity',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppTheme.gray700,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                            color: AppTheme.gray400, fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _buildDailyActivitySpots(),
                    isCurved: true,
                    color: AppTheme.vibrantGreen,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.vibrantGreen.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _buildDailyActivitySpots() {
    final sortedDays = _stats!.dailyActivity.keys.toList()..sort();
    return sortedDays.asMap().entries.map((entry) {
      final index = entry.key;
      final day = entry.value;
      final count = _stats!.dailyActivity[day] ?? 0;
      return FlSpot(index.toDouble(), count.toDouble());
    }).toList();
  }

  Widget _buildActivityHeatmap() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.gray900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Heatmap',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Activity heatmap coming soon...',
            style: TextStyle(color: AppTheme.gray400),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceTrend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.gray900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Confidence Trend (Last 7 Days)',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppTheme.gray700,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text(
                        '${(value * 100).toInt()}%',
                        style: const TextStyle(
                            color: AppTheme.gray400, fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: 1,
                lineBarsData: [
                  LineChartBarData(
                    spots: _stats!.confidenceTrend
                        .asMap()
                        .entries
                        .map((entry) =>
                            FlSpot(entry.key.toDouble(), entry.value))
                        .toList(),
                    isCurved: true,
                    color: AppTheme.twitterBlue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.twitterBlue.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsagePatterns() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.gray900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Usage Patterns',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Advanced usage pattern analysis coming soon...',
            style: TextStyle(color: AppTheme.gray400),
          ),
        ],
      ),
    );
  }

  void _showPeriodSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.gray900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Period',
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.today, color: AppTheme.vibrantGreen),
              title: const Text('Last 7 days',
                  style: TextStyle(color: AppTheme.white)),
              onTap: () {
                setState(() {
                  _selectedPeriod = DateRange(
                    start: DateTime.now().subtract(const Duration(days: 7)),
                    end: DateTime.now(),
                  );
                });
                Navigator.pop(context);
                _loadStatistics();
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.calendar_month, color: AppTheme.twitterBlue),
              title: const Text('Last 30 days',
                  style: TextStyle(color: AppTheme.white)),
              onTap: () {
                setState(() {
                  _selectedPeriod = DateRange(
                    start: DateTime.now().subtract(const Duration(days: 30)),
                    end: DateTime.now(),
                  );
                });
                Navigator.pop(context);
                _loadStatistics();
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_view_month,
                  color: AppTheme.vibrantOrange),
              title: const Text('Last 90 days',
                  style: TextStyle(color: AppTheme.white)),
              onTap: () {
                setState(() {
                  _selectedPeriod = DateRange(
                    start: DateTime.now().subtract(const Duration(days: 90)),
                    end: DateTime.now(),
                  );
                });
                Navigator.pop(context);
                _loadStatistics();
              },
            ),
          ],
        ),
      ),
    );
  }
}
