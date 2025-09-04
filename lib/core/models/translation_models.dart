// 🌐 LingoSphere - Translation Models
// Comprehensive data models for translation results, context analysis, and metadata

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../constants/app_constants.dart';

part 'translation_models.g.dart';

/// Main translation result containing all translation data and metadata
@JsonSerializable()
class TranslationResult extends Equatable {
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final TranslationConfidence confidence;
  final String provider;
  final SentimentAnalysis sentiment;
  final ContextAnalysis context;
  final TranslationMetadata metadata;
  final List<AlternativeTranslation>? alternatives;

  const TranslationResult({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.confidence,
    required this.provider,
    required this.sentiment,
    required this.context,
    required this.metadata,
    this.alternatives,
  });

  factory TranslationResult.fromJson(Map<String, dynamic> json) =>
      _$TranslationResultFromJson(json);

  Map<String, dynamic> toJson() => _$TranslationResultToJson(this);

  TranslationResult copyWith({
    String? originalText,
    String? translatedText,
    String? sourceLanguage,
    String? targetLanguage,
    TranslationConfidence? confidence,
    String? provider,
    SentimentAnalysis? sentiment,
    ContextAnalysis? context,
    TranslationMetadata? metadata,
    List<AlternativeTranslation>? alternatives,
  }) {
    return TranslationResult(
      originalText: originalText ?? this.originalText,
      translatedText: translatedText ?? this.translatedText,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      confidence: confidence ?? this.confidence,
      provider: provider ?? this.provider,
      sentiment: sentiment ?? this.sentiment,
      context: context ?? this.context,
      metadata: metadata ?? this.metadata,
      alternatives: alternatives ?? this.alternatives,
    );
  }

  /// Get confidence as percentage
  double get confidencePercentage {
    switch (confidence) {
      case TranslationConfidence.high:
        return 95.0;
      case TranslationConfidence.medium:
        return 80.0;
      case TranslationConfidence.low:
        return 65.0;
      case TranslationConfidence.uncertain:
        return 40.0;
    }
  }

  /// Check if translation is high quality
  bool get isHighQuality => confidence == TranslationConfidence.high;

  /// Get language pair string
  String get languagePair => '$sourceLanguage → $targetLanguage';

  @override
  List<Object?> get props => [
        originalText,
        translatedText,
        sourceLanguage,
        targetLanguage,
        confidence,
        provider,
        sentiment,
        context,
        metadata,
        alternatives,
      ];
}

/// Alternative translation suggestions
@JsonSerializable()
class AlternativeTranslation extends Equatable {
  final String text;
  final double confidence;
  final String? context;
  final Map<String, dynamic>? metadata;

  const AlternativeTranslation({
    required this.text,
    required this.confidence,
    this.context,
    this.metadata,
  });

  factory AlternativeTranslation.fromJson(Map<String, dynamic> json) =>
      _$AlternativeTranslationFromJson(json);

  Map<String, dynamic> toJson() => _$AlternativeTranslationToJson(this);

  @override
  List<Object?> get props => [text, confidence, context, metadata];
}

/// Sentiment analysis results
@JsonSerializable()
class SentimentAnalysis extends Equatable {
  final SentimentType sentiment;
  final double score; // -1.0 to 1.0
  final double confidence; // 0.0 to 100.0
  final Map<String, dynamic>? details;

  const SentimentAnalysis({
    required this.sentiment,
    required this.score,
    required this.confidence,
    this.details,
  });

  factory SentimentAnalysis.fromJson(Map<String, dynamic> json) =>
      _$SentimentAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$SentimentAnalysisToJson(this);

  /// Get sentiment as readable string
  String get sentimentString {
    switch (sentiment) {
      case SentimentType.positive:
        return 'Positive';
      case SentimentType.negative:
        return 'Negative';
      case SentimentType.neutral:
        return 'Neutral';
    }
  }

  /// Get sentiment emoji representation
  String get sentimentEmoji {
    switch (sentiment) {
      case SentimentType.positive:
        return '😊';
      case SentimentType.negative:
        return '😔';
      case SentimentType.neutral:
        return '😐';
    }
  }

  /// Check if sentiment is strong (high confidence)
  bool get isStrong => confidence > 70.0;

  @override
  List<Object?> get props => [sentiment, score, confidence, details];
}

/// Context analysis for better translation quality
@JsonSerializable()
class ContextAnalysis extends Equatable {
  final FormalityLevel formality;
  final TextDomain domain;
  final List<String> culturalMarkers;
  final double slangLevel; // 0.0 to 1.0
  final Map<String, dynamic> additionalContext;

  const ContextAnalysis({
    required this.formality,
    required this.domain,
    required this.culturalMarkers,
    required this.slangLevel,
    required this.additionalContext,
  });

  factory ContextAnalysis.fromJson(Map<String, dynamic> json) =>
      _$ContextAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$ContextAnalysisToJson(this);

  /// Get formality as readable string
  String get formalityString {
    switch (formality) {
      case FormalityLevel.formal:
        return 'Formal';
      case FormalityLevel.informal:
        return 'Informal';
      case FormalityLevel.neutral:
        return 'Neutral';
    }
  }

  /// Get domain as readable string
  String get domainString {
    switch (domain) {
      case TextDomain.business:
        return 'Business';
      case TextDomain.technical:
        return 'Technical';
      case TextDomain.casual:
        return 'Casual';
      case TextDomain.academic:
        return 'Academic';
      case TextDomain.creative:
        return 'Creative';
      case TextDomain.general:
        return 'General';
    }
  }

  /// Check if text contains significant slang
  bool get hasSlang => slangLevel > 0.2;

  /// Check if text has cultural context
  bool get hasCulturalContext => culturalMarkers.isNotEmpty;

  @override
  List<Object?> get props => [
        formality,
        domain,
        culturalMarkers,
        slangLevel,
        additionalContext,
      ];
}

/// Translation metadata for analytics and performance tracking
@JsonSerializable()
class TranslationMetadata extends Equatable {
  final DateTime timestamp;
  final Duration? processingTime;
  final String? userId;
  final String? sessionId;
  final Map<String, dynamic>? analytics;

  const TranslationMetadata({
    required this.timestamp,
    this.processingTime,
    this.userId,
    this.sessionId,
    this.analytics,
  });

  factory TranslationMetadata.fromJson(Map<String, dynamic> json) =>
      _$TranslationMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$TranslationMetadataToJson(this);

  TranslationMetadata copyWith({
    DateTime? timestamp,
    Duration? processingTime,
    String? userId,
    String? sessionId,
    Map<String, dynamic>? analytics,
  }) {
    return TranslationMetadata(
      timestamp: timestamp ?? this.timestamp,
      processingTime: processingTime ?? this.processingTime,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      analytics: analytics ?? this.analytics,
    );
  }

  /// Get processing time in milliseconds
  int? get processingTimeMs => processingTime?.inMilliseconds;

  /// Check if translation was fast (< 500ms)
  bool get isFast =>
      processingTime != null && processingTime!.inMilliseconds < 500;

  @override
  List<Object?> get props => [
        timestamp,
        processingTime,
        userId,
        sessionId,
        analytics,
      ];
}

/// Cached translation for performance optimization
@JsonSerializable()
class CachedTranslation extends Equatable {
  final TranslationResult result;
  final DateTime cachedAt;
  final Duration expiresAfter;

  const CachedTranslation({
    required this.result,
    required this.cachedAt,
    required this.expiresAfter,
  });

  factory CachedTranslation.fromJson(Map<String, dynamic> json) =>
      _$CachedTranslationFromJson(json);

  Map<String, dynamic> toJson() => _$CachedTranslationToJson(this);

  /// Check if cached translation is expired
  bool get isExpired {
    final expiryTime = cachedAt.add(expiresAfter);
    return DateTime.now().isAfter(expiryTime);
  }

  /// Get remaining time before expiration
  Duration? get timeToExpiry {
    if (isExpired) return null;
    final expiryTime = cachedAt.add(expiresAfter);
    return expiryTime.difference(DateTime.now());
  }

  @override
  List<Object?> get props => [result, cachedAt, expiresAfter];
}

/// Language detection result
@JsonSerializable()
class LanguageDetection extends Equatable {
  final String language;
  final double confidence;
  final List<LanguageMatch>? alternatives;

  const LanguageDetection({
    required this.language,
    required this.confidence,
    this.alternatives,
  });

  factory LanguageDetection.fromJson(Map<String, dynamic> json) =>
      _$LanguageDetectionFromJson(json);

  Map<String, dynamic> toJson() => _$LanguageDetectionToJson(this);

  /// Get language name
  String get languageName =>
      AppConstants.supportedLanguages[language] ?? language;

  /// Check if detection is reliable
  bool get isReliable => confidence > 0.8;

  @override
  List<Object?> get props => [language, confidence, alternatives];
}

/// Language match for detection alternatives
@JsonSerializable()
class LanguageMatch extends Equatable {
  final String language;
  final double confidence;

  const LanguageMatch({
    required this.language,
    required this.confidence,
  });

  factory LanguageMatch.fromJson(Map<String, dynamic> json) =>
      _$LanguageMatchFromJson(json);

  Map<String, dynamic> toJson() => _$LanguageMatchToJson(this);

  @override
  List<Object?> get props => [language, confidence];
}

/// Voice translation specific data
@JsonSerializable()
class VoiceTranslation extends Equatable {
  final TranslationResult translation;
  final Duration audioDuration;
  final double audioQuality;
  final String? audioFormat;
  final SpeechRecognitionMetadata speechMetadata;

  const VoiceTranslation({
    required this.translation,
    required this.audioDuration,
    required this.audioQuality,
    this.audioFormat,
    required this.speechMetadata,
  });

  factory VoiceTranslation.fromJson(Map<String, dynamic> json) =>
      _$VoiceTranslationFromJson(json);

  Map<String, dynamic> toJson() => _$VoiceTranslationToJson(this);

  @override
  List<Object?> get props => [
        translation,
        audioDuration,
        audioQuality,
        audioFormat,
        speechMetadata,
      ];
}

/// Speech recognition metadata
@JsonSerializable()
class SpeechRecognitionMetadata extends Equatable {
  final double confidence;
  final List<String>? alternatives;
  final bool hasNoise;
  final String? accent;

  const SpeechRecognitionMetadata({
    required this.confidence,
    this.alternatives,
    required this.hasNoise,
    this.accent,
  });

  factory SpeechRecognitionMetadata.fromJson(Map<String, dynamic> json) =>
      _$SpeechRecognitionMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$SpeechRecognitionMetadataToJson(this);

  @override
  List<Object?> get props => [confidence, alternatives, hasNoise, accent];
}

/// Enhanced Voice Recognition Result
@JsonSerializable()
class VoiceRecognitionResult extends Equatable {
  final String text;
  final double confidence;
  final bool isFinal;
  final String language;
  final List<String>? alternatives;
  final DateTime timestamp;
  final Duration? processingTime;

  const VoiceRecognitionResult({
    required this.text,
    required this.confidence,
    required this.isFinal,
    required this.language,
    this.alternatives,
    required this.timestamp,
    this.processingTime,
  });

  VoiceRecognitionResult.create({
    required this.text,
    required this.confidence,
    required this.isFinal,
    required this.language,
    this.alternatives,
    DateTime? timestamp,
    this.processingTime,
  }) : timestamp = timestamp ?? DateTime.now();

  factory VoiceRecognitionResult.fromJson(Map<String, dynamic> json) =>
      _$VoiceRecognitionResultFromJson(json);

  Map<String, dynamic> toJson() => _$VoiceRecognitionResultToJson(this);

  VoiceRecognitionResult copyWith({
    String? text,
    double? confidence,
    bool? isFinal,
    String? language,
    List<String>? alternatives,
    DateTime? timestamp,
    Duration? processingTime,
  }) {
    return VoiceRecognitionResult(
      text: text ?? this.text,
      confidence: confidence ?? this.confidence,
      isFinal: isFinal ?? this.isFinal,
      language: language ?? this.language,
      alternatives: alternatives ?? this.alternatives,
      timestamp: timestamp ?? this.timestamp,
      processingTime: processingTime ?? this.processingTime,
    );
  }

  @override
  List<Object?> get props => [
    text,
    confidence,
    isFinal,
    language,
    alternatives,
    timestamp,
    processingTime,
  ];
}

/// Enhanced Voice Translation Result
@JsonSerializable()
class VoiceTranslationResult extends Equatable {
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final double speechConfidence;
  final double translationConfidence;
  final Duration totalProcessingTime;
  final String provider;
  final SentimentAnalysis sentiment;
  final bool isFinal;
  final DateTime timestamp;

  const VoiceTranslationResult({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.speechConfidence,
    required this.translationConfidence,
    required this.totalProcessingTime,
    required this.provider,
    required this.sentiment,
    this.isFinal = true,
    required this.timestamp,
  });

  VoiceTranslationResult.create({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.speechConfidence,
    required this.translationConfidence,
    required this.totalProcessingTime,
    required this.provider,
    required this.sentiment,
    this.isFinal = true,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory VoiceTranslationResult.fromJson(Map<String, dynamic> json) =>
      _$VoiceTranslationResultFromJson(json);

  Map<String, dynamic> toJson() => _$VoiceTranslationResultToJson(this);

  VoiceTranslationResult copyWith({
    String? originalText,
    String? translatedText,
    String? sourceLanguage,
    String? targetLanguage,
    double? speechConfidence,
    double? translationConfidence,
    Duration? totalProcessingTime,
    String? provider,
    SentimentAnalysis? sentiment,
    bool? isFinal,
    DateTime? timestamp,
  }) {
    return VoiceTranslationResult(
      originalText: originalText ?? this.originalText,
      translatedText: translatedText ?? this.translatedText,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      speechConfidence: speechConfidence ?? this.speechConfidence,
      translationConfidence: translationConfidence ?? this.translationConfidence,
      totalProcessingTime: totalProcessingTime ?? this.totalProcessingTime,
      provider: provider ?? this.provider,
      sentiment: sentiment ?? this.sentiment,
      isFinal: isFinal ?? this.isFinal,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [
    originalText,
    translatedText,
    sourceLanguage,
    targetLanguage,
    speechConfidence,
    translationConfidence,
    totalProcessingTime,
    provider,
    sentiment,
    isFinal,
    timestamp,
  ];
}

/// Voice Settings Configuration
@JsonSerializable()
class VoiceSettings extends Equatable {
  final String inputLanguage;
  final String outputLanguage;
  final double speechRate;
  final double pitch;
  final double volume;
  final bool enableTTS;
  final double minConfidenceThreshold;
  final VoiceRecognitionMode recognitionMode;
  final String? preferredVoice;

  const VoiceSettings({
    this.inputLanguage = 'auto',
    this.outputLanguage = 'en',
    this.speechRate = 0.5,
    this.pitch = 1.0,
    this.volume = 1.0,
    this.enableTTS = true,
    this.minConfidenceThreshold = 0.7,
    this.recognitionMode = VoiceRecognitionMode.continuous,
    this.preferredVoice,
  });

  factory VoiceSettings.fromJson(Map<String, dynamic> json) =>
      _$VoiceSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$VoiceSettingsToJson(this);

  VoiceSettings copyWith({
    String? inputLanguage,
    String? outputLanguage,
    double? speechRate,
    double? pitch,
    double? volume,
    bool? enableTTS,
    double? minConfidenceThreshold,
    VoiceRecognitionMode? recognitionMode,
    String? preferredVoice,
  }) {
    return VoiceSettings(
      inputLanguage: inputLanguage ?? this.inputLanguage,
      outputLanguage: outputLanguage ?? this.outputLanguage,
      speechRate: speechRate ?? this.speechRate,
      pitch: pitch ?? this.pitch,
      volume: volume ?? this.volume,
      enableTTS: enableTTS ?? this.enableTTS,
      minConfidenceThreshold: minConfidenceThreshold ?? this.minConfidenceThreshold,
      recognitionMode: recognitionMode ?? this.recognitionMode,
      preferredVoice: preferredVoice ?? this.preferredVoice,
    );
  }

  @override
  List<Object?> get props => [
    inputLanguage,
    outputLanguage,
    speechRate,
    pitch,
    volume,
    enableTTS,
    minConfidenceThreshold,
    recognitionMode,
    preferredVoice,
  ];
}

/// Voice Conversation Item for conversation history
@JsonSerializable()
class VoiceConversationItem extends Equatable {
  final String id;
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime timestamp;
  final ConversationRole role;
  final double confidence;
  final Duration? audioDuration;

  const VoiceConversationItem({
    required this.id,
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.timestamp,
    required this.role,
    required this.confidence,
    this.audioDuration,
  });

  factory VoiceConversationItem.fromJson(Map<String, dynamic> json) =>
      _$VoiceConversationItemFromJson(json);

  Map<String, dynamic> toJson() => _$VoiceConversationItemToJson(this);

  @override
  List<Object?> get props => [
    id,
    originalText,
    translatedText,
    sourceLanguage,
    targetLanguage,
    timestamp,
    role,
    confidence,
    audioDuration,
  ];
}

/// Batch translation request
@JsonSerializable()
class BatchTranslationRequest extends Equatable {
  final List<String> texts;
  final String targetLanguage;
  final String sourceLanguage;
  final Map<String, dynamic>? context;
  final int? maxConcurrency;

  const BatchTranslationRequest({
    required this.texts,
    required this.targetLanguage,
    this.sourceLanguage = 'auto',
    this.context,
    this.maxConcurrency,
  });

  factory BatchTranslationRequest.fromJson(Map<String, dynamic> json) =>
      _$BatchTranslationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$BatchTranslationRequestToJson(this);

  @override
  List<Object?> get props => [
        texts,
        targetLanguage,
        sourceLanguage,
        context,
        maxConcurrency,
      ];
}

/// Enums for various classification types

enum SentimentType {
  @JsonValue('positive')
  positive,
  @JsonValue('negative')
  negative,
  @JsonValue('neutral')
  neutral,
}

enum FormalityLevel {
  @JsonValue('formal')
  formal,
  @JsonValue('informal')
  informal,
  @JsonValue('neutral')
  neutral,
}

enum TextDomain {
  @JsonValue('general')
  general,
  @JsonValue('business')
  business,
  @JsonValue('technical')
  technical,
  @JsonValue('casual')
  casual,
  @JsonValue('academic')
  academic,
  @JsonValue('creative')
  creative,
}

enum VoiceRecognitionMode {
  @JsonValue('continuous')
  continuous,
  @JsonValue('oneShot')
  oneShot,
  @JsonValue('conversation')
  conversation,
}

enum ConversationRole {
  @JsonValue('user')
  user,
  @JsonValue('assistant')
  assistant,
  @JsonValue('system')
  system,
}

/// Translation quality metrics
@JsonSerializable()
class QualityMetrics extends Equatable {
  final double fluency; // 0.0 to 1.0
  final double accuracy; // 0.0 to 1.0
  final double naturalness; // 0.0 to 1.0
  final double contextRelevance; // 0.0 to 1.0
  final double overallScore; // 0.0 to 1.0

  const QualityMetrics({
    required this.fluency,
    required this.accuracy,
    required this.naturalness,
    required this.contextRelevance,
    required this.overallScore,
  });

  factory QualityMetrics.fromJson(Map<String, dynamic> json) =>
      _$QualityMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$QualityMetricsToJson(this);

  /// Calculate overall score from individual metrics
  static double calculateOverallScore({
    required double fluency,
    required double accuracy,
    required double naturalness,
    required double contextRelevance,
  }) {
    return (fluency * 0.3 +
        accuracy * 0.35 +
        naturalness * 0.2 +
        contextRelevance * 0.15);
  }

  /// Check if quality is acceptable (> 0.7)
  bool get isAcceptable => overallScore > 0.7;

  /// Get quality grade
  String get qualityGrade {
    if (overallScore >= 0.9) return 'A';
    if (overallScore >= 0.8) return 'B';
    if (overallScore >= 0.7) return 'C';
    if (overallScore >= 0.6) return 'D';
    return 'F';
  }

  @override
  List<Object?> get props => [
        fluency,
        accuracy,
        naturalness,
        contextRelevance,
        overallScore,
      ];
}
