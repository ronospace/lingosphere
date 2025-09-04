// 🌐 LingoSphere - Main App Screen with Advanced Navigation
// Modern navigation system with bottom nav, drawer, and feature integration

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/navigation/app_navigation.dart';
import '../../../core/services/history_service.dart';
import '../../../core/services/offline_sync_service.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/widgets/sharing/quick_share_button.dart';
import '../../home/presentation/enhanced_dashboard_screen.dart';
import '../../camera/presentation/camera_translation_screen.dart';
import '../../voice/presentation/voice_translation_screen.dart';
import '../../history/screens/enhanced_history_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../../main.dart';

/// Navigation destinations
enum NavigationDestination {
  home,
  camera,
  voice,
  history,
  profile,
}

/// Main app screen with advanced navigation
class MainAppScreen extends ConsumerStatefulWidget {
  const MainAppScreen({super.key});

  @override
  ConsumerState<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends ConsumerState<MainAppScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  NavigationDestination _currentDestination = NavigationDestination.home;
  late AnimationController _fabAnimationController;
  late AnimationController _bottomNavAnimationController;
  bool _isKeyboardVisible = false;

  final PageController _pageController = PageController();

  // Screen instances
  late final List<Widget> _screens = [
    const EnhancedDashboardScreen(),
    const CameraTranslationScreen(),
    const VoiceTranslationScreen(),
    const EnhancedHistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fabAnimationController.dispose();
    _bottomNavAnimationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _bottomNavAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabAnimationController.forward();
    _bottomNavAnimationController.forward();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final newKeyboardVisible = bottomInset > 0;

    if (_isKeyboardVisible != newKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = newKeyboardVisible;
      });

      if (_isKeyboardVisible) {
        _bottomNavAnimationController.reverse();
        _fabAnimationController.reverse();
      } else {
        _bottomNavAnimationController.forward();
        _fabAnimationController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentDestination = NavigationDestination.values[index];
          });
          _triggerHapticFeedback();
        },
        itemCount: _screens.length,
        itemBuilder: (context, index) {
          return AnimationLimiter(
            child: _screens[index],
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      drawer: _buildNavigationDrawer(),
      extendBody: true,
    );
  }

  Widget _buildBottomNavigationBar() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _bottomNavAnimationController,
        curve: Curves.easeInOut,
      )),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          boxShadow: [
            BoxShadow(
              color: AppTheme.gray900.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _currentDestination.index,
            onTap: _onDestinationTapped,
            selectedItemColor: AppTheme.primaryBlue,
            unselectedItemColor: AppTheme.gray400,
            selectedLabelStyle: const TextStyle(
              fontFamily: AppTheme.primaryFontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: AppTheme.primaryFontFamily,
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
            items: [
              _buildNavItem(
                Icons.home_outlined,
                Icons.home,
                'Home',
                NavigationDestination.home,
              ),
              _buildNavItem(
                Icons.camera_alt_outlined,
                Icons.camera_alt,
                'Camera',
                NavigationDestination.camera,
              ),
              const BottomNavigationBarItem(
                icon: SizedBox(width: 24, height: 24), // Space for FAB
                label: '',
              ),
              _buildNavItem(
                Icons.history_outlined,
                Icons.history,
                'History',
                NavigationDestination.history,
              ),
              _buildNavItem(
                Icons.person_outline,
                Icons.person,
                'Profile',
                NavigationDestination.profile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
    NavigationDestination destination,
  ) {
    final isSelected = _currentDestination == destination;

    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(isSelected ? activeIcon : icon),
      ),
      label: label,
    );
  }

  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: _fabAnimationController,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppTheme.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _onVoiceFabTapped,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _currentDestination == NavigationDestination.voice
                  ? Icons.stop
                  : Icons.mic,
              key: ValueKey(_currentDestination == NavigationDestination.voice),
              color: AppTheme.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationDrawer() {
    return Drawer(
      backgroundColor: AppTheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(child: _buildDrawerContent()),
          _buildDrawerFooter(),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.language,
              color: AppTheme.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LingoSphere',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppTheme.headingFontFamily,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'AI-Powered Translation',
                  style: TextStyle(
                    color: AppTheme.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerContent() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        _buildDrawerSection('TRANSLATION', [
          _DrawerItem(
            icon: Icons.translate,
            title: 'Text Translation',
            onTap: () => _navigateToDestination(NavigationDestination.home),
          ),
          _DrawerItem(
            icon: Icons.camera_alt,
            title: 'Camera OCR',
            onTap: () => _navigateToDestination(NavigationDestination.camera),
          ),
          _DrawerItem(
            icon: Icons.mic,
            title: 'Voice Translation',
            onTap: () => _navigateToDestination(NavigationDestination.voice),
          ),
        ]),
        const SizedBox(height: 16),
        _buildDrawerSection('HISTORY & DATA', [
          _DrawerItem(
            icon: Icons.history,
            title: 'Translation History',
            onTap: () => _navigateToDestination(NavigationDestination.history),
          ),
          _DrawerItem(
            icon: Icons.analytics,
            title: 'Statistics',
            onTap: () => AppNavigation.toStatistics(context),
          ),
          Consumer(
            builder: (context, ref, child) {
              final syncService = ref.watch(offlineSyncServiceProvider);
              final hasConflicts = syncService.conflicts.isNotEmpty;
              return _DrawerItem(
                icon: hasConflicts ? Icons.warning_amber : Icons.sync,
                title: hasConflicts
                    ? 'Resolve Conflicts (${syncService.conflicts.length})'
                    : 'Sync Status',
                badge: hasConflicts ? syncService.conflicts.length : null,
                onTap: () {
                  Navigator.pop(context);
                  if (hasConflicts) {
                    AppNavigation.toConflictResolution(context);
                  } else {
                    _showSyncStatus(syncService);
                  }
                },
              );
            },
          ),
        ]),
        const SizedBox(height: 16),
        _buildDrawerSection('SETTINGS', [
          _DrawerItem(
            icon: Icons.settings,
            title: 'App Settings',
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to settings
            },
          ),
          _DrawerItem(
            icon: Icons.language,
            title: 'Language Preferences',
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to language settings
            },
          ),
          _DrawerItem(
            icon: Icons.help,
            title: 'Help & Support',
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to help
            },
          ),
        ]),
      ],
    );
  }

  Widget _buildDrawerSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildDrawerFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.gray200)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.language,
            color: AppTheme.primaryBlue,
            size: 20,
          ),
          const SizedBox(width: 12),
          const Text(
            'LingoSphere v1.0.0',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppTheme.gray600,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              // TODO: Show about dialog
            },
            icon: const Icon(
              Icons.info_outline,
              color: AppTheme.gray500,
            ),
          ),
        ],
      ),
    );
  }

  // Navigation methods
  void _onDestinationTapped(int index) {
    // Skip middle index (FAB placeholder)
    if (index == 2) return;

    // Adjust for FAB placeholder
    final adjustedIndex = index > 2 ? index - 1 : index;
    final destination = NavigationDestination.values[adjustedIndex];

    _navigateToDestination(destination);
  }

  void _navigateToDestination(NavigationDestination destination) {
    if (destination == _currentDestination) return;

    setState(() {
      _currentDestination = destination;
    });

    _pageController.animateToPage(
      destination.index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    _triggerHapticFeedback();
    Navigator.pop(context); // Close drawer if open
  }

  void _onVoiceFabTapped() {
    if (_currentDestination == NavigationDestination.voice) {
      // Stop voice translation if currently active
      // TODO: Implement voice translation stop
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice translation stopped'),
          backgroundColor: AppTheme.warningAmber,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // Navigate to voice translation
      _navigateToDestination(NavigationDestination.voice);
    }
  }

  void _triggerHapticFeedback() {
    HapticFeedback.lightImpact();
  }

  void _showSyncStatus(OfflineSyncService syncService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.sync,
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(width: 12),
            const Text('Sync Status'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusRow('Status', syncService.syncStatus.name),
            _buildStatusRow('Online', syncService.isOnline ? 'Yes' : 'No'),
            _buildStatusRow(
                'Pending Operations', '${syncService.pendingOperationsCount}'),
            _buildStatusRow('Conflicts', '${syncService.conflicts.length}'),
            _buildStatusRow(
                'Last Sync', 'Just now'), // TODO: Add actual last sync time
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (syncService.isOnline)
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await syncService.triggerManualSync();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sync completed successfully'),
                        backgroundColor: AppTheme.successGreen,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sync failed: $e'),
                        backgroundColor: AppTheme.errorRed,
                      ),
                    );
                  }
                }
              },
              child: const Text('Sync Now'),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.gray700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.gray600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Drawer item widget
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final int? badge;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryBlue,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppTheme.gray800,
        ),
      ),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.errorRed,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge.toString(),
                style: const TextStyle(
                  color: AppTheme.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : const Icon(
              Icons.chevron_right,
              color: AppTheme.gray400,
            ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
