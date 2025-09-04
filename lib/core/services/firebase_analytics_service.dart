// 🌐 LingoSphere - Firebase Analytics Service
// Comprehensive event tracking and user analytics with Firebase

import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:logger/logger.dart';
import '../models/translation_models.dart';
import '../constants/app_constants.dart';

class FirebaseAnalyticsService {
  static final FirebaseAnalyticsService _instance = FirebaseAnalyticsService._internal();
  factory FirebaseAnalyticsService() => _instance;
  FirebaseAnalyticsService._internal();
  
  FirebaseAnalytics? _analytics;
  final Logger _logger = Logger();
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  bool _isInitialized = false;
  String? _userId;
  Map<String, dynamic> _userProperties = {};

  /// Initialize Firebase Analytics
  Future<void> initialize() async {
    try {
      _analytics = FirebaseAnalytics.instance;
      await _analytics!.setAnalyticsCollectionEnabled(true);
      
      // Set default user properties
      await setUserProperty('app_version', AppConstants.appVersion);
      await setUserProperty('platform', 'flutter_mobile');
      await setUserProperty('session_start', DateTime.now().millisecondsSinceEpoch.toString());
      
      _isInitialized = true;
      _logger.i('Firebase Analytics Service initialized');
      
      // Log initialization event
      await logEvent('analytics_service_initialized', {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'success': true,
      });
      
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize Firebase Analytics: $e');
      _crashlytics.recordError(e, stackTrace, fatal: false);
    }
  }

  /// Set user ID for analytics
  Future<void> setUserId(String userId) async {
    try {
      _userId = userId;
      await _analytics?.setUserId(id: userId);
      await _crashlytics.setUserIdentifier(userId);
      
      await logEvent('user_identified', {
        'user_id': userId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      
      _logger.d('User ID set: $userId');
    } catch (e) {
      _logger.e('Failed to set user ID: $e');
    }
  }

  /// Set user property
  Future<void> setUserProperty(String name, String? value) async {
    try {
      await _analytics?.setUserProperty(name: name, value: value);
      _userProperties[name] = value;
      _logger.d('User property set: $name = $value');
    } catch (e) {
      _logger.e('Failed to set user property $name: $e');
    }
  }

  /// Log custom event
  Future<void> logEvent(String name, Map<String, Object>? parameters) async {
    try {
      if (!_isInitialized) {
        _logger.w('Analytics not initialized, queuing event: $name');
        // Could implement event queuing here
        return;
      }

      await _analytics?.logEvent(
        name: name,
        parameters: parameters,
      );
      
      _logger.d('Event logged: $name with parameters: $parameters');
    } catch (e) {
      _logger.e('Failed to log event $name: $e');
    }
  }

  /// Translation Analytics Events

  /// Log translation request
  Future<void> logTranslationRequest({
    required String sourceLanguage,
    required String targetLanguage,
    required String provider,
    required int textLength,
    String? mode,
  }) async {
    await logEvent('translation_requested', {
      'source_language': sourceLanguage,
      'target_language': targetLanguage,
      'provider': provider,
      'text_length': textLength,
      'mode': mode ?? 'text',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Log translation completed
  Future<void> logTranslationCompleted({
    required TranslationResult result,
    required Duration processingTime,
    String? mode,
  }) async {
    await logEvent('translation_completed', {
      'source_language': result.sourceLanguage,
      'target_language': result.targetLanguage,
      'provider': result.provider,
      'confidence': result.confidence.name,
      'confidence_percentage': result.confidencePercentage,
      'processing_time_ms': processingTime.inMilliseconds,
      'text_length': result.originalText.length,
      'mode': mode ?? 'text',
      'sentiment': result.sentiment.sentiment.name,
      'formality': result.context.formality.name,
      'domain': result.context.domain.name,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Log translation error
  Future<void> logTranslationError({
    required String error,
    required String sourceLanguage,
    required String targetLanguage,
    String? provider,
  }) async {
    await logEvent('translation_error', {
      'error_type': error,
      'source_language': sourceLanguage,
      'target_language': targetLanguage,
      'provider': provider ?? 'unknown',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Voice Translation Analytics

  /// Log voice translation session started
  Future<void> logVoiceSessionStarted({
    required String sourceLanguage,
    required String targetLanguage,
    required String mode,
  }) async {
    await logEvent('voice_session_started', {
      'source_language': sourceLanguage,
      'target_language': targetLanguage,
      'mode': mode,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Log voice recognition result
  Future<void> logVoiceRecognition({
    required double confidence,
    required bool isFinal,
    required String language,
    required int textLength,
  }) async {
    if (isFinal) {
      await logEvent('voice_recognition_final', {
        'confidence': confidence,
        'language': language,
        'text_length': textLength,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  /// Camera OCR Analytics

  /// Log OCR scan started
  Future<void> logOCRScanStarted() async {
    await logEvent('ocr_scan_started', {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Log OCR results
  Future<void> logOCRCompleted({
    required int textRegionsFound,
    required double averageConfidence,
    required String detectedLanguage,
    required Duration processingTime,
  }) async {
    await logEvent('ocr_completed', {
      'text_regions_found': textRegionsFound,
      'average_confidence': averageConfidence,
      'detected_language': detectedLanguage,
      'processing_time_ms': processingTime.inMilliseconds,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// User Engagement Analytics

  /// Log screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics?.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? screenName,
    );
  }

  /// Log app usage session
  Future<void> logSessionStart() async {
    await logEvent('session_start', {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'user_properties': _userProperties,
    });
  }

  /// Log app usage session end
  Future<void> logSessionEnd({
    required Duration sessionDuration,
    required int translationsCount,
    required int voiceTranslationsCount,
    required int ocrScansCount,
  }) async {
    await logEvent('session_end', {
      'session_duration_ms': sessionDuration.inMilliseconds,
      'translations_count': translationsCount,
      'voice_translations_count': voiceTranslationsCount,
      'ocr_scans_count': ocrScansCount,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Feature Usage Analytics

  /// Log feature usage
  Future<void> logFeatureUsed({
    required String featureName,
    String? context,
    Map<String, Object>? additionalData,
  }) async {
    final parameters = <String, Object>{
      'feature_name': featureName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    if (context != null) parameters['context'] = context;
    if (additionalData != null) parameters.addAll(additionalData);
    
    await logEvent('feature_used', parameters);
  }

  /// Log quick action used
  Future<void> logQuickActionUsed(String actionType) async {
    await logEvent('quick_action_used', {
      'action_type': actionType,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Log settings changed
  Future<void> logSettingsChanged({
    required String settingName,
    required String newValue,
    String? previousValue,
  }) async {
    await logEvent('settings_changed', {
      'setting_name': settingName,
      'new_value': newValue,
      'previous_value': previousValue ?? 'unknown',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Performance Analytics

  /// Log app performance metrics
  Future<void> logPerformanceMetrics({
    required Duration startupTime,
    required int memoryUsageMB,
    required double cpuUsage,
    required String networkStatus,
  }) async {
    await logEvent('performance_metrics', {
      'startup_time_ms': startupTime.inMilliseconds,
      'memory_usage_mb': memoryUsageMB,
      'cpu_usage_percent': cpuUsage,
      'network_status': networkStatus,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Log custom timed event
  Future<void> logTimedEvent({
    required String eventName,
    required Duration duration,
    Map<String, Object>? additionalData,
  }) async {
    final parameters = <String, Object>{
      'duration_ms': duration.inMilliseconds,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    if (additionalData != null) {
      parameters.addAll(additionalData);
    }
    
    await logEvent(eventName, parameters);
  }

  /// Error and Exception Analytics

  /// Log non-fatal error
  Future<void> logNonFatalError({
    required String error,
    required String context,
    Map<String, Object>? additionalData,
  }) async {
    await logEvent('non_fatal_error', {
      'error_message': error,
      'error_context': context,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      ...?additionalData,
    });
  }

  /// Log user feedback
  Future<void> logUserFeedback({
    required String feedbackType,
    required String rating,
    String? comment,
    String? featureContext,
  }) async {
    await logEvent('user_feedback', {
      'feedback_type': feedbackType,
      'rating': rating,
      'has_comment': comment != null,
      'feature_context': featureContext ?? 'general',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// A/B Testing and Experiments

  /// Log experiment participation
  Future<void> logExperimentParticipation({
    required String experimentId,
    required String variant,
  }) async {
    await logEvent('experiment_participation', {
      'experiment_id': experimentId,
      'variant': variant,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Revenue and Business Analytics

  /// Log purchase/subscription event
  Future<void> logPurchase({
    required String itemId,
    required String itemName,
    required double value,
    required String currency,
    String? category,
  }) async {
    await _analytics?.logPurchase(
      currency: currency,
      value: value,
      parameters: {
        'item_id': itemId,
        'item_name': itemName,
        'item_category': category ?? 'subscription',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Get Firebase Analytics Observer for navigation
  FirebaseAnalyticsObserver? getNavigatorObserver() {
    return _analytics != null ? FirebaseAnalyticsObserver(analytics: _analytics!) : null;
  }

  /// Get current user properties
  Map<String, dynamic> get userProperties => Map.from(_userProperties);

  /// Check if analytics is initialized
  bool get isInitialized => _isInitialized;

  /// Get current user ID
  String? get userId => _userId;
}
