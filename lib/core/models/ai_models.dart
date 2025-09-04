// 🌐 LingoSphere - Advanced AI Models
// Data models for AI-powered features, personality analysis, and contextual suggestions

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'translation_models.dart';

part 'ai_models.g.dart';

/// Smart Translation Suggestion
@JsonSerializable()
class SmartSuggestion extends Equatable {
  final String text;
  final double confidence;
  final String source;
  final SuggestionContext context;
  final String reasoning;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  const SmartSuggestion({
    required this.text,
    required this.confidence,
    required this.source,
    required this.context,
    required this.reasoning,
    this.metadata,
    required this.timestamp,
  });

  SmartSuggestion.create({
    required this.text,
    required this.confidence,
    required this.source,
    required this.context,
    required this.reasoning,
    this.metadata,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory SmartSuggestion.fromJson(Map<String, dynamic> json) =>
      _$SmartSuggestionFromJson(json);

  Map<String, dynamic> toJson() => _$SmartSuggestionToJson(this);

  SmartSuggestion copyWith({
    String? text,
    double? confidence,
    String? source,
    SuggestionContext? context,
    String? reasoning,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  }) {
    return SmartSuggestion(
      text: text ?? this.text,
      confidence: confidence ?? this.confidence,
      source: source ?? this.source,
      context: context ?? this.context,
      reasoning: reasoning ?? this.reasoning,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [
        text,
        confidence,
        source,
        context,
        reasoning,
        metadata,
        timestamp,
      ];
}

/// Language Detection Result with Context
@JsonSerializable()
class LanguageDetectionResult extends Equatable {
  final String detectedLanguage;
  final double confidence;
  final List<String> alternatives;
  final List<String> contextClues;
  final Map<String, double>? languageScores;
  final String? reasoning;

  const LanguageDetectionResult({
    required this.detectedLanguage,
    required this.confidence,
    required this.alternatives,
    required this.contextClues,
    this.languageScores,
    this.reasoning,
  });

  factory LanguageDetectionResult.fromJson(Map<String, dynamic> json) =>
      _$LanguageDetectionResultFromJson(json);

  Map<String, dynamic> toJson() => _$LanguageDetectionResultToJson(this);

  /// Check if detection is highly confident
  bool get isHighConfidence => confidence >= 0.9;

  /// Get language name from code
  String get languageName {
    const languageNames = {
      'en': 'English',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'it': 'Italian',
      'pt': 'Portuguese',
      'ru': 'Russian',
      'ja': 'Japanese',
      'ko': 'Korean',
      'zh': 'Chinese',
      'ar': 'Arabic',
      'hi': 'Hindi',
    };
    return languageNames[detectedLanguage] ?? detectedLanguage;
  }

  @override
  List<Object?> get props => [
        detectedLanguage,
        confidence,
        alternatives,
        contextClues,
        languageScores,
        reasoning,
      ];
}

/// User Personality Profile
@JsonSerializable()
class UserPersonality extends Equatable {
  final PersonalityType primaryType;
  final Map<PersonalityTrait, double> traits;
  final double confidence;
  final List<String> communicationPreferences;
  final Map<String, dynamic> analysisData;
  final DateTime lastUpdated;

  const UserPersonality({
    required this.primaryType,
    required this.traits,
    required this.confidence,
    required this.communicationPreferences,
    required this.analysisData,
    required this.lastUpdated,
  });

  UserPersonality.create({
    required this.primaryType,
    required this.traits,
    required this.confidence,
    required this.communicationPreferences,
    required this.analysisData,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  factory UserPersonality.fromJson(Map<String, dynamic> json) =>
      _$UserPersonalityFromJson(json);

  Map<String, dynamic> toJson() => _$UserPersonalityToJson(this);

  /// Create a neutral personality profile
  factory UserPersonality.neutral() {
    return UserPersonality(
      primaryType: PersonalityType.neutral,
      traits: {
        PersonalityTrait.formality: 0.5,
        PersonalityTrait.directness: 0.5,
        PersonalityTrait.emotionality: 0.5,
        PersonalityTrait.verbosity: 0.5,
        PersonalityTrait.culturalSensitivity: 0.7,
      },
      confidence: 0.5,
      communicationPreferences: ['balanced', 'clear'],
      analysisData: {},
      lastUpdated: DateTime.now(),
    );
  }

  /// Get dominant trait
  PersonalityTrait get dominantTrait {
    var maxValue = 0.0;
    var dominantTrait = PersonalityTrait.formality;
    
    for (final entry in traits.entries) {
      if (entry.value > maxValue) {
        maxValue = entry.value;
        dominantTrait = entry.key;
      }
    }
    
    return dominantTrait;
  }

  /// Get personality description
  String get description {
    switch (primaryType) {
      case PersonalityType.formal:
        return 'Prefers formal, professional communication';
      case PersonalityType.casual:
        return 'Enjoys relaxed, informal conversation';
      case PersonalityType.direct:
        return 'Values straightforward, concise communication';
      case PersonalityType.diplomatic:
        return 'Favors tactful, considerate expression';
      case PersonalityType.expressive:
        return 'Uses rich, emotional language';
      case PersonalityType.analytical:
        return 'Prefers precise, detailed communication';
      case PersonalityType.neutral:
        return 'Balanced communication style';
    }
  }

  @override
  List<Object?> get props => [
        primaryType,
        traits,
        confidence,
        communicationPreferences,
        analysisData,
        lastUpdated,
      ];
}

/// Conversation Context for AI Analysis
@JsonSerializable()
class ConversationContext extends Equatable {
  final String id;
  final List<String> recentMessages;
  final List<String> languagesUsed;
  final String tone;
  final String topic;
  final Map<String, dynamic> metadata;
  final DateTime lastUpdated;

  const ConversationContext({
    required this.id,
    required this.recentMessages,
    required this.languagesUsed,
    required this.tone,
    required this.topic,
    this.metadata = const {},
    required this.lastUpdated,
  });

  ConversationContext.create({
    required this.id,
    required this.recentMessages,
    required this.languagesUsed,
    required this.tone,
    required this.topic,
    this.metadata = const {},
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  factory ConversationContext.fromJson(Map<String, dynamic> json) =>
      _$ConversationContextFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationContextToJson(this);

  ConversationContext copyWith({
    String? id,
    List<String>? recentMessages,
    List<String>? languagesUsed,
    String? tone,
    String? topic,
    Map<String, dynamic>? metadata,
    DateTime? lastUpdated,
  }) {
    return ConversationContext(
      id: id ?? this.id,
      recentMessages: recentMessages ?? this.recentMessages,
      languagesUsed: languagesUsed ?? this.languagesUsed,
      tone: tone ?? this.tone,
      topic: topic ?? this.topic,
      metadata: metadata ?? this.metadata,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Check if context is recent
  bool get isRecent {
    return DateTime.now().difference(lastUpdated).inHours < 24;
  }

  /// Get context summary
  String get summary {
    return 'Conversation about $topic in $tone tone with ${recentMessages.length} recent messages';
  }

  @override
  List<Object?> get props => [
        id,
        recentMessages,
        languagesUsed,
        tone,
        topic,
        metadata,
        lastUpdated,
      ];
}

/// Translation Context Analysis Result
@JsonSerializable()
class TranslationContextAnalysis extends Equatable {
  final ContextType contextType;
  final double confidence;
  final List<String> detectedTopics;
  final FormalityLevel formalityLevel;
  final EmotionalTone emotionalTone;
  final List<String> culturalMarkers;
  final Map<String, dynamic> analysisData;

  const TranslationContextAnalysis({
    required this.contextType,
    required this.confidence,
    required this.detectedTopics,
    required this.formalityLevel,
    required this.emotionalTone,
    required this.culturalMarkers,
    required this.analysisData,
  });

  factory TranslationContextAnalysis.fromJson(Map<String, dynamic> json) =>
      _$TranslationContextAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$TranslationContextAnalysisToJson(this);

  /// Create empty analysis
  factory TranslationContextAnalysis.empty() {
    return const TranslationContextAnalysis(
      contextType: ContextType.general,
      confidence: 0.0,
      detectedTopics: [],
      formalityLevel: FormalityLevel.neutral,
      emotionalTone: EmotionalTone.neutral,
      culturalMarkers: [],
      analysisData: {},
    );
  }

  /// Get analysis summary
  String get summary {
    return '${contextType.name} context with ${formalityLevel.name} formality and ${emotionalTone.name} tone';
  }

  @override
  List<Object?> get props => [
        contextType,
        confidence,
        detectedTopics,
        formalityLevel,
        emotionalTone,
        culturalMarkers,
        analysisData,
      ];
}

/// AI Learning Data Point
@JsonSerializable()
class AILearningDataPoint extends Equatable {
  final String id;
  final String userId;
  final String sourceText;
  final String targetText;
  final String sourceLanguage;
  final String targetLanguage;
  final double userRating;
  final Map<String, dynamic> contextData;
  final DateTime timestamp;

  const AILearningDataPoint({
    required this.id,
    required this.userId,
    required this.sourceText,
    required this.targetText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.userRating,
    required this.contextData,
    required this.timestamp,
  });

  AILearningDataPoint.create({
    required this.id,
    required this.userId,
    required this.sourceText,
    required this.targetText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.userRating,
    required this.contextData,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory AILearningDataPoint.fromJson(Map<String, dynamic> json) =>
      _$AILearningDataPointFromJson(json);

  Map<String, dynamic> toJson() => _$AILearningDataPointToJson(this);

  /// Check if rating is positive
  bool get isPositiveRating => userRating >= 4.0;

  /// Check if data point is recent
  bool get isRecent => DateTime.now().difference(timestamp).inDays < 30;

  @override
  List<Object?> get props => [
        id,
        userId,
        sourceText,
        targetText,
        sourceLanguage,
        targetLanguage,
        userRating,
        contextData,
        timestamp,
      ];
}

/// AI Model Performance Metrics
@JsonSerializable()
class AIModelMetrics extends Equatable {
  final String modelName;
  final String version;
  final double accuracy;
  final double latency;
  final int requestCount;
  final double successRate;
  final Map<String, double> languagePairAccuracy;
  final DateTime lastUpdated;

  const AIModelMetrics({
    required this.modelName,
    required this.version,
    required this.accuracy,
    required this.latency,
    required this.requestCount,
    required this.successRate,
    required this.languagePairAccuracy,
    required this.lastUpdated,
  });

  AIModelMetrics.create({
    required this.modelName,
    required this.version,
    required this.accuracy,
    required this.latency,
    required this.requestCount,
    required this.successRate,
    required this.languagePairAccuracy,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  factory AIModelMetrics.fromJson(Map<String, dynamic> json) =>
      _$AIModelMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$AIModelMetricsToJson(this);

  /// Get performance grade
  String get performanceGrade {
    if (accuracy >= 0.95 && successRate >= 0.98) return 'A+';
    if (accuracy >= 0.90 && successRate >= 0.95) return 'A';
    if (accuracy >= 0.85 && successRate >= 0.90) return 'B';
    if (accuracy >= 0.80 && successRate >= 0.85) return 'C';
    return 'D';
  }

  /// Check if model is performing well
  bool get isPerformingWell => accuracy >= 0.85 && successRate >= 0.90;

  @override
  List<Object?> get props => [
        modelName,
        version,
        accuracy,
        latency,
        requestCount,
        successRate,
        languagePairAccuracy,
        lastUpdated,
      ];
}

/// Enums for AI Features

enum SuggestionContext {
  @JsonValue('contextual')
  contextual,
  @JsonValue('alternative')
  alternative,
  @JsonValue('standard')
  standard,
  @JsonValue('creative')
  creative,
  @JsonValue('formal')
  formal,
  @JsonValue('casual')
  casual,
}

enum PersonalityType {
  @JsonValue('formal')
  formal,
  @JsonValue('casual')
  casual,
  @JsonValue('direct')
  direct,
  @JsonValue('diplomatic')
  diplomatic,
  @JsonValue('expressive')
  expressive,
  @JsonValue('analytical')
  analytical,
  @JsonValue('neutral')
  neutral,
}

enum PersonalityTrait {
  @JsonValue('formality')
  formality,
  @JsonValue('directness')
  directness,
  @JsonValue('emotionality')
  emotionality,
  @JsonValue('verbosity')
  verbosity,
  @JsonValue('cultural_sensitivity')
  culturalSensitivity,
}

enum ContextType {
  @JsonValue('business')
  business,
  @JsonValue('casual')
  casual,
  @JsonValue('academic')
  academic,
  @JsonValue('technical')
  technical,
  @JsonValue('creative')
  creative,
  @JsonValue('social')
  social,
  @JsonValue('general')
  general,
}

enum EmotionalTone {
  @JsonValue('positive')
  positive,
  @JsonValue('negative')
  negative,
  @JsonValue('neutral')
  neutral,
  @JsonValue('excited')
  excited,
  @JsonValue('concerned')
  concerned,
  @JsonValue('professional')
  professional,
  @JsonValue('friendly')
  friendly,
}

/// AI Feature Configuration
@JsonSerializable()
class AIFeatureConfig extends Equatable {
  final bool enableContextualSuggestions;
  final bool enablePersonalityAnalysis;
  final bool enableSmartLanguageDetection;
  final bool enableLearningFromFeedback;
  final double confidenceThreshold;
  final int maxSuggestions;
  final Duration cacheTimeout;
  final Map<String, dynamic> modelConfigs;

  const AIFeatureConfig({
    this.enableContextualSuggestions = true,
    this.enablePersonalityAnalysis = true,
    this.enableSmartLanguageDetection = true,
    this.enableLearningFromFeedback = true,
    this.confidenceThreshold = 0.7,
    this.maxSuggestions = 5,
    this.cacheTimeout = const Duration(hours: 1),
    this.modelConfigs = const {},
  });

  factory AIFeatureConfig.fromJson(Map<String, dynamic> json) =>
      _$AIFeatureConfigFromJson(json);

  Map<String, dynamic> toJson() => _$AIFeatureConfigToJson(this);

  AIFeatureConfig copyWith({
    bool? enableContextualSuggestions,
    bool? enablePersonalityAnalysis,
    bool? enableSmartLanguageDetection,
    bool? enableLearningFromFeedback,
    double? confidenceThreshold,
    int? maxSuggestions,
    Duration? cacheTimeout,
    Map<String, dynamic>? modelConfigs,
  }) {
    return AIFeatureConfig(
      enableContextualSuggestions: enableContextualSuggestions ?? this.enableContextualSuggestions,
      enablePersonalityAnalysis: enablePersonalityAnalysis ?? this.enablePersonalityAnalysis,
      enableSmartLanguageDetection: enableSmartLanguageDetection ?? this.enableSmartLanguageDetection,
      enableLearningFromFeedback: enableLearningFromFeedback ?? this.enableLearningFromFeedback,
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      maxSuggestions: maxSuggestions ?? this.maxSuggestions,
      cacheTimeout: cacheTimeout ?? this.cacheTimeout,
      modelConfigs: modelConfigs ?? this.modelConfigs,
    );
  }

  @override
  List<Object?> get props => [
        enableContextualSuggestions,
        enablePersonalityAnalysis,
        enableSmartLanguageDetection,
        enableLearningFromFeedback,
        confidenceThreshold,
        maxSuggestions,
        cacheTimeout,
        modelConfigs,
      ];
}
