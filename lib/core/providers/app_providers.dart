// 🌐 LingoSphere - App Providers
// Comprehensive dependency injection setup for all app services

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/history_service.dart';
import '../services/export_service.dart';
import '../services/offline_sync_service.dart';
import '../services/analytics_service.dart';
import '../services/feature_discovery_service.dart';
import '../services/native_sharing_service.dart';
import '../services/translation_service.dart';
import '../services/voice_service.dart';
import '../services/camera_ocr_service.dart';
import '../services/enhanced_email_sharing_service.dart';
import '../services/tts_service.dart';
import '../services/whatsapp_service.dart';
import '../../features/history/services/translation_history_integration_service.dart';

/// Core Services Providers
///
/// Translation Service - Core translation functionality
final translationServiceProvider = Provider<TranslationService>((ref) {
  return TranslationService();
});

/// History Service - Translation history management
final historyServiceProvider = Provider<HistoryService>((ref) {
  return HistoryService();
});

/// Export Service - File export functionality
final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService();
});

/// Offline Sync Service - Background sync and conflict resolution
final offlineSyncServiceProvider =
    ChangeNotifierProvider<OfflineSyncService>((ref) {
  final historyService = ref.watch(historyServiceProvider);
  return OfflineSyncService(historyService);
});

/// Analytics Service - Usage analytics and insights
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

/// Feature Discovery Service - Onboarding and feature highlights
final featureDiscoveryServiceProvider =
    ChangeNotifierProvider<FeatureDiscoveryService>((ref) {
  return FeatureDiscoveryService();
});

/// Native Sharing Service - Platform-specific sharing
final nativeSharingServiceProvider = Provider<NativeSharingService>((ref) {
  return NativeSharingService();
});

/// Enhanced Email Sharing Service - Rich email templates
final enhancedEmailSharingServiceProvider =
    Provider<EnhancedEmailSharingService>((ref) {
  return EnhancedEmailSharingService();
});

/// Translation Services Providers
///
/// Voice Service - Voice recording and processing
final voiceServiceProvider = Provider<VoiceService>((ref) {
  return VoiceService();
});

/// TTS Service - Text-to-speech functionality
final ttsServiceProvider = Provider<TTSService>((ref) {
  return TTSService();
});

/// Camera OCR Service - Image text recognition
final cameraOcrServiceProvider = Provider<CameraOCRService>((ref) {
  return CameraOCRService();
});

/// Integration Services Providers
///
/// Translation History Integration - Unified history management
final translationHistoryIntegrationProvider =
    Provider<TranslationHistoryIntegration>((ref) {
  final historyService = ref.watch(historyServiceProvider);
  final offlineSyncService = ref.watch(offlineSyncServiceProvider);
  return TranslationHistoryIntegration(historyService, offlineSyncService);
});

/// Communication Services Providers
///
/// WhatsApp Service - WhatsApp Business API integration
final whatsappServiceProvider = Provider<WhatsAppService>((ref) {
  return WhatsAppService();
});

/// App State Providers
///
/// Current navigation state
final currentNavigationIndexProvider = StateProvider<int>((ref) => 0);

/// Theme mode provider
final themeModeProvider =
    StateProvider<bool>((ref) => false); // false = light, true = dark

/// Language preference provider
final languagePreferenceProvider = StateProvider<String>((ref) => 'en');

/// First launch state
final isFirstLaunchProvider = StateProvider<bool>((ref) => true);

/// Network connectivity state
final isOnlineProvider = StateProvider<bool>((ref) => true);

/// Voice recording state
final isRecordingProvider = StateProvider<bool>((ref) => false);

/// Camera permission state
final hasCameraPermissionProvider = StateProvider<bool>((ref) => false);

/// Microphone permission state
final hasMicrophonePermissionProvider = StateProvider<bool>((ref) => false);

/// Computed Providers
///
/// Combined sync status provider
final syncStatusProvider = Provider<Map<String, dynamic>>((ref) {
  final offlineSyncService = ref.watch(offlineSyncServiceProvider);
  final isOnline = ref.watch(isOnlineProvider);

  return {
    'status': offlineSyncService.syncStatus,
    'isOnline': isOnline,
    'pendingOperations': offlineSyncService.pendingOperationsCount,
    'conflicts': offlineSyncService.conflicts.length,
    'lastSync':
        DateTime.now().toIso8601String(), // TODO: Get actual last sync time
  };
});

/// Service initialization status provider
final serviceInitializationProvider = FutureProvider<bool>((ref) async {
  try {
    // Initialize core services
    await ref.read(translationServiceProvider).initialize();
    await ref.read(historyServiceProvider).initialize();
    await ref.read(featureDiscoveryServiceProvider).initialize();

    // Initialize analytics if enabled
    final analyticsService = ref.read(analyticsServiceProvider);
    await analyticsService.initialize();

    // Initialize TTS service
    final ttsService = ref.read(ttsServiceProvider);
    await ttsService.initialize();

    return true;
  } catch (e) {
    // Log error but don't fail app initialization
    print('Service initialization error: $e');
    return false;
  }
});

/// Provider Overrides for Testing
///
/// Use these overrides in tests to provide mock implementations

List<Override> getTestProviders() {
  return [
    // Add test overrides here
    // Example:
    // translationServiceProvider.overrideWithValue(MockTranslationService()),
  ];
}

/// Provider Container Extensions
///
extension AppProviderContainer on ProviderContainer {
  /// Get translation service
  TranslationService get translationService => read(translationServiceProvider);

  /// Get history service
  HistoryService get historyService => read(historyServiceProvider);

  /// Get analytics service
  AnalyticsService get analyticsService => read(analyticsServiceProvider);

  /// Get sharing service
  NativeSharingService get sharingService => read(nativeSharingServiceProvider);

  /// Initialize all services
  Future<void> initializeServices() async {
    await read(serviceInitializationProvider.future);
  }
}

/// Provider Scope Widget Helper
///
class AppProviderScope extends ConsumerWidget {
  final Widget child;
  final List<Override>? overrides;

  const AppProviderScope({
    super.key,
    required this.child,
    this.overrides,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: overrides ?? [],
      child: child,
    );
  }
}

/// Provider Listener Helper
///
class ServiceStatusListener extends ConsumerWidget {
  final Widget child;

  const ServiceStatusListener({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to service initialization
    ref.listen<AsyncValue<bool>>(serviceInitializationProvider,
        (previous, next) {
      next.when(
        data: (initialized) {
          if (initialized) {
            print('✅ All services initialized successfully');
          } else {
            print('⚠️ Service initialization completed with warnings');
          }
        },
        loading: () => print('🔄 Initializing services...'),
        error: (error, stack) =>
            print('❌ Service initialization failed: $error'),
      );
    });

    // Listen to sync status changes
    ref.listen(syncStatusProvider, (previous, next) {
      if (previous != null && previous != next) {
        final conflicts = next['conflicts'] as int;
        if (conflicts > 0) {
          print('⚠️ Sync conflicts detected: $conflicts');
        }
      }
    });

    return child;
  }
}

/// Global Provider Access Helper
///
class AppServices {
  static final _container = ProviderContainer();

  /// Get the global provider container
  static ProviderContainer get container => _container;

  /// Initialize all services globally
  static Future<void> initialize() async {
    await _container.initializeServices();
  }

  /// Dispose global container
  static void dispose() {
    _container.dispose();
  }

  /// Quick access to services
  static TranslationService get translation => _container.translationService;

  static HistoryService get history => _container.historyService;

  static AnalyticsService get analytics => _container.analyticsService;

  static NativeSharingService get sharing => _container.sharingService;
}
