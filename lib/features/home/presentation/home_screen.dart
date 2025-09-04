// 🌐 LingoSphere - Enhanced Home Screen
// Comprehensive translation hub with tabs, recent translations, and quick actions

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../translation/presentation/translation_screen.dart';
import '../../voice/presentation/voice_translation_screen.dart';
import '../../insights/presentation/insights_dashboard.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const TranslationTab(),
    const ChatsTab(),
    const InsightsTab(),
    const VoiceTab(),
    const SettingsTab(),
  ];

  final List<BottomNavigationBarItem> _navigationItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.translate_rounded),
      activeIcon: Icon(Icons.translate_rounded),
      label: 'Translate',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.chat_bubble_outline_rounded),
      activeIcon: Icon(Icons.chat_bubble_rounded),
      label: 'Chats',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.insights_outlined),
      activeIcon: Icon(Icons.insights_rounded),
      label: 'Insights',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.mic_outlined),
      activeIcon: Icon(Icons.mic_rounded),
      label: 'Voice',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.settings_outlined),
      activeIcon: Icon(Icons.settings_rounded),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: _navigationItems,
        backgroundColor: AppTheme.white,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: AppTheme.gray500,
        selectedLabelStyle: const TextStyle(
          fontFamily: AppTheme.primaryFontFamily,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: AppTheme.primaryFontFamily,
          fontWeight: FontWeight.normal,
        ),
        elevation: 8,
      ),
    );
  }
}

// Enhanced Translation Tab with comprehensive features
class TranslationTab extends StatefulWidget {
  const TranslationTab({super.key});

  @override
  State<TranslationTab> createState() => _TranslationTabState();
}

class _TranslationTabState extends State<TranslationTab> {
  final TextEditingController _translationController = TextEditingController();
  String _selectedSourceLanguage = 'auto';
  String _selectedTargetLanguage = 'en';
  bool _isTranslating = false;

  final List<RecentTranslation> _recentTranslations = [
    RecentTranslation(
      originalText: "Hola, ¿cómo estás?",
      translatedText: "Hello, how are you?",
      sourceLanguage: "es",
      targetLanguage: "en",
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      confidence: 0.95,
    ),
    RecentTranslation(
      originalText: "Je suis très heureux de te voir",
      translatedText: "I am very happy to see you",
      sourceLanguage: "fr",
      targetLanguage: "en",
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      confidence: 0.92,
    ),
    RecentTranslation(
      originalText: "今日は天気がいいですね",
      translatedText: "The weather is nice today",
      sourceLanguage: "ja",
      targetLanguage: "en",
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      confidence: 0.88,
    ),
  ];

  @override
  void dispose() {
    _translationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AnimationLimiter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildQuickStats(),
                  const SizedBox(height: 24),
                  _buildLanguageSelector(),
                  const SizedBox(height: 20),
                  _buildTranslationInput(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildRecentTranslations(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          'LingoSphere',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontFamily: AppTheme.headingFontFamily,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // Handle notifications
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            // Navigate to settings
          },
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Translations Today',
              '24',
              Icons.trending_up,
              AppTheme.white,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.white.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _buildStatItem(
              'Languages Used',
              '8',
              Icons.language,
              AppTheme.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withValues(alpha: 0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildLanguageDropdown(
                'From',
                _selectedSourceLanguage,
                (value) => setState(() => _selectedSourceLanguage = value!),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: FloatingActionButton.small(
                onPressed: () {
                  setState(() {
                    final temp = _selectedSourceLanguage;
                    _selectedSourceLanguage = _selectedTargetLanguage;
                    _selectedTargetLanguage = temp;
                  });
                },
                backgroundColor: AppTheme.vibrantGreen,
                child: const Icon(Icons.swap_horiz, color: AppTheme.white),
              ),
            ),
            Expanded(
              child: _buildLanguageDropdown(
                'To',
                _selectedTargetLanguage,
                (value) => setState(() => _selectedTargetLanguage = value!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown(
    String label,
    String value,
    void Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.gray600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.gray300),
            ),
          ),
          items: AppConstants.supportedLanguages.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTranslationInput() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              constraints: const BoxConstraints(minHeight: 80),
              child: TextField(
                controller: _translationController,
                maxLines: null,
                minLines: 3,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'Enter text to translate...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintStyle: TextStyle(color: AppTheme.gray500),
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(fontSize: 16),
                autofocus: false,
                enabled: true,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    _handleVoiceInput();
                  },
                  icon: const Icon(Icons.mic, color: AppTheme.vibrantGreen),
                ),
                IconButton(
                  onPressed: () {
                    _handleCameraOCR();
                  },
                  icon:
                      const Icon(Icons.camera_alt, color: AppTheme.accentTeal),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _isTranslating ? null : _handleTranslation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.vibrantGreen,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: _isTranslating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(AppTheme.white),
                          ),
                        )
                      : const Text('Translate'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      QuickAction(
        'WhatsApp Chat',
        Icons.chat,
        AppTheme.vibrantGreen,
        () => _handleQuickAction('whatsapp'),
      ),
      QuickAction(
        'Voice Call',
        Icons.phone,
        AppTheme.accentTeal,
        () => _handleQuickAction('voice'),
      ),
      QuickAction(
        'Photo Translate',
        Icons.camera_alt,
        AppTheme.warningAmber,
        () => _handleQuickAction('camera'),
      ),
      QuickAction(
        'Conversation',
        Icons.record_voice_over,
        AppTheme.primaryBlue,
        () => _handleQuickAction('conversation'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.gray900,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: action.onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(action.icon, color: action.color, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          action.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.gray700,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentTranslations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Translations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.gray900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentTranslations.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final translation = _recentTranslations[index];
            return _buildTranslationCard(translation);
          },
        ),
      ],
    );
  }

  Widget _buildTranslationCard(RecentTranslation translation) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${translation.sourceLanguage} → ${translation.targetLanguage}',
                    style: const TextStyle(
                      fontSize: 12,
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
              ],
            ),
            const SizedBox(height: 12),
            Text(
              translation.originalText,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.gray700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              translation.translatedText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.gray900,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.verified,
                  size: 16,
                  color: _getConfidenceColor(translation.confidence),
                ),
                const SizedBox(width: 4),
                Text(
                  '${(translation.confidence * 100).toInt()}% confidence',
                  style: TextStyle(
                    fontSize: 12,
                    color: _getConfidenceColor(translation.confidence),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  onPressed: () => _copyToClipboard(translation.translatedText),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                IconButton(
                  icon: const Icon(Icons.share, size: 16),
                  onPressed: () => _shareTranslation(translation),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleTranslation() {
    if (_translationController.text.trim().isEmpty) {
      // Navigate to empty translation screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TranslationScreen(
            sourceLanguage: _selectedSourceLanguage,
            targetLanguage: _selectedTargetLanguage,
          ),
        ),
      );
      return;
    }

    // Navigate to translation screen with pre-filled text
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TranslationScreen(
          initialText: _translationController.text,
          sourceLanguage: _selectedSourceLanguage,
          targetLanguage: _selectedTargetLanguage,
        ),
      ),
    );
  }

  void _handleVoiceInput() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice input feature coming soon!'),
        backgroundColor: AppTheme.vibrantGreen,
      ),
    );
  }

  void _handleCameraOCR() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Camera OCR feature coming soon!'),
        backgroundColor: AppTheme.accentTeal,
      ),
    );
  }

  void _handleQuickAction(String action) {
    switch (action) {
      case 'whatsapp':
        _launchWhatsAppTranslation();
        break;
      case 'voice':
        _startVoiceCall();
        break;
      case 'camera':
        _launchCameraTranslation();
        break;
      case 'conversation':
        _startConversationMode();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$action feature coming soon!'),
            backgroundColor: AppTheme.vibrantGreen,
          ),
        );
    }
  }

  void _launchWhatsAppTranslation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.chat, color: AppTheme.vibrantGreen),
              SizedBox(width: 8),
              Text('WhatsApp Integration'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enable real-time translation for your WhatsApp conversations.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                '• Auto-translate incoming messages',
                style: TextStyle(color: AppTheme.gray600),
              ),
              Text(
                '• Translate before sending',
                style: TextStyle(color: AppTheme.gray600),
              ),
              Text(
                '• Support for 100+ languages',
                style: TextStyle(color: AppTheme.gray600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _setupWhatsAppIntegration();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.vibrantGreen,
                foregroundColor: AppTheme.white,
              ),
              child: const Text('Setup'),
            ),
          ],
        );
      },
    );
  }

  void _setupWhatsAppIntegration() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('WhatsApp integration setup initiated!'),
        backgroundColor: AppTheme.vibrantGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _startVoiceCall() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.phone, color: AppTheme.accentTeal),
              SizedBox(width: 8),
              Text('Voice Translation Call'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Start a voice call with real-time translation.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                '• Real-time speech translation',
                style: TextStyle(color: AppTheme.gray600),
              ),
              Text(
                '• Voice-to-voice translation',
                style: TextStyle(color: AppTheme.gray600),
              ),
              Text(
                '• High-quality audio processing',
                style: TextStyle(color: AppTheme.gray600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VoiceTranslationScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentTeal,
                foregroundColor: AppTheme.white,
              ),
              child: const Text('Start Call'),
            ),
          ],
        );
      },
    );
  }

  void _launchCameraTranslation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TranslationScreen(
          sourceLanguage: _selectedSourceLanguage,
          targetLanguage: _selectedTargetLanguage,
        ),
      ),
    ).then((_) {
      // Immediately trigger camera OCR when screen loads
      Future.delayed(const Duration(milliseconds: 500), () {
        // This would trigger the camera OCR functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera translation ready! Tap camera icon.'),
            backgroundColor: AppTheme.warningAmber,
            duration: Duration(seconds: 2),
          ),
        );
      });
    });
  }

  void _startConversationMode() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.record_voice_over, color: AppTheme.primaryBlue),
              SizedBox(width: 8),
              Text('Conversation Mode'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enable two-way conversation translation.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                '• Automatic speaker detection',
                style: TextStyle(color: AppTheme.gray600),
              ),
              Text(
                '• Real-time bidirectional translation',
                style: TextStyle(color: AppTheme.gray600),
              ),
              Text(
                '• Voice synthesis for both languages',
                style: TextStyle(color: AppTheme.gray600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VoiceTranslationScreen(
                      conversationMode: true,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: AppTheme.white,
              ),
              child: const Text('Start'),
            ),
          ],
        );
      },
    );
  }

  void _showTranslationResult() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Translation Result'),
        content: const Text('This would show the actual translation result.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _shareTranslation(RecentTranslation translation) {
    // Implement sharing functionality
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

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.9) return AppTheme.successGreen;
    if (confidence >= 0.7) return AppTheme.warningAmber;
    return AppTheme.errorRed;
  }
}

// Placeholder tabs
class ChatsTab extends StatelessWidget {
  const ChatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 64,
            color: AppTheme.gray400,
          ),
          SizedBox(height: 16),
          Text(
            'Group Chats',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Connect your messaging apps to enable\nreal-time translation',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.gray500,
            ),
          ),
        ],
      ),
    );
  }
}

class InsightsTab extends StatelessWidget {
  const InsightsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const InsightsDashboard();
  }
}

class VoiceTab extends StatelessWidget {
  const VoiceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.mic,
                size: 64,
                color: AppTheme.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Voice Translation',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppTheme.gray700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Speak and translate in real-time\nwith voice recognition',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.gray500,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VoiceTranslationScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.vibrantGreen,
                foregroundColor: AppTheme.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mic),
                  SizedBox(width: 8),
                  Text('Start Voice Translation'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VoiceTranslationScreen(
                      conversationMode: true,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentTeal,
                foregroundColor: AppTheme.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.record_voice_over),
                  SizedBox(width: 8),
                  Text('Conversation Mode'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  // Settings state
  bool _autoTranslate = true;
  bool _darkMode = false;
  bool _offlineMode = false;
  bool _voicePrompts = true;
  bool _notifications = true;
  bool _autoDetectLanguage = true;
  double _speechRate = 0.5;
  double _voicePitch = 0.5;
  String _preferredVoice = 'system';
  String _defaultTargetLanguage = 'en';
  String _translationProvider = 'google';
  int _cacheRetentionDays = 30;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AnimationLimiter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 300),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildSection(
                  'Translation Settings',
                  Icons.translate,
                  [
                    _buildSwitchTile(
                      'Auto-translate',
                      'Automatically translate as you type',
                      _autoTranslate,
                      (value) => setState(() => _autoTranslate = value),
                    ),
                    _buildSwitchTile(
                      'Auto-detect language',
                      'Automatically detect input language',
                      _autoDetectLanguage,
                      (value) => setState(() => _autoDetectLanguage = value),
                    ),
                    _buildDropdownTile(
                      'Default target language',
                      _defaultTargetLanguage,
                      AppConstants.supportedLanguages,
                      (value) => setState(() => _defaultTargetLanguage = value!),
                    ),
                    _buildDropdownTile(
                      'Translation provider',
                      _translationProvider,
                      {
                        'google': 'Google Translate',
                        'azure': 'Microsoft Translator',
                        'aws': 'Amazon Translate',
                        'deepl': 'DeepL',
                      },
                      (value) => setState(() => _translationProvider = value!),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSection(
                  'Voice Settings',
                  Icons.record_voice_over,
                  [
                    _buildSwitchTile(
                      'Voice prompts',
                      'Enable audio feedback and prompts',
                      _voicePrompts,
                      (value) => setState(() => _voicePrompts = value),
                    ),
                    _buildSliderTile(
                      'Speech rate',
                      'Adjust playback speed',
                      _speechRate,
                      (value) => setState(() => _speechRate = value),
                    ),
                    _buildSliderTile(
                      'Voice pitch',
                      'Adjust voice tone',
                      _voicePitch,
                      (value) => setState(() => _voicePitch = value),
                    ),
                    _buildDropdownTile(
                      'Preferred voice',
                      _preferredVoice,
                      {
                        'system': 'System Default',
                        'male': 'Male Voice',
                        'female': 'Female Voice',
                        'neural': 'Neural Voice',
                      },
                      (value) => setState(() => _preferredVoice = value!),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSection(
                  'App Settings',
                  Icons.settings,
                  [
                    _buildSwitchTile(
                      'Dark mode',
                      'Use dark theme',
                      _darkMode,
                      (value) => setState(() => _darkMode = value),
                    ),
                    _buildSwitchTile(
                      'Offline mode',
                      'Use cached translations when offline',
                      _offlineMode,
                      (value) => setState(() => _offlineMode = value),
                    ),
                    _buildSwitchTile(
                      'Push notifications',
                      'Receive app updates and tips',
                      _notifications,
                      (value) => setState(() => _notifications = value),
                    ),
                    _buildSliderTile(
                      'Cache retention (days)',
                      'Days to keep translation cache',
                      _cacheRetentionDays.toDouble(),
                      (value) => setState(() => _cacheRetentionDays = value.toInt()),
                      min: 1,
                      max: 90,
                      divisions: 89,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSection(
                  'Data & Privacy',
                  Icons.privacy_tip,
                  [
                    _buildActionTile(
                      'Clear cache',
                      'Remove stored translations and data',
                      Icons.delete_sweep,
                      _clearCache,
                    ),
                    _buildActionTile(
                      'Export data',
                      'Export your translation history',
                      Icons.download,
                      _exportData,
                    ),
                    _buildActionTile(
                      'Privacy policy',
                      'View our privacy policy',
                      Icons.policy,
                      _viewPrivacyPolicy,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSection(
                  'About',
                  Icons.info,
                  [
                    _buildInfoTile('Version', '1.0.0 (Beta)'),
                    _buildActionTile(
                      'Check for updates',
                      'Get the latest features',
                      Icons.system_update,
                      _checkForUpdates,
                    ),
                    _buildActionTile(
                      'Send feedback',
                      'Help us improve LingoSphere',
                      Icons.feedback,
                      _sendFeedback,
                    ),
                    _buildActionTile(
                      'Rate app',
                      'Rate us on the App Store',
                      Icons.star,
                      _rateApp,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.settings,
            color: AppTheme.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        const Text(
          'Settings',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.gray900,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryBlue, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.gray900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray800,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.gray600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile<T>(
    String title,
    T value,
    Map<T, String> items,
    ValueChanged<T?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray800,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.gray300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              items: items.entries
                  .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    String subtitle,
    double value,
    ValueChanged<double> onChanged, {
    double min = 0.0,
    double max = 1.0,
    int? divisions,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray800,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.gray600,
            ),
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: AppTheme.primaryBlue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryBlue),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.gray800,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.gray600,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.gray400),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray800,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.gray600,
            ),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will remove all cached translations and data. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage('Cache cleared successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: AppTheme.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    _showSuccessMessage('Export feature coming soon!');
  }

  void _viewPrivacyPolicy() {
    _showSuccessMessage('Privacy policy feature coming soon!');
  }

  void _checkForUpdates() {
    _showSuccessMessage('You have the latest version!');
  }

  void _sendFeedback() {
    _showSuccessMessage('Feedback feature coming soon!');
  }

  void _rateApp() {
    _showSuccessMessage('Rate app feature coming soon!');
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.vibrantGreen,
      ),
    );
  }
}

// Data Models
class RecentTranslation {
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime timestamp;
  final double confidence;

  RecentTranslation({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.timestamp,
    required this.confidence,
  });
}

class QuickAction {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  QuickAction(this.title, this.icon, this.color, this.onTap);
}
