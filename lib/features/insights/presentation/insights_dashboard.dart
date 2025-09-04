// 🌐 LingoSphere - Conversation Insights & Analytics Dashboard
// Advanced analytics dashboard with usage statistics and performance metrics

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/models/analytics_models.dart';
import '../../../core/providers/app_providers.dart';

class InsightsDashboard extends ConsumerStatefulWidget {
  const InsightsDashboard({super.key});

  @override
  ConsumerState<InsightsDashboard> createState() => _InsightsDashboardState();
}

class _InsightsDashboardState extends ConsumerState<InsightsDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _chartAnimationController;
  late AnimationController _cardAnimationController;
  
  late Animation<double> _chartAnimation;
  late Animation<double> _cardAnimation;

  String _selectedPeriod = '7d';
  bool _isLoading = true;
  
  // Analytics data
  UsageAnalytics? _usageData;
  PerformanceMetrics? _performanceData;
  List<LanguageUsageStats> _languageStats = [];
  List<ConversationInsight> _conversationInsights = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _chartAnimation = CurvedAnimation(
      parent: _chartAnimationController,
      curve: Curves.easeOutCubic,
    );
    _cardAnimation = CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutBack,
    );
    
    _loadAnalyticsData();
    _cardAnimationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chartAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalyticsData() async {
    try {
      setState(() => _isLoading = true);
      
      final analyticsService = ref.read(analyticsServiceProvider);
      
      // Load different analytics data
      final results = await Future.wait([
        analyticsService.getUsageAnalytics(_selectedPeriod),
        analyticsService.getPerformanceMetrics(_selectedPeriod),
        analyticsService.getLanguageUsageStats(_selectedPeriod),
        analyticsService.getConversationInsights(_selectedPeriod),
      ]);
      
      if (mounted) {
        setState(() {
          _usageData = results[0] as UsageAnalytics;
          _performanceData = results[1] as PerformanceMetrics;
          _languageStats = results[2] as List<LanguageUsageStats>;
          _conversationInsights = results[3] as List<ConversationInsight>;
          _isLoading = false;
        });
        
        _chartAnimationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading analytics: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildPeriodSelector(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildLanguagesTab(),
                  _buildPerformanceTab(),
                  _buildInsightsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insights,
                color: AppTheme.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Insights & Analytics',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.white,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppTheme.white),
                onPressed: _loadAnalyticsData,
              ),
            ],
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.white,
            labelColor: AppTheme.white,
            unselectedLabelColor: AppTheme.white.withValues(alpha: 0.7),
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            isScrollable: true,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Languages'),
              Tab(text: 'Performance'),
              Tab(text: 'Insights'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text(
            'Period: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray700,
            ),
          ),
          const SizedBox(width: 12),
          ...['24h', '7d', '30d', '90d'].map((period) => 
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(period),
                selected: _selectedPeriod == period,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedPeriod = period);
                    _loadAnalyticsData();
                  }
                },
                backgroundColor: AppTheme.gray100,
                selectedColor: AppTheme.vibrantGreen.withValues(alpha: 0.2),
                checkmarkColor: AppTheme.vibrantGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.vibrantGreen),
      );
    }

    return AnimationLimiter(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            horizontalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            _buildStatsGrid(),
            const SizedBox(height: 20),
            _buildUsageChart(),
            const SizedBox(height: 20),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      StatCard(
        'Total Translations',
        _usageData?.totalTranslations.toString() ?? '0',
        Icons.translate,
        AppTheme.primaryBlue,
        '+${_usageData?.translationsGrowth ?? 0}%',
      ),
      StatCard(
        'Languages Used',
        _usageData?.languagesUsed.toString() ?? '0',
        Icons.language,
        AppTheme.vibrantGreen,
        '${_languageStats.length} active',
      ),
      StatCard(
        'Avg. Confidence',
        '${_usageData?.averageConfidence ?? 0}%',
        Icons.verified,
        AppTheme.accentTeal,
        _getConfidenceLabel(_usageData?.averageConfidence ?? 0),
      ),
      StatCard(
        'Success Rate',
        '${_usageData?.successRate ?? 0}%',
        Icons.check_circle,
        AppTheme.successGreen,
        _getSuccessRateLabel(_usageData?.successRate ?? 0),
      ),
    ];

    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimation.value,
          child: Opacity(
            opacity: _cardAnimation.value,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemCount: stats.length,
              itemBuilder: (context, index) {
                final stat = stats[index];
                return _buildStatCard(stat);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(StatCard stat) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              stat.color.withValues(alpha: 0.1),
              stat.color.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(stat.icon, color: stat.color, size: 24),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: stat.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    stat.subtitle,
                    style: TextStyle(
                      color: stat.color,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              stat.value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.gray900,
              ),
            ),
            Text(
              stat.title,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.gray600,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                const Text(
                  'Translation Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray900,
                  ),
                ),
                const Spacer(),
                Text(
                  'Last ${_selectedPeriod}',
                  style: const TextStyle(
                    color: AppTheme.gray500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, child) {
                return Container(
                  height: 200,
                  child: CustomPaint(
                    painter: UsageChartPainter(
                      data: _usageData?.dailyUsage ?? [],
                      progress: _chartAnimation.value,
                    ),
                    size: Size.infinite,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history, color: AppTheme.accentTeal),
                SizedBox(width: 8),
                Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_usageData?.recentTranslations.isEmpty ?? true)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No recent translations',
                    style: TextStyle(color: AppTheme.gray500),
                  ),
                ),
              )
            else
              ...(_usageData!.recentTranslations.take(5).map((translation) =>
                  _buildActivityItem(translation))),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(RecentTranslation translation) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _getTranslationMethodIcon(translation.method),
              color: AppTheme.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  translation.originalText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.gray800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${translation.sourceLanguage} → ${translation.targetLanguage}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.gray500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatTimeAgo(translation.timestamp),
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.gray400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagesTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.vibrantGreen),
      );
    }

    return AnimationLimiter(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            horizontalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            _buildLanguageDistributionChart(),
            const SizedBox(height: 20),
            _buildLanguageList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageDistributionChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.pie_chart, color: AppTheme.vibrantGreen),
                SizedBox(width: 8),
                Text(
                  'Language Distribution',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, child) {
                return Container(
                  height: 200,
                  child: CustomPaint(
                    painter: LanguagePieChartPainter(
                      data: _languageStats,
                      progress: _chartAnimation.value,
                    ),
                    size: Size.infinite,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageList() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.language, color: AppTheme.accentTeal),
                SizedBox(width: 8),
                Text(
                  'Language Usage',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._languageStats.map((stat) => _buildLanguageItem(stat)),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageItem(LanguageUsageStats stat) {
    final percentage = (stat.usage / _languageStats.first.usage * 100);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: stat.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    stat.languageCode.toUpperCase(),
                    style: TextStyle(
                      color: stat.color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat.languageName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.gray800,
                      ),
                    ),
                    Text(
                      '${stat.usage} translations',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${percentage.toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gray700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _chartAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: percentage / 100 * _chartAnimation.value,
                backgroundColor: AppTheme.gray200,
                valueColor: AlwaysStoppedAnimation(stat.color),
                minHeight: 4,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.vibrantGreen),
      );
    }

    return AnimationLimiter(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            horizontalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            _buildPerformanceMetrics(),
            const SizedBox(height: 20),
            _buildResponseTimeChart(),
            const SizedBox(height: 20),
            _buildQualityMetrics(),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    final metrics = [
      MetricCard(
        'Avg Response Time',
        '${_performanceData?.averageResponseTime ?? 0}ms',
        Icons.speed,
        AppTheme.primaryBlue,
      ),
      MetricCard(
        'Success Rate',
        '${_performanceData?.successRate ?? 0}%',
        Icons.check_circle,
        AppTheme.successGreen,
      ),
      MetricCard(
        'Error Rate',
        '${_performanceData?.errorRate ?? 0}%',
        Icons.error,
        AppTheme.errorRed,
      ),
      MetricCard(
        'Cache Hit Rate',
        '${_performanceData?.cacheHitRate ?? 0}%',
        Icons.cached,
        AppTheme.accentTeal,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.8,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return _buildMetricCard(metric);
      },
    );
  }

  Widget _buildMetricCard(MetricCard metric) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              metric.color.withValues(alpha: 0.1),
              metric.color.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(metric.icon, color: metric.color, size: 24),
            const Spacer(),
            Text(
              metric.value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.gray900,
              ),
            ),
            Text(
              metric.title,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.gray600,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseTimeChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.timeline, color: AppTheme.primaryBlue),
                SizedBox(width: 8),
                Text(
                  'Response Time Trend',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, child) {
                return Container(
                  height: 180,
                  child: CustomPaint(
                    painter: ResponseTimeChartPainter(
                      data: _performanceData?.responseTimeTrend ?? [],
                      progress: _chartAnimation.value,
                    ),
                    size: Size.infinite,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityMetrics() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.high_quality, color: AppTheme.vibrantGreen),
                SizedBox(width: 8),
                Text(
                  'Translation Quality',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildQualityItem('High Confidence', 
                _performanceData?.highConfidenceRate ?? 0, AppTheme.successGreen),
            _buildQualityItem('Medium Confidence', 
                _performanceData?.mediumConfidenceRate ?? 0, AppTheme.warningAmber),
            _buildQualityItem('Low Confidence', 
                _performanceData?.lowConfidenceRate ?? 0, AppTheme.errorRed),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityItem(String label, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.gray700,
                ),
              ),
              const Spacer(),
              Text(
                '${percentage.toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          AnimatedBuilder(
            animation: _chartAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: percentage / 100 * _chartAnimation.value,
                backgroundColor: AppTheme.gray200,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 6,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.vibrantGreen),
      );
    }

    return AnimationLimiter(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            horizontalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            _buildConversationInsights(),
            const SizedBox(height: 20),
            _buildUsagePatterns(),
            const SizedBox(height: 20),
            _buildRecommendations(),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationInsights() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.psychology, color: AppTheme.primaryBlue),
                SizedBox(width: 8),
                Text(
                  'Conversation Insights',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_conversationInsights.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No conversation insights available yet',
                    style: TextStyle(color: AppTheme.gray500),
                  ),
                ),
              )
            else
              ..._conversationInsights.map((insight) => _buildInsightItem(insight)),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(ConversationInsight insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: insight.type.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: insight.type.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                insight.type.icon,
                color: insight.type.color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                insight.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: insight.type.color,
                ),
              ),
              const Spacer(),
              if (insight.importance.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: insight.type.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    insight.importance.toUpperCase(),
                    style: TextStyle(
                      color: insight.type.color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            insight.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.gray700,
            ),
          ),
          if (insight.actionSuggestion.isNotEmpty) ...[ 
            const SizedBox(height: 8),
            Text(
              '💡 ${insight.actionSuggestion}',
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.gray600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUsagePatterns() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.pattern, color: AppTheme.accentTeal),
                SizedBox(width: 8),
                Text(
                  'Usage Patterns',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPatternItem(
              'Peak Usage Hours',
              '${_usageData?.peakHour ?? "N/A"} - Most active translation time',
              Icons.schedule,
              AppTheme.primaryBlue,
            ),
            _buildPatternItem(
              'Favorite Method',
              '${_usageData?.preferredMethod ?? "Text"} translation - ${_usageData?.methodUsagePercentage ?? 0}% of usage',
              Icons.favorite,
              AppTheme.vibrantGreen,
            ),
            _buildPatternItem(
              'Average Session',
              '${_usageData?.averageSessionLength ?? 0} minutes per session',
              Icons.timer,
              AppTheme.warningAmber,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternItem(String title, String description, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray800,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.gray600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    final recommendations = [
      'Try using voice translation for better accuracy in conversations',
      'Your most translated language pair is ES → EN. Consider saving favorites for quick access',
      'Translation confidence is highest during morning hours - optimal time for important translations',
      'Camera translation works best with clear, high-contrast text',
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb, color: AppTheme.warningAmber),
                SizedBox(width: 8),
                Text(
                  'Smart Recommendations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recommendations.asMap().entries.map((entry) {
              final index = entry.key;
              final recommendation = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppTheme.warningAmber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.warningAmber,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        recommendation,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.gray700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _getConfidenceLabel(double confidence) {
    if (confidence >= 90) return 'Excellent';
    if (confidence >= 80) return 'Good';
    if (confidence >= 70) return 'Average';
    return 'Needs Improvement';
  }

  String _getSuccessRateLabel(double rate) {
    if (rate >= 95) return 'Outstanding';
    if (rate >= 85) return 'Very Good';
    if (rate >= 75) return 'Good';
    return 'Improving';
  }

  IconData _getTranslationMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'voice':
        return Icons.mic;
      case 'camera':
        return Icons.camera_alt;
      case 'text':
        return Icons.text_fields;
      default:
        return Icons.translate;
    }
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

// Data classes for cards and metrics
class StatCard {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  StatCard(this.title, this.value, this.icon, this.color, this.subtitle);
}

class MetricCard {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  MetricCard(this.title, this.value, this.icon, this.color);
}

// Custom painters for charts
class UsageChartPainter extends CustomPainter {
  final List<DailyUsage> data;
  final double progress;

  UsageChartPainter({required this.data, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = AppTheme.primaryBlue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.primaryBlue.withValues(alpha: 0.3),
          AppTheme.primaryBlue.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final maxUsage = data.fold<double>(0, (max, usage) => math.max(max, usage.count.toDouble()));
    final path = Path();
    final gradientPath = Path();

    for (int i = 0; i < data.length; i++) {
      if (i / data.length > progress) break;

      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - (data[i].count / maxUsage) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
        gradientPath.moveTo(x, size.height);
        gradientPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        gradientPath.lineTo(x, y);
      }
    }

    gradientPath.lineTo(size.width * progress, size.height);
    gradientPath.close();

    canvas.drawPath(gradientPath, gradientPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant UsageChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.data != data;
  }
}

class LanguagePieChartPainter extends CustomPainter {
  final List<LanguageUsageStats> data;
  final double progress;

  LanguagePieChartPainter({required this.data, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;

    final total = data.fold<int>(0, (sum, stat) => sum + stat.usage);
    double startAngle = -math.pi / 2;

    for (final stat in data) {
      final sweepAngle = (stat.usage / total) * 2 * math.pi * progress;
      
      final paint = Paint()
        ..color = stat.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant LanguagePieChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.data != data;
  }
}

class ResponseTimeChartPainter extends CustomPainter {
  final List<ResponseTimePoint> data;
  final double progress;

  ResponseTimeChartPainter({required this.data, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = AppTheme.accentTeal
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final maxTime = data.fold<double>(0, (max, point) => math.max(max, point.responseTime));
    final path = Path();

    for (int i = 0; i < data.length; i++) {
      if (i / data.length > progress) break;

      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - (data[i].responseTime / maxTime) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ResponseTimeChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.data != data;
  }
}

// Extension for insight types
extension InsightTypeExtension on InsightType {
  Color get color {
    switch (this) {
      case InsightType.performance:
        return AppTheme.primaryBlue;
      case InsightType.usage:
        return AppTheme.vibrantGreen;
      case InsightType.quality:
        return AppTheme.warningAmber;
      case InsightType.recommendation:
        return AppTheme.accentTeal;
    }
  }

  IconData get icon {
    switch (this) {
      case InsightType.performance:
        return Icons.speed;
      case InsightType.usage:
        return Icons.trending_up;
      case InsightType.quality:
        return Icons.high_quality;
      case InsightType.recommendation:
        return Icons.lightbulb;
    }
  }
}
