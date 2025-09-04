// 🌐 LingoSphere - Profile Screen
// User profile, settings, and preferences management

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../../shared/widgets/sharing/share_dialog.dart';
import '../../../core/services/native_sharing_service.dart';
import '../../../main.dart';

/// User profile and settings screen
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  // User preferences
  bool _isDarkMode = false;
  bool _enableNotifications = true;
  bool _enableAnalytics = true;
  bool _enableAutoBackup = true;
  String _preferredLanguage = 'English';
  String _translationEngine = 'Google Translate';

  final List<String> _availableLanguages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
    'Russian',
    'Japanese',
    'Korean',
    'Chinese'
  ];

  final List<String> _translationEngines = [
    'Google Translate',
    'DeepL',
    'OpenAI GPT',
    'Azure Translator'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
    _loadUserPreferences();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserPreferences() async {
    // TODO: Load from shared preferences or user service
    setState(() {
      _isDarkMode = false; // Load actual preference
      _enableNotifications = true;
      _enableAnalytics = true;
      _enableAutoBackup = true;
      _preferredLanguage = 'English';
      _translationEngine = 'Google Translate';
    });
  }

  Future<void> _saveUserPreferences() async {
    // TODO: Save to shared preferences or user service
    logger.i('User preferences saved');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          _buildProfileContent(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primaryBlue,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
          child: SafeArea(
            child: AnimationLimiter(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 600),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    horizontalOffset: 50,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: [
                    const SizedBox(height: 60),
                    _buildProfileAvatar(),
                    const SizedBox(height: 16),
                    _buildProfileInfo(),
                    const SizedBox(height: 24),
                    _buildQuickStats(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.white.withValues(alpha: 0.2),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.white,
            child: Text(
              'LS', // User initials
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.successGreen,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.white, width: 2),
            ),
            child: const Icon(
              Icons.verified,
              color: AppTheme.white,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      children: [
        const Text(
          'LingoSphere User',
          style: TextStyle(
            color: AppTheme.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: AppTheme.headingFontFamily,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'user@lingosphere.app',
          style: TextStyle(
            color: AppTheme.white.withValues(alpha: 0.9),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem('1,247', 'Translations'),
        _buildStatDivider(),
        _buildStatItem('23', 'Languages'),
        _buildStatDivider(),
        _buildStatItem('15', 'Days Active'),
      ],
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            color: AppTheme.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 30,
      width: 1,
      color: AppTheme.white.withValues(alpha: 0.3),
    );
  }

  Widget _buildProfileContent() {
    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          AnimationLimiter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  _buildSectionTitle('Preferences'),
                  const SizedBox(height: 16),
                  _buildPreferencesSection(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Translation Settings'),
                  const SizedBox(height: 16),
                  _buildTranslationSettings(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Data & Privacy'),
                  const SizedBox(height: 16),
                  _buildDataPrivacySection(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Account'),
                  const SizedBox(height: 16),
                  _buildAccountSection(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Support'),
                  const SizedBox(height: 16),
                  _buildSupportSection(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppTheme.gray900,
        fontFamily: AppTheme.headingFontFamily,
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSwitchTile(
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              subtitle: 'Switch to dark theme',
              value: _isDarkMode,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
                _saveUserPreferences();
              },
            ),
            const Divider(),
            _buildSwitchTile(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Receive app notifications',
              value: _enableNotifications,
              onChanged: (value) {
                setState(() {
                  _enableNotifications = value;
                });
                _saveUserPreferences();
              },
            ),
            const Divider(),
            _buildDropdownTile(
              icon: Icons.language,
              title: 'App Language',
              subtitle: 'Interface language',
              value: _preferredLanguage,
              items: _availableLanguages,
              onChanged: (value) {
                setState(() {
                  _preferredLanguage = value!;
                });
                _saveUserPreferences();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationSettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDropdownTile(
              icon: Icons.translate,
              title: 'Translation Engine',
              subtitle: 'Primary translation service',
              value: _translationEngine,
              items: _translationEngines,
              onChanged: (value) {
                setState(() {
                  _translationEngine = value!;
                });
                _saveUserPreferences();
              },
            ),
            const Divider(),
            _buildActionTile(
              icon: Icons.speed,
              title: 'Translation Speed',
              subtitle: 'Fast, balanced, or accurate',
              onTap: () => _showTranslationSpeedDialog(),
            ),
            const Divider(),
            _buildActionTile(
              icon: Icons.history,
              title: 'Auto-save Translations',
              subtitle: 'Automatically save to history',
              onTap:
                  () {}, // Add empty callback since this has a switch as trailing
              trailing: Switch(
                value: true,
                onChanged: (value) {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataPrivacySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSwitchTile(
              icon: Icons.analytics,
              title: 'Analytics',
              subtitle: 'Help improve the app',
              value: _enableAnalytics,
              onChanged: (value) {
                setState(() {
                  _enableAnalytics = value;
                });
                _saveUserPreferences();
              },
            ),
            const Divider(),
            _buildSwitchTile(
              icon: Icons.backup,
              title: 'Auto Backup',
              subtitle: 'Backup data to cloud',
              value: _enableAutoBackup,
              onChanged: (value) {
                setState(() {
                  _enableAutoBackup = value;
                });
                _saveUserPreferences();
              },
            ),
            const Divider(),
            _buildActionTile(
              icon: Icons.security,
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              onTap: () => _showPrivacyPolicy(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildActionTile(
              icon: Icons.person,
              title: 'Edit Profile',
              subtitle: 'Update your profile information',
              onTap: () => _showEditProfileDialog(),
            ),
            const Divider(),
            _buildActionTile(
              icon: Icons.key,
              title: 'Change Password',
              subtitle: 'Update your account password',
              onTap: () => _showChangePasswordDialog(),
            ),
            const Divider(),
            _buildActionTile(
              icon: Icons.share,
              title: 'Share App',
              subtitle: 'Tell friends about LingoSphere',
              onTap: () => _shareApp(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildActionTile(
              icon: Icons.help,
              title: 'Help Center',
              subtitle: 'Get help and tutorials',
              onTap: () => _showHelpCenter(),
            ),
            const Divider(),
            _buildActionTile(
              icon: Icons.bug_report,
              title: 'Report Bug',
              subtitle: 'Report issues or bugs',
              onTap: () => _reportBug(),
            ),
            const Divider(),
            _buildActionTile(
              icon: Icons.star,
              title: 'Rate App',
              subtitle: 'Rate us on the app store',
              onTap: () => _rateApp(),
            ),
            const Divider(),
            _buildActionTile(
              icon: Icons.science,
              title: 'Test Voice Features',
              subtitle: 'Run comprehensive voice translation tests',
              onTap: () => AppNavigation.toVoiceTranslationTest(context),
            ),
            const Divider(),
            _buildActionTile(
              icon: Icons.info,
              title: 'About',
              subtitle: 'App version and info',
              onTap: () => _showAboutDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryBlue),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppTheme.gray900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppTheme.gray600),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryBlue,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryBlue),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppTheme.gray900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppTheme.gray600),
      ),
      trailing: DropdownButton<String>(
        value: value,
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
        onChanged: onChanged,
        underline: const SizedBox(),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryBlue),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppTheme.gray900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppTheme.gray600),
      ),
      trailing: trailing ??
          const Icon(
            Icons.chevron_right,
            color: AppTheme.gray400,
          ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  // Action methods
  void _showTranslationSpeedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Translation Speed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Fast'),
              subtitle: const Text('Quick but basic translation'),
              value: 'fast',
              groupValue: 'balanced',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('Balanced'),
              subtitle: const Text('Good speed and accuracy'),
              value: 'balanced',
              groupValue: 'balanced',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('Accurate'),
              subtitle: const Text('Slower but more accurate'),
              value: 'accurate',
              groupValue: 'balanced',
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'LingoSphere Privacy Policy\n\n'
            'We respect your privacy and are committed to protecting your personal data. '
            'This privacy policy explains how we collect, use, and safeguard your information.\n\n'
            '1. Information We Collect\n'
            '2. How We Use Your Information\n'
            '3. Data Security\n'
            '4. Your Rights\n'
            '5. Contact Us',
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: 'LingoSphere User'),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: 'user@lingosphere.app'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _shareApp() {
    showDialog(
      context: context,
      builder: (context) => ShareDialog(
        title: 'Share LingoSphere',
        content: ShareContent(
          type: ShareContentType.text,
          text:
              'Check out LingoSphere - the best AI-powered translation app!\n\n'
              'Available on App Store and Google Play.',
          subject: 'LingoSphere - AI Translation App',
        ),
      ),
    );
  }

  void _showHelpCenter() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Help Center coming soon!'),
        backgroundColor: AppTheme.primaryBlue,
      ),
    );
  }

  void _reportBug() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bug report feature coming soon!'),
        backgroundColor: AppTheme.warningAmber,
      ),
    );
  }

  void _rateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Redirecting to app store...'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'LingoSphere',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.language,
          color: AppTheme.white,
          size: 32,
        ),
      ),
      children: const [
        Text(
          'AI-powered multilingual translation app with advanced features '
          'including camera OCR, voice translation, and real-time conversation support.',
        ),
        SizedBox(height: 16),
        Text('© 2024 LingoSphere. All rights reserved.'),
      ],
    );
  }
}
