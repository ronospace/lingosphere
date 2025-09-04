// 🌐 LingoSphere - Firebase Performance Monitoring Service
// Comprehensive performance tracking and optimization with Firebase

import 'dart:async';
import 'dart:io';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:logger/logger.dart';
import 'firebase_analytics_service.dart';

class FirebasePerformanceService {
  static final FirebasePerformanceService _instance = FirebasePerformanceService._internal();
  factory FirebasePerformanceService() => _instance;
  FirebasePerformanceService._internal();

  final Logger _logger = Logger();
  final FirebasePerformance _performance = FirebasePerformance.instance;
  final FirebaseAnalyticsService _analytics = FirebaseAnalyticsService();

  bool _isInitialized = false;
  final Map<String, Trace> _activeTraces = {};
  final Map<String, HttpMetric> _activeHttpMetrics = {};

  /// Initialize Firebase Performance Monitoring
  Future<void> initialize() async {
    try {
      await _performance.setPerformanceCollectionEnabled(true);
      _isInitialized = true;
      
      _logger.i('Firebase Performance Service initialized');
      
      // Start app startup trace
      await startTrace('app_startup');
      
    } catch (e) {
      _logger.e('Failed to initialize Firebase Performance: $e');
    }
  }

  /// Start a custom trace
  Future<Trace?> startTrace(String traceName, {Map<String, String>? attributes}) async {
    try {
      if (!_isInitialized) {
        _logger.w('Performance monitoring not initialized');
        return null;
      }

      final trace = _performance.newTrace(traceName);
      
      // Set custom attributes if provided
      if (attributes != null) {
        for (final entry in attributes.entries) {
          trace.putAttribute(entry.key, entry.value);
        }
      }
      
      await trace.start();
      _activeTraces[traceName] = trace;
      
      _logger.d('Started trace: $traceName');
      return trace;
    } catch (e) {
      _logger.e('Failed to start trace $traceName: $e');
      return null;
    }
  }

  /// Stop a custom trace
  Future<void> stopTrace(String traceName, {Map<String, String>? finalAttributes}) async {
    try {
      final trace = _activeTraces[traceName];
      if (trace == null) {
        _logger.w('No active trace found: $traceName');
        return;
      }

      // Add final attributes if provided
      if (finalAttributes != null) {
        for (final entry in finalAttributes.entries) {
          trace.putAttribute(entry.key, entry.value);
        }
      }

      await trace.stop();
      _activeTraces.remove(traceName);
      
      _logger.d('Stopped trace: $traceName');
    } catch (e) {
      _logger.e('Failed to stop trace $traceName: $e');
    }
  }

  /// Set a custom metric for an active trace
  Future<void> setTraceMetric(String traceName, String metricName, int value) async {
    try {
      final trace = _activeTraces[traceName];
      if (trace != null) {
        trace.setMetric(metricName, value);
        _logger.d('Set metric $metricName = $value for trace $traceName');
      }
    } catch (e) {
      _logger.e('Failed to set metric $metricName for trace $traceName: $e');
    }
  }

  /// Increment a metric for an active trace
  Future<void> incrementTraceMetric(String traceName, String metricName, int increment) async {
    try {
      final trace = _activeTraces[traceName];
      if (trace != null) {
        trace.incrementMetric(metricName, increment);
        _logger.d('Incremented metric $metricName by $increment for trace $traceName');
      }
    } catch (e) {
      _logger.e('Failed to increment metric $metricName for trace $traceName: $e');
    }
  }

  /// Start HTTP metric tracking
  Future<HttpMetric?> startHttpMetric({
    required String url,
    required HttpMethod method,
  }) async {
    try {
      if (!_isInitialized) return null;

      final httpMetric = _performance.newHttpMetric(url, method);
      await httpMetric.start();
      
      final key = '${method.name}_$url';
      _activeHttpMetrics[key] = httpMetric;
      
      _logger.d('Started HTTP metric: $method $url');
      return httpMetric;
    } catch (e) {
      _logger.e('Failed to start HTTP metric: $e');
      return null;
    }
  }

  /// Stop HTTP metric tracking
  Future<void> stopHttpMetric({
    required String url,
    required HttpMethod method,
    int? responseCode,
    int? requestPayloadSize,
    int? responsePayloadSize,
    String? contentType,
  }) async {
    try {
      final key = '${method.name}_$url';
      final httpMetric = _activeHttpMetrics[key];
      
      if (httpMetric == null) {
        _logger.w('No active HTTP metric found: $key');
        return;
      }

      // Set optional response data
      if (responseCode != null) {
        httpMetric.httpResponseCode = responseCode;
      }
      if (requestPayloadSize != null) {
        httpMetric.requestPayloadSize = requestPayloadSize;
      }
      if (responsePayloadSize != null) {
        httpMetric.responsePayloadSize = responsePayloadSize;
      }
      if (contentType != null) {
        httpMetric.responseContentType = contentType;
      }

      await httpMetric.stop();
      _activeHttpMetrics.remove(key);
      
      _logger.d('Stopped HTTP metric: $method $url (${responseCode ?? 'unknown'})');
    } catch (e) {
      _logger.e('Failed to stop HTTP metric: $e');
    }
  }

  /// Translation Performance Tracking

  /// Track translation request performance
  Future<Trace?> trackTranslationRequest({
    required String provider,
    required String sourceLanguage,
    required String targetLanguage,
    required int textLength,
  }) async {
    final traceName = 'translation_${provider}_${sourceLanguage}_to_$targetLanguage';
    
    return await startTrace(traceName, attributes: {
      'provider': provider,
      'source_language': sourceLanguage,
      'target_language': targetLanguage,
      'text_length_range': _getTextLengthRange(textLength),
    });
  }

  /// Complete translation request tracking
  Future<void> completeTranslationTracking({
    required String provider,
    required String sourceLanguage,
    required String targetLanguage,
    required Duration processingTime,
    required bool success,
    String? errorType,
  }) async {
    final traceName = 'translation_${provider}_${sourceLanguage}_to_$targetLanguage';
    
    // Set metrics
    await setTraceMetric(traceName, 'processing_time_ms', processingTime.inMilliseconds);
    
    // Set final attributes
    final finalAttributes = <String, String>{
      'success': success.toString(),
      'processing_time_category': _getProcessingTimeCategory(processingTime),
    };
    
    if (errorType != null) {
      finalAttributes['error_type'] = errorType;
    }
    
    await stopTrace(traceName, finalAttributes: finalAttributes);
    
    // Also log to analytics
    await _analytics.logTimedEvent(
      eventName: 'translation_performance',
      duration: processingTime,
      additionalData: {
        'provider': provider,
        'source_language': sourceLanguage,
        'target_language': targetLanguage,
        'success': success,
      },
    );
  }

  /// Voice Translation Performance

  /// Track voice recognition performance
  Future<Trace?> trackVoiceRecognition({
    required String language,
    required String mode,
  }) async {
    final traceName = 'voice_recognition_${language}_$mode';
    
    return await startTrace(traceName, attributes: {
      'language': language,
      'mode': mode,
    });
  }

  /// Complete voice recognition tracking
  Future<void> completeVoiceRecognitionTracking({
    required String language,
    required String mode,
    required Duration processingTime,
    required double confidence,
    required bool success,
  }) async {
    final traceName = 'voice_recognition_${language}_$mode';
    
    await setTraceMetric(traceName, 'processing_time_ms', processingTime.inMilliseconds);
    await setTraceMetric(traceName, 'confidence_percent', (confidence * 100).round());
    
    await stopTrace(traceName, finalAttributes: {
      'success': success.toString(),
      'confidence_level': _getConfidenceLevel(confidence),
    });
  }

  /// OCR Performance Tracking

  /// Track OCR processing performance
  Future<Trace?> trackOCRProcessing() async {
    return await startTrace('ocr_processing');
  }

  /// Complete OCR processing tracking
  Future<void> completeOCRTracking({
    required Duration processingTime,
    required int textRegionsFound,
    required double averageConfidence,
    required bool success,
  }) async {
    const traceName = 'ocr_processing';
    
    await setTraceMetric(traceName, 'processing_time_ms', processingTime.inMilliseconds);
    await setTraceMetric(traceName, 'text_regions_found', textRegionsFound);
    await setTraceMetric(traceName, 'avg_confidence_percent', (averageConfidence * 100).round());
    
    await stopTrace(traceName, finalAttributes: {
      'success': success.toString(),
      'regions_category': _getRegionsCategory(textRegionsFound),
    });
  }

  /// Screen Loading Performance

  /// Track screen loading performance
  Future<Trace?> trackScreenLoad(String screenName) async {
    final traceName = 'screen_load_$screenName';
    return await startTrace(traceName, attributes: {
      'screen_name': screenName,
    });
  }

  /// Complete screen loading tracking
  Future<void> completeScreenLoadTracking({
    required String screenName,
    required Duration loadTime,
    bool success = true,
  }) async {
    final traceName = 'screen_load_$screenName';
    
    await setTraceMetric(traceName, 'load_time_ms', loadTime.inMilliseconds);
    await stopTrace(traceName, finalAttributes: {
      'success': success.toString(),
      'load_speed': _getLoadSpeedCategory(loadTime),
    });
  }

  /// Network Performance

  /// Track API request performance
  Future<HttpMetric?> trackApiRequest({
    required String endpoint,
    required String method,
  }) async {
    final url = 'https://api.lingosphere.com$endpoint';
    final httpMethod = _getHttpMethod(method);
    
    return await startHttpMetric(url: url, method: httpMethod);
  }

  /// Complete API request tracking
  Future<void> completeApiRequestTracking({
    required String endpoint,
    required String method,
    required int statusCode,
    int? requestSize,
    int? responseSize,
  }) async {
    final url = 'https://api.lingosphere.com$endpoint';
    final httpMethod = _getHttpMethod(method);
    
    await stopHttpMetric(
      url: url,
      method: httpMethod,
      responseCode: statusCode,
      requestPayloadSize: requestSize,
      responsePayloadSize: responseSize,
      contentType: 'application/json',
    );
  }

  /// App Lifecycle Performance

  /// Track app startup performance
  Future<void> completeAppStartup({
    required Duration startupTime,
    required bool coldStart,
  }) async {
    await setTraceMetric('app_startup', 'startup_time_ms', startupTime.inMilliseconds);
    await stopTrace('app_startup', finalAttributes: {
      'cold_start': coldStart.toString(),
      'startup_speed': _getStartupSpeedCategory(startupTime),
      'platform': Platform.operatingSystem,
    });
    
    // Log to analytics as well
    await _analytics.logPerformanceMetrics(
      startupTime: startupTime,
      memoryUsageMB: 0, // Would need actual memory tracking
      cpuUsage: 0, // Would need actual CPU tracking
      networkStatus: 'unknown',
    );
  }

  /// Custom Business Metrics

  /// Track feature usage performance
  Future<void> trackFeatureUsage({
    required String featureName,
    required Duration usageTime,
    required bool completed,
    Map<String, String>? context,
  }) async {
    final traceName = 'feature_usage_$featureName';
    
    final trace = await startTrace(traceName, attributes: {
      'feature_name': featureName,
      'completed': completed.toString(),
      ...?context,
    });
    
    if (trace != null) {
      trace.setMetric('usage_time_ms', usageTime.inMilliseconds);
      await trace.stop();
    }
  }

  /// Helper Methods

  String _getTextLengthRange(int length) {
    if (length < 50) return 'short';
    if (length < 200) return 'medium';
    if (length < 1000) return 'long';
    return 'very_long';
  }

  String _getProcessingTimeCategory(Duration duration) {
    final ms = duration.inMilliseconds;
    if (ms < 500) return 'fast';
    if (ms < 1500) return 'medium';
    if (ms < 3000) return 'slow';
    return 'very_slow';
  }

  String _getConfidenceLevel(double confidence) {
    if (confidence >= 0.9) return 'high';
    if (confidence >= 0.7) return 'medium';
    return 'low';
  }

  String _getRegionsCategory(int regions) {
    if (regions == 0) return 'none';
    if (regions <= 2) return 'few';
    if (regions <= 5) return 'several';
    return 'many';
  }

  String _getLoadSpeedCategory(Duration duration) {
    final ms = duration.inMilliseconds;
    if (ms < 200) return 'instant';
    if (ms < 500) return 'fast';
    if (ms < 1000) return 'medium';
    return 'slow';
  }

  String _getStartupSpeedCategory(Duration duration) {
    final ms = duration.inMilliseconds;
    if (ms < 1000) return 'fast';
    if (ms < 2000) return 'medium';
    if (ms < 4000) return 'slow';
    return 'very_slow';
  }

  HttpMethod _getHttpMethod(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return HttpMethod.Get;
      case 'POST':
        return HttpMethod.Post;
      case 'PUT':
        return HttpMethod.Put;
      case 'DELETE':
        return HttpMethod.Delete;
      case 'PATCH':
        return HttpMethod.Patch;
      default:
        return HttpMethod.Get;
    }
  }

  /// Getters

  bool get isInitialized => _isInitialized;
  
  List<String> get activeTraces => _activeTraces.keys.toList();
  
  List<String> get activeHttpMetrics => _activeHttpMetrics.keys.toList();
}
