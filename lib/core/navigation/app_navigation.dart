// 🌐 LingoSphere - App Navigation with History Integration
// Navigation helper that includes all history-related routes and navigation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/history/screens/enhanced_history_screen.dart';
import '../../features/history/screens/statistics_dashboard.dart';
import '../../features/history/screens/conflict_resolution_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/main/presentation/main_app_screen.dart';
import '../../features/analytics/presentation/analytics_dashboard_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/camera/presentation/camera_translation_screen.dart';
import '../../features/voice/presentation/voice_translation_screen.dart';
import '../../features/voice/presentation/voice_translation_test_screen.dart';
import '../services/history_service.dart';
import '../services/offline_sync_service.dart';

/// Navigation routes for the app
class AppRoutes {
  static const String home = '/';
  static const String history = '/history';
  static const String statistics = '/statistics';
  static const String conflicts = '/conflicts';
  static const String export = '/export';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String onboarding = '/onboarding';
  static const String camera = '/camera';
  static const String voice = '/voice';
  static const String voiceTest = '/voice-test';
  static const String analytics = '/analytics';
  static const String mainApp = '/main';
}

/// Navigation helper class with history integration
class AppNavigation {
  /// Navigate to enhanced history screen
  static void toHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EnhancedHistoryScreen(),
        settings: const RouteSettings(name: AppRoutes.history),
      ),
    );
  }

  /// Navigate to statistics dashboard
  static void toStatistics(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StatisticsDashboard(
          historyService: context.read<HistoryService>(),
        ),
        settings: const RouteSettings(name: AppRoutes.statistics),
      ),
    );
  }

  /// Navigate to conflict resolution screen
  static void toConflictResolution(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConflictResolutionScreen(
          syncService: context.read<OfflineSyncService>(),
        ),
        settings: const RouteSettings(name: AppRoutes.conflicts),
      ),
    );
  }

  /// Navigate to voice translation test screen
  static void toVoiceTranslationTest(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const VoiceTranslationTestScreen(),
        settings: const RouteSettings(name: AppRoutes.voiceTest),
      ),
    );
  }

  /// Show export dialog
  static void showExportDialog(BuildContext context) {
    // Implementation moved to EnhancedHistoryScreen
    toHistory(context);
  }

  /// Navigate back with result
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop(result);
  }

  /// Navigate to home and clear stack
  static void toHomeAndClearStack(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }

  /// Replace current route
  static void replaceCurrent(BuildContext context, Widget screen,
      {String? routeName}) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => screen,
        settings: RouteSettings(name: routeName),
      ),
    );
  }

  /// Check if can go back
  static bool canPop(BuildContext context) {
    return Navigator.of(context).canPop();
  }

  /// Get current route name
  static String? getCurrentRouteName(BuildContext context) {
    return ModalRoute.of(context)?.settings.name;
  }
}

/// Navigation observer for analytics and monitoring
class AppNavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logNavigation('push', route.settings.name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _logNavigation('pop', route.settings.name);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _logNavigation('replace', newRoute?.settings.name);
  }

  void _logNavigation(String action, String? routeName) {
    debugPrint('Navigation: $action -> ${routeName ?? 'unknown'}');
    // TODO: Add analytics tracking here
  }
}

/// Bottom navigation items configuration
class AppBottomNavigation {
  /// Get bottom navigation bar items
  static List<BottomNavigationBarItem> getItems() {
    return [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.camera_alt_outlined),
        activeIcon: Icon(Icons.camera_alt),
        label: 'Camera',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.mic_outlined),
        activeIcon: Icon(Icons.mic),
        label: 'Voice',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.history_outlined),
        activeIcon: Icon(Icons.history),
        label: 'History',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outlined),
        activeIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];
  }

  /// Handle bottom navigation tap
  static void onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        // Navigate to home
        AppNavigation.toHomeAndClearStack(context);
        break;
      case 1:
        // Navigate to camera
        Navigator.of(context).pushNamed(AppRoutes.camera);
        break;
      case 2:
        // Navigate to voice
        Navigator.of(context).pushNamed(AppRoutes.voice);
        break;
      case 3:
        // Navigate to history
        AppNavigation.toHistory(context);
        break;
      case 4:
        // Navigate to profile
        Navigator.of(context).pushNamed(AppRoutes.profile);
        break;
    }
  }
}

/// App drawer configuration
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer header
          UserAccountsDrawerHeader(
            accountName: const Text('LingoSphere User'),
            accountEmail: const Text('user@lingosphere.app'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),

          // Navigation items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () {
                    Navigator.of(context).pop();
                    AppNavigation.toHomeAndClearStack(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Translation History'),
                  onTap: () {
                    Navigator.of(context).pop();
                    AppNavigation.toHistory(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.analytics),
                  title: const Text('Statistics'),
                  onTap: () {
                    Navigator.of(context).pop();
                    AppNavigation.toStatistics(context);
                  },
                ),
                Consumer<OfflineSyncService>(
                  builder: (context, syncService, child) {
                    final hasConflicts = syncService.conflicts.isNotEmpty;
                    return ListTile(
                      leading: Icon(
                        Icons.warning_amber,
                        color: hasConflicts ? Colors.orange : null,
                      ),
                      title: Text(hasConflicts
                          ? 'Resolve Conflicts (${syncService.conflicts.length})'
                          : 'Sync Status'),
                      onTap: () {
                        Navigator.of(context).pop();
                        if (hasConflicts) {
                          AppNavigation.toConflictResolution(context);
                        } else {
                          // Show sync status dialog
                          _showSyncStatusDialog(context, syncService);
                        }
                      },
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed(AppRoutes.settings);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help & Support'),
                  onTap: () {
                    Navigator.of(context).pop();
                    // TODO: Navigate to help screen
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('About'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.language,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'LingoSphere v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSyncStatusDialog(
      BuildContext context, OfflineSyncService syncService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusRow('Status', syncService.syncStatus.name),
            _buildStatusRow('Online', syncService.isOnline ? 'Yes' : 'No'),
            _buildStatusRow(
                'Pending Operations', '${syncService.pendingOperationsCount}'),
            _buildStatusRow('Conflicts', '${syncService.conflicts.length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (syncService.isOnline)
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await syncService.triggerManualSync();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Manual sync completed'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sync failed: $e'),
                        backgroundColor: Colors.red,
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'LingoSphere',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.language,
        size: 64,
        color: Theme.of(context).primaryColor,
      ),
      children: [
        const Text(
          'Advanced multilingual translation app with AI-powered insights and real-time group chat translation.',
        ),
        const SizedBox(height: 16),
        const Text('Features:'),
        const Text('• Camera OCR Translation'),
        const Text('• Voice Translation'),
        const Text('• Advanced History Management'),
        const Text('• Offline Sync'),
        const Text('• Translation Analytics'),
        const Text('• Export & Sharing'),
      ],
    );
  }
}

/// Route generator for named routes
class AppRouteGenerator {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
      case AppRoutes.mainApp:
        return MaterialPageRoute(
          builder: (context) => const MainAppScreen(),
          settings: settings,
        );

      case AppRoutes.onboarding:
        return MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
          settings: settings,
        );

      case AppRoutes.camera:
        return MaterialPageRoute(
          builder: (context) => const CameraTranslationScreen(),
          settings: settings,
        );

      case AppRoutes.voice:
        return MaterialPageRoute(
          builder: (context) => const VoiceTranslationScreen(),
          settings: settings,
        );

      case AppRoutes.history:
        return MaterialPageRoute(
          builder: (context) => const EnhancedHistoryScreen(),
          settings: settings,
        );

      case AppRoutes.analytics:
      case AppRoutes.statistics:
        return MaterialPageRoute(
          builder: (context) => const AnalyticsDashboardScreen(),
          settings: settings,
        );

      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
          settings: settings,
        );

      case AppRoutes.conflicts:
        return MaterialPageRoute(
          builder: (context) => ConflictResolutionScreen(
            syncService:
                Provider.of<OfflineSyncService>(context, listen: false),
          ),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: const Center(
              child: Text('This page does not exist.'),
            ),
          ),
          settings: settings,
        );
    }
  }
}
