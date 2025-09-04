// 🌐 LingoSphere - Enhanced Dashboard Home Screen
// Comprehensive feature hub with analytics, quick actions, and personalized content

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../../core/models/translation_entry.dart';
import '../../../shared/widgets/sharing/quick_share_button.dart';
import '../../translation/presentation/translation_screen.dart';
import '../../voice/presentation/voice_translation_screen.dart';
import '../../camera/presentation/camera_translation_screen.dart';

/// Enhanced dashboard home screen
class EnhancedDashboardScreen extends ConsumerStatefulWidget {
  const EnhancedDashboardScreen({super.key});

  @override
  ConsumerState<EnhancedDashboardScreen> createState() =>
      _EnhancedDashboardScreenState();
}

class _EnhancedDashboardScreenState
    extends ConsumerState<EnhancedDashboardScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _statsAnimationController;
  late ScrollController _scrollController;

  bool _isScrolled = false;

  // Mock data - in real implementation, these would come from providers/services
  List<TranslationEntry> _recentTranslations = [
    TranslationEntry(
      id: '1',
      sourceText: 'Hello, how are you today?',
      translatedText: 'Hola, ¿cómo estás hoy?',
      sourceLanguage: 'en',
      targetLanguage: 'es',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      type: TranslationMethod.text,
      isFavorite: true,
    ),
    TranslationEntry(
      id: '2',
      sourceText: 'Je voudrais un café, s\'il vous plaît',
      translatedText: 'I would like a coffee, please',
      sourceLanguage: 'fr',
      targetLanguage: 'en',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      type: TranslationMethod.voice,
      isFavorite: false,
    ),
    TranslationEntry(
      id: '3',
      sourceText: '今日は良い天気ですね',
      translatedText: 'The weather is nice today',
      sourceLanguage: 'ja',
      targetLanguage: 'en',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: TranslationMethod.camera,
      isFavorite: false,
    ),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _statsAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _statsAnimationController.forward();
    });
  }

  void _onScroll() {
    final isScrolled = _scrollController.offset > 50;
    if (isScrolled != _isScrolled) {
      setState(() {
        _isScrolled = isScrolled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppTheme.primaryBlue,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildSliverAppBar(),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildQuickStats(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildFeatureDiscovery(),
                  const SizedBox(height: 24),
                  _buildRecentActivity(),
                  const SizedBox(height: 24),
                  _buildUsageChart(),
                  const SizedBox(height: 24),
                  _buildLanguageInsights(),
                  const SizedBox(height: 100), // Bottom padding for FAB
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: _isScrolled ? AppTheme.white : Colors.transparent,
      foregroundColor: _isScrolled ? AppTheme.gray800 : AppTheme.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
          child: SafeArea(
            child: AnimatedBuilder(
              animation: _headerAnimationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    0,
                    50 * (1 - _headerAnimationController.value),
                  ),
                  child: Opacity(
                    opacity: _headerAnimationController.value,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.language,
                                  color: AppTheme.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getGreeting(),
                                      style: const TextStyle(
                                        color: AppTheme.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Ready to translate?',
                                      style: TextStyle(
                                        color: AppTheme.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: AppTheme.headingFontFamily,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Scaffold.of(context).openDrawer();
                                },
                                icon: const Icon(
                                  Icons.menu,
                                  color: AppTheme.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        title: _isScrolled
            ? const Text(
                'LingoSphere',
                style: TextStyle(
                  fontFamily: AppTheme.headingFontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildQuickStats() {
    return AnimatedBuilder(
      animation: _statsAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _statsAnimationController.value)),
          child: Opacity(
            opacity: _statsAnimationController.value,
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.gray200.withValues(alpha: 0.5),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Today',
                        '24',
                        'translations',
                        Icons.trending_up,
                        AppTheme.primaryBlue,
                        '+12%',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 60,
                      color: AppTheme.gray200,
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'This Week',
                        '142',
                        'translations',
                        Icons.bar_chart,
                        AppTheme.vibrantGreen,
                        '+8%',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 60,
                      color: AppTheme.gray200,
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Languages',
                        '12',
                        'discovered',
                        Icons.language,
                        AppTheme.accentTeal,
                        'new',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    String trend,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: AppTheme.primaryFontFamily,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.gray700,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.gray500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            trend,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return AnimationLimiter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.gray900,
              fontFamily: AppTheme.headingFontFamily,
            ),
          ),
          const SizedBox(height: 16),
          AnimationConfiguration.staggeredGrid(
            position: 0,
            duration: const Duration(milliseconds: 375),
            columnCount: 2,
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        'Text Translation',
                        'Type or paste text to translate',
                        Icons.translate,
                        AppTheme.primaryBlue,
                        () => _navigateToTextTranslation(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionCard(
                        'Voice Translation',
                        'Speak and translate in real-time',
                        Icons.mic,
                        AppTheme.vibrantGreen,
                        () => _navigateToVoiceTranslation(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          AnimationConfiguration.staggeredGrid(
            position: 1,
            duration: const Duration(milliseconds: 375),
            columnCount: 2,
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        'Camera OCR',
                        'Scan and translate text from images',
                        Icons.camera_alt,
                        AppTheme.accentTeal,
                        () => _navigateToCameraTranslation(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionCard(
                        'Conversation',
                        'Real-time conversation translation',
                        Icons.record_voice_over,
                        AppTheme.warningAmber,
                        () => _navigateToConversation(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.gray900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.gray600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureDiscovery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Discover Features',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.gray900,
                fontFamily: AppTheme.headingFontFamily,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // TODO: Show all tips
              },
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFeatureCard(
                '🎯 Smart Suggestions',
                'Get AI-powered translation improvements and alternatives.',
                AppTheme.primaryBlue,
              ),
              _buildFeatureCard(
                '📊 Usage Analytics',
                'Track your translation patterns and language learning progress.',
                AppTheme.vibrantGreen,
              ),
              _buildFeatureCard(
                '🔄 Offline Sync',
                'Access your translations even without internet connection.',
                AppTheme.accentTeal,
              ),
              _buildFeatureCard(
                '📤 Easy Sharing',
                'Share translations across all your favorite platforms.',
                AppTheme.warningAmber,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(String title, String description, Color color) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.gray600,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Recent Translations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.gray900,
                fontFamily: AppTheme.headingFontFamily,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => AppNavigation.toHistory(context),
              child: const Text('View all'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AnimationLimiter(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentTranslations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _buildTranslationCard(_recentTranslations[index]),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTranslationCard(TranslationEntry translation) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _getTypeColor(translation.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTypeIcon(translation.type),
                    size: 16,
                    color: _getTypeColor(translation.type),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${AppConstants.supportedLanguages[translation.sourceLanguage] ?? translation.sourceLanguage.toUpperCase()} → ${AppConstants.supportedLanguages[translation.targetLanguage] ?? translation.targetLanguage.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTimestamp(translation.timestamp),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.gray500,
                  ),
                ),
                if (translation.isFavorite) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.favorite,
                    size: 16,
                    color: AppTheme.errorRed,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              translation.sourceText,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.gray700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              translation.translatedText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.gray900,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: () => _copyToClipboard(translation.translatedText),
                  icon: const Icon(Icons.copy, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: AppTheme.gray600,
                ),
                const SizedBox(width: 16),
                QuickShareButton.forTranslation(
                  translation: translation,
                  size: QuickShareSize.small,
                  primaryColor: AppTheme.gray600,
                  tooltip: 'Share translation',
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () => _toggleFavorite(translation),
                  icon: Icon(
                    translation.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: translation.isFavorite
                      ? AppTheme.errorRed
                      : AppTheme.gray600,
                ),
                const Spacer(),
                Text(
                  translation.type.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getTypeColor(translation.type),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Translation Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.gray900,
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
                      spots: const [
                        FlSpot(0, 12),
                        FlSpot(1, 18),
                        FlSpot(2, 24),
                        FlSpot(3, 15),
                        FlSpot(4, 32),
                        FlSpot(5, 28),
                        FlSpot(6, 24),
                      ],
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

  Widget _buildLanguageInsights() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Language Insights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.gray900,
              ),
            ),
            const SizedBox(height: 16),
            _buildLanguageInsightItem(
                'Spanish', 'es', 45, AppTheme.vibrantGreen),
            _buildLanguageInsightItem('French', 'fr', 32, AppTheme.primaryBlue),
            _buildLanguageInsightItem(
                'Japanese', 'ja', 28, AppTheme.accentTeal),
            _buildLanguageInsightItem(
                'German', 'de', 15, AppTheme.warningAmber),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageInsightItem(
      String language, String code, int percentage, Color color) {
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
                    code.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                language,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gray800,
                ),
              ),
              const Spacer(),
              Text(
                '$percentage%',
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
            value: percentage / 100,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  IconData _getTypeIcon(TranslationMethod type) {
    switch (type) {
      case TranslationMethod.voice:
        return Icons.mic;
      case TranslationMethod.camera:
        return Icons.camera_alt;
      case TranslationMethod.image:
        return Icons.camera_alt;
      default:
        return Icons.translate;
    }
  }

  Color _getTypeColor(TranslationMethod type) {
    switch (type) {
      case TranslationMethod.voice:
        return AppTheme.vibrantGreen;
      case TranslationMethod.camera:
        return AppTheme.accentTeal;
      case TranslationMethod.image:
        return AppTheme.accentTeal;
      default:
        return AppTheme.primaryBlue;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  // Navigation methods
  void _navigateToTextTranslation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TranslationScreen(),
      ),
    );
  }

  void _navigateToVoiceTranslation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VoiceTranslationScreen(),
      ),
    );
  }

  void _navigateToCameraTranslation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraTranslationScreen(),
      ),
    );
  }

  void _navigateToConversation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const VoiceTranslationScreen(conversationMode: true),
      ),
    );
  }

  // Action methods
  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    // TODO: Refresh data from services
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        backgroundColor: AppTheme.successGreen,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _toggleFavorite(TranslationEntry translation) {
    HapticFeedback.lightImpact();
    setState(() {
      final index =
          _recentTranslations.indexWhere((t) => t.id == translation.id);
      if (index != -1) {
        _recentTranslations[index] = translation.copyWith(
          isFavorite: !translation.isFavorite,
        );
      }
    });
    // TODO: Update in history service
  }
}
