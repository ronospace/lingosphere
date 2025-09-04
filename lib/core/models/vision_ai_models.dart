// 👁️ LingoSphere - Vision AI Models
// Data models for image context understanding and visual translation enhancement

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'neural_conversation_models.dart';

part 'vision_ai_models.g.dart';

/// Vision analysis result containing image understanding data
@JsonSerializable()
class VisionAnalysisResult extends Equatable {
  final String imagePath;
  final List<DetectedText> detectedText;
  final List<DetectedObject> detectedObjects;
  final String sceneDescription;
  final List<String> culturalMarkers;
  final List<String> contextualInsights;
  final List<String> translationSuggestions;
  final double confidence;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime processingTime;

  const VisionAnalysisResult({
    required this.imagePath,
    required this.detectedText,
    required this.detectedObjects,
    required this.sceneDescription,
    required this.culturalMarkers,
    required this.contextualInsights,
    required this.translationSuggestions,
    required this.confidence,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.processingTime,
  });

  factory VisionAnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$VisionAnalysisResultFromJson(json);

  Map<String, dynamic> toJson() => _$VisionAnalysisResultToJson(this);

  /// Create from TurnAnalysis for compatibility
  factory VisionAnalysisResult.fromTurnAnalysis(TurnAnalysis analysis) {
    return VisionAnalysisResult(
      imagePath: '',
      detectedText: [],
      detectedObjects: [],
      sceneDescription: 'Cached analysis result',
      culturalMarkers: analysis.culturalMarkers.detectedMarkers,
      contextualInsights: ['From cached turn analysis'],
      translationSuggestions: analysis.culturalMarkers.adaptationSuggestions,
      confidence: analysis.confidence,
      sourceLanguage: 'unknown',
      targetLanguage: 'unknown',
      processingTime: DateTime.now(),
    );
  }

  /// Convert to TurnAnalysis for caching
  TurnAnalysis toTurnAnalysis() {
    return TurnAnalysis(
      sentiment: SentimentAnalysis(
        primarySentiment: SentimentType.neutral,
        intensity: 0.5,
        sentimentSpectrum: {SentimentType.neutral: 1.0},
        emotionVector: EmotionVector(
          valence: 0.0,
          arousal: 0.0,
          dominance: 0.0,
          certainty: confidence,
        ),
        emotionalStability: 0.8,
        emotionalShifts: [],
      ),
      intent: const IntentAnalysis(
        primaryIntent: 'visual_analysis',
        confidence: 0.9,
        secondaryIntents: ['context_extraction'],
      ),
      contextRelevance: ContextualRelevance(
        relevanceScore: confidence,
        relevantElements: detectedObjects.map((obj) => obj.name).toList(),
        contextConnections: contextualInsights,
      ),
      complexity: LinguisticComplexity(
        complexityScore: detectedText.length > 10 ? 0.8 : 0.4,
        sentenceLength: detectedText.length,
        vocabularyLevel: 2,
        complexFeatures: translationSuggestions,
      ),
      culturalMarkers: CulturalMarkers(
        detectedMarkers: culturalMarkers,
        culturalScores: {'visual_context': confidence},
        adaptationSuggestions: translationSuggestions,
      ),
      confidence: confidence,
      keyEntities: detectedObjects.map((obj) => obj.name).toList(),
      topics: ['visual_analysis', 'image_context'],
    );
  }

  @override
  List<Object?> get props => [
        imagePath,
        detectedText,
        detectedObjects,
        sceneDescription,
        culturalMarkers,
        contextualInsights,
        translationSuggestions,
        confidence,
        sourceLanguage,
        targetLanguage,
        processingTime,
      ];
}

/// Detected text in image with location and confidence
@JsonSerializable()
class DetectedText extends Equatable {
  final String text;
  final double confidence;
  final BoundingBox boundingBox;
  final String? language;

  const DetectedText({
    required this.text,
    required this.confidence,
    required this.boundingBox,
    this.language,
  });

  factory DetectedText.fromJson(Map<String, dynamic> json) =>
      _$DetectedTextFromJson(json);

  Map<String, dynamic> toJson() => _$DetectedTextToJson(this);

  @override
  List<Object?> get props => [text, confidence, boundingBox, language];
}

/// Detected object in image with location and confidence
@JsonSerializable()
class DetectedObject extends Equatable {
  final String name;
  final double confidence;
  final BoundingBox boundingBox;
  final Map<String, dynamic>? attributes;

  const DetectedObject({
    required this.name,
    required this.confidence,
    required this.boundingBox,
    this.attributes,
  });

  factory DetectedObject.fromJson(Map<String, dynamic> json) =>
      _$DetectedObjectFromJson(json);

  Map<String, dynamic> toJson() => _$DetectedObjectToJson(this);

  @override
  List<Object?> get props => [name, confidence, boundingBox, attributes];
}

/// Bounding box for detected elements
@JsonSerializable()
class BoundingBox extends Equatable {
  final double x;
  final double y;
  final double width;
  final double height;

  const BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory BoundingBox.fromJson(Map<String, dynamic> json) =>
      _$BoundingBoxFromJson(json);

  Map<String, dynamic> toJson() => _$BoundingBoxToJson(this);

  /// Get center point of bounding box
  Point get center => Point(x + width / 2, y + height / 2);

  /// Get area of bounding box
  double get area => width * height;

  /// Check if this box overlaps with another
  bool overlaps(BoundingBox other) {
    return x < other.x + other.width &&
        x + width > other.x &&
        y < other.y + other.height &&
        y + height > other.y;
  }

  @override
  List<Object?> get props => [x, y, width, height];
}

/// Point representation for geometric calculations
@JsonSerializable()
class Point extends Equatable {
  final double x;
  final double y;

  const Point(this.x, this.y);

  factory Point.fromJson(Map<String, dynamic> json) => _$PointFromJson(json);

  Map<String, dynamic> toJson() => _$PointToJson(this);

  /// Calculate distance to another point
  double distanceTo(Point other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return (dx * dx + dy * dy) * 0.5; // sqrt approximation
  }

  @override
  List<Object?> get props => [x, y];
}

/// Visual context extracted from image
@JsonSerializable()
class VisualContext extends Equatable {
  final String imagePath;
  final List<String> detectedObjects;
  final String sceneDescription;
  final List<String> textElements;
  final List<String> colors;
  final String mood;
  final List<String> culturalMarkers;
  final DateTime timestamp;
  final double confidence;

  const VisualContext({
    required this.imagePath,
    required this.detectedObjects,
    required this.sceneDescription,
    required this.textElements,
    required this.colors,
    required this.mood,
    required this.culturalMarkers,
    required this.timestamp,
    required this.confidence,
  });

  factory VisualContext.fromJson(Map<String, dynamic> json) =>
      _$VisualContextFromJson(json);

  Map<String, dynamic> toJson() => _$VisualContextToJson(this);

  @override
  List<Object?> get props => [
        imagePath,
        detectedObjects,
        sceneDescription,
        textElements,
        colors,
        mood,
        culturalMarkers,
        timestamp,
        confidence,
      ];
}

/// Context-enhanced translation result
@JsonSerializable()
class ContextEnhancedTranslation extends Equatable {
  final String originalText;
  final String baseTranslation;
  final String enhancedTranslation;
  final VisualContext visualContext;
  final List<String> improvements;
  final double confidence;
  final double contextRelevance;
  final DateTime timestamp;

  const ContextEnhancedTranslation({
    required this.originalText,
    required this.baseTranslation,
    required this.enhancedTranslation,
    required this.visualContext,
    required this.improvements,
    required this.confidence,
    required this.contextRelevance,
    required this.timestamp,
  });

  factory ContextEnhancedTranslation.fromJson(Map<String, dynamic> json) =>
      _$ContextEnhancedTranslationFromJson(json);

  Map<String, dynamic> toJson() => _$ContextEnhancedTranslationToJson(this);

  /// Check if enhancement significantly improved translation
  bool get isSignificantImprovement {
    return enhancedTranslation != baseTranslation &&
        improvements.isNotEmpty &&
        contextRelevance > 0.7;
  }

  /// Get improvement summary
  String get improvementSummary {
    if (improvements.isEmpty) return 'No improvements suggested';
    return improvements.join('; ');
  }

  @override
  List<Object?> get props => [
        originalText,
        baseTranslation,
        enhancedTranslation,
        visualContext,
        improvements,
        confidence,
        contextRelevance,
        timestamp,
      ];
}

/// Vision AI capabilities
@JsonSerializable()
class VisionCapabilities extends Equatable {
  final bool textExtraction;
  final bool objectDetection;
  final bool sceneAnalysis;
  final bool culturalContext;
  final bool emotionalAnalysis;
  final bool colorAnalysis;
  final bool faceDetection;
  final bool landmarkDetection;
  final bool logoDetection;

  const VisionCapabilities({
    required this.textExtraction,
    required this.objectDetection,
    required this.sceneAnalysis,
    required this.culturalContext,
    required this.emotionalAnalysis,
    required this.colorAnalysis,
    required this.faceDetection,
    required this.landmarkDetection,
    required this.logoDetection,
  });

  factory VisionCapabilities.fromJson(Map<String, dynamic> json) =>
      _$VisionCapabilitiesFromJson(json);

  Map<String, dynamic> toJson() => _$VisionCapabilitiesToJson(this);

  /// Get list of enabled capabilities
  List<String> get enabledCapabilities {
    final enabled = <String>[];
    if (textExtraction) enabled.add('Text Extraction');
    if (objectDetection) enabled.add('Object Detection');
    if (sceneAnalysis) enabled.add('Scene Analysis');
    if (culturalContext) enabled.add('Cultural Context');
    if (emotionalAnalysis) enabled.add('Emotional Analysis');
    if (colorAnalysis) enabled.add('Color Analysis');
    if (faceDetection) enabled.add('Face Detection');
    if (landmarkDetection) enabled.add('Landmark Detection');
    if (logoDetection) enabled.add('Logo Detection');
    return enabled;
  }

  /// Get capability score (0.0 to 1.0)
  double get capabilityScore {
    int enabledCount = 0;
    if (textExtraction) enabledCount++;
    if (objectDetection) enabledCount++;
    if (sceneAnalysis) enabledCount++;
    if (culturalContext) enabledCount++;
    if (emotionalAnalysis) enabledCount++;
    if (colorAnalysis) enabledCount++;
    if (faceDetection) enabledCount++;
    if (landmarkDetection) enabledCount++;
    if (logoDetection) enabledCount++;

    return enabledCount / 9.0;
  }

  @override
  List<Object?> get props => [
        textExtraction,
        objectDetection,
        sceneAnalysis,
        culturalContext,
        emotionalAnalysis,
        colorAnalysis,
        faceDetection,
        landmarkDetection,
        logoDetection,
      ];
}

/// Multi-modal translation result combining text and visual analysis
@JsonSerializable()
class MultiModalTranslationResult extends Equatable {
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final VisionAnalysisResult? visualAnalysis;
  final ContextEnhancedTranslation? contextEnhanced;
  final double overallConfidence;
  final Map<String, dynamic> insights;
  final DateTime timestamp;

  const MultiModalTranslationResult({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.visualAnalysis,
    this.contextEnhanced,
    required this.overallConfidence,
    this.insights = const {},
    required this.timestamp,
  });

  factory MultiModalTranslationResult.fromJson(Map<String, dynamic> json) =>
      _$MultiModalTranslationResultFromJson(json);

  Map<String, dynamic> toJson() => _$MultiModalTranslationResultToJson(this);

  /// Check if visual context was used
  bool get hasVisualContext => visualAnalysis != null;

  /// Check if translation was enhanced by context
  bool get wasContextEnhanced => contextEnhanced != null;

  /// Get the best available translation
  String get bestTranslation {
    if (contextEnhanced != null && contextEnhanced!.isSignificantImprovement) {
      return contextEnhanced!.enhancedTranslation;
    }
    return translatedText;
  }

  /// Get enhancement details
  String? get enhancementDetails {
    if (contextEnhanced != null) {
      return contextEnhanced!.improvementSummary;
    }
    return null;
  }

  @override
  List<Object?> get props => [
        originalText,
        translatedText,
        sourceLanguage,
        targetLanguage,
        visualAnalysis,
        contextEnhanced,
        overallConfidence,
        insights,
        timestamp,
      ];
}

/// Batch vision analysis request
@JsonSerializable()
class BatchVisionRequest extends Equatable {
  final List<String> imagePaths;
  final String sourceLanguage;
  final String targetLanguage;
  final int maxConcurrent;
  final Map<String, String>? imageContexts;

  const BatchVisionRequest({
    required this.imagePaths,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.maxConcurrent = 3,
    this.imageContexts,
  });

  factory BatchVisionRequest.fromJson(Map<String, dynamic> json) =>
      _$BatchVisionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$BatchVisionRequestToJson(this);

  @override
  List<Object?> get props => [
        imagePaths,
        sourceLanguage,
        targetLanguage,
        maxConcurrent,
        imageContexts,
      ];
}

/// Batch vision analysis result
@JsonSerializable()
class BatchVisionResult extends Equatable {
  final List<VisionAnalysisResult> results;
  final List<String> errors;
  final int successCount;
  final int errorCount;
  final Duration processingTime;
  final DateTime timestamp;

  const BatchVisionResult({
    required this.results,
    required this.errors,
    required this.successCount,
    required this.errorCount,
    required this.processingTime,
    required this.timestamp,
  });

  factory BatchVisionResult.fromJson(Map<String, dynamic> json) =>
      _$BatchVisionResultFromJson(json);

  Map<String, dynamic> toJson() => _$BatchVisionResultToJson(this);

  /// Get success rate as percentage
  double get successRate {
    final total = successCount + errorCount;
    return total > 0 ? (successCount / total) * 100 : 0.0;
  }

  /// Check if batch processing was successful
  bool get isSuccessful => errorCount == 0;

  @override
  List<Object?> get props => [
        results,
        errors,
        successCount,
        errorCount,
        processingTime,
        timestamp,
      ];
}

/// Vision processing statistics
@JsonSerializable()
class VisionProcessingStats extends Equatable {
  final int totalImagesProcessed;
  final int successfulAnalyses;
  final int failedAnalyses;
  final double averageProcessingTime;
  final double averageConfidence;
  final Map<String, int> objectDetectionCounts;
  final Map<String, int> culturalMarkerCounts;
  final DateTime lastUpdated;

  const VisionProcessingStats({
    required this.totalImagesProcessed,
    required this.successfulAnalyses,
    required this.failedAnalyses,
    required this.averageProcessingTime,
    required this.averageConfidence,
    required this.objectDetectionCounts,
    required this.culturalMarkerCounts,
    required this.lastUpdated,
  });

  factory VisionProcessingStats.fromJson(Map<String, dynamic> json) =>
      _$VisionProcessingStatsFromJson(json);

  Map<String, dynamic> toJson() => _$VisionProcessingStatsToJson(this);

  /// Get success rate as percentage
  double get successRate {
    return totalImagesProcessed > 0
        ? (successfulAnalyses / totalImagesProcessed) * 100
        : 0.0;
  }

  /// Get most common detected object
  String? get mostCommonObject {
    if (objectDetectionCounts.isEmpty) return null;

    return objectDetectionCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Get most common cultural marker
  String? get mostCommonCulturalMarker {
    if (culturalMarkerCounts.isEmpty) return null;

    return culturalMarkerCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  @override
  List<Object?> get props => [
        totalImagesProcessed,
        successfulAnalyses,
        failedAnalyses,
        averageProcessingTime,
        averageConfidence,
        objectDetectionCounts,
        culturalMarkerCounts,
        lastUpdated,
      ];
}

/// Image quality assessment
@JsonSerializable()
class ImageQualityAssessment extends Equatable {
  final String imagePath;
  final double overallQuality;
  final double sharpness;
  final double brightness;
  final double contrast;
  final bool hasText;
  final bool hasFaces;
  final bool isBlurry;
  final List<String> qualityIssues;
  final Map<String, dynamic> technicalDetails;

  const ImageQualityAssessment({
    required this.imagePath,
    required this.overallQuality,
    required this.sharpness,
    required this.brightness,
    required this.contrast,
    required this.hasText,
    required this.hasFaces,
    required this.isBlurry,
    required this.qualityIssues,
    this.technicalDetails = const {},
  });

  factory ImageQualityAssessment.fromJson(Map<String, dynamic> json) =>
      _$ImageQualityAssessmentFromJson(json);

  Map<String, dynamic> toJson() => _$ImageQualityAssessmentToJson(this);

  /// Check if image is suitable for vision analysis
  bool get isSuitableForAnalysis => overallQuality > 0.6 && !isBlurry;

  /// Get quality rating as text
  String get qualityRating {
    if (overallQuality > 0.8) return 'Excellent';
    if (overallQuality > 0.6) return 'Good';
    if (overallQuality > 0.4) return 'Fair';
    return 'Poor';
  }

  @override
  List<Object?> get props => [
        imagePath,
        overallQuality,
        sharpness,
        brightness,
        contrast,
        hasText,
        hasFaces,
        isBlurry,
        qualityIssues,
        technicalDetails,
      ];
}
