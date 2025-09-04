// 🧠 LingoSphere - Minimal AI Integration Service
// Provides basic AI integration with graceful fallbacks

import 'dart:async';
import 'package:logger/logger.dart';

import 'translation_service.dart';

/// Minimal AI integration service with fallback mechanisms
class AdvancedAIIntegrationService {
  static final AdvancedAIIntegrationService _instance =
      AdvancedAIIntegrationService._internal();
  factory AdvancedAIIntegrationService() => _instance;
  AdvancedAIIntegrationService._internal();

  final Logger _logger = Logger();

  // Core service
  final TranslationService _translationService = TranslationService();

  // Integration state
  bool _isInitialized = false;
  bool _isAdvancedModeEnabled = false;
  AICapabilityLevel _currentCapabilityLevel = AICapabilityLevel.basic;

  /// Initialize the AI integration service
  Future<void> initialize({
    String? openAIApiKey,
    String? googleVisionApiKey,
    bool enableAdvancedMode = false,
    AICapabilityLevel capabilityLevel = AICapabilityLevel.basic,
  }) async {
    if (_isInitialized) return;

    try {
      _logger.i('🧠 Initializing AI Integration Service...');

      // Initialize translation service
      await _translationService.initialize();

      // Set configuration
      _isAdvancedModeEnabled = enableAdvancedMode;
      _currentCapabilityLevel = capabilityLevel;

      _isInitialized = true;
      _logger.i('✅ AI Integration Service initialized successfully');

    } catch (e) {
      _logger.e('Failed to initialize AI Integration Service: $e');
      // Don't rethrow - use fallback mode
      _isInitialized = true; // Allow service to work in basic mode
    }
  }

  /// Perform basic translation with available features
  Future<BasicTranslationResult> performBasicTranslation({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    String? userId,
    Map<String, dynamic>? context,
  }) async {
    if (!_isInitialized) {
      await initialize(); // Auto-initialize if needed
    }

    try {
      final stopwatch = Stopwatch()..start();
      
      // Use translation service
      final translationResult = await _translationService.translate(
        text: text,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );

      stopwatch.stop();

      return BasicTranslationResult(
        originalText: text,
        translatedText: translationResult.translatedText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        confidence: translationResult.confidencePercentage,
        processingTimeMs: stopwatch.elapsedMilliseconds,
        capabilityLevel: _currentCapabilityLevel,
        timestamp: DateTime.now(),
      );

    } catch (e) {
      _logger.e('Translation failed: $e');
      
      // Fallback to basic translation
      return BasicTranslationResult(
        originalText: text,
        translatedText: text, // Fallback: return original text
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        confidence: 0.0,
        processingTimeMs: 0,
        capabilityLevel: AICapabilityLevel.basic,
        timestamp: DateTime.now(),
        error: e.toString(),
      );
    }
  }

  /// Get service status
  AIServiceStatus getServiceStatus() {
    return AIServiceStatus(
      isInitialized: _isInitialized,
      isAdvancedModeEnabled: _isAdvancedModeEnabled,
      currentCapabilityLevel: _currentCapabilityLevel,
      availableServices: _getAvailableServices(),
      lastHealthCheck: DateTime.now(),
    );
  }

  /// Get list of available services
  List<String> _getAvailableServices() {
    final services = <String>[];
    
    if (_isInitialized) {
      services.add('basic_translation');
      
      if (_isAdvancedModeEnabled) {
        services.add('enhanced_features');
      }
    }

    return services;
  }

  /// Dispose service
  Future<void> dispose() async {
    try {
      _translationService.dispose();
      _isInitialized = false;
      _logger.i('🛑 AI Integration Service disposed');
    } catch (e) {
      _logger.e('Failed to dispose AI service: $e');
    }
  }

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isAdvancedModeEnabled => _isAdvancedModeEnabled;
  AICapabilityLevel get currentCapabilityLevel => _currentCapabilityLevel;
}

// Enums and data classes

enum AICapabilityLevel {
  basic,
  intermediate,
  advanced,
  expert;
}

/// Basic translation result
class BasicTranslationResult {
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final double confidence;
  final int processingTimeMs;
  final AICapabilityLevel capabilityLevel;
  final DateTime timestamp;
  final String? error;

  const BasicTranslationResult({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.confidence,
    required this.processingTimeMs,
    required this.capabilityLevel,
    required this.timestamp,
    this.error,
  });

  bool get hasError => error != null;
  bool get isSuccessful => !hasError && confidence > 0;

  Map<String, dynamic> toMap() => {
    'original_text': originalText,
    'translated_text': translatedText,
    'source_language': sourceLanguage,
    'target_language': targetLanguage,
    'confidence': confidence,
    'processing_time_ms': processingTimeMs,
    'capability_level': capabilityLevel.name,
    'timestamp': timestamp.toIso8601String(),
    'has_error': hasError,
    'is_successful': isSuccessful,
    if (error != null) 'error': error,
  };
}

/// AI service status
class AIServiceStatus {
  final bool isInitialized;
  final bool isAdvancedModeEnabled;
  final AICapabilityLevel currentCapabilityLevel;
  final List<String> availableServices;
  final DateTime lastHealthCheck;

  const AIServiceStatus({
    required this.isInitialized,
    required this.isAdvancedModeEnabled,
    required this.currentCapabilityLevel,
    required this.availableServices,
    required this.lastHealthCheck,
  });

  bool get isHealthy => isInitialized && availableServices.isNotEmpty;
  
  Map<String, dynamic> toMap() => {
    'is_initialized': isInitialized,
    'is_advanced_mode_enabled': isAdvancedModeEnabled,
    'capability_level': currentCapabilityLevel.name,
    'available_services': availableServices,
    'service_count': availableServices.length,
    'is_healthy': isHealthy,
    'last_health_check': lastHealthCheck.toIso8601String(),
  };
}
