// 🌐 LingoSphere - Feature Discovery Service
// Advanced onboarding, tips, and feature discovery system

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Feature discovery item
class DiscoveryItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String? imagePath;
  final String? videoPath;
  final List<String> benefits;
  final String actionText;
  final VoidCallback? onAction;
  final bool isNew;
  final int priority;

  DiscoveryItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.imagePath,
    this.videoPath,
    required this.benefits,
    required this.actionText,
    this.onAction,
    this.isNew = false,
    this.priority = 0,
  });
}

/// Onboarding step
class OnboardingStep {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String? imagePath;
  final Widget? customWidget;
  final bool showSkip;

  OnboardingStep({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.imagePath,
    this.customWidget,
    this.showSkip = true,
  });
}

/// Feature tip
class FeatureTip {
  final String id;
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final String category;
  final int importance;
  final DateTime? showAfter;
  final bool isDismissible;

  FeatureTip({
    required this.id,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.category,
    this.importance = 1,
    this.showAfter,
    this.isDismissible = true,
  });
}

/// Guided tour step
class GuidedTourStep {
  final String id;
  final String title;
  final String description;
  final GlobalKey targetKey;
  final String? actionText;
  final VoidCallback? onAction;
  final EdgeInsets? padding;

  GuidedTourStep({
    required this.id,
    required this.title,
    required this.description,
    required this.targetKey,
    this.actionText,
    this.onAction,
    this.padding,
  });
}

/// Feature Discovery Service
class FeatureDiscoveryService extends ChangeNotifier {
  static final FeatureDiscoveryService _instance =
      FeatureDiscoveryService._internal();
  factory FeatureDiscoveryService() => _instance;
  FeatureDiscoveryService._internal();

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  // Tracking
  final Set<String> _seenFeatures = {};
  final Set<String> _dismissedTips = {};
  final Set<String> _completedOnboarding = {};
  final Set<String> _completedTours = {};

  // State
  bool _showFeatureHighlights = true;
  bool _showTips = true;
  String _lastShownTip = '';

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    await _loadState();
    _isInitialized = true;
    notifyListeners();
  }

  /// Load saved state
  Future<void> _loadState() async {
    if (_prefs == null) return;

    _seenFeatures.addAll(_prefs!.getStringList('seen_features') ?? []);
    _dismissedTips.addAll(_prefs!.getStringList('dismissed_tips') ?? []);
    _completedOnboarding
        .addAll(_prefs!.getStringList('completed_onboarding') ?? []);
    _completedTours.addAll(_prefs!.getStringList('completed_tours') ?? []);
    _showFeatureHighlights = _prefs!.getBool('show_feature_highlights') ?? true;
    _showTips = _prefs!.getBool('show_tips') ?? true;
    _lastShownTip = _prefs!.getString('last_shown_tip') ?? '';
  }

  /// Save state to preferences
  Future<void> _saveState() async {
    if (_prefs == null) return;

    await _prefs!.setStringList('seen_features', _seenFeatures.toList());
    await _prefs!.setStringList('dismissed_tips', _dismissedTips.toList());
    await _prefs!
        .setStringList('completed_onboarding', _completedOnboarding.toList());
    await _prefs!.setStringList('completed_tours', _completedTours.toList());
    await _prefs!.setBool('show_feature_highlights', _showFeatureHighlights);
    await _prefs!.setBool('show_tips', _showTips);
    await _prefs!.setString('last_shown_tip', _lastShownTip);
  }

  /// Check if user needs onboarding
  bool needsOnboarding() {
    return !_completedOnboarding.contains('main_app');
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding(String onboardingId) async {
    _completedOnboarding.add(onboardingId);
    await _saveState();
    notifyListeners();
  }

  /// Mark feature as seen
  Future<void> markFeatureSeen(String featureId) async {
    _seenFeatures.add(featureId);
    await _saveState();
    notifyListeners();
  }

  /// Dismiss a tip
  Future<void> dismissTip(String tipId) async {
    _dismissedTips.add(tipId);
    await _saveState();
    notifyListeners();
  }

  /// Complete a guided tour
  Future<void> completeTour(String tourId) async {
    _completedTours.add(tourId);
    await _saveState();
    notifyListeners();
  }

  /// Toggle feature highlights
  Future<void> toggleFeatureHighlights() async {
    _showFeatureHighlights = !_showFeatureHighlights;
    await _saveState();
    notifyListeners();
  }

  /// Toggle tips
  Future<void> toggleTips() async {
    _showTips = !_showTips;
    await _saveState();
    notifyListeners();
  }

  /// Get discovery items
  List<DiscoveryItem> getDiscoveryItems() {
    final items = [
      DiscoveryItem(
        id: 'voice_translation',
        title: '🎤 Voice Translation',
        description:
            'Speak naturally and get instant translations in real-time',
        icon: Icons.mic,
        color: const Color(0xFF10B981),
        benefits: [
          'Hands-free translation experience',
          'Perfect pronunciation detection',
          'Real-time conversation mode',
          'Works with 50+ languages',
        ],
        actionText: 'Try Voice Translation',
        isNew: !_seenFeatures.contains('voice_translation'),
        priority: 10,
      ),
      DiscoveryItem(
        id: 'camera_ocr',
        title: '📷 Camera Translation',
        description: 'Point your camera at text and see instant translations',
        icon: Icons.camera_alt,
        color: const Color(0xFF0EA5E9),
        benefits: [
          'Translate signs, menus, documents',
          'Works offline with downloaded languages',
          'Preserves original text formatting',
          'Smart text detection and extraction',
        ],
        actionText: 'Try Camera Translation',
        isNew: !_seenFeatures.contains('camera_ocr'),
        priority: 9,
      ),
      DiscoveryItem(
        id: 'conversation_mode',
        title: '💬 Conversation Mode',
        description:
            'Have real-time conversations with automatic language switching',
        icon: Icons.record_voice_over,
        color: const Color(0xFFF59E0B),
        benefits: [
          'Automatic speaker detection',
          'Turn-based conversation flow',
          'Visual conversation history',
          'Perfect for travel and meetings',
        ],
        actionText: 'Start Conversation',
        isNew: !_seenFeatures.contains('conversation_mode'),
        priority: 8,
      ),
      DiscoveryItem(
        id: 'offline_mode',
        title: '📶 Offline Translation',
        description: 'Download languages for translation without internet',
        icon: Icons.download,
        color: const Color(0xFF8B5CF6),
        benefits: [
          'No internet required',
          'Fast local processing',
          'Privacy-focused translations',
          'Perfect for travel abroad',
        ],
        actionText: 'Download Languages',
        isNew: !_seenFeatures.contains('offline_mode'),
        priority: 7,
      ),
      DiscoveryItem(
        id: 'smart_sharing',
        title: '📤 Smart Sharing',
        description: 'Share translations across all your favorite platforms',
        icon: Icons.share,
        color: const Color(0xFFEC4899),
        benefits: [
          'One-tap sharing to any app',
          'Custom formatting options',
          'Email templates included',
          'Social media optimized',
        ],
        actionText: 'Explore Sharing',
        isNew: !_seenFeatures.contains('smart_sharing'),
        priority: 6,
      ),
      DiscoveryItem(
        id: 'analytics_insights',
        title: '📊 Analytics & Insights',
        description:
            'Track your translation patterns and language learning progress',
        icon: Icons.analytics,
        color: const Color(0xFF059669),
        benefits: [
          'Visual usage statistics',
          'Language learning insights',
          'Personal improvement tips',
          'Export progress reports',
        ],
        actionText: 'View Analytics',
        isNew: !_seenFeatures.contains('analytics_insights'),
        priority: 5,
      ),
    ];

    // Filter and sort by priority
    return items.where((item) => _showFeatureHighlights || item.isNew).toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));
  }

  /// Get onboarding steps
  List<OnboardingStep> getOnboardingSteps() {
    return [
      OnboardingStep(
        id: 'welcome',
        title: 'Welcome to LingoSphere! 🌐',
        description:
            'Your intelligent translation companion for seamless global communication.',
        icon: Icons.language,
        color: const Color(0xFF3B82F6),
        showSkip: false,
      ),
      OnboardingStep(
        id: 'voice_intro',
        title: 'Voice Translation 🎤',
        description:
            'Simply speak and get instant translations. Perfect for conversations and quick queries.',
        icon: Icons.mic,
        color: const Color(0xFF10B981),
      ),
      OnboardingStep(
        id: 'camera_intro',
        title: 'Camera Translation 📷',
        description:
            'Point your camera at any text - signs, menus, documents - and see instant translations.',
        icon: Icons.camera_alt,
        color: const Color(0xFF0EA5E9),
      ),
      OnboardingStep(
        id: 'history_intro',
        title: 'Smart History 📚',
        description:
            'All your translations are saved, searchable, and accessible offline. Never lose important translations again.',
        icon: Icons.history,
        color: const Color(0xFF8B5CF6),
      ),
      OnboardingStep(
        id: 'sharing_intro',
        title: 'Easy Sharing 📤',
        description:
            'Share translations instantly across all platforms - WhatsApp, email, social media, and more.',
        icon: Icons.share,
        color: const Color(0xFFEC4899),
      ),
      OnboardingStep(
        id: 'ready',
        title: 'Ready to Explore! 🚀',
        description:
            'You\'re all set! Start translating and discover the power of seamless communication.',
        icon: Icons.rocket_launch,
        color: const Color(0xFFF59E0B),
        showSkip: false,
      ),
    ];
  }

  /// Get feature tips
  List<FeatureTip> getFeatureTips() {
    final allTips = [
      FeatureTip(
        id: 'voice_tip_pronunciation',
        title: 'Pro Tip: Voice Quality',
        message:
            'For best results, speak clearly and pause briefly between sentences.',
        icon: Icons.mic,
        color: const Color(0xFF10B981),
        category: 'voice',
        importance: 3,
      ),
      FeatureTip(
        id: 'camera_tip_lighting',
        title: 'Camera Tip: Better Results',
        message:
            'Ensure good lighting and hold your device steady for clearer text recognition.',
        icon: Icons.camera_alt,
        color: const Color(0xFF0EA5E9),
        category: 'camera',
        importance: 3,
      ),
      FeatureTip(
        id: 'history_tip_favorites',
        title: 'Organization Tip',
        message:
            'Mark important translations as favorites for quick access later.',
        icon: Icons.favorite,
        color: const Color(0xFFEC4899),
        category: 'history',
        importance: 2,
      ),
      FeatureTip(
        id: 'sharing_tip_formats',
        title: 'Sharing Formats',
        message:
            'Try different sharing formats - formal emails, casual messages, or social posts.',
        icon: Icons.share,
        color: const Color(0xFF8B5CF6),
        category: 'sharing',
        importance: 2,
      ),
      FeatureTip(
        id: 'offline_tip_download',
        title: 'Offline Ready',
        message:
            'Download languages before traveling to use translations without internet.',
        icon: Icons.download,
        color: const Color(0xFF059669),
        category: 'offline',
        importance: 4,
      ),
      FeatureTip(
        id: 'conversation_tip_flow',
        title: 'Conversation Flow',
        message:
            'In conversation mode, the app automatically switches between languages as you speak.',
        icon: Icons.record_voice_over,
        color: const Color(0xFFF59E0B),
        category: 'conversation',
        importance: 3,
      ),
    ];

    return allTips
        .where((tip) => _showTips && !_dismissedTips.contains(tip.id))
        .toList()
      ..sort((a, b) => b.importance.compareTo(a.importance));
  }

  /// Get next tip to show
  FeatureTip? getNextTip() {
    final tips = getFeatureTips();
    if (tips.isEmpty) return null;

    // Find a tip that hasn't been shown recently
    for (final tip in tips) {
      if (tip.id != _lastShownTip) {
        return tip;
      }
    }

    return tips.first;
  }

  /// Show a specific tip
  Future<void> showTip(String tipId) async {
    _lastShownTip = tipId;
    await _saveState();
    notifyListeners();
  }

  /// Get guided tour steps for a specific feature
  List<GuidedTourStep> getTourSteps(String tourId) {
    switch (tourId) {
      case 'main_app':
        return [
          GuidedTourStep(
            id: 'navigation_bar',
            title: 'Bottom Navigation',
            description:
                'Quickly access all main features from the bottom navigation bar.',
            targetKey: GlobalKey(), // Would be provided by the UI
          ),
          GuidedTourStep(
            id: 'voice_button',
            title: 'Voice Translation',
            description: 'Tap the microphone to start voice translation.',
            targetKey: GlobalKey(),
          ),
          GuidedTourStep(
            id: 'menu_drawer',
            title: 'Menu Drawer',
            description:
                'Access advanced features and settings from the drawer menu.',
            targetKey: GlobalKey(),
          ),
        ];
      default:
        return [];
    }
  }

  /// Check if tour is available
  bool isTourAvailable(String tourId) {
    return !_completedTours.contains(tourId);
  }

  /// Reset all discovery data (for testing/debugging)
  Future<void> resetAllData() async {
    _seenFeatures.clear();
    _dismissedTips.clear();
    _completedOnboarding.clear();
    _completedTours.clear();
    _showFeatureHighlights = true;
    _showTips = true;
    _lastShownTip = '';

    await _saveState();
    notifyListeners();
  }

  /// Get discovery statistics
  Map<String, dynamic> getDiscoveryStats() {
    final totalFeatures = getDiscoveryItems().length;
    final discoveredFeatures = _seenFeatures.length;
    final totalTips = getFeatureTips().length + _dismissedTips.length;
    final seenTips = _dismissedTips.length;

    return {
      'features_discovered': discoveredFeatures,
      'total_features': totalFeatures,
      'discovery_progress':
          totalFeatures > 0 ? (discoveredFeatures / totalFeatures) : 0.0,
      'tips_seen': seenTips,
      'total_tips': totalTips,
      'onboarding_completed': _completedOnboarding.isNotEmpty,
      'tours_completed': _completedTours.length,
    };
  }

  /// Check if should show welcome back message
  bool shouldShowWelcomeBack() {
    if (_prefs == null) return false;

    final lastLaunch = _prefs!.getString('last_launch_date');
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (lastLaunch == null) {
      _prefs!.setString('last_launch_date', today);
      return false;
    }

    final lastLaunchDate = DateTime.parse('${lastLaunch}T00:00:00Z');
    final todayDate = DateTime.parse('${today}T00:00:00Z');
    final daysDifference = todayDate.difference(lastLaunchDate).inDays;

    _prefs!.setString('last_launch_date', today);

    return daysDifference >= 1; // Show if user hasn't used app for a day
  }

  /// Get context-sensitive tips
  List<FeatureTip> getContextTips(String context) {
    final contextTips =
        getFeatureTips().where((tip) => tip.category == context).toList();

    return contextTips;
  }

  // Getters
  bool get isInitialized => _isInitialized;
  bool get showFeatureHighlights => _showFeatureHighlights;
  bool get showTips => _showTips;
  Set<String> get seenFeatures => Set.unmodifiable(_seenFeatures);
  Set<String> get dismissedTips => Set.unmodifiable(_dismissedTips);
  Set<String> get completedOnboarding => Set.unmodifiable(_completedOnboarding);
  Set<String> get completedTours => Set.unmodifiable(_completedTours);
}
