// 👁️ LingoSphere - Multimodal Models
// Comprehensive data models for vision AI, OCR, and multimodal intelligence

import 'dart:typed_data';

/// Core Multimodal Models
class MultimodalIntelligenceResult {
  final String id;
  final String sessionId;
  final MultimodalInputType inputType;
  final Map<String, dynamic> inputData;
  final List<IntelligenceInsight> insights;
  final Map<String, ConfidenceScore> confidenceScores;
  final Duration processingTime;
  final DateTime processedAt;
  final Map<String, dynamic> metadata;

  MultimodalIntelligenceResult({
    required this.id,
    required this.sessionId,
    required this.inputType,
    required this.inputData,
    required this.insights,
    required this.confidenceScores,
    required this.processingTime,
    required this.processedAt,
    required this.metadata,
  });

  static MultimodalIntelligenceResult empty() => MultimodalIntelligenceResult(
    id: '',
    sessionId: '',
    inputType: MultimodalInputType.image,
    inputData: {},
    insights: [],
    confidenceScores: {},
    processingTime: Duration.zero,
    processedAt: DateTime.now(),
    metadata: {},
  );
}

class IntelligenceInsight {
  final String type;
  final String category;
  final String description;
  final double confidence;
  final Map<String, dynamic> details;
  final List<String> tags;
  final InsightPriority priority;

  IntelligenceInsight({
    required this.type,
    required this.category,
    required this.description,
    required this.confidence,
    required this.details,
    required this.tags,
    required this.priority,
  });
}

class ConfidenceScore {
  final double overall;
  final double accuracy;
  final double reliability;
  final Map<String, double> componentScores;

  ConfidenceScore({
    required this.overall,
    required this.accuracy,
    required this.reliability,
    required this.componentScores,
  });
}

class VisionAnalysisResult {
  final String id;
  final VisionAnalysisType analysisType;
  final Uint8List? originalImage;
  final ImageMetadata imageMetadata;
  final List<DetectedObject> detectedObjects;
  final List<DetectedText> detectedText;
  final List<DetectedFace> detectedFaces;
  final SceneAnalysis sceneAnalysis;
  final Map<String, dynamic> rawResults;
  final double overallConfidence;
  final DateTime analyzedAt;

  VisionAnalysisResult({
    required this.id,
    required this.analysisType,
    this.originalImage,
    required this.imageMetadata,
    required this.detectedObjects,
    required this.detectedText,
    required this.detectedFaces,
    required this.sceneAnalysis,
    required this.rawResults,
    required this.overallConfidence,
    required this.analyzedAt,
  });

  static VisionAnalysisResult empty() => VisionAnalysisResult(
    id: '',
    analysisType: VisionAnalysisType.general,
    imageMetadata: ImageMetadata.empty(),
    detectedObjects: [],
    detectedText: [],
    detectedFaces: [],
    sceneAnalysis: SceneAnalysis.empty(),
    rawResults: {},
    overallConfidence: 0.0,
    analyzedAt: DateTime.now(),
  );
}

class ImageMetadata {
  final int width;
  final int height;
  final String format;
  final int fileSizeBytes;
  final String? colorSpace;
  final double? aspectRatio;
  final Map<String, dynamic> exifData;
  final DateTime? capturedAt;
  final String? cameraModel;
  final GpsCoordinates? location;

  ImageMetadata({
    required this.width,
    required this.height,
    required this.format,
    required this.fileSizeBytes,
    this.colorSpace,
    this.aspectRatio,
    required this.exifData,
    this.capturedAt,
    this.cameraModel,
    this.location,
  });

  static ImageMetadata empty() => ImageMetadata(
    width: 0,
    height: 0,
    format: 'unknown',
    fileSizeBytes: 0,
    exifData: {},
  );
}

class DetectedObject {
  final String id;
  final String label;
  final double confidence;
  final BoundingBox boundingBox;
  final Map<String, dynamic> properties;
  final List<String> categories;
  final ObjectRelations relations;

  DetectedObject({
    required this.id,
    required this.label,
    required this.confidence,
    required this.boundingBox,
    required this.properties,
    required this.categories,
    required this.relations,
  });
}

class DetectedText {
  final String id;
  final String text;
  final String detectedLanguage;
  final double confidence;
  final BoundingBox boundingBox;
  final TextOrientation orientation;
  final TextStyle style;
  final List<TextWord> words;

  DetectedText({
    required this.id,
    required this.text,
    required this.detectedLanguage,
    required this.confidence,
    required this.boundingBox,
    required this.orientation,
    required this.style,
    required this.words,
  });
}

class TextWord {
  final String word;
  final double confidence;
  final BoundingBox boundingBox;
  final Map<String, dynamic> properties;

  TextWord({
    required this.word,
    required this.confidence,
    required this.boundingBox,
    required this.properties,
  });
}

class DetectedFace {
  final String id;
  final BoundingBox boundingBox;
  final double confidence;
  final FaceAttributes attributes;
  final List<FaceLandmark> landmarks;
  final EmotionalAnalysis emotionalState;
  final String? estimatedAge;
  final String? estimatedGender;

  DetectedFace({
    required this.id,
    required this.boundingBox,
    required this.confidence,
    required this.attributes,
    required this.landmarks,
    required this.emotionalState,
    this.estimatedAge,
    this.estimatedGender,
  });
}

class FaceAttributes {
  final bool hasGlasses;
  final bool hasBeard;
  final bool isSmiling;
  final String eyeColor;
  final String hairColor;
  final Map<String, double> qualityMetrics;

  FaceAttributes({
    required this.hasGlasses,
    required this.hasBeard,
    required this.isSmiling,
    required this.eyeColor,
    required this.hairColor,
    required this.qualityMetrics,
  });
}

class FaceLandmark {
  final String type;
  final Point2D position;
  final double confidence;

  FaceLandmark({
    required this.type,
    required this.position,
    required this.confidence,
  });
}

class EmotionalAnalysis {
  final Map<String, double> emotionScores;
  final String dominantEmotion;
  final double emotionConfidence;
  final EmotionalValence valence;
  final double arousalLevel;

  EmotionalAnalysis({
    required this.emotionScores,
    required this.dominantEmotion,
    required this.emotionConfidence,
    required this.valence,
    required this.arousalLevel,
  });
}

class SceneAnalysis {
  final String sceneType;
  final String description;
  final double confidence;
  final List<String> tags;
  final Map<String, double> categoryScores;
  final ColorAnalysis colorAnalysis;
  final CompositionAnalysis composition;

  SceneAnalysis({
    required this.sceneType,
    required this.description,
    required this.confidence,
    required this.tags,
    required this.categoryScores,
    required this.colorAnalysis,
    required this.composition,
  });

  static SceneAnalysis empty() => SceneAnalysis(
    sceneType: 'unknown',
    description: '',
    confidence: 0.0,
    tags: [],
    categoryScores: {},
    colorAnalysis: ColorAnalysis.empty(),
    composition: CompositionAnalysis.empty(),
  );
}

class ColorAnalysis {
  final List<ColorPalette> dominantColors;
  final String colorScheme;
  final double colorHarmony;
  final Map<String, double> colorDistribution;

  ColorAnalysis({
    required this.dominantColors,
    required this.colorScheme,
    required this.colorHarmony,
    required this.colorDistribution,
  });

  static ColorAnalysis empty() => ColorAnalysis(
    dominantColors: [],
    colorScheme: 'unknown',
    colorHarmony: 0.0,
    colorDistribution: {},
  );
}

class ColorPalette {
  final String colorHex;
  final String colorName;
  final double percentage;
  final Map<String, int> rgbValues;
  final Map<String, double> hslValues;

  ColorPalette({
    required this.colorHex,
    required this.colorName,
    required this.percentage,
    required this.rgbValues,
    required this.hslValues,
  });
}

class CompositionAnalysis {
  final String layout;
  final double balance;
  final List<String> compositionalElements;
  final Map<String, double> ruleOfThirds;
  final double symmetryScore;

  CompositionAnalysis({
    required this.layout,
    required this.balance,
    required this.compositionalElements,
    required this.ruleOfThirds,
    required this.symmetryScore,
  });

  static CompositionAnalysis empty() => CompositionAnalysis(
    layout: 'unknown',
    balance: 0.0,
    compositionalElements: [],
    ruleOfThirds: {},
    symmetryScore: 0.0,
  );
}

class OCRResult {
  final String id;
  final String documentId;
  final List<OCRTextBlock> textBlocks;
  final List<OCRTable> tables;
  final List<OCRForm> forms;
  final double overallConfidence;
  final String detectedLanguage;
  final OCRQualityMetrics quality;
  final Map<String, dynamic> metadata;
  final DateTime processedAt;
  // Additional properties needed by multimodal AI service
  final List<TextRegion> textRegions;
  final double confidence;

  OCRResult({
    required this.id,
    required this.documentId,
    required this.textBlocks,
    required this.tables,
    required this.forms,
    required this.overallConfidence,
    required this.detectedLanguage,
    required this.quality,
    required this.metadata,
    required this.processedAt,
    required this.textRegions,
    required this.confidence,
  });

  static OCRResult empty() => OCRResult(
    id: '',
    documentId: '',
    textBlocks: [],
    tables: [],
    forms: [],
    overallConfidence: 0.0,
    detectedLanguage: '',
    quality: OCRQualityMetrics.empty(),
    metadata: {},
    processedAt: DateTime.now(),
    textRegions: [],
    confidence: 0.0,
  );
}

class OCRTextBlock {
  final String id;
  final String text;
  final BoundingBox boundingBox;
  final double confidence;
  final TextBlockType blockType;
  final Map<String, dynamic> formatting;
  final List<OCRLine> lines;

  OCRTextBlock({
    required this.id,
    required this.text,
    required this.boundingBox,
    required this.confidence,
    required this.blockType,
    required this.formatting,
    required this.lines,
  });
}

class OCRLine {
  final String text;
  final BoundingBox boundingBox;
  final double confidence;
  final List<OCRWord> words;

  OCRLine({
    required this.text,
    required this.boundingBox,
    required this.confidence,
    required this.words,
  });
}

class OCRWord {
  final String text;
  final BoundingBox boundingBox;
  final double confidence;
  final Map<String, dynamic> properties;

  OCRWord({
    required this.text,
    required this.boundingBox,
    required this.confidence,
    required this.properties,
  });
}

class OCRTable {
  final String id;
  final BoundingBox boundingBox;
  final int rows;
  final int columns;
  final List<List<OCRTableCell>> cells;
  final double confidence;

  OCRTable({
    required this.id,
    required this.boundingBox,
    required this.rows,
    required this.columns,
    required this.cells,
    required this.confidence,
  });
}

class OCRTableCell {
  final String text;
  final BoundingBox boundingBox;
  final int rowIndex;
  final int columnIndex;
  final int rowSpan;
  final int columnSpan;
  final double confidence;

  OCRTableCell({
    required this.text,
    required this.boundingBox,
    required this.rowIndex,
    required this.columnIndex,
    required this.rowSpan,
    required this.columnSpan,
    required this.confidence,
  });
}

class OCRForm {
  final String id;
  final String formType;
  final BoundingBox boundingBox;
  final Map<String, OCRFormField> fields;
  final double confidence;

  OCRForm({
    required this.id,
    required this.formType,
    required this.boundingBox,
    required this.fields,
    required this.confidence,
  });
}

class OCRFormField {
  final String key;
  final String value;
  final BoundingBox keyBoundingBox;
  final BoundingBox valueBoundingBox;
  final FormFieldType fieldType;
  final double confidence;

  OCRFormField({
    required this.key,
    required this.value,
    required this.keyBoundingBox,
    required this.valueBoundingBox,
    required this.fieldType,
    required this.confidence,
  });
}

class OCRQualityMetrics {
  final double textClarity;
  final double imageQuality;
  final double layoutComplexity;
  final double languageDetectionConfidence;
  final Map<String, double> qualityFactors;

  OCRQualityMetrics({
    required this.textClarity,
    required this.imageQuality,
    required this.layoutComplexity,
    required this.languageDetectionConfidence,
    required this.qualityFactors,
  });

  static OCRQualityMetrics empty() => OCRQualityMetrics(
    textClarity: 0.0,
    imageQuality: 0.0,
    layoutComplexity: 0.0,
    languageDetectionConfidence: 0.0,
    qualityFactors: {},
  );
}

class AudioIntelligence {
  final String id;
  final AudioAnalysisType analysisType;
  final AudioMetadata metadata;
  final SpeechAnalysis speechAnalysis;
  final EmotionRecognitionResult emotionRecognition;
  final BackgroundAnalysis backgroundAnalysis;
  final AudioQualityMetrics qualityMetrics;
  final DateTime analyzedAt;

  AudioIntelligence({
    required this.id,
    required this.analysisType,
    required this.metadata,
    required this.speechAnalysis,
    required this.emotionRecognition,
    required this.backgroundAnalysis,
    required this.qualityMetrics,
    required this.analyzedAt,
  });
}

class AudioMetadata {
  final Duration duration;
  final int sampleRate;
  final int channels;
  final int bitRate;
  final String format;
  final double volume;
  final Map<String, dynamic> technicalMetrics;

  AudioMetadata({
    required this.duration,
    required this.sampleRate,
    required this.channels,
    required this.bitRate,
    required this.format,
    required this.volume,
    required this.technicalMetrics,
  });
}

class SpeechAnalysis {
  final List<SpeechSegment> segments;
  final Map<String, double> speakerCharacteristics;
  final double speechRate;
  final List<String> detectedLanguages;
  final Map<String, double> languageConfidences;
  final SpeechQuality quality;

  SpeechAnalysis({
    required this.segments,
    required this.speakerCharacteristics,
    required this.speechRate,
    required this.detectedLanguages,
    required this.languageConfidences,
    required this.quality,
  });
}

class SpeechSegment {
  final String id;
  final Duration startTime;
  final Duration endTime;
  final String text;
  final String detectedLanguage;
  final double confidence;
  final Map<String, dynamic> acousticFeatures;

  SpeechSegment({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.text,
    required this.detectedLanguage,
    required this.confidence,
    required this.acousticFeatures,
  });
}

class EmotionRecognitionResult {
  final Map<String, double> emotionScores;
  final String dominantEmotion;
  final double emotionStability;
  final List<EmotionTimestamp> emotionTimeline;
  final double overallConfidence;

  EmotionRecognitionResult({
    required this.emotionScores,
    required this.dominantEmotion,
    required this.emotionStability,
    required this.emotionTimeline,
    required this.overallConfidence,
  });
}

class EmotionTimestamp {
  final Duration timestamp;
  final String emotion;
  final double intensity;
  final double confidence;

  EmotionTimestamp({
    required this.timestamp,
    required this.emotion,
    required this.intensity,
    required this.confidence,
  });
}

class BackgroundAnalysis {
  final List<DetectedSound> detectedSounds;
  final double noiseLevel;
  final String environmentType;
  final Map<String, double> acousticProperties;

  BackgroundAnalysis({
    required this.detectedSounds,
    required this.noiseLevel,
    required this.environmentType,
    required this.acousticProperties,
  });
}

class DetectedSound {
  final String soundType;
  final Duration startTime;
  final Duration endTime;
  final double confidence;
  final double intensity;

  DetectedSound({
    required this.soundType,
    required this.startTime,
    required this.endTime,
    required this.confidence,
    required this.intensity,
  });
}

class AudioQualityMetrics {
  final double clarity;
  final double signalToNoise;
  final double distortion;
  final double dynamicRange;
  final Map<String, double> frequencyAnalysis;

  AudioQualityMetrics({
    required this.clarity,
    required this.signalToNoise,
    required this.distortion,
    required this.dynamicRange,
    required this.frequencyAnalysis,
  });
}

class ContextEnhancedTranslation {
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final VisualContext visualContext;
  final AudioContext audioContext;
  final Map<String, dynamic> contextualAdaptations;
  final double contextAwarenessScore;
  final DateTime translatedAt;

  ContextEnhancedTranslation({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.visualContext,
    required this.audioContext,
    required this.contextualAdaptations,
    required this.contextAwarenessScore,
    required this.translatedAt,
  });
}

class VisualContext {
  final List<String> sceneElements;
  final Map<String, String> objectTranslations;
  final String environmentType;
  final List<String> culturalMarkers;
  final Map<String, dynamic> visualCues;

  VisualContext({
    required this.sceneElements,
    required this.objectTranslations,
    required this.environmentType,
    required this.culturalMarkers,
    required this.visualCues,
  });
}

class AudioContext {
  final String speakerMood;
  final double emotionalIntensity;
  final String backgroundEnvironment;
  final List<String> acousticContexts;
  final Map<String, dynamic> audioContextCues;

  AudioContext({
    required this.speakerMood,
    required this.emotionalIntensity,
    required this.backgroundEnvironment,
    required this.acousticContexts,
    required this.audioContextCues,
  });
}

/// Utility Classes
class BoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;

  BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  double get area => width * height;
  Point2D get center => Point2D(x + width / 2, y + height / 2);
}

class Point2D {
  final double x;
  final double y;

  Point2D(this.x, this.y);
}

class GpsCoordinates {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;

  GpsCoordinates({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
  });
}

class ObjectRelations {
  final List<String> relatedObjects;
  final Map<String, String> spatialRelations;
  final Map<String, double> relationshipStrengths;

  ObjectRelations({
    required this.relatedObjects,
    required this.spatialRelations,
    required this.relationshipStrengths,
  });
}

class TextOrientation {
  final double angle;
  final TextDirection direction;
  final bool isUpright;

  TextOrientation({
    required this.angle,
    required this.direction,
    required this.isUpright,
  });
}

class TextStyle {
  final String fontFamily;
  final double fontSize;
  final bool isBold;
  final bool isItalic;
  final String color;

  TextStyle({
    required this.fontFamily,
    required this.fontSize,
    required this.isBold,
    required this.isItalic,
    required this.color,
  });
}

class SpeechQuality {
  final double clarity;
  final double fluency;
  final double pronunciation;
  final double pace;
  final Map<String, double> qualityMetrics;

  SpeechQuality({
    required this.clarity,
    required this.fluency,
    required this.pronunciation,
    required this.pace,
    required this.qualityMetrics,
  });
}

class TextRegion {
  final BoundingBox boundingBox;
  final String text;
  final String originalText;
  final String translatedText;
  final double confidence;
  final VisualContext visualContext;
  final String semanticRole;
  final String detectedLanguage;

  TextRegion({
    required this.boundingBox,
    required this.text,
    required this.originalText,
    required this.translatedText,
    required this.confidence,
    required this.visualContext,
    required this.semanticRole,
    required this.detectedLanguage,
  });

  static TextRegion empty() => TextRegion(
    boundingBox: BoundingBox(x: 0, y: 0, width: 0, height: 0),
    text: '',
    originalText: '',
    translatedText: '',
    confidence: 0.0,
    visualContext: VisualContext(
      sceneElements: [],
      objectTranslations: {},
      environmentType: '',
      culturalMarkers: [],
      visualCues: {},
    ),
    semanticRole: '',
    detectedLanguage: '',
  );
}

/// Enums
enum MultimodalInputType {
  image,
  audio,
  video,
  document,
  mixed
}

enum InsightPriority {
  low,
  medium,
  high,
  critical
}

enum VisionAnalysisType {
  general,
  text,
  face,
  object,
  scene,
  medical,
  document
}

enum EmotionalValence {
  negative,
  neutral,
  positive
}

enum TextDirection {
  leftToRight,
  rightToLeft,
  topToBottom,
  bottomToTop
}

enum TextBlockType {
  paragraph,
  heading,
  list,
  table,
  caption,
  footer,
  header
}

enum FormFieldType {
  text,
  number,
  date,
  checkbox,
  signature,
  unknown
}

enum AudioAnalysisType {
  speech,
  music,
  environmental,
  mixed
}
