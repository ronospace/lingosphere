// 🌐 LingoSphere - Analytics Dashboard Screen
// Comprehensive analytics dashboard with charts, insights, and usage patterns

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/native_sharing_service.dart';
import '../../../shared/widgets/sharing/quick_share_button.dart';

/// Comprehensive analytics dashboard screen
class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  ConsumerState<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState
    extends ConsumerState<AnalyticsDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late TabController _tabController;

  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.week;
  final AnalyticsService _analyticsService = AnalyticsService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _tabController = TabController(length: 3, vsync: this);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        title: const Text(
          'Analytics & Insights',
          style: TextStyle(
            fontFamily: AppTheme.headingFontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.gray900,
        elevation: 0,
        actions: [
          PopupMenuButton<AnalyticsPeriod>(
            onSelected: (period) {
              setState(() {
                _selectedPeriod = period;
              });
            },
            itemBuilder: (context) => AnalyticsPeriod.values
                .map(
                  (period) => PopupMenuItem(
                    value: period,
                    child: Text(_getPeriodLabel(period)),
                  ),
                )
                .toList(),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getPeriodLabel(_selectedPeriod),
                    style: const TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: AppTheme.primaryBlue,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: AppTheme.gray600,
          indicatorColor: AppTheme.primaryBlue,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Languages'),
            Tab(text: 'Insights'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildLanguagesTab(),
          _buildInsightsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final stats = _analyticsService.getMockStats();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: AnimationLimiter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimationConfiguration.staggeredList(
                  position: 0,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildStatsOverview(stats),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AnimationConfiguration.staggeredList(
                  position: 1,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildUsageChart(stats),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AnimationConfiguration.staggeredList(
                  position: 2,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildTypeDistributionChart(stats),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AnimationConfiguration.staggeredList(
                  position: 3,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildQuickStats(stats),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguagesTab() {
    final stats = _analyticsService.getMockStats();
    final languagePairs = _analyticsService.getMockLanguagePairStats();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: AnimationLimiter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimationConfiguration.staggeredList(
                  position: 0,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildLanguageDistributionChart(stats),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AnimationConfiguration.staggeredList(
                  position: 1,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildLanguagePairsList(languagePairs),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AnimationConfiguration.staggeredList(
                  position: 2,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildTopLanguages(stats),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInsightsTab() {
    final insights = _analyticsService.getMockUserInsights();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: AnimationLimiter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimationConfiguration.staggeredList(
                  position: 0,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildUserBehaviorCard(insights),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AnimationConfiguration.staggeredList(
                  position: 1,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildEfficiencyMetrics(insights),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AnimationConfiguration.staggeredList(
                  position: 2,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildSuggestionsCard(insights),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AnimationConfiguration.staggeredList(
                  position: 3,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildStreakCard(insights),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsOverview(TranslationStats stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: AppTheme.primaryGradient,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.analytics_outlined,
                  color: AppTheme.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Translation Overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.white,
                      fontFamily: AppTheme.headingFontFamily,
                    ),
                  ),
                ),
                QuickShareButton.forAnalytics(
                  content: ShareContent(
                    type: ShareContentType.text,
                    text: 'Analytics Data for $_selectedPeriod\n\n' +
                        'Total Translations: ${stats.totalTranslations}\n' +
                        'Daily Average: ${stats.averageTranslationsPerDay.toStringAsFixed(1)}\n' +
                        'Favorites: ${stats.favoriteTranslations}',
                    subject: 'LingoSphere Analytics Report',
                    metadata:
                        _analyticsService.exportAnalyticsData(_selectedPeriod),
                  ),
                  size: QuickShareSize.small,
                  primaryColor: AppTheme.white,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total',
                    '${stats.totalTranslations}',
                    'translations',
                    AppTheme.white,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Daily Avg',
                    '${stats.averageTranslationsPerDay.toStringAsFixed(1)}',
                    'per day',
                    AppTheme.white,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Favorites',
                    '${stats.favoriteTranslations}',
                    'saved',
                    AppTheme.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, String subtitle, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: AppTheme.primaryFontFamily,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color.withValues(alpha: 0.9),
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: color.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildUsageChart(TranslationStats stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.gray900,
                fontFamily: AppTheme.headingFontFamily,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const style = TextStyle(
                            color: AppTheme.gray600,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          );
                          String text;
                          switch (value.toInt()) {
                            case 0:
                              text = 'Mon';
                              break;
                            case 1:
                              text = 'Tue';
                              break;
                            case 2:
                              text = 'Wed';
                              break;
                            case 3:
                              text = 'Thu';
                              break;
                            case 4:
                              text = 'Fri';
                              break;
                            case 5:
                              text = 'Sat';
                              break;
                            case 6:
                              text = 'Sun';
                              break;
                            default:
                              text = '';
                          }
                          return Text(text, style: style);
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: stats.dailyUsage.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(),
                            entry.value.translations.toDouble());
                      }).toList(),
                      isCurved: true,
                      gradient: AppTheme.primaryGradient,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppTheme.primaryBlue,
                            strokeColor: AppTheme.white,
                            strokeWidth: 2,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.primaryBlue.withValues(alpha: 0.3),
                            AppTheme.primaryBlue.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeDistributionChart(TranslationStats stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Translation Types',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.gray900,
                fontFamily: AppTheme.headingFontFamily,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 150,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(
                            value: stats.textTranslations.toDouble(),
                            title: '${stats.textTranslations}',
                            color: AppTheme.primaryBlue,
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: stats.voiceTranslations.toDouble(),
                            title: '${stats.voiceTranslations}',
                            color: AppTheme.vibrantGreen,
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: stats.cameraTranslations.toDouble(),
                            title: '${stats.cameraTranslations}',
                            color: AppTheme.accentTeal,
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTypeLegend(
                          'Text', stats.textTranslations, AppTheme.primaryBlue),
                      const SizedBox(height: 12),
                      _buildTypeLegend('Voice', stats.voiceTranslations,
                          AppTheme.vibrantGreen),
                      const SizedBox(height: 12),
                      _buildTypeLegend('Camera', stats.cameraTranslations,
                          AppTheme.accentTeal),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeLegend(String type, int count, Color color) {
    final total = count;
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gray800,
                ),
              ),
              Text(
                '$count translations',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.gray600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(TranslationStats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickStatCard(
            'Languages',
            stats.topLanguages.length.toString(),
            Icons.language,
            AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickStatCard(
            'Avg/Day',
            stats.averageTranslationsPerDay.toStringAsFixed(1),
            Icons.trending_up,
            AppTheme.vibrantGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickStatCard(
            'Favorites',
            stats.favoriteTranslations.toString(),
            Icons.favorite,
            AppTheme.errorRed,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withValues(alpha: 0.05),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: AppTheme.primaryFontFamily,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageDistributionChart(TranslationStats stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Language Usage Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.gray900,
                fontFamily: AppTheme.headingFontFamily,
              ),
            ),
            const SizedBox(height: 20),
            ...stats.languageUsage.entries
                .take(5)
                .map((entry) => _buildLanguageBar(
                    entry.key, entry.value, stats.totalTranslations))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageBar(String languageCode, int count, int total) {
    final percentage = (count / total * 100).round();
    final languageName = AppConstants.supportedLanguages[languageCode] ??
        languageCode.toUpperCase();
    final colors = [
      AppTheme.primaryBlue,
      AppTheme.vibrantGreen,
      AppTheme.accentTeal,
      AppTheme.warningAmber,
      AppTheme.successGreen,
    ];
    final color = colors[languageCode.hashCode % colors.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    languageCode.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  languageName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray800,
                  ),
                ),
              ),
              Text(
                '$count ($percentage%)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: count / total,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagePairsList(List<LanguagePairStats> languagePairs) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Language Pairs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.gray900,
                fontFamily: AppTheme.headingFontFamily,
              ),
            ),
            const SizedBox(height: 16),
            ...languagePairs
                .take(5)
                .map((pair) => _buildLanguagePairItem(pair))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagePairItem(LanguagePairStats pair) {
    final sourceLanguage = AppConstants.supportedLanguages[pair.sourceLang] ??
        pair.sourceLang.toUpperCase();
    final targetLanguage = AppConstants.supportedLanguages[pair.targetLang] ??
        pair.targetLang.toUpperCase();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${pair.sourceLang.toUpperCase()} → ${pair.targetLang.toUpperCase()}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$sourceLanguage → $targetLanguage',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.gray800,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${pair.count}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.gray900,
                ),
              ),
              Text(
                '${pair.percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.gray600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopLanguages(TranslationStats stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Language Discovery',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.gray900,
                fontFamily: AppTheme.headingFontFamily,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: stats.topLanguages.map((lang) {
                final languageName =
                    AppConstants.supportedLanguages[lang] ?? lang.toUpperCase();
                return Chip(
                  label: Text(languageName),
                  backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  labelStyle: const TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserBehaviorCard(UserInsights insights) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Usage Patterns',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.gray900,
                fontFamily: AppTheme.headingFontFamily,
              ),
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              'Most Active Time',
              insights.mostActiveTimeOfDay,
              Icons.access_time,
              AppTheme.primaryBlue,
            ),
            _buildInsightItem(
              'Preferred Translation',
              insights.mostUsedTranslationType.toUpperCase(),
              Icons.translate,
              AppTheme.vibrantGreen,
            ),
            _buildInsightItem(
              'Daily Average',
              '${insights.translationsPerDay.toStringAsFixed(1)} translations',
              Icons.trending_up,
              AppTheme.accentTeal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEfficiencyMetrics(UserInsights insights) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Efficiency Metrics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.gray900,
                fontFamily: AppTheme.headingFontFamily,
              ),
            ),
            const SizedBox(height: 16),
            _buildMetricBar(
              'Favorite Rate',
              insights.efficiencyMetrics['favoriteRate']!,
              AppTheme.errorRed,
              '${(insights.efficiencyMetrics['favoriteRate']! * 100).round()}%',
            ),
            _buildMetricBar(
              'Language Diversity',
              insights.efficiencyMetrics['diversityScore']! / 10,
              AppTheme.primaryBlue,
              '${insights.efficiencyMetrics['diversityScore']!.round()} languages',
            ),
            _buildMetricBar(
              'Consistency Score',
              insights.efficiencyMetrics['consistencyScore']! / 30,
              AppTheme.vibrantGreen,
              '${insights.efficiencyMetrics['consistencyScore']!.round()} days',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBar(
      String label, double value, Color color, String display) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gray800,
                ),
              ),
              const Spacer(),
              Text(
                display,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsCard(UserInsights insights) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personalized Suggestions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.gray900,
                fontFamily: AppTheme.headingFontFamily,
              ),
            ),
            const SizedBox(height: 16),
            ...insights.suggestions
                .map((suggestion) => _buildSuggestionItem(suggestion))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(String suggestion) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppTheme.primaryBlue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              suggestion,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.gray700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(UserInsights insights) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.vibrantGreen.withValues(alpha: 0.1),
              AppTheme.vibrantGreen.withValues(alpha: 0.05),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.vibrantGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.local_fire_department,
                color: AppTheme.vibrantGreen,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${insights.streak} Day Streak!',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.vibrantGreen,
                      fontFamily: AppTheme.headingFontFamily,
                    ),
                  ),
                  const Text(
                    'Keep up the great work translating daily',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.gray700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(
      String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.gray600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gray900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getPeriodLabel(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.today:
        return 'Today';
      case AnalyticsPeriod.week:
        return 'Week';
      case AnalyticsPeriod.month:
        return 'Month';
      case AnalyticsPeriod.quarter:
        return 'Quarter';
      case AnalyticsPeriod.year:
        return 'Year';
      case AnalyticsPeriod.allTime:
        return 'All Time';
    }
  }
}
