// 🔍 LingoSphere - Google Vision API Provider
// Google Cloud Vision integration for OCR and object detection

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../../models/vision_ai_models.dart';

/// Google Cloud Vision API provider
class GoogleVisionProvider {
  final String _apiKey;
  final String _baseUrl;
  final http.Client _httpClient;

  static const String _defaultBaseUrl = 'https://vision.googleapis.com/v1';

  GoogleVisionProvider({
    required String apiKey,
    String? baseUrl,
    http.Client? httpClient,
  })  : _apiKey = apiKey,
        _baseUrl = baseUrl ?? _defaultBaseUrl,
        _httpClient = httpClient ?? http.Client();

  /// Analyze image using Google Vision API
  Future<VisionAnalysisResult> analyzeImage({
    required String imagePath,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      final imageData = await _loadImageData(imagePath);

      // Run multiple Google Vision features in parallel
      final futures = await Future.wait([
        _detectText(imageData),
        _detectObjects(imageData),
        _detectLandmarks(imageData),
        _detectLogos(imageData),
      ]);

      final detectedText = futures[0] as List<DetectedText>;
      final detectedObjects = futures[1] as List<DetectedObject>;
      final landmarks = futures[2] as List<String>;
      final logos = futures[3] as List<String>;

      // Build cultural markers from detected elements
      final culturalMarkers = <String>[];
      culturalMarkers.addAll(landmarks);
      culturalMarkers.addAll(logos);

      // Generate scene description from detected objects
      final sceneDescription = _generateSceneDescription(detectedObjects);

      // Create contextual insights
      final contextualInsights = _generateContextualInsights(
        detectedText,
        detectedObjects,
        landmarks,
        logos,
      );

      // Generate translation suggestions
      final translationSuggestions = _generateTranslationSuggestions(
        detectedText,
        culturalMarkers,
        sourceLanguage,
        targetLanguage,
      );

      return VisionAnalysisResult(
        imagePath: imagePath,
        detectedText: detectedText,
        detectedObjects: detectedObjects,
        sceneDescription: sceneDescription,
        culturalMarkers: culturalMarkers,
        contextualInsights: contextualInsights,
        translationSuggestions: translationSuggestions,
        confidence: _calculateOverallConfidence(detectedText, detectedObjects),
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        processingTime: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Google Vision analysis failed: $e');
    }
  }

  /// Extract text using Google Cloud Vision OCR
  Future<List<DetectedText>> extractText(String imagePath) async {
    try {
      final imageData = await _loadImageData(imagePath);
      return await _detectText(imageData);
    } catch (e) {
      throw Exception('Text extraction failed: $e');
    }
  }

  /// Get visual context using Google Vision features
  Future<VisualContext> getVisualContext(String imagePath) async {
    try {
      final imageData = await _loadImageData(imagePath);

      final futures = await Future.wait([
        _detectObjects(imageData),
        _detectText(imageData),
        _detectLandmarks(imageData),
        _detectLogos(imageData),
        _analyzeImageProperties(imageData),
      ]);

      final detectedObjects = futures[0] as List<DetectedObject>;
      final detectedText = futures[1] as List<DetectedText>;
      final landmarks = futures[2] as List<String>;
      final logos = futures[3] as List<String>;
      final imageProperties = futures[4] as Map<String, dynamic>;

      final objectNames = detectedObjects.map((obj) => obj.name).toList();
      final textElements = detectedText.map((text) => text.text).toList();
      final colors = imageProperties['colors'] as List<String>;
      final mood = _determineMood(objectNames, colors);

      final culturalMarkers = <String>[];
      culturalMarkers.addAll(landmarks);
      culturalMarkers.addAll(logos);

      return VisualContext(
        imagePath: imagePath,
        detectedObjects: objectNames,
        sceneDescription: _generateSceneDescription(detectedObjects),
        textElements: textElements,
        colors: colors,
        mood: mood,
        culturalMarkers: culturalMarkers,
        confidence: _calculateOverallConfidence(detectedText, detectedObjects),
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Visual context analysis failed: $e');
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
      throw Exception('Batch analysis failed: $e');
    }
  }

  /// Check Google Vision API capabilities
  Future<VisionCapabilities> getCapabilities() async {
    try {
      return const VisionCapabilities(
        textExtraction: true,
        objectDetection: true,
        sceneAnalysis: true,
        culturalContext: true,
        emotionalAnalysis: false, // Limited in Google Vision
        colorAnalysis: true,
        faceDetection: true,
        landmarkDetection: true,
        logoDetection: true,
      );
    } catch (e) {
      throw Exception('Failed to get capabilities: $e');
    }
  }

  /// Assess image quality using Google Vision
  Future<ImageQualityAssessment> assessImageQuality(String imagePath) async {
    try {
      final imageData = await _loadImageData(imagePath);

      final request = {
        'requests': [
          {
            'image': {'content': imageData},
            'features': [
              {'type': 'IMAGE_PROPERTIES'},
              {'type': 'TEXT_DETECTION'},
              {'type': 'FACE_DETECTION'},
            ],
          }
        ]
      };

      final response = await _makeApiRequest('/images:annotate', request);
      final annotation = response['responses'][0];

      // Analyze image properties
      final imageProps = annotation['imagePropertiesAnnotation'];
      final textAnnotations = annotation['textAnnotations'] as List?;
      final faceAnnotations = annotation['faceAnnotations'] as List?;

      // Calculate quality metrics
      final brightness = _calculateBrightness(imageProps);
      final contrast = _calculateContrast(imageProps);
      final sharpness = _estimateSharpness(textAnnotations);

      final hasText = textAnnotations != null && textAnnotations.isNotEmpty;
      final hasFaces = faceAnnotations != null && faceAnnotations.isNotEmpty;
      final isBlurry = sharpness < 0.5;

      final overallQuality = _calculateOverallQuality(
        brightness,
        contrast,
        sharpness,
        hasText,
      );

      final qualityIssues = <String>[];
      if (brightness < 0.3) qualityIssues.add('Too dark');
      if (brightness > 0.9) qualityIssues.add('Too bright');
      if (contrast < 0.4) qualityIssues.add('Low contrast');
      if (isBlurry) qualityIssues.add('Blurry or out of focus');

      return ImageQualityAssessment(
        imagePath: imagePath,
        overallQuality: overallQuality,
        sharpness: sharpness,
        brightness: brightness,
        contrast: contrast,
        hasText: hasText,
        hasFaces: hasFaces,
        isBlurry: isBlurry,
        qualityIssues: qualityIssues,
        technicalDetails: {
          'imageProperties': imageProps,
          'textCount': textAnnotations?.length ?? 0,
          'faceCount': faceAnnotations?.length ?? 0,
        },
      );
    } catch (e) {
      throw Exception('Image quality assessment failed: $e');
    }
  }

  // Private methods

  Future<String> _loadImageData(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Image file not found: $imagePath');
      }

      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      throw Exception('Failed to load image data: $e');
    }
  }

  Future<Map<String, dynamic>> _makeApiRequest(
    String endpoint,
    Map<String, dynamic> requestBody,
  ) async {
    final url = Uri.parse('$_baseUrl$endpoint?key=$_apiKey');

    final response = await _httpClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200) {
      throw Exception('Google Vision API request failed: ${response.statusCode} ${response.body}');
    }

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;

    if (responseData['error'] != null) {
      throw Exception('Google Vision API error: ${responseData['error']['message']}');
    }

    return responseData;
  }

  Future<List<DetectedText>> _detectText(String imageData) async {
    final request = {
      'requests': [
        {
          'image': {'content': imageData},
          'features': [
            {'type': 'TEXT_DETECTION', 'maxResults': 100}
          ],
        }
      ]
    };

    final response = await _makeApiRequest('/images:annotate', request);
    final textAnnotations =
        response['responses'][0]['textAnnotations'] as List?;

    if (textAnnotations == null || textAnnotations.isEmpty) {
      return [];
    }

    return textAnnotations.skip(1).map((annotation) {
      final vertices = annotation['boundingPoly']['vertices'] as List;
      final bbox = _calculateBoundingBox(vertices);

      return DetectedText(
        text: annotation['description']?.toString() ?? '',
        confidence:
            0.9, // Google Vision doesn't provide text confidence directly
        language: annotation['locale']?.toString(),
        boundingBox: bbox,
      );
    }).toList();
  }

  Future<List<DetectedObject>> _detectObjects(String imageData) async {
    final request = {
      'requests': [
        {
          'image': {'content': imageData},
          'features': [
            {'type': 'OBJECT_LOCALIZATION', 'maxResults': 50}
          ],
        }
      ]
    };

    final response = await _makeApiRequest('/images:annotate', request);
    final objectAnnotations =
        response['responses'][0]['localizedObjectAnnotations'] as List?;

    if (objectAnnotations == null || objectAnnotations.isEmpty) {
      return [];
    }

    return objectAnnotations.map((annotation) {
      final vertices = annotation['boundingPoly']['normalizedVertices'] as List;
      final bbox = _calculateNormalizedBoundingBox(vertices);

      return DetectedObject(
        name: annotation['name']?.toString() ?? '',
        confidence: (annotation['score'] as num?)?.toDouble() ?? 0.0,
        boundingBox: bbox,
        attributes: {
          'mid': annotation['mid'],
        },
      );
    }).toList();
  }

  Future<List<String>> _detectLandmarks(String imageData) async {
    final request = {
      'requests': [
        {
          'image': {'content': imageData},
          'features': [
            {'type': 'LANDMARK_DETECTION', 'maxResults': 10}
          ],
        }
      ]
    };

    final response = await _makeApiRequest('/images:annotate', request);
    final landmarkAnnotations =
        response['responses'][0]['landmarkAnnotations'] as List?;

    if (landmarkAnnotations == null || landmarkAnnotations.isEmpty) {
      return [];
    }

    return landmarkAnnotations
        .map((annotation) => annotation['description']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  Future<List<String>> _detectLogos(String imageData) async {
    final request = {
      'requests': [
        {
          'image': {'content': imageData},
          'features': [
            {'type': 'LOGO_DETECTION', 'maxResults': 10}
          ],
        }
      ]
    };

    final response = await _makeApiRequest('/images:annotate', request);
    final logoAnnotations =
        response['responses'][0]['logoAnnotations'] as List?;

    if (logoAnnotations == null || logoAnnotations.isEmpty) {
      return [];
    }

    return logoAnnotations
        .map((annotation) => annotation['description']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  Future<Map<String, dynamic>> _analyzeImageProperties(String imageData) async {
    final request = {
      'requests': [
        {
          'image': {'content': imageData},
          'features': [
            {'type': 'IMAGE_PROPERTIES'}
          ],
        }
      ]
    };

    final response = await _makeApiRequest('/images:annotate', request);
    final imageProps = response['responses'][0]['imagePropertiesAnnotation'];

    if (imageProps == null) {
      return {'colors': <String>[]};
    }

    final dominantColors = imageProps['dominantColors']['colors'] as List?;
    final colors = dominantColors
            ?.take(5)
            .map((color) => _rgbToColorName(color['color']))
            .where((colorName) => colorName.isNotEmpty)
            .toList() ??
        <String>[];

    return {
      'colors': colors,
      'dominantColors': dominantColors,
    };
  }

  BoundingBox _calculateBoundingBox(List vertices) {
    final xs =
        vertices.map((v) => (v['x'] as num?)?.toDouble() ?? 0.0).toList();
    final ys =
        vertices.map((v) => (v['y'] as num?)?.toDouble() ?? 0.0).toList();

    final minX = xs.reduce((a, b) => a < b ? a : b);
    final maxX = xs.reduce((a, b) => a > b ? a : b);
    final minY = ys.reduce((a, b) => a < b ? a : b);
    final maxY = ys.reduce((a, b) => a > b ? a : b);

    return BoundingBox(
      x: minX,
      y: minY,
      width: maxX - minX,
      height: maxY - minY,
    );
  }

  BoundingBox _calculateNormalizedBoundingBox(List vertices) {
    // Normalized coordinates are 0.0 to 1.0, convert to pixel coordinates
    // This is a simplification - in reality we'd need image dimensions
    final xs =
        vertices.map((v) => (v['x'] as num?)?.toDouble() ?? 0.0).toList();
    final ys =
        vertices.map((v) => (v['y'] as num?)?.toDouble() ?? 0.0).toList();

    final minX =
        xs.reduce((a, b) => a < b ? a : b) * 1000; // Assume 1000px width
    final maxX = xs.reduce((a, b) => a > b ? a : b) * 1000;
    final minY =
        ys.reduce((a, b) => a < b ? a : b) * 1000; // Assume 1000px height
    final maxY = ys.reduce((a, b) => a > b ? a : b) * 1000;

    return BoundingBox(
      x: minX,
      y: minY,
      width: maxX - minX,
      height: maxY - minY,
    );
  }

  String _generateSceneDescription(List<DetectedObject> objects) {
    if (objects.isEmpty) return 'No objects detected in the image';

    final objectNames = objects
        .where((obj) => obj.confidence > 0.5)
        .map((obj) => obj.name.toLowerCase())
        .toSet()
        .toList();

    if (objectNames.isEmpty) return 'Low confidence object detection results';

    // Simple scene description generation
    if (objectNames.contains('person') || objectNames.contains('people')) {
      if (objectNames.contains('food') || objectNames.contains('table')) {
        return 'A dining scene with people and food';
      } else if (objectNames.contains('building') ||
          objectNames.contains('street')) {
        return 'An urban scene with people and buildings';
      }
      return 'A scene featuring people';
    }

    if (objectNames.contains('food') || objectNames.contains('meal')) {
      return 'A food-related scene';
    }

    if (objectNames.contains('building') ||
        objectNames.contains('architecture')) {
      return 'An architectural or urban scene';
    }

    return 'A scene containing ${objectNames.take(3).join(', ')}';
  }

  List<String> _generateContextualInsights(
    List<DetectedText> texts,
    List<DetectedObject> objects,
    List<String> landmarks,
    List<String> logos,
  ) {
    final insights = <String>[];

    if (texts.isNotEmpty) {
      insights.add('Contains ${texts.length} text elements');

      final languages =
          texts.map((t) => t.language).where((l) => l != null).toSet();
      if (languages.isNotEmpty) {
        insights.add('Detected languages: ${languages.join(', ')}');
      }
    }

    if (objects.isNotEmpty) {
      final highConfidenceObjects =
          objects.where((obj) => obj.confidence > 0.8).length;
      insights.add('$highConfidenceObjects high-confidence objects detected');
    }

    if (landmarks.isNotEmpty) {
      insights
          .add('Famous landmarks detected: ${landmarks.take(2).join(', ')}');
    }

    if (logos.isNotEmpty) {
      insights.add('Brand logos detected: ${logos.take(2).join(', ')}');
    }

    return insights;
  }

  List<String> _generateTranslationSuggestions(
    List<DetectedText> texts,
    List<String> culturalMarkers,
    String sourceLanguage,
    String targetLanguage,
  ) {
    final suggestions = <String>[];

    if (culturalMarkers.isNotEmpty) {
      suggestions.add('Consider cultural context: ${culturalMarkers.first}');
    }

    if (texts.any((t) => t.text.contains(RegExp(r'\d')))) {
      suggestions.add('Numbers and measurements may need localization');
    }

    if (texts.any((t) => t.text.contains(RegExp(r'[@#\$£€¥]')))) {
      suggestions.add('Currency symbols and social media handles detected');
    }

    return suggestions;
  }

  double _calculateOverallConfidence(
    List<DetectedText> texts,
    List<DetectedObject> objects,
  ) {
    if (texts.isEmpty && objects.isEmpty) return 0.0;

    var totalConfidence = 0.0;
    var count = 0;

    for (final text in texts) {
      totalConfidence += text.confidence;
      count++;
    }

    for (final object in objects) {
      totalConfidence += object.confidence;
      count++;
    }

    return count > 0 ? totalConfidence / count : 0.0;
  }

  String _rgbToColorName(Map<String, dynamic> color) {
    final r = (color['red'] as num?)?.toInt() ?? 0;
    final g = (color['green'] as num?)?.toInt() ?? 0;
    final b = (color['blue'] as num?)?.toInt() ?? 0;

    // Simple color name mapping
    if (r > 200 && g < 100 && b < 100) return 'red';
    if (g > 200 && r < 100 && b < 100) return 'green';
    if (b > 200 && r < 100 && g < 100) return 'blue';
    if (r > 200 && g > 200 && b < 100) return 'yellow';
    if (r > 200 && g < 100 && b > 200) return 'purple';
    if (r < 100 && g > 200 && b > 200) return 'cyan';
    if (r > 200 && g > 200 && b > 200) return 'white';
    if (r < 100 && g < 100 && b < 100) return 'black';

    return 'unknown';
  }

  String _determineMood(List<String> objects, List<String> colors) {
    // Simple mood detection based on objects and colors
    if (objects.any((obj) =>
        ['party', 'celebration', 'festival'].contains(obj.toLowerCase()))) {
      return 'festive';
    }

    if (colors.contains('red') && colors.contains('yellow')) {
      return 'energetic';
    }

    if (colors.contains('blue') || colors.contains('green')) {
      return 'calm';
    }

    if (objects.any(
        (obj) => ['food', 'meal', 'restaurant'].contains(obj.toLowerCase()))) {
      return 'appetizing';
    }

    return 'neutral';
  }

  double _calculateBrightness(Map<String, dynamic>? imageProps) {
    if (imageProps == null) return 0.5;

    final dominantColors = imageProps['dominantColors']?['colors'] as List?;
    if (dominantColors == null || dominantColors.isEmpty) return 0.5;

    var totalBrightness = 0.0;
    var count = 0;

    for (final colorInfo in dominantColors.take(3)) {
      final color = colorInfo['color'];
      final r = (color['red'] as num?)?.toInt() ?? 0;
      final g = (color['green'] as num?)?.toInt() ?? 0;
      final b = (color['blue'] as num?)?.toInt() ?? 0;

      // Calculate perceived brightness
      final brightness = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
      totalBrightness += brightness;
      count++;
    }

    return count > 0 ? totalBrightness / count : 0.5;
  }

  double _calculateContrast(Map<String, dynamic>? imageProps) {
    if (imageProps == null) return 0.5;

    final dominantColors = imageProps['dominantColors']?['colors'] as List?;
    if (dominantColors == null || dominantColors.length < 2) return 0.5;

    // Simple contrast calculation between dominant colors
    final color1 = dominantColors[0]['color'];
    final color2 = dominantColors[1]['color'];

    final r1 = (color1['red'] as num?)?.toInt() ?? 0;
    final g1 = (color1['green'] as num?)?.toInt() ?? 0;
    final b1 = (color1['blue'] as num?)?.toInt() ?? 0;

    final r2 = (color2['red'] as num?)?.toInt() ?? 0;
    final g2 = (color2['green'] as num?)?.toInt() ?? 0;
    final b2 = (color2['blue'] as num?)?.toInt() ?? 0;

    final brightness1 = (0.299 * r1 + 0.587 * g1 + 0.114 * b1) / 255;
    final brightness2 = (0.299 * r2 + 0.587 * g2 + 0.114 * b2) / 255;

    return (brightness1 - brightness2).abs();
  }

  double _estimateSharpness(List? textAnnotations) {
    // Estimate sharpness based on text detection quality
    if (textAnnotations == null || textAnnotations.isEmpty) return 0.5;

    // More text detected usually indicates sharper image
    final textCount = textAnnotations.length;

    if (textCount > 20) return 0.9;
    if (textCount > 10) return 0.7;
    if (textCount > 5) return 0.6;
    if (textCount > 2) return 0.5;

    return 0.3;
  }

  double _calculateOverallQuality(
    double brightness,
    double contrast,
    double sharpness,
    bool hasText,
  ) {
    var quality = 0.0;

    // Brightness score (penalize extremes)
    if (brightness > 0.2 && brightness < 0.8) {
      quality += 0.25;
    } else if (brightness > 0.1 && brightness < 0.9) {
      quality += 0.15;
    }

    // Contrast score
    quality += contrast * 0.25;

    // Sharpness score
    quality += sharpness * 0.4;

    // Text presence bonus
    if (hasText) quality += 0.1;

    return quality.clamp(0.0, 1.0);
  }

  void dispose() {
    _httpClient.close();
  }
}
