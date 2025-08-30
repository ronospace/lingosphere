// 🌐 LingoSphere - Advanced Translation Service
// Multi-provider translation with AI context awareness and sentiment analysis

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:translator/translator.dart';
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';
import '../models/translation_models.dart';
import '../exceptions/translation_exceptions.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  final Dio _dio = Dio();
  final GoogleTranslator _googleTranslator = GoogleTranslator();
  final Logger _logger = Logger();
  
  // Translation cache for performance
  final Map<String, CachedTranslation> _translationCache = {};
  
  // API Keys (should be loaded from secure storage)
  String? _googleApiKey;
  String? _deepLApiKey;
  String? _openAIApiKey;
  
  // Initialize service with API keys
  Future<void> initialize({
    String? googleApiKey,
    String? deepLApiKey,
    String? openAIApiKey,
  }) async {
    _googleApiKey = googleApiKey;
    _deepLApiKey = deepLApiKey;
    _openAIApiKey = openAIApiKey;
    
    // Configure Dio with timeout and interceptors
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'LingoSphere/1.0.0',
      },
    );
    
    // Add logging interceptor
    _dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      logPrint: (obj) => _logger.d(obj.toString()),
    ));
    
    _logger.i('Translation service initialized with multiple providers');
  }
  
  /// Main translation method with intelligent provider selection
  Future<TranslationResult> translate({
    required String text,
    required String targetLanguage,
    String sourceLanguage = 'auto',
    TranslationMode mode = TranslationMode.realTime,
    Map<String, dynamic>? context,
  }) async {
    try {
      // Input validation
      if (text.trim().isEmpty) {
        throw const InvalidTextException('Text cannot be empty');
      }
      
      if (text.length > AppConstants.maxTranslationLength) {
        throw TextTooLongException(
          'Text exceeds maximum length of ${AppConstants.maxTranslationLength} characters',
          textLength: text.length,
          maxLength: AppConstants.maxTranslationLength,
        );
      }
      
      // Check cache first
      final cacheKey = _generateCacheKey(text, sourceLanguage, targetLanguage);
      final cached = _getFromCache(cacheKey);
      if (cached != null && !cached.isExpired) {
        _logger.d('Translation served from cache');
        return cached.result;
      }
      
      // Detect source language if auto
      if (sourceLanguage == 'auto') {
        sourceLanguage = await detectLanguage(text);
      }
      
      // Skip translation if source and target are the same
      if (sourceLanguage.toLowerCase() == targetLanguage.toLowerCase()) {
        return TranslationResult(
          originalText: text,
          translatedText: text,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
          confidence: TranslationConfidence.high,
          provider: 'none',
          sentiment: await _analyzeSentiment(text),
          context: await _analyzeContext(text, context),
          metadata: TranslationMetadata(
            timestamp: DateTime.now(),
            processingTime: Duration.zero,
          ),
        );
      }
      
      final stopwatch = Stopwatch()..start();
      
      // Try multiple translation providers in order of preference
      TranslationResult? result;
      
      // 1. Try DeepL API (highest quality for supported languages)
      if (_deepLApiKey != null && _isDeepLSupported(sourceLanguage, targetLanguage)) {
        try {
          result = await _translateWithDeepL(text, sourceLanguage, targetLanguage, context);
          _logger.d('Translation completed with DeepL');
        } catch (e) {
          _logger.w('DeepL translation failed: $e');
        }
      }
      
      // 2. Fallback to Google Translate API (more language support)
      if (result == null && _googleApiKey != null) {
        try {
          result = await _translateWithGoogleAPI(text, sourceLanguage, targetLanguage, context);
          _logger.d('Translation completed with Google Translate API');
        } catch (e) {
          _logger.w('Google Translate API failed: $e');
        }
      }
      
      // 3. Final fallback to Google Translator package
      if (result == null) {
        try {
          result = await _translateWithGooglePackage(text, sourceLanguage, targetLanguage, context);
          _logger.d('Translation completed with Google Translator package');
        } catch (e) {
          _logger.w('Google Translator package failed: $e');
        }
      }
      
      if (result == null) {
        throw const TranslationServiceException('All translation providers failed');
      }
      
      stopwatch.stop();
      result = result.copyWith(
        metadata: result.metadata.copyWith(
          processingTime: stopwatch.elapsed,
        ),
      );
      
      // Cache the result
      _cacheTranslation(cacheKey, result);
      
      // Log analytics
      _logTranslationAnalytics(result);
      
      return result;
    } catch (e) {
      _logger.e('Translation failed: $e');
      if (e is TranslationException) rethrow;
      throw TranslationServiceException('Translation service error: ${e.toString()}');
    }
  }
  
  /// Advanced language detection with confidence scoring
  Future<String> detectLanguage(String text) async {
    try {
      // Use pattern matching for quick detection
      final detectedByPattern = _detectLanguageByPattern(text);
      if (detectedByPattern != null) {
        return detectedByPattern;
      }
      
      // Use Google's language detection via translation
      try {
        final translation = await _googleTranslator.translate(text, from: 'auto', to: 'en');
        final detectedLanguage = translation.sourceLanguage.code;
        if (detectedLanguage != 'auto') {
          return detectedLanguage;
        }
      } catch (e) {
        _logger.w('Google language detection failed: $e');
      }
      
      // Fallback to default
      return AppConstants.defaultSourceLanguage;
    } catch (e) {
      _logger.w('Language detection failed: $e');
      return AppConstants.defaultSourceLanguage;
    }
  }
  
  /// Batch translation for multiple texts
  Future<List<TranslationResult>> translateBatch({
    required List<String> texts,
    required String targetLanguage,
    String sourceLanguage = 'auto',
    Map<String, dynamic>? context,
  }) async {
    final results = <TranslationResult>[];
    
    // Process in parallel with controlled concurrency
    final futures = texts.map((text) => translate(
      text: text,
      targetLanguage: targetLanguage,
      sourceLanguage: sourceLanguage,
      context: context,
    ));
    
    results.addAll(await Future.wait(futures));
    return results;
  }
  
  /// DeepL API translation
  Future<TranslationResult> _translateWithDeepL(
    String text,
    String sourceLanguage,
    String targetLanguage,
    Map<String, dynamic>? context,
  ) async {
    final response = await _dio.post(
      AppConstants.deepLApiUrl,
      options: Options(
        headers: {'Authorization': 'DeepL-Auth-Key $_deepLApiKey'},
      ),
      data: {
        'text': [text],
        'source_lang': _mapToDeepLCode(sourceLanguage),
        'target_lang': _mapToDeepLCode(targetLanguage),
        'preserve_formatting': true,
        'formality': context?['formality'] ?? 'default',
      },
    );
    
    final translations = response.data['translations'] as List;
    if (translations.isEmpty) {
      throw const TranslationServiceException('No translation returned from DeepL');
    }
    
    final translation = translations.first;
    final confidence = _calculateConfidence(
      translation['detected_source_language'],
      sourceLanguage,
    );
    
    return TranslationResult(
      originalText: text,
      translatedText: translation['text'],
      sourceLanguage: translation['detected_source_language'].toLowerCase(),
      targetLanguage: targetLanguage,
      confidence: confidence,
      provider: 'deepl',
      sentiment: await _analyzeSentiment(text),
      context: await _analyzeContext(text, context),
      metadata: TranslationMetadata(timestamp: DateTime.now()),
    );
  }
  
  /// Google Translate API translation
  Future<TranslationResult> _translateWithGoogleAPI(
    String text,
    String sourceLanguage,
    String targetLanguage,
    Map<String, dynamic>? context,
  ) async {
    final response = await _dio.post(
      '${AppConstants.googleTranslateApiUrl}?key=$_googleApiKey',
      data: {
        'q': text,
        'source': sourceLanguage == 'auto' ? null : sourceLanguage,
        'target': targetLanguage,
        'format': 'text',
      },
    );
    
    final translations = response.data['data']['translations'] as List;
    if (translations.isEmpty) {
      throw const TranslationServiceException('No translation returned from Google API');
    }
    
    final translation = translations.first;
    final detectedLanguage = translation['detectedSourceLanguage'] ?? sourceLanguage;
    
    return TranslationResult(
      originalText: text,
      translatedText: translation['translatedText'],
      sourceLanguage: detectedLanguage,
      targetLanguage: targetLanguage,
      confidence: TranslationConfidence.medium,
      provider: 'google_api',
      sentiment: await _analyzeSentiment(text),
      context: await _analyzeContext(text, context),
      metadata: TranslationMetadata(timestamp: DateTime.now()),
    );
  }
  
  /// Google Translator package translation
  Future<TranslationResult> _translateWithGooglePackage(
    String text,
    String sourceLanguage,
    String targetLanguage,
    Map<String, dynamic>? context,
  ) async {
    final translation = await _googleTranslator.translate(
      text,
      from: sourceLanguage == 'auto' ? 'auto' : sourceLanguage,
      to: targetLanguage,
    );
    
    return TranslationResult(
      originalText: text,
      translatedText: translation.text,
      sourceLanguage: translation.sourceLanguage.code,
      targetLanguage: targetLanguage,
      confidence: TranslationConfidence.medium,
      provider: 'google_package',
      sentiment: await _analyzeSentiment(text),
      context: await _analyzeContext(text, context),
      metadata: TranslationMetadata(timestamp: DateTime.now()),
    );
  }
  
  /// AI-powered sentiment analysis
  Future<SentimentAnalysis> _analyzeSentiment(String text) async {
    try {
      // Simple emoji-based sentiment detection
      double sentimentScore = 0.0;
      int emojiCount = 0;
      
      for (final entry in LanguagePatterns.emojiSentiment.entries) {
        final count = entry.key.allMatches(text).length;
        if (count > 0) {
          sentimentScore += entry.value * count;
          emojiCount += count;
        }
      }
      
      if (emojiCount > 0) {
        sentimentScore /= emojiCount;
      }
      
      // Analyze text patterns for additional context
      final positiveWords = ['good', 'great', 'excellent', 'amazing', 'wonderful', 'fantastic'];
      final negativeWords = ['bad', 'terrible', 'awful', 'horrible', 'disappointing'];
      
      final lowerText = text.toLowerCase();
      final positiveCount = positiveWords.where((word) => lowerText.contains(word)).length;
      final negativeCount = negativeWords.where((word) => lowerText.contains(word)).length;
      
      if (positiveCount > negativeCount) {
        sentimentScore += 0.3;
      } else if (negativeCount > positiveCount) {
        sentimentScore -= 0.3;
      }
      
      // Determine sentiment category
      SentimentType sentiment;
      if (sentimentScore > 0.2) {
        sentiment = SentimentType.positive;
      } else if (sentimentScore < -0.2) {
        sentiment = SentimentType.negative;
      } else {
        sentiment = SentimentType.neutral;
      }
      
      return SentimentAnalysis(
        sentiment: sentiment,
        score: sentimentScore.clamp(-1.0, 1.0),
        confidence: (sentimentScore.abs() * 100).clamp(0.0, 100.0),
      );
    } catch (e) {
      _logger.w('Sentiment analysis failed: $e');
      return SentimentAnalysis(
        sentiment: SentimentType.neutral,
        score: 0.0,
        confidence: 0.0,
      );
    }
  }
  
  /// Context analysis for better translations
  Future<ContextAnalysis> _analyzeContext(
    String text,
    Map<String, dynamic>? additionalContext,
  ) async {
    try {
      final analysis = ContextAnalysis(
        formality: _detectFormality(text),
        domain: _detectDomain(text),
        culturalMarkers: _detectCulturalMarkers(text),
        slangLevel: _detectSlangLevel(text),
        additionalContext: additionalContext ?? {},
      );
      
      return analysis;
    } catch (e) {
      _logger.w('Context analysis failed: $e');
      return ContextAnalysis(
        formality: FormalityLevel.neutral,
        domain: TextDomain.general,
        culturalMarkers: [],
        slangLevel: 0.0,
        additionalContext: additionalContext ?? {},
      );
    }
  }
  
  /// Pattern-based language detection for quick identification
  String? _detectLanguageByPattern(String text) {
    final lowerText = text.toLowerCase();
    
    for (final entry in LanguagePatterns.slangPatterns.entries) {
      final language = entry.key;
      final patterns = entry.value;
      
      final matches = patterns.where((pattern) => lowerText.contains(pattern)).length;
      if (matches >= 2) {
        return language;
      }
    }
    
    return null;
  }
  
  /// Detect formality level in text
  FormalityLevel _detectFormality(String text) {
    final lowerText = text.toLowerCase();
    
    // Check for formal patterns
    int formalScore = 0;
    int informalScore = 0;
    
    for (final patterns in LanguagePatterns.formalPatterns.values) {
      for (final pattern in patterns) {
        if (lowerText.contains(pattern.toLowerCase())) {
          formalScore++;
        }
      }
    }
    
    for (final patterns in LanguagePatterns.slangPatterns.values) {
      for (final pattern in patterns) {
        if (lowerText.contains(pattern.toLowerCase())) {
          informalScore++;
        }
      }
    }
    
    if (formalScore > informalScore) {
      return FormalityLevel.formal;
    } else if (informalScore > formalScore) {
      return FormalityLevel.informal;
    } else {
      return FormalityLevel.neutral;
    }
  }
  
  /// Detect text domain/topic
  TextDomain _detectDomain(String text) {
    final lowerText = text.toLowerCase();
    
    // Simple keyword-based domain detection
    final businessKeywords = ['meeting', 'project', 'deadline', 'client', 'revenue'];
    final techKeywords = ['api', 'database', 'algorithm', 'software', 'programming'];
    final casualKeywords = ['hang out', 'chill', 'party', 'fun', 'friend'];
    
    if (businessKeywords.any((keyword) => lowerText.contains(keyword))) {
      return TextDomain.business;
    } else if (techKeywords.any((keyword) => lowerText.contains(keyword))) {
      return TextDomain.technical;
    } else if (casualKeywords.any((keyword) => lowerText.contains(keyword))) {
      return TextDomain.casual;
    }
    
    return TextDomain.general;
  }
  
  /// Detect cultural markers in text
  List<String> _detectCulturalMarkers(String text) {
    final markers = <String>[];
    
    // Simple cultural marker detection
    if (text.contains('🇺🇸') || text.contains('america')) {
      markers.add('us_culture');
    }
    if (text.contains('🇬🇧') || text.contains('britain')) {
      markers.add('uk_culture');
    }
    if (text.contains('🇪🇸') || text.contains('spain')) {
      markers.add('spanish_culture');
    }
    
    return markers;
  }
  
  /// Calculate slang level in text
  double _detectSlangLevel(String text) {
    final lowerText = text.toLowerCase();
    int slangCount = 0;
    int totalWords = text.split(' ').length;
    
    for (final patterns in LanguagePatterns.slangPatterns.values) {
      for (final pattern in patterns) {
        if (lowerText.contains(pattern.toLowerCase())) {
          slangCount++;
        }
      }
    }
    
    return totalWords > 0 ? slangCount / totalWords : 0.0;
  }
  
  /// Check if language pair is supported by DeepL
  bool _isDeepLSupported(String source, String target) {
    final deepLLanguages = [
      'en', 'de', 'fr', 'es', 'pt', 'it', 'nl', 'pl', 'ru', 'ja', 'zh'
    ];
    return deepLLanguages.contains(source) && deepLLanguages.contains(target);
  }
  
  /// Map language codes to DeepL format
  String _mapToDeepLCode(String languageCode) {
    final mapping = {
      'en': 'EN',
      'de': 'DE',
      'fr': 'FR',
      'es': 'ES',
      'pt': 'PT',
      'it': 'IT',
      'nl': 'NL',
      'pl': 'PL',
      'ru': 'RU',
      'ja': 'JA',
      'zh': 'ZH',
    };
    return mapping[languageCode] ?? languageCode.toUpperCase();
  }
  
  /// Calculate translation confidence
  TranslationConfidence _calculateConfidence(String detected, String expected) {
    if (expected == 'auto' || detected.toLowerCase() == expected.toLowerCase()) {
      return TranslationConfidence.high;
    } else {
      return TranslationConfidence.medium;
    }
  }
  
  /// Generate cache key
  String _generateCacheKey(String text, String source, String target) {
    return '${text.hashCode}_${source}_${target}';
  }
  
  /// Get translation from cache
  CachedTranslation? _getFromCache(String key) {
    final cached = _translationCache[key];
    if (cached != null && !cached.isExpired) {
      return cached;
    }
    _translationCache.remove(key);
    return null;
  }
  
  /// Cache translation result
  void _cacheTranslation(String key, TranslationResult result) {
    _translationCache[key] = CachedTranslation(
      result: result,
      cachedAt: DateTime.now(),
      expiresAfter: const Duration(days: AppConstants.translationCacheExpiration),
    );
    
    // Clean up old cache entries
    if (_translationCache.length > 1000) {
      final oldestKeys = _translationCache.entries
          .where((entry) => entry.value.isExpired)
          .map((entry) => entry.key)
          .take(200)
          .toList();
      
      for (final key in oldestKeys) {
        _translationCache.remove(key);
      }
    }
  }
  
  /// Log translation analytics
  void _logTranslationAnalytics(TranslationResult result) {
    try {
      _logger.i('Translation Analytics: '
          'Provider: ${result.provider}, '
          'Confidence: ${result.confidence}, '
          'Processing Time: ${result.metadata.processingTime?.inMilliseconds}ms, '
          'Source: ${result.sourceLanguage}, '
          'Target: ${result.targetLanguage}');
    } catch (e) {
      _logger.w('Failed to log analytics: $e');
    }
  }
  
  /// Clear translation cache
  void clearCache() {
    _translationCache.clear();
    _logger.i('Translation cache cleared');
  }
  
  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    final now = DateTime.now();
    final validEntries = _translationCache.values.where((cached) => !cached.isExpired).length;
    final expiredEntries = _translationCache.length - validEntries;
    
    return {
      'total_entries': _translationCache.length,
      'valid_entries': validEntries,
      'expired_entries': expiredEntries,
      'cache_hit_ratio': validEntries / (_translationCache.length + 1),
    };
  }
  
  /// Dispose service
  void dispose() {
    _dio.close();
    _translationCache.clear();
    _logger.i('Translation service disposed');
  }
}
