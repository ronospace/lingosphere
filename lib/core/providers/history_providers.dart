// 🌐 LingoSphere - History Service Providers
// Dependency injection setup for all history-related services

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../services/history_service.dart';
import '../services/export_service.dart';
import '../services/offline_sync_service.dart';

/// Provider setup for all history-related services
class HistoryProviders {
  /// Create all history service providers
  static List<SingleChildWidget> getProviders() {
    return [
      // History Service - Core database operations
      Provider<HistoryService>(
        create: (context) => HistoryService(),
        lazy: false, // Initialize immediately
      ),

      // Export Service - File export functionality
      Provider<ExportService>(
        create: (context) => ExportService(),
        lazy: true, // Initialize when needed
      ),

      // Offline Sync Service - Synchronization and conflict resolution
      ProxyProvider<HistoryService, OfflineSyncService>(
        create: (context) => OfflineSyncService(
          context.read<HistoryService>(),
        ),
        update: (context, historyService, previousSyncService) =>
            previousSyncService ?? OfflineSyncService(historyService),
        lazy: false, // Initialize immediately for background sync
      ),
    ];
  }

  /// Initialize all services (call this during app startup)
  static Future<void> initializeServices() async {
    try {
      debugPrint('🔄 Initializing history services...');

      // Any additional initialization logic can go here
      // For example, database migrations, cache warming, etc.

      debugPrint('✅ History services initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize history services: $e');
      rethrow;
    }
  }

  /// Dispose all services (call this during app shutdown)
  static Future<void> disposeServices() async {
    try {
      debugPrint('🔄 Disposing history services...');

      // Any cleanup logic can go here
      // Services will be disposed automatically by Provider

      debugPrint('✅ History services disposed successfully');
    } catch (e) {
      debugPrint('❌ Failed to dispose history services: $e');
      rethrow;
    }
  }
}

/// Extension methods for easy access to history services
extension HistoryServiceExtension on BuildContext {
  /// Get HistoryService instance
  HistoryService get historyService => read<HistoryService>();

  /// Watch HistoryService for changes
  HistoryService get watchHistoryService => watch<HistoryService>();

  /// Get ExportService instance
  ExportService get exportService => read<ExportService>();

  /// Get OfflineSyncService instance
  OfflineSyncService get offlineSyncService => read<OfflineSyncService>();

  /// Watch OfflineSyncService for changes
  OfflineSyncService get watchOfflineSyncService => watch<OfflineSyncService>();
}

/// Service locator for accessing services without BuildContext
class HistoryServiceLocator {
  static HistoryService? _historyService;
  static ExportService? _exportService;
  static OfflineSyncService? _offlineSyncService;

  /// Initialize the service locator
  static void initialize({
    required HistoryService historyService,
    required ExportService exportService,
    required OfflineSyncService offlineSyncService,
  }) {
    _historyService = historyService;
    _exportService = exportService;
    _offlineSyncService = offlineSyncService;
  }

  /// Get HistoryService instance
  static HistoryService get historyService {
    if (_historyService == null) {
      throw Exception(
          'HistoryServiceLocator not initialized. Call initialize() first.');
    }
    return _historyService!;
  }

  /// Get ExportService instance
  static ExportService get exportService {
    if (_exportService == null) {
      throw Exception(
          'HistoryServiceLocator not initialized. Call initialize() first.');
    }
    return _exportService!;
  }

  /// Get OfflineSyncService instance
  static OfflineSyncService get offlineSyncService {
    if (_offlineSyncService == null) {
      throw Exception(
          'HistoryServiceLocator not initialized. Call initialize() first.');
    }
    return _offlineSyncService!;
  }

  /// Clear the service locator
  static void dispose() {
    _historyService = null;
    _exportService = null;
    _offlineSyncService = null;
  }
}

/// Mixin for widgets that need history services
mixin HistoryServiceMixin<T extends StatefulWidget> on State<T> {
  late HistoryService _historyService;
  late ExportService _exportService;
  late OfflineSyncService _offlineSyncService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _historyService = context.read<HistoryService>();
    _exportService = context.read<ExportService>();
    _offlineSyncService = context.read<OfflineSyncService>();
  }

  /// Access to HistoryService
  HistoryService get historyService => _historyService;

  /// Access to ExportService
  ExportService get exportService => _exportService;

  /// Access to OfflineSyncService
  OfflineSyncService get offlineSyncService => _offlineSyncService;
}

/// Provider for history configuration
class HistoryConfig extends ChangeNotifier {
  bool _enableOfflineSync = true;
  bool _enableAnalytics = true;
  bool _enableExport = true;
  int _maxHistoryItems = 10000;
  Duration _syncInterval = const Duration(minutes: 5);

  // Getters
  bool get enableOfflineSync => _enableOfflineSync;
  bool get enableAnalytics => _enableAnalytics;
  bool get enableExport => _enableExport;
  int get maxHistoryItems => _maxHistoryItems;
  Duration get syncInterval => _syncInterval;

  // Setters
  set enableOfflineSync(bool value) {
    if (_enableOfflineSync != value) {
      _enableOfflineSync = value;
      notifyListeners();
    }
  }

  set enableAnalytics(bool value) {
    if (_enableAnalytics != value) {
      _enableAnalytics = value;
      notifyListeners();
    }
  }

  set enableExport(bool value) {
    if (_enableExport != value) {
      _enableExport = value;
      notifyListeners();
    }
  }

  set maxHistoryItems(int value) {
    if (_maxHistoryItems != value && value > 0) {
      _maxHistoryItems = value;
      notifyListeners();
    }
  }

  set syncInterval(Duration value) {
    if (_syncInterval != value) {
      _syncInterval = value;
      notifyListeners();
    }
  }

  /// Load configuration from storage
  Future<void> loadConfiguration() async {
    try {
      // TODO: Load from SharedPreferences or other storage
      // For now, using default values
      debugPrint('📋 History configuration loaded');
    } catch (e) {
      debugPrint('❌ Failed to load history configuration: $e');
    }
  }

  /// Save configuration to storage
  Future<void> saveConfiguration() async {
    try {
      // TODO: Save to SharedPreferences or other storage
      debugPrint('💾 History configuration saved');
    } catch (e) {
      debugPrint('❌ Failed to save history configuration: $e');
    }
  }

  /// Reset to default configuration
  void resetToDefaults() {
    _enableOfflineSync = true;
    _enableAnalytics = true;
    _enableExport = true;
    _maxHistoryItems = 10000;
    _syncInterval = const Duration(minutes: 5);
    notifyListeners();
  }
}

/// Complete provider setup including configuration
class CompleteHistoryProviders {
  /// Get all providers including configuration
  static List<SingleChildWidget> getAllProviders() {
    return [
      // Configuration provider
      ChangeNotifierProvider<HistoryConfig>(
        create: (context) => HistoryConfig(),
        lazy: false,
      ),

      // Core service providers
      ...HistoryProviders.getProviders(),
    ];
  }

  /// Initialize all services and configuration
  static Future<void> initialize() async {
    await HistoryProviders.initializeServices();
    debugPrint('🚀 Complete history system initialized');
  }

  /// Dispose all services and configuration
  static Future<void> dispose() async {
    await HistoryProviders.disposeServices();
    HistoryServiceLocator.dispose();
    debugPrint('🛑 Complete history system disposed');
  }
}
