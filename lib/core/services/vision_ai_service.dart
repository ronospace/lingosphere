// 👁️ LingoSphere - Vision AI Service
// Advanced image context understanding for enhanced translations using GPT-4 Vision

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../models/vision_ai_models.dart';
import '../exceptions/translation_exceptions.dart';
import '../optimization/neural_performance_optimizer.dart';

/// Advanced vision AI service for image context understanding
class VisionAIService {
  static final VisionAIService _instance = VisionAIService._internal();
  factory VisionAIService() => _instance;
  VisionAIService._internal();

  final Logger _logger = Logger();
  final Dio _dio = Dio();
  final NeuralPerformanceOptimizer _optimizer = NeuralPerformanceOptimizer();

  // Configuration
  static const String _openAIVisionEndpoint =
      'https://api.openai.com/v1/chat/completions';
  static const String _googleVisionEndpoint =
      'https://vision.googleapis.com/v1/images:annotate';
  static const int _maxImageSize = 20 * 1024 * 1024; // 20MB
  static const Duration _requestTimeout = Duration(seconds: 30);

  String? _openAIApiKey;
  String? _googleApiKey;
  bool _isInitialized = false;

  // Cache for vision analysis results
  final Map<String, VisionAnalysisResult> _analysisCache = {};
  final Map<String, VisualContext> _contextCache = {};

  /// Initialize the vision AI service
  Future<void> initialize({
    required String openAIApiKey,
    String? googleApiKey,
  }) async {
    try {
      _openAIApiKey = openAIApiKey;
      _googleApiKey = googleApiKey;

      // Configure Dio
      _dio.options = BaseOptions(
        connectTimeout: _requestTimeout,
        receiveTimeout: _requestTimeout,
        sendTimeout: _requestTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAIApiKey',
        },
      );

      _isInitialized = true;
      _logger.i('Vision AI Service initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize Vision AI Service: $e');
      throw VisionAIException('Initialization failed: $e');
    }
  }

  /// Analyze image for translation context
  Future<VisionAnalysisResult> analyzeImageForTranslation({
    required String imagePath,
    required String sourceLanguage,
    required String targetLanguage,
    String? additionalContext,
  }) async {
    if (!_isInitialized) {
      throw VisionAIException('Service not initialized');
    }

    final stopwatch = Stopwatch()..start();

    try {
      // Check cache first
      final cacheKey =
          _generateCacheKey(imagePath, sourceLanguage, targetLanguage);
      final cached = await _optimizer.getCachedAnalysis(cacheKey);
      if (cached != null) {
        _logger.d('Retrieved cached vision analysis for image');
        return VisionAnalysisResult.fromTurnAnalysis(cached);
      }

      // Validate image
      await _validateImage(imagePath);

      // Perform multi-provider analysis
      final [gptAnalysis, googleAnalysis] = await Future.wait([
        _analyzeWithGPT4Vision(
            imagePath, sourceLanguage, targetLanguage, additionalContext),
        _analyzeWithGoogleVision(imagePath),
      ]);

      // Combine and enhance results
      final result = _combineAnalysisResults(
          gptAnalysis, googleAnalysis, sourceLanguage, targetLanguage);

      // Cache the result
      await _optimizer.cacheAnalysis(cacheKey, result.toTurnAnalysis());

      _logger
          .i('Image analysis completed in ${stopwatch.elapsedMilliseconds}ms');
      return result;
    } catch (e) {
      _logger.e('Image analysis failed: $e');
      throw VisionAIException('Image analysis failed: $e');
    } finally {
      stopwatch.stop();
    }
  }

  /// Extract visual context for conversation enhancement
  Future<VisualContext> extractVisualContext(String imagePath) async {
    if (!_isInitialized) {
      throw VisionAIException('Service not initialized');
    }

    try {
      // Check context cache
      final cached = _contextCache[imagePath];
      if (cached != null && !_isContextExpired(cached)) {
        return cached;
      }

      // Analyze image for visual elements
      final analysis = await _extractVisualElements(imagePath);

      // Build visual context
      final context = VisualContext(
        imagePath: imagePath,
        detectedObjects: analysis['objects'] ?? [],
        sceneDescription: analysis['scene'] ?? '',
        textElements: analysis['text'] ?? [],
        colors: analysis['colors'] ?? [],
        mood: analysis['mood'] ?? '',
        culturalMarkers: analysis['cultural'] ?? [],
        timestamp: DateTime.now(),
        confidence: analysis['confidence'] ?? 0.8,
      );

      // Cache the context
      _contextCache[imagePath] = context;

      return context;
    } catch (e) {
      _logger.e('Visual context extraction failed: $e');
      throw VisionAIException('Context extraction failed: $e');
    }
  }

  /// Enhance translation with visual context
  Future<ContextEnhancedTranslation> enhanceTranslationWithVisualContext({
    required String originalText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
    required String imagePath,
  }) async {
    try {
      // Get visual context
      final visualContext = await extractVisualContext(imagePath);

      // Analyze for improvements
      final improvements = await _generateContextualImprovements(
        originalText,
        translatedText,
        sourceLanguage,
        targetLanguage,
        visualContext,
      );

      return ContextEnhancedTranslation(
        originalText: originalText,
        baseTranslation: translatedText,
        enhancedTranslation: improvements.enhancedTranslation,
        visualContext: visualContext,
        improvements: improvements.suggestions,
        confidence: improvements.confidence,
        contextRelevance: improvements.relevanceScore,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      _logger.e('Translation enhancement failed: $e');
      throw VisionAIException('Enhancement failed: $e');
    }
  }

  /// Batch process multiple images
  Future<List<VisionAnalysisResult>> batchAnalyzeImages({
    required List<String> imagePaths,
    required String sourceLanguage,
    required String targetLanguage,
    int maxConcurrent = 3,
  }) async {
    if (!_isInitialized) {
      throw VisionAIException('Service not initialized');
    }

    final results = <VisionAnalysisResult>[];
    final semaphore = Semaphore(maxConcurrent);

    try {
      final futures = imagePaths.map((path) async {
        await semaphore.acquire();
        try {
          return await analyzeImageForTranslation(
            imagePath: path,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
          );
        } finally {
          semaphore.release();
        }
      });

      results.addAll(await Future.wait(futures));
      return results;
    } catch (e) {
      _logger.e('Batch image analysis failed: $e');
      throw VisionAIException('Batch analysis failed: $e');
    }
  }

  /// Get supported image formats
  List<String> getSupportedFormats() {
    return ['jpg', 'jpeg', 'png', 'webp', 'gif'];
  }

  /// Get analysis capabilities
  VisionCapabilities getCapabilities() {
    return VisionCapabilities(
      textExtraction: true,
      objectDetection: true,
      sceneAnalysis: true,
      culturalContext: true,
      emotionalAnalysis: true,
      colorAnalysis: true,
      faceDetection: _googleApiKey != null,
      landmarkDetection: _googleApiKey != null,
      logoDetection: _googleApiKey != null,
    );
  }

  /// Clear cache
  Future<void> clearCache() async {
    _analysisCache.clear();
    _contextCache.clear();
    _logger.i('Vision AI cache cleared');
  }

  /// Dispose service
  Future<void> dispose() async {
    await clearCache();
    _dio.close();
    _isInitialized = false;
    _logger.i('Vision AI Service disposed');
  }

  // Private methods

  Future<void> _validateImage(String imagePath) async {
    final file = File(imagePath);

    if (!await file.exists()) {
      throw VisionAIException('Image file not found: $imagePath');
    }

    final stat = await file.stat();
    if (stat.size > _maxImageSize) {
      throw VisionAIException('Image size exceeds maximum allowed size');
    }

    final extension = imagePath.split('.').last.toLowerCase();
    if (!getSupportedFormats().contains(extension)) {
      throw VisionAIException('Unsupported image format: $extension');
    }
  }

  Future<Map<String, dynamic>> _analyzeWithGPT4Vision(
    String imagePath,
    String sourceLanguage,
    String targetLanguage,
    String? additionalContext,
  ) async {
    try {
      // Read and encode image
      final imageBytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(imageBytes);
      final mimeType = _getMimeType(imagePath);

      // Create prompt for translation context analysis
      final prompt =
          _buildVisionPrompt(sourceLanguage, targetLanguage, additionalContext);

      final response = await _dio.post(
        _openAIVisionEndpoint,
        data: {
          'model': 'gpt-4-vision-preview',
          'messages': [
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': prompt},
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:$mimeType;base64,$base64Image',
                    'detail': 'high'
                  }
                }
              ]
            }
          ],
          'max_tokens': 1000,
          'temperature': 0.3,
        },
      );

      final content = response.data['choices'][0]['message']['content'];
      return _parseGPTVisionResponse(content);
    } catch (e) {
      _logger.w('GPT-4 Vision analysis failed: $e');
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _analyzeWithGoogleVision(
      String imagePath) async {
    if (_googleApiKey == null) {
      return {'error': 'Google Vision API key not provided'};
    }

    try {
      final imageBytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final response = await _dio.post(
        '$_googleVisionEndpoint?key=$_googleApiKey',
        data: {
          'requests': [
            {
              'image': {'content': base64Image},
              'features': [
                {'type': 'TEXT_DETECTION'},
                {'type': 'OBJECT_LOCALIZATION'},
                {'type': 'FACE_DETECTION'},
                {'type': 'LANDMARK_DETECTION'},
                {'type': 'LOGO_DETECTION'},
                {'type': 'IMAGE_PROPERTIES'},
              ]
            }
          ]
        },
      );

      return _parseGoogleVisionResponse(response.data);
    } catch (e) {
      _logger.w('Google Vision analysis failed: $e');
      return {'error': e.toString()};
    }
  }

  VisionAnalysisResult _combineAnalysisResults(
    Map<String, dynamic> gptResult,
    Map<String, dynamic> googleResult,
    String sourceLanguage,
    String targetLanguage,
  ) {
    // Combine insights from both providers
    final detectedText = <DetectedText>[];
    final objects = <DetectedObject>[];
    final culturalMarkers = <String>[];
    final contextualInsights = <String>[];

    // Process GPT-4 Vision results
    if (!gptResult.containsKey('error')) {
      detectedText.addAll(gptResult['detectedText'] ?? []);
      objects.addAll(gptResult['objects'] ?? []);
      culturalMarkers.addAll(gptResult['culturalMarkers'] ?? []);
      contextualInsights.addAll(gptResult['insights'] ?? []);
    }

    // Process Google Vision results
    if (!googleResult.containsKey('error')) {
      detectedText.addAll(googleResult['textAnnotations'] ?? []);
      objects.addAll(googleResult['localizedObjects'] ?? []);
    }

    // Calculate overall confidence
    final confidence = _calculateCombinedConfidence(gptResult, googleResult);

    return VisionAnalysisResult(
      imagePath: '',
      detectedText: detectedText,
      detectedObjects: objects,
      sceneDescription: gptResult['sceneDescription'] ?? '',
      culturalMarkers: culturalMarkers,
      contextualInsights: contextualInsights,
      translationSuggestions: gptResult['translationSuggestions'] ?? [],
      confidence: confidence,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      processingTime: DateTime.now(),
    );
  }

  String _buildVisionPrompt(
      String sourceLanguage, String targetLanguage, String? additionalContext) {
    final contextPart = additionalContext != null
        ? 'Additional context: $additionalContext\n\n'
        : '';

    return '''
${contextPart}Analyze this image to provide context for translation from $sourceLanguage to $targetLanguage.

Please provide a JSON response with the following structure:
{
  "sceneDescription": "Brief description of what's in the image",
  "detectedText": [{"text": "detected text", "confidence": 0.95, "bounds": {"x": 0, "y": 0, "width": 100, "height": 20}}],
  "objects": [{"name": "object name", "confidence": 0.9, "bounds": {"x": 0, "y": 0, "width": 100, "height": 100}}],
  "culturalMarkers": ["cultural context clues"],
  "insights": ["translation insights based on visual context"],
  "translationSuggestions": ["suggested improvements for translations in this context"],
  "confidence": 0.85
}

Focus on elements that would help improve translation accuracy and cultural appropriateness.
''';
  }

  Map<String, dynamic> _parseGPTVisionResponse(String content) {
    try {
      // Try to parse as JSON
      if (content.contains('{')) {
        final jsonStart = content.indexOf('{');
        final jsonEnd = content.lastIndexOf('}');
        if (jsonStart != -1 && jsonEnd != -1) {
          final jsonStr = content.substring(jsonStart, jsonEnd + 1);
          return json.decode(jsonStr);
        }
      }

      // Fallback: parse as structured text
      return _parseStructuredText(content);
    } catch (e) {
      _logger.w('Failed to parse GPT Vision response: $e');
      return {'error': 'Parse error', 'rawContent': content};
    }
  }

  Map<String, dynamic> _parseGoogleVisionResponse(
      Map<String, dynamic> response) {
    try {
      final responses = response['responses'] as List;
      if (responses.isEmpty) return {};

      final result = responses[0] as Map<String, dynamic>;

      return {
        'textAnnotations':
            _parseGoogleTextAnnotations(result['textAnnotations']),
        'localizedObjects':
            _parseGoogleObjects(result['localizedObjectAnnotations']),
        'faces': result['faceAnnotations'],
        'landmarks': result['landmarkAnnotations'],
        'logos': result['logoAnnotations'],
        'imageProperties': result['imagePropertiesAnnotation'],
      };
    } catch (e) {
      _logger.w('Failed to parse Google Vision response: $e');
      return {'error': 'Parse error'};
    }
  }

  List<DetectedText> _parseGoogleTextAnnotations(dynamic annotations) {
    if (annotations == null) return [];

    final textList = <DetectedText>[];
    for (final annotation in annotations) {
      textList.add(DetectedText(
        text: annotation['description'] ?? '',
        confidence: 0.9, // Google doesn't provide confidence for text
        boundingBox: _parseBoundingBox(annotation['boundingPoly']),
      ));
    }
    return textList;
  }

  List<DetectedObject> _parseGoogleObjects(dynamic objects) {
    if (objects == null) return [];

    final objectList = <DetectedObject>[];
    for (final obj in objects) {
      objectList.add(DetectedObject(
        name: obj['name'] ?? '',
        confidence: obj['score']?.toDouble() ?? 0.8,
        boundingBox: _parseBoundingBox(obj['boundingPoly']),
      ));
    }
    return objectList;
  }

  BoundingBox _parseBoundingBox(dynamic poly) {
    if (poly == null || poly['vertices'] == null) {
      return const BoundingBox(x: 0, y: 0, width: 0, height: 0);
    }

    final vertices = poly['vertices'] as List;
    if (vertices.isEmpty)
      return const BoundingBox(x: 0, y: 0, width: 0, height: 0);

    final minX = vertices
        .map((v) => v['x'] ?? 0)
        .reduce((a, b) => a < b ? a : b)
        .toDouble();
    final maxX = vertices
        .map((v) => v['x'] ?? 0)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    final minY = vertices
        .map((v) => v['y'] ?? 0)
        .reduce((a, b) => a < b ? a : b)
        .toDouble();
    final maxY = vertices
        .map((v) => v['y'] ?? 0)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return BoundingBox(
      x: minX,
      y: minY,
      width: maxX - minX,
      height: maxY - minY,
    );
  }

  Map<String, dynamic> _parseStructuredText(String content) {
    // Simple fallback parser for structured text responses
    return {
      'sceneDescription': _extractSection(content, 'Scene:'),
      'insights': [_extractSection(content, 'Insights:')],
      'confidence': 0.7,
    };
  }

  String _extractSection(String content, String sectionName) {
    final lines = content.split('\n');
    final sectionIndex = lines.indexWhere((line) => line.contains(sectionName));
    if (sectionIndex == -1 || sectionIndex >= lines.length - 1) return '';

    return lines[sectionIndex + 1].trim();
  }

  double _calculateCombinedConfidence(
      Map<String, dynamic> gptResult, Map<String, dynamic> googleResult) {
    double confidence = 0.5;

    if (!gptResult.containsKey('error')) {
      confidence += 0.3;
      if (gptResult['confidence'] != null) {
        confidence += gptResult['confidence'] * 0.2;
      }
    }

    if (!googleResult.containsKey('error')) {
      confidence += 0.2;
    }

    return confidence.clamp(0.0, 1.0);
  }

  Future<Map<String, dynamic>> _extractVisualElements(String imagePath) async {
    // Simplified visual element extraction
    final gptAnalysis = await _analyzeWithGPT4Vision(
      imagePath,
      'auto',
      'auto',
      'Extract visual elements: objects, colors, mood, cultural markers',
    );

    return gptAnalysis;
  }

  Future<TranslationImprovement> _generateContextualImprovements(
    String originalText,
    String translatedText,
    String sourceLanguage,
    String targetLanguage,
    VisualContext visualContext,
  ) async {
    try {
      final prompt = '''
Improve this translation based on visual context:

Original ($sourceLanguage): $originalText
Translation ($targetLanguage): $translatedText

Visual Context:
- Scene: ${visualContext.sceneDescription}
- Objects: ${visualContext.detectedObjects.join(', ')}
- Mood: ${visualContext.mood}
- Cultural markers: ${visualContext.culturalMarkers.join(', ')}

Provide an improved translation that better fits the visual context.
Also provide specific suggestions for why the improvement is better.

Respond in JSON format:
{
  "enhancedTranslation": "improved translation",
  "suggestions": ["suggestion 1", "suggestion 2"],
  "confidence": 0.9,
  "relevanceScore": 0.85
}
''';

      final response = await _dio.post(
        _openAIVisionEndpoint.replaceAll('vision', 'completions'),
        data: {
          'model': 'gpt-4',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.3,
          'max_tokens': 500,
        },
      );

      final content = response.data['choices'][0]['message']['content'];
      final parsed = json.decode(content);

      return TranslationImprovement(
        enhancedTranslation: parsed['enhancedTranslation'] ?? translatedText,
        suggestions: List<String>.from(parsed['suggestions'] ?? []),
        confidence: parsed['confidence']?.toDouble() ?? 0.8,
        relevanceScore: parsed['relevanceScore']?.toDouble() ?? 0.8,
      );
    } catch (e) {
      _logger.w('Failed to generate contextual improvements: $e');
      return TranslationImprovement(
        enhancedTranslation: translatedText,
        suggestions: [],
        confidence: 0.5,
        relevanceScore: 0.5,
      );
    }
  }

  String _generateCacheKey(
      String imagePath, String sourceLanguage, String targetLanguage) {
    return '$imagePath-$sourceLanguage-$targetLanguage';
  }

  String _getMimeType(String imagePath) {
    final extension = imagePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }

  bool _isContextExpired(VisualContext context) {
    return DateTime.now().difference(context.timestamp).inHours > 24;
  }
}

/// Semaphore for controlling concurrent operations
class Semaphore {
  int _current;
  final int _max;
  final Queue<Completer<void>> _waitQueue = Queue<Completer<void>>();

  Semaphore(this._max) : _current = 0;

  Future<void> acquire() async {
    if (_current < _max) {
      _current++;
      return;
    }

    final completer = Completer<void>();
    _waitQueue.add(completer);
    return completer.future;
  }

  void release() {
    if (_waitQueue.isNotEmpty) {
      final completer = _waitQueue.removeFirst();
      completer.complete();
    } else {
      _current--;
    }
  }
}

/// Vision AI specific exception
class VisionAIException implements Exception {
  final String message;
  final String? code;
  final Exception? originalException;

  const VisionAIException(
    this.message, {
    this.code,
    this.originalException,
  });

  @override
  String toString() => 'VisionAIException: $message';
}

/// Translation improvement result
class TranslationImprovement {
  final String enhancedTranslation;
  final List<String> suggestions;
  final double confidence;
  final double relevanceScore;

  const TranslationImprovement({
    required this.enhancedTranslation,
    required this.suggestions,
    required this.confidence,
    required this.relevanceScore,
  });
}
