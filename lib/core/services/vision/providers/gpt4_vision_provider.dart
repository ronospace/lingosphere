// 🌟 LingoSphere - GPT-4 Vision API Provider
// OpenAI GPT-4 Vision integration for advanced image context understanding

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../../models/vision_ai_models.dart';

/// OpenAI GPT-4 Vision API provider
class GPT4VisionProvider {
  final String _apiKey;
  final String _baseUrl;
  final http.Client _httpClient;

  static const String _defaultBaseUrl = 'https://api.openai.com/v1';
  static const String _model = 'gpt-4-vision-preview';
  static const int _maxTokens = 4000;

  GPT4VisionProvider({
    required String apiKey,
    String? baseUrl,
    http.Client? httpClient,
  })  : _apiKey = apiKey,
        _baseUrl = baseUrl ?? _defaultBaseUrl,
        _httpClient = httpClient ?? http.Client();

  /// Analyze image for translation context
  Future<VisionAnalysisResult> analyzeImage({
    required String imagePath,
    required String sourceLanguage,
    required String targetLanguage,
    String? customPrompt,
  }) async {
    try {
      final imageData = await _loadImageData(imagePath);

      final prompt = customPrompt ??
          _buildAnalysisPrompt(
            sourceLanguage,
            targetLanguage,
          );

      final response = await _makeVisionRequest(
        imageData: imageData,
        prompt: prompt,
      );

      return _parseAnalysisResponse(
        response,
        imagePath,
        sourceLanguage,
        targetLanguage,
      );
    } catch (e) {
      throw VisionAnalysisException(
        'GPT-4 Vision analysis failed: $e',
        imagePath: imagePath,
      );
    }
  }

  /// Extract text from image with enhanced OCR
  Future<List<DetectedText>> extractText(String imagePath) async {
    try {
      final imageData = await _loadImageData(imagePath);

      const prompt = '''
Analyze this image and extract all visible text with precise location information.
Return a JSON array with this structure:
[{
  "text": "extracted text",
  "confidence": 0.95,
  "boundingBox": {
    "x": 100.0,
    "y": 200.0,
    "width": 150.0,
    "height": 30.0
  },
  "language": "en"
}]

Focus on:
- Accurate text extraction including signs, labels, documents
- Precise bounding box coordinates
- Language detection for each text element
- High confidence scores for readable text
''';

      final response = await _makeVisionRequest(
        imageData: imageData,
        prompt: prompt,
      );

      return _parseTextExtractionResponse(response);
    } catch (e) {
      throw VisionAnalysisException(
        'Text extraction failed: $e',
        imagePath: imagePath,
      );
    }
  }

  /// Get scene description and cultural context
  Future<VisualContext> getVisualContext(String imagePath) async {
    try {
      final imageData = await _loadImageData(imagePath);

      const prompt = '''
Analyze this image and provide detailed visual context information.
Return a JSON object with this structure:
{
  "detectedObjects": ["person", "building", "sign", "food"],
  "sceneDescription": "A bustling street market with various vendors and customers",
  "textElements": ["menu items", "price tags", "street signs"],
  "colors": ["red", "blue", "yellow", "green"],
  "mood": "vibrant and energetic",
  "culturalMarkers": ["traditional architecture", "local customs", "regional food"],
  "confidence": 0.88
}

Focus on:
- Comprehensive object detection
- Rich scene description
- Cultural and contextual elements
- Mood and atmosphere
- Dominant colors and visual themes
''';

      final response = await _makeVisionRequest(
        imageData: imageData,
        prompt: prompt,
      );

      return _parseVisualContextResponse(response, imagePath);
    } catch (e) {
      throw VisionAnalysisException(
        'Visual context analysis failed: $e',
        imagePath: imagePath,
      );
    }
  }

  /// Enhance translation using visual context
  Future<ContextEnhancedTranslation> enhanceTranslation({
    required String originalText,
    required String baseTranslation,
    required String imagePath,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      final imageData = await _loadImageData(imagePath);
      final visualContext = await getVisualContext(imagePath);

      final prompt = '''
Given this image context and translation pair, provide an enhanced translation that better fits the visual context.

Original text: "$originalText"
Base translation: "$baseTranslation"
Source language: $sourceLanguage
Target language: $targetLanguage

Visual context: ${visualContext.sceneDescription}
Objects: ${visualContext.detectedObjects.join(', ')}
Cultural markers: ${visualContext.culturalMarkers.join(', ')}

Return a JSON object:
{
  "enhancedTranslation": "improved translation considering visual context",
  "improvements": ["specific improvement made", "another improvement"],
  "confidence": 0.92,
  "contextRelevance": 0.85
}

Focus on:
- Cultural appropriateness for the visual setting
- Context-specific terminology
- Visual elements that affect meaning
- Local expressions and idioms
''';

      final response = await _makeVisionRequest(
        imageData: imageData,
        prompt: prompt,
      );

      return _parseEnhancedTranslationResponse(
        response,
        originalText,
        baseTranslation,
        visualContext,
      );
    } catch (e) {
      throw VisionAnalysisException(
        'Translation enhancement failed: $e',
        imagePath: imagePath,
      );
    }
  }

  /// Batch analyze multiple images
  Future<BatchVisionResult> analyzeBatch(BatchVisionRequest request) async {
    final stopwatch = Stopwatch()..start();
    final results = <VisionAnalysisResult>[];
    final errors = <String>[];

    try {
      final futures = <Future<void>>[];

      for (final imagePath in request.imagePaths) {
        if (futures.length >= request.maxConcurrent) {
          await Future.wait(futures);
          futures.clear();
        }

        final future = analyzeImage(
          imagePath: imagePath,
          sourceLanguage: request.sourceLanguage,
          targetLanguage: request.targetLanguage,
        ).then((result) {
          results.add(result);
        }).catchError((error) {
          errors.add('$imagePath: $error');
        });

        futures.add(future);
      }

      // Wait for remaining futures
      if (futures.isNotEmpty) {
        await Future.wait(futures);
      }

      stopwatch.stop();

      return BatchVisionResult(
        results: results,
        errors: errors,
        successCount: results.length,
        errorCount: errors.length,
        processingTime: stopwatch.elapsed,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      stopwatch.stop();
      throw VisionAnalysisException('Batch analysis failed: $e');
    }
  }

  /// Check API capabilities and status
  Future<VisionCapabilities> getCapabilities() async {
    try {
      // GPT-4 Vision capabilities are relatively fixed
      return const VisionCapabilities(
        textExtraction: true,
        objectDetection: true,
        sceneAnalysis: true,
        culturalContext: true,
        emotionalAnalysis: true,
        colorAnalysis: true,
        faceDetection: false, // Limited by OpenAI policy
        landmarkDetection: true,
        logoDetection: true,
      );
    } catch (e) {
      throw VisionAnalysisException('Failed to get capabilities: $e');
    }
  }

  // Private methods

  Future<String> _loadImageData(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw VisionAnalysisException('Image file not found: $imagePath');
      }

      final bytes = await file.readAsBytes();
      final extension = imagePath.toLowerCase().split('.').last;

      // Validate image format
      if (!['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
        throw VisionAnalysisException('Unsupported image format: $extension');
      }

      // Convert to base64
      final base64Image = base64Encode(bytes);
      final mimeType = _getMimeType(extension);

      return 'data:$mimeType;base64,$base64Image';
    } catch (e) {
      throw VisionAnalysisException('Failed to load image data: $e');
    }
  }

  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  String _buildAnalysisPrompt(String sourceLanguage, String targetLanguage) {
    return '''
Analyze this image for translation context between $sourceLanguage and $targetLanguage.

Return a comprehensive JSON response with this structure:
{
  "detectedText": [
    {
      "text": "visible text",
      "confidence": 0.95,
      "boundingBox": {"x": 0, "y": 0, "width": 100, "height": 20},
      "language": "$sourceLanguage"
    }
  ],
  "detectedObjects": [
    {
      "name": "object name",
      "confidence": 0.88,
      "boundingBox": {"x": 0, "y": 0, "width": 100, "height": 100}
    }
  ],
  "sceneDescription": "detailed scene description",
  "culturalMarkers": ["cultural element 1", "cultural element 2"],
  "contextualInsights": ["insight about translation context"],
  "translationSuggestions": ["suggestion for better translation"],
  "confidence": 0.87
}

Focus on:
- Extracting all visible text accurately
- Identifying cultural and contextual elements
- Providing translation-relevant insights
- Detecting objects that might affect translation meaning
- Suggesting context-aware translation improvements
''';
  }

  Future<Map<String, dynamic>> _makeVisionRequest({
    required String imageData,
    required String prompt,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };

    final body = {
      'model': _model,
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': prompt,
            },
            {
              'type': 'image_url',
              'image_url': {
                'url': imageData,
                'detail': 'high',
              },
            },
          ],
        },
      ],
      'max_tokens': _maxTokens,
      'temperature': 0.1, // Low temperature for consistent analysis
    };

    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw VisionAnalysisException(
        'API request failed: ${response.statusCode} ${response.body}',
      );
    }

    final responseData = jsonDecode(response.body);

    if (responseData['error'] != null) {
      throw VisionAnalysisException(
        'API error: ${responseData['error']['message']}',
      );
    }

    return responseData;
  }

  VisionAnalysisResult _parseAnalysisResponse(
    Map<String, dynamic> response,
    String imagePath,
    String sourceLanguage,
    String targetLanguage,
  ) {
    try {
      final content = response['choices'][0]['message']['content'] as String;

      // Extract JSON from response (might be wrapped in markdown)
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(content);
      if (jsonMatch == null) {
        throw VisionAnalysisException('Invalid response format');
      }

      final analysisData =
          jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;

      return VisionAnalysisResult(
        imagePath: imagePath,
        detectedText: _parseDetectedText(analysisData['detectedText']),
        detectedObjects: _parseDetectedObjects(analysisData['detectedObjects']),
        sceneDescription: analysisData['sceneDescription']?.toString() ?? '',
        culturalMarkers:
            List<String>.from(analysisData['culturalMarkers'] ?? []),
        contextualInsights:
            List<String>.from(analysisData['contextualInsights'] ?? []),
        translationSuggestions:
            List<String>.from(analysisData['translationSuggestions'] ?? []),
        confidence: (analysisData['confidence'] as num?)?.toDouble() ?? 0.5,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        processingTime: DateTime.now(),
      );
    } catch (e) {
      throw VisionAnalysisException('Failed to parse analysis response: $e');
    }
  }

  List<DetectedText> _parseDetectedText(dynamic textData) {
    if (textData == null) return [];

    return (textData as List).map((item) {
      final bbox = item['boundingBox'] as Map<String, dynamic>;
      return DetectedText(
        text: item['text']?.toString() ?? '',
        confidence: (item['confidence'] as num?)?.toDouble() ?? 0.0,
        language: item['language']?.toString(),
        boundingBox: BoundingBox(
          x: (bbox['x'] as num?)?.toDouble() ?? 0.0,
          y: (bbox['y'] as num?)?.toDouble() ?? 0.0,
          width: (bbox['width'] as num?)?.toDouble() ?? 0.0,
          height: (bbox['height'] as num?)?.toDouble() ?? 0.0,
        ),
      );
    }).toList();
  }

  List<DetectedObject> _parseDetectedObjects(dynamic objectData) {
    if (objectData == null) return [];

    return (objectData as List).map((item) {
      final bbox = item['boundingBox'] as Map<String, dynamic>;
      return DetectedObject(
        name: item['name']?.toString() ?? '',
        confidence: (item['confidence'] as num?)?.toDouble() ?? 0.0,
        attributes: item['attributes'] as Map<String, dynamic>?,
        boundingBox: BoundingBox(
          x: (bbox['x'] as num?)?.toDouble() ?? 0.0,
          y: (bbox['y'] as num?)?.toDouble() ?? 0.0,
          width: (bbox['width'] as num?)?.toDouble() ?? 0.0,
          height: (bbox['height'] as num?)?.toDouble() ?? 0.0,
        ),
      );
    }).toList();
  }

  List<DetectedText> _parseTextExtractionResponse(
      Map<String, dynamic> response) {
    try {
      final content = response['choices'][0]['message']['content'] as String;
      final jsonMatch = RegExp(r'\[.*\]', dotAll: true).firstMatch(content);

      if (jsonMatch == null) {
        return [];
      }

      final textData = jsonDecode(jsonMatch.group(0)!) as List;
      return _parseDetectedText(textData);
    } catch (e) {
      throw VisionAnalysisException('Failed to parse text extraction: $e');
    }
  }

  VisualContext _parseVisualContextResponse(
    Map<String, dynamic> response,
    String imagePath,
  ) {
    try {
      final content = response['choices'][0]['message']['content'] as String;
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(content);

      if (jsonMatch == null) {
        throw VisionAnalysisException('Invalid visual context response');
      }

      final contextData =
          jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;

      return VisualContext(
        imagePath: imagePath,
        detectedObjects:
            List<String>.from(contextData['detectedObjects'] ?? []),
        sceneDescription: contextData['sceneDescription']?.toString() ?? '',
        textElements: List<String>.from(contextData['textElements'] ?? []),
        colors: List<String>.from(contextData['colors'] ?? []),
        mood: contextData['mood']?.toString() ?? '',
        culturalMarkers:
            List<String>.from(contextData['culturalMarkers'] ?? []),
        confidence: (contextData['confidence'] as num?)?.toDouble() ?? 0.5,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw VisionAnalysisException('Failed to parse visual context: $e');
    }
  }

  ContextEnhancedTranslation _parseEnhancedTranslationResponse(
    Map<String, dynamic> response,
    String originalText,
    String baseTranslation,
    VisualContext visualContext,
  ) {
    try {
      final content = response['choices'][0]['message']['content'] as String;
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(content);

      if (jsonMatch == null) {
        throw VisionAnalysisException('Invalid enhanced translation response');
      }

      final translationData =
          jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;

      return ContextEnhancedTranslation(
        originalText: originalText,
        baseTranslation: baseTranslation,
        enhancedTranslation:
            translationData['enhancedTranslation']?.toString() ??
                baseTranslation,
        visualContext: visualContext,
        improvements: List<String>.from(translationData['improvements'] ?? []),
        confidence: (translationData['confidence'] as num?)?.toDouble() ?? 0.5,
        contextRelevance:
            (translationData['contextRelevance'] as num?)?.toDouble() ?? 0.5,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw VisionAnalysisException('Failed to parse enhanced translation: $e');
    }
  }

  void dispose() {
    _httpClient.close();
  }
}

/// Exception thrown when vision analysis fails
class VisionAnalysisException implements Exception {
  final String message;
  final String? imagePath;

  const VisionAnalysisException(this.message, {this.imagePath});

  @override
  String toString() {
    if (imagePath != null) {
      return 'VisionAnalysisException for $imagePath: $message';
    }
    return 'VisionAnalysisException: $message';
  }
}
