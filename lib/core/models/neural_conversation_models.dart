// 🧠 LingoSphere - Neural Conversation Intelligence Models
// Advanced models for context-aware, emotionally intelligent translation systems

import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'neural_conversation_models.g.dart';

// ===== CORE CONVERSATION MODELS =====

/// Advanced conversation context with neural understanding
@JsonSerializable()
class NeuralConversationContext extends Equatable {
  final String conversationId;
  final List<ConversationTurn> conversationHistory;
  final ConversationState currentState;
  final EmotionalContext emotionalFlow;
  final TopicContext topicEvolution;
  final ParticipantAnalysis participants;
  final ConversationMetrics metrics;
  final PredictiveInsights predictions;
  final DateTime createdAt;
  final DateTime lastUpdated;

  const NeuralConversationContext({
    required this.conversationId,
    required this.conversationHistory,
    required this.currentState,
    required this.emotionalFlow,
    required this.topicEvolution,
    required this.participants,
    required this.metrics,
    required this.predictions,
    required this.createdAt,
    required this.lastUpdated,
  });

  factory NeuralConversationContext.fromJson(Map<String, dynamic> json) =>
      _$NeuralConversationContextFromJson(json);

  Map<String, dynamic> toJson() => _$NeuralConversationContextToJson(this);

  NeuralConversationContext copyWith({
    List<ConversationTurn>? conversationHistory,
    ConversationState? currentState,
    EmotionalContext? emotionalFlow,
    TopicContext? topicEvolution,
    ParticipantAnalysis? participants,
    ConversationMetrics? metrics,
    PredictiveInsights? predictions,
    DateTime? lastUpdated,
  }) {
    return NeuralConversationContext(
      conversationId: conversationId,
      conversationHistory: conversationHistory ?? this.conversationHistory,
      currentState: currentState ?? this.currentState,
      emotionalFlow: emotionalFlow ?? this.emotionalFlow,
      topicEvolution: topicEvolution ?? this.topicEvolution,
      participants: participants ?? this.participants,
      metrics: metrics ?? this.metrics,
      predictions: predictions ?? this.predictions,
      createdAt: createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Get conversation length in turns
  int get conversationLength => conversationHistory.length;

  /// Get conversation duration
  Duration get conversationDuration {
    if (conversationHistory.isEmpty) return Duration.zero;
    final first = conversationHistory.first.timestamp;
    final last = conversationHistory.last.timestamp;
    return last.difference(first);
  }

  /// Check if conversation is active (recent activity)
  bool get isActive {
    if (conversationHistory.isEmpty) return false;
    final lastActivity = conversationHistory.last.timestamp;
    final timeSinceLastActivity = DateTime.now().difference(lastActivity);
    return timeSinceLastActivity.inMinutes < 30; // Active within 30 minutes
  }

  @override
  List<Object?> get props => [
        conversationId,
        conversationHistory,
        currentState,
        emotionalFlow,
        topicEvolution,
        participants,
        metrics,
        predictions,
        createdAt,
        lastUpdated,
      ];
}

/// Individual conversation turn with neural analysis
@JsonSerializable()
class ConversationTurn extends Equatable {
  final String id;
  final String speakerId;
  final String originalText;
  final String? translatedText;
  final String sourceLanguage;
  final String? targetLanguage;
  final DateTime timestamp;
  final TurnAnalysis analysis;
  final List<Translation> translationAlternatives;
  final Map<String, dynamic> metadata;

  const ConversationTurn({
    required this.id,
    required this.speakerId,
    required this.originalText,
    this.translatedText,
    required this.sourceLanguage,
    this.targetLanguage,
    required this.timestamp,
    required this.analysis,
    this.translationAlternatives = const [],
    this.metadata = const {},
  });

  factory ConversationTurn.fromJson(Map<String, dynamic> json) =>
      _$ConversationTurnFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationTurnToJson(this);

  @override
  List<Object?> get props => [
        id,
        speakerId,
        originalText,
        translatedText,
        sourceLanguage,
        targetLanguage,
        timestamp,
        analysis,
        translationAlternatives,
        metadata,
      ];
}

/// Deep analysis of each conversation turn
@JsonSerializable()
class TurnAnalysis extends Equatable {
  final SentimentAnalysis sentiment;
  final IntentAnalysis intent;
  final ContextualRelevance contextRelevance;
  final LinguisticComplexity complexity;
  final CulturalMarkers culturalMarkers;
  final double confidence;
  final List<String> keyEntities;
  final List<String> topics;

  const TurnAnalysis({
    required this.sentiment,
    required this.intent,
    required this.contextRelevance,
    required this.complexity,
    required this.culturalMarkers,
    required this.confidence,
    required this.keyEntities,
    required this.topics,
  });

  factory TurnAnalysis.fromJson(Map<String, dynamic> json) =>
      _$TurnAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$TurnAnalysisToJson(this);

  @override
  List<Object?> get props => [
        sentiment,
        intent,
        contextRelevance,
        complexity,
        culturalMarkers,
        confidence,
        keyEntities,
        topics,
      ];
}

/// Advanced sentiment analysis with neural understanding
@JsonSerializable()
class SentimentAnalysis extends Equatable {
  final SentimentType primarySentiment;
  final double intensity; // 0.0 to 1.0
  final Map<SentimentType, double> sentimentSpectrum;
  final EmotionVector emotionVector;
  final double emotionalStability; // How consistent emotions are
  final List<EmotionalShift> emotionalShifts; // Changes throughout the text

  const SentimentAnalysis({
    required this.primarySentiment,
    required this.intensity,
    required this.sentimentSpectrum,
    required this.emotionVector,
    required this.emotionalStability,
    required this.emotionalShifts,
  });

  factory SentimentAnalysis.fromJson(Map<String, dynamic> json) =>
      _$SentimentAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$SentimentAnalysisToJson(this);

  @override
  List<Object?> get props => [
        primarySentiment,
        intensity,
        sentimentSpectrum,
        emotionVector,
        emotionalStability,
        emotionalShifts,
      ];
}

/// Multi-dimensional emotion representation
@JsonSerializable()
class EmotionVector extends Equatable {
  final double valence; // -1.0 (negative) to 1.0 (positive)
  final double arousal; // 0.0 (calm) to 1.0 (excited)
  final double dominance; // 0.0 (submissive) to 1.0 (dominant)
  final double certainty; // 0.0 (uncertain) to 1.0 (certain)

  const EmotionVector({
    required this.valence,
    required this.arousal,
    required this.dominance,
    required this.certainty,
  });

  factory EmotionVector.fromJson(Map<String, dynamic> json) =>
      _$EmotionVectorFromJson(json);

  Map<String, dynamic> toJson() => _$EmotionVectorToJson(this);

  /// Calculate emotional distance between two emotion vectors
  double distanceTo(EmotionVector other) {
    final dValence = valence - other.valence;
    final dArousal = arousal - other.arousal;
    final dDominance = dominance - other.dominance;
    final dCertainty = certainty - other.certainty;

    return sqrt(dValence * dValence +
        dArousal * dArousal +
        dDominance * dDominance +
        dCertainty * dCertainty);
  }

  @override
  List<Object?> get props => [valence, arousal, dominance, certainty];
}

/// Emotional shift within a conversation turn
@JsonSerializable()
class EmotionalShift extends Equatable {
  final int startPosition;
  final int endPosition;
  final EmotionVector fromEmotion;
  final EmotionVector toEmotion;
  final String trigger; // What caused the shift
  final double shiftIntensity; // How dramatic the shift was

  const EmotionalShift({
    required this.startPosition,
    required this.endPosition,
    required this.fromEmotion,
    required this.toEmotion,
    required this.trigger,
    required this.shiftIntensity,
  });

  factory EmotionalShift.fromJson(Map<String, dynamic> json) =>
      _$EmotionalShiftFromJson(json);

  Map<String, dynamic> toJson() => _$EmotionalShiftToJson(this);

  @override
  List<Object?> get props => [
        startPosition,
        endPosition,
        fromEmotion,
        toEmotion,
        trigger,
        shiftIntensity,
      ];
}

// ===== CONVERSATION FLOW MODELS =====

/// Current state of the conversation
@JsonSerializable()
class ConversationState extends Equatable {
  final ConversationPhase phase;
  final ConversationMode mode;
  final double engagement; // 0.0 to 1.0
  final double coherence; // How well-connected the conversation is
  final int turnsUntilResolution; // Predicted turns to natural end
  final List<String> activeTopics;
  final Map<String, dynamic> stateMetadata;

  const ConversationState({
    required this.phase,
    required this.mode,
    required this.engagement,
    required this.coherence,
    required this.turnsUntilResolution,
    required this.activeTopics,
    this.stateMetadata = const {},
  });

  factory ConversationState.fromJson(Map<String, dynamic> json) =>
      _$ConversationStateFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationStateToJson(this);

  @override
  List<Object?> get props => [
        phase,
        mode,
        engagement,
        coherence,
        turnsUntilResolution,
        activeTopics,
        stateMetadata,
      ];
}

/// Emotional flow throughout the entire conversation
@JsonSerializable()
class EmotionalContext extends Equatable {
  final List<EmotionVector> emotionalTrajectory;
  final EmotionVector currentEmotion;
  final EmotionVector dominantEmotion; // Most prevalent emotion
  final double emotionalVolatility; // How much emotions change
  final List<EmotionalMilestone> milestones;
  final ConversationMood overallMood;

  const EmotionalContext({
    required this.emotionalTrajectory,
    required this.currentEmotion,
    required this.dominantEmotion,
    required this.emotionalVolatility,
    required this.milestones,
    required this.overallMood,
  });

  factory EmotionalContext.fromJson(Map<String, dynamic> json) =>
      _$EmotionalContextFromJson(json);

  Map<String, dynamic> toJson() => _$EmotionalContextToJson(this);

  @override
  List<Object?> get props => [
        emotionalTrajectory,
        currentEmotion,
        dominantEmotion,
        emotionalVolatility,
        milestones,
        overallMood,
      ];

  EmotionalContext copyWith({
    List<EmotionVector>? emotionalTrajectory,
    EmotionVector? currentEmotion,
    EmotionVector? dominantEmotion,
    double? emotionalVolatility,
    List<EmotionalMilestone>? milestones,
    ConversationMood? overallMood,
  }) {
    return EmotionalContext(
      emotionalTrajectory: emotionalTrajectory ?? this.emotionalTrajectory,
      currentEmotion: currentEmotion ?? this.currentEmotion,
      dominantEmotion: dominantEmotion ?? this.dominantEmotion,
      emotionalVolatility: emotionalVolatility ?? this.emotionalVolatility,
      milestones: milestones ?? this.milestones,
      overallMood: overallMood ?? this.overallMood,
    );
  }
}

/// Significant emotional moments in conversation
@JsonSerializable()
class EmotionalMilestone extends Equatable {
  final DateTime timestamp;
  final String turnId;
  final MilestoneType type;
  final EmotionVector emotion;
  final String description;
  final double significance; // How important this milestone is

  const EmotionalMilestone({
    required this.timestamp,
    required this.turnId,
    required this.type,
    required this.emotion,
    required this.description,
    required this.significance,
  });

  factory EmotionalMilestone.fromJson(Map<String, dynamic> json) =>
      _$EmotionalMilestoneFromJson(json);

  Map<String, dynamic> toJson() => _$EmotionalMilestoneToJson(this);

  @override
  List<Object?> get props => [
        timestamp,
        turnId,
        type,
        emotion,
        description,
        significance,
      ];
}

// ===== PREDICTIVE MODELS =====

/// AI-powered predictions about conversation direction
@JsonSerializable()
class PredictiveInsights extends Equatable {
  final List<NextTurnPrediction> nextTurnPredictions;
  final List<TopicPrediction> topicPredictions;
  final List<TranslationSuggestion> proactiveSuggestions;
  final ConversationOutcome predictedOutcome;
  final double predictionConfidence;
  final DateTime generatedAt;

  const PredictiveInsights({
    required this.nextTurnPredictions,
    required this.topicPredictions,
    required this.proactiveSuggestions,
    required this.predictedOutcome,
    required this.predictionConfidence,
    required this.generatedAt,
  });

  factory PredictiveInsights.fromJson(Map<String, dynamic> json) =>
      _$PredictiveInsightsFromJson(json);

  Map<String, dynamic> toJson() => _$PredictiveInsightsToJson(this);

  @override
  List<Object?> get props => [
        nextTurnPredictions,
        topicPredictions,
        proactiveSuggestions,
        predictedOutcome,
        predictionConfidence,
        generatedAt,
      ];
}

/// Prediction for what the next conversation turn might be
@JsonSerializable()
class NextTurnPrediction extends Equatable {
  final String predictedText;
  final String predictedLanguage;
  final double probability;
  final List<String> alternatives;
  final Map<String, dynamic> reasoning;

  const NextTurnPrediction({
    required this.predictedText,
    required this.predictedLanguage,
    required this.probability,
    required this.alternatives,
    required this.reasoning,
  });

  factory NextTurnPrediction.fromJson(Map<String, dynamic> json) =>
      _$NextTurnPredictionFromJson(json);

  Map<String, dynamic> toJson() => _$NextTurnPredictionToJson(this);

  @override
  List<Object?> get props => [
        predictedText,
        predictedLanguage,
        probability,
        alternatives,
        reasoning,
      ];
}

/// Smart translation suggestions based on conversation flow
@JsonSerializable()
class TranslationSuggestion extends Equatable {
  final SuggestionType type;
  final String suggestedTranslation;
  final String sourcePhrase;
  final String targetLanguage;
  final double relevanceScore;
  final String reasoning;
  final Map<String, dynamic> contextFactors;
  final bool isProactive; // Generated before user asks

  const TranslationSuggestion({
    required this.type,
    required this.suggestedTranslation,
    required this.sourcePhrase,
    required this.targetLanguage,
    required this.relevanceScore,
    required this.reasoning,
    required this.contextFactors,
    required this.isProactive,
  });

  factory TranslationSuggestion.fromJson(Map<String, dynamic> json) =>
      _$TranslationSuggestionFromJson(json);

  Map<String, dynamic> toJson() => _$TranslationSuggestionToJson(this);

  @override
  List<Object?> get props => [
        type,
        suggestedTranslation,
        sourcePhrase,
        targetLanguage,
        relevanceScore,
        reasoning,
        contextFactors,
        isProactive,
      ];
}

// ===== PARTICIPANT ANALYSIS =====

/// Analysis of all conversation participants
@JsonSerializable()
class ParticipantAnalysis extends Equatable {
  final Map<String, ParticipantProfile> participants;
  final InteractionDynamics dynamics;
  final CommunicationPatterns patterns;
  final LanguageProficiency languageProficiencies;

  const ParticipantAnalysis({
    required this.participants,
    required this.dynamics,
    required this.patterns,
    required this.languageProficiencies,
  });

  factory ParticipantAnalysis.fromJson(Map<String, dynamic> json) =>
      _$ParticipantAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$ParticipantAnalysisToJson(this);

  @override
  List<Object?> get props => [
        participants,
        dynamics,
        patterns,
        languageProficiencies,
      ];
}

/// Individual participant profile with neural insights
@JsonSerializable()
class ParticipantProfile extends Equatable {
  final String participantId;
  final String name;
  final List<String> preferredLanguages;
  final CommunicationStyle communicationStyle;
  final EmotionalProfile emotionalProfile;
  final ConversationRole role;
  final Map<String, dynamic> preferences;

  const ParticipantProfile({
    required this.participantId,
    required this.name,
    required this.preferredLanguages,
    required this.communicationStyle,
    required this.emotionalProfile,
    required this.role,
    this.preferences = const {},
  });

  factory ParticipantProfile.fromJson(Map<String, dynamic> json) =>
      _$ParticipantProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ParticipantProfileToJson(this);

  @override
  List<Object?> get props => [
        participantId,
        name,
        preferredLanguages,
        communicationStyle,
        emotionalProfile,
        role,
        preferences,
      ];
}

/// Emotional profile of a participant
@JsonSerializable()
class EmotionalProfile extends Equatable {
  final EmotionVector baselineEmotion;
  final double emotionalRange; // How much they vary from baseline
  final List<EmotionalTrigger> triggers;
  final EmotionalAdaptability adaptability;

  const EmotionalProfile({
    required this.baselineEmotion,
    required this.emotionalRange,
    required this.triggers,
    required this.adaptability,
  });

  factory EmotionalProfile.fromJson(Map<String, dynamic> json) =>
      _$EmotionalProfileFromJson(json);

  Map<String, dynamic> toJson() => _$EmotionalProfileToJson(this);

  @override
  List<Object?> get props => [
        baselineEmotion,
        emotionalRange,
        triggers,
        adaptability,
      ];
}

/// What triggers emotional responses in a participant
@JsonSerializable()
class EmotionalTrigger extends Equatable {
  final String triggerType;
  final List<String> keywords;
  final EmotionVector expectedResponse;
  final double sensitivity; // How easily triggered

  const EmotionalTrigger({
    required this.triggerType,
    required this.keywords,
    required this.expectedResponse,
    required this.sensitivity,
  });

  factory EmotionalTrigger.fromJson(Map<String, dynamic> json) =>
      _$EmotionalTriggerFromJson(json);

  Map<String, dynamic> toJson() => _$EmotionalTriggerToJson(this);

  @override
  List<Object?> get props => [
        triggerType,
        keywords,
        expectedResponse,
        sensitivity,
      ];
}

// ===== CONVERSATION METRICS =====

/// Comprehensive metrics about conversation quality and flow
@JsonSerializable()
class ConversationMetrics extends Equatable {
  final double coherenceScore; // How well-connected the conversation is
  final double engagementScore; // How engaged participants are
  final double translationQuality; // Overall quality of translations
  final double culturalAdaptation; // How well cultural nuances are handled
  final int totalTurns;
  final Duration avgResponseTime;
  final Map<String, int> languageDistribution;
  final List<QualityMetric> qualityBreakdown;

  const ConversationMetrics({
    required this.coherenceScore,
    required this.engagementScore,
    required this.translationQuality,
    required this.culturalAdaptation,
    required this.totalTurns,
    required this.avgResponseTime,
    required this.languageDistribution,
    required this.qualityBreakdown,
  });

  factory ConversationMetrics.fromJson(Map<String, dynamic> json) =>
      _$ConversationMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationMetricsToJson(this);

  /// Get overall conversation score
  double get overallScore {
    return (coherenceScore +
            engagementScore +
            translationQuality +
            culturalAdaptation) /
        4;
  }

  @override
  List<Object?> get props => [
        coherenceScore,
        engagementScore,
        translationQuality,
        culturalAdaptation,
        totalTurns,
        avgResponseTime,
        languageDistribution,
        qualityBreakdown,
      ];

  ConversationMetrics copyWith({
    double? coherenceScore,
    double? engagementScore,
    double? translationQuality,
    double? culturalAdaptation,
    int? totalTurns,
    Duration? avgResponseTime,
    Map<String, int>? languageDistribution,
    List<QualityMetric>? qualityBreakdown,
  }) {
    return ConversationMetrics(
      coherenceScore: coherenceScore ?? this.coherenceScore,
      engagementScore: engagementScore ?? this.engagementScore,
      translationQuality: translationQuality ?? this.translationQuality,
      culturalAdaptation: culturalAdaptation ?? this.culturalAdaptation,
      totalTurns: totalTurns ?? this.totalTurns,
      avgResponseTime: avgResponseTime ?? this.avgResponseTime,
      languageDistribution: languageDistribution ?? this.languageDistribution,
      qualityBreakdown: qualityBreakdown ?? this.qualityBreakdown,
    );
  }
}

/// Individual quality metrics
@JsonSerializable()
class QualityMetric extends Equatable {
  final String metricName;
  final double score;
  final String description;
  final List<String> improvements;

  const QualityMetric({
    required this.metricName,
    required this.score,
    required this.description,
    required this.improvements,
  });

  factory QualityMetric.fromJson(Map<String, dynamic> json) =>
      _$QualityMetricFromJson(json);

  Map<String, dynamic> toJson() => _$QualityMetricToJson(this);

  @override
  List<Object?> get props => [metricName, score, description, improvements];
}

// ===== NEURAL TRANSLATION RESULT =====

/// Enhanced translation result with neural conversation intelligence
@JsonSerializable()
class NeuralTranslationResult extends Equatable {
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final double confidence;
  final NeuralConversationContext conversationContext;
  final ConversationAdaptations adaptations;
  final List<Translation> alternatives;
  final PredictiveInsights predictions;
  final Map<String, dynamic> culturalInsights;
  final DateTime timestamp;

  const NeuralTranslationResult({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.confidence,
    required this.conversationContext,
    required this.adaptations,
    required this.alternatives,
    required this.predictions,
    required this.culturalInsights,
    required this.timestamp,
  });

  factory NeuralTranslationResult.fromJson(Map<String, dynamic> json) =>
      _$NeuralTranslationResultFromJson(json);

  Map<String, dynamic> toJson() => _$NeuralTranslationResultToJson(this);

  @override
  List<Object?> get props => [
        originalText,
        translatedText,
        sourceLanguage,
        targetLanguage,
        confidence,
        conversationContext,
        adaptations,
        alternatives,
        predictions,
        culturalInsights,
        timestamp,
      ];
}

/// How the translation was adapted based on conversation context
@JsonSerializable()
class ConversationAdaptations extends Equatable {
  final List<String> contextualAdjustments;
  final List<String> emotionalAdaptations;
  final List<String> culturalAdaptations;
  final List<String> participantAdaptations;
  final double adaptationConfidence;

  const ConversationAdaptations({
    required this.contextualAdjustments,
    required this.emotionalAdaptations,
    required this.culturalAdaptations,
    required this.participantAdaptations,
    required this.adaptationConfidence,
  });

  factory ConversationAdaptations.fromJson(Map<String, dynamic> json) =>
      _$ConversationAdaptationsFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationAdaptationsToJson(this);

  @override
  List<Object?> get props => [
        contextualAdjustments,
        emotionalAdaptations,
        culturalAdaptations,
        participantAdaptations,
        adaptationConfidence,
      ];
}

// ===== SUPPORTING MODELS =====

/// Basic translation alternative
@JsonSerializable()
class Translation extends Equatable {
  final String text;
  final double confidence;
  final String reasoning;

  const Translation({
    required this.text,
    required this.confidence,
    required this.reasoning,
  });

  factory Translation.fromJson(Map<String, dynamic> json) =>
      _$TranslationFromJson(json);

  Map<String, dynamic> toJson() => _$TranslationToJson(this);

  @override
  List<Object?> get props => [text, confidence, reasoning];
}

// ===== ENUMS =====

enum SentimentType {
  @JsonValue('positive')
  positive,
  @JsonValue('negative')
  negative,
  @JsonValue('neutral')
  neutral,
  @JsonValue('mixed')
  mixed,
  @JsonValue('excited')
  excited,
  @JsonValue('anxious')
  anxious,
  @JsonValue('confident')
  confident,
  @JsonValue('uncertain')
  uncertain,
}

enum ConversationPhase {
  @JsonValue('opening')
  opening,
  @JsonValue('building')
  building,
  @JsonValue('peak')
  peak,
  @JsonValue('resolution')
  resolution,
  @JsonValue('closing')
  closing,
}

enum ConversationMode {
  @JsonValue('formal')
  formal,
  @JsonValue('casual')
  casual,
  @JsonValue('business')
  business,
  @JsonValue('educational')
  educational,
  @JsonValue('social')
  social,
  @JsonValue('emergency')
  emergency,
}

enum MilestoneType {
  @JsonValue('emotional_peak')
  emotionalPeak,
  @JsonValue('topic_shift')
  topicShift,
  @JsonValue('agreement')
  agreement,
  @JsonValue('conflict')
  conflict,
  @JsonValue('breakthrough')
  breakthrough,
  @JsonValue('misunderstanding')
  misunderstanding,
}

enum ConversationRole {
  @JsonValue('initiator')
  initiator,
  @JsonValue('responder')
  responder,
  @JsonValue('mediator')
  mediator,
  @JsonValue('observer')
  observer,
  @JsonValue('facilitator')
  facilitator,
}

enum SuggestionType {
  @JsonValue('contextual')
  contextual,
  @JsonValue('predictive')
  predictive,
  @JsonValue('cultural')
  cultural,
  @JsonValue('emotional')
  emotional,
  @JsonValue('grammatical')
  grammatical,
}

enum ConversationMood {
  @JsonValue('collaborative')
  collaborative,
  @JsonValue('tense')
  tense,
  @JsonValue('friendly')
  friendly,
  @JsonValue('professional')
  professional,
  @JsonValue('emotional')
  emotional,
  @JsonValue('analytical')
  analytical,
}

enum EmotionalAdaptability {
  @JsonValue('highly_adaptive')
  highlyAdaptive,
  @JsonValue('moderately_adaptive')
  moderatelyAdaptive,
  @JsonValue('stable')
  stable,
  @JsonValue('rigid')
  rigid,
}

// Additional enum placeholders for future expansion...

/// Intent analysis for conversation turns
@JsonSerializable()
class IntentAnalysis extends Equatable {
  final String primaryIntent;
  final double confidence;
  final List<String> secondaryIntents;
  final Map<String, dynamic> intentMetadata;

  const IntentAnalysis({
    required this.primaryIntent,
    required this.confidence,
    required this.secondaryIntents,
    this.intentMetadata = const {},
  });

  factory IntentAnalysis.fromJson(Map<String, dynamic> json) =>
      _$IntentAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$IntentAnalysisToJson(this);

  @override
  List<Object?> get props => [
        primaryIntent,
        confidence,
        secondaryIntents,
        intentMetadata,
      ];
}

/// Contextual relevance scoring
@JsonSerializable()
class ContextualRelevance extends Equatable {
  final double relevanceScore;
  final List<String> relevantElements;
  final List<String> contextConnections;

  const ContextualRelevance({
    required this.relevanceScore,
    required this.relevantElements,
    required this.contextConnections,
  });

  factory ContextualRelevance.fromJson(Map<String, dynamic> json) =>
      _$ContextualRelevanceFromJson(json);

  Map<String, dynamic> toJson() => _$ContextualRelevanceToJson(this);

  @override
  List<Object?> get props => [
        relevanceScore,
        relevantElements,
        contextConnections,
      ];
}

/// Linguistic complexity analysis
@JsonSerializable()
class LinguisticComplexity extends Equatable {
  final double complexityScore;
  final int sentenceLength;
  final int vocabularyLevel;
  final List<String> complexFeatures;

  const LinguisticComplexity({
    required this.complexityScore,
    required this.sentenceLength,
    required this.vocabularyLevel,
    required this.complexFeatures,
  });

  factory LinguisticComplexity.fromJson(Map<String, dynamic> json) =>
      _$LinguisticComplexityFromJson(json);

  Map<String, dynamic> toJson() => _$LinguisticComplexityToJson(this);

  @override
  List<Object?> get props => [
        complexityScore,
        sentenceLength,
        vocabularyLevel,
        complexFeatures,
      ];
}

/// Cultural markers detection
@JsonSerializable()
class CulturalMarkers extends Equatable {
  final List<String> detectedMarkers;
  final Map<String, double> culturalScores;
  final List<String> adaptationSuggestions;

  const CulturalMarkers({
    required this.detectedMarkers,
    required this.culturalScores,
    required this.adaptationSuggestions,
  });

  factory CulturalMarkers.fromJson(Map<String, dynamic> json) =>
      _$CulturalMarkersFromJson(json);

  Map<String, dynamic> toJson() => _$CulturalMarkersToJson(this);

  @override
  List<Object?> get props => [
        detectedMarkers,
        culturalScores,
        adaptationSuggestions,
      ];
}

/// Topic evolution tracking
@JsonSerializable()
class TopicContext extends Equatable {
  final List<String> currentTopics;
  final List<TopicTransition> topicHistory;
  final Map<String, double> topicImportance;
  final List<TopicPrediction> predictedTopics;

  const TopicContext({
    required this.currentTopics,
    required this.topicHistory,
    required this.topicImportance,
    required this.predictedTopics,
  });

  factory TopicContext.fromJson(Map<String, dynamic> json) =>
      _$TopicContextFromJson(json);

  Map<String, dynamic> toJson() => _$TopicContextToJson(this);

  @override
  List<Object?> get props => [
        currentTopics,
        topicHistory,
        topicImportance,
        predictedTopics,
      ];

  TopicContext copyWith({
    List<String>? currentTopics,
    List<TopicTransition>? topicHistory,
    Map<String, double>? topicImportance,
    List<TopicPrediction>? predictedTopics,
  }) {
    return TopicContext(
      currentTopics: currentTopics ?? this.currentTopics,
      topicHistory: topicHistory ?? this.topicHistory,
      topicImportance: topicImportance ?? this.topicImportance,
      predictedTopics: predictedTopics ?? this.predictedTopics,
    );
  }
}

/// Topic transition tracking
@JsonSerializable()
class TopicTransition extends Equatable {
  final String fromTopic;
  final String toTopic;
  final DateTime timestamp;
  final String trigger;
  final double smoothness;

  const TopicTransition({
    required this.fromTopic,
    required this.toTopic,
    required this.timestamp,
    required this.trigger,
    required this.smoothness,
  });

  factory TopicTransition.fromJson(Map<String, dynamic> json) =>
      _$TopicTransitionFromJson(json);

  Map<String, dynamic> toJson() => _$TopicTransitionToJson(this);

  @override
  List<Object?> get props => [
        fromTopic,
        toTopic,
        timestamp,
        trigger,
        smoothness,
      ];
}

/// Predicted future topics
@JsonSerializable()
class TopicPrediction extends Equatable {
  final String predictedTopic;
  final double probability;
  final List<String> triggeringFactors;

  const TopicPrediction({
    required this.predictedTopic,
    required this.probability,
    required this.triggeringFactors,
  });

  factory TopicPrediction.fromJson(Map<String, dynamic> json) =>
      _$TopicPredictionFromJson(json);

  Map<String, dynamic> toJson() => _$TopicPredictionToJson(this);

  @override
  List<Object?> get props => [
        predictedTopic,
        probability,
        triggeringFactors,
      ];
}

/// Interaction dynamics between participants
@JsonSerializable()
class InteractionDynamics extends Equatable {
  final double collaborationScore;
  final double dominanceBalance;
  final Map<String, double> participationLevels;
  final List<String> communicationPatterns;

  const InteractionDynamics({
    required this.collaborationScore,
    required this.dominanceBalance,
    required this.participationLevels,
    required this.communicationPatterns,
  });

  factory InteractionDynamics.fromJson(Map<String, dynamic> json) =>
      _$InteractionDynamicsFromJson(json);

  Map<String, dynamic> toJson() => _$InteractionDynamicsToJson(this);

  @override
  List<Object?> get props => [
        collaborationScore,
        dominanceBalance,
        participationLevels,
        communicationPatterns,
      ];
}

/// Communication patterns analysis
@JsonSerializable()
class CommunicationPatterns extends Equatable {
  final Map<String, int> turnTakingPatterns;
  final double averageResponseTime;
  final List<String> commonPhrases;
  final Map<String, double> styleConsistency;

  const CommunicationPatterns({
    required this.turnTakingPatterns,
    required this.averageResponseTime,
    required this.commonPhrases,
    required this.styleConsistency,
  });

  factory CommunicationPatterns.fromJson(Map<String, dynamic> json) =>
      _$CommunicationPatternsFromJson(json);

  Map<String, dynamic> toJson() => _$CommunicationPatternsToJson(this);

  @override
  List<Object?> get props => [
        turnTakingPatterns,
        averageResponseTime,
        commonPhrases,
        styleConsistency,
      ];
}

/// Language proficiency analysis
@JsonSerializable()
class LanguageProficiency extends Equatable {
  final Map<String, ProficiencyLevel> proficiencies;
  final Map<String, double> confidenceScores;
  final List<String> improvementAreas;

  const LanguageProficiency({
    required this.proficiencies,
    required this.confidenceScores,
    required this.improvementAreas,
  });

  factory LanguageProficiency.fromJson(Map<String, dynamic> json) =>
      _$LanguageProficiencyFromJson(json);

  Map<String, dynamic> toJson() => _$LanguageProficiencyToJson(this);

  @override
  List<Object?> get props => [
        proficiencies,
        confidenceScores,
        improvementAreas,
      ];
}

/// Communication style (reused from personality models)
@JsonSerializable()
class CommunicationStyle extends Equatable {
  final double formality;
  final double directness;
  final double expressiveness;
  final double technicality;
  final double culturalAdaptation;

  const CommunicationStyle({
    required this.formality,
    required this.directness,
    required this.expressiveness,
    required this.technicality,
    required this.culturalAdaptation,
  });

  factory CommunicationStyle.fromJson(Map<String, dynamic> json) =>
      _$CommunicationStyleFromJson(json);

  Map<String, dynamic> toJson() => _$CommunicationStyleToJson(this);

  @override
  List<Object?> get props => [
        formality,
        directness,
        expressiveness,
        technicality,
        culturalAdaptation,
      ];
}

/// Predicted conversation outcome
@JsonSerializable()
class ConversationOutcome extends Equatable {
  final OutcomeType predictedType;
  final double confidence;
  final List<String> reasoningFactors;
  final Map<String, dynamic> outcomeMetadata;

  const ConversationOutcome({
    required this.predictedType,
    required this.confidence,
    required this.reasoningFactors,
    this.outcomeMetadata = const {},
  });

  factory ConversationOutcome.fromJson(Map<String, dynamic> json) =>
      _$ConversationOutcomeFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationOutcomeToJson(this);

  @override
  List<Object?> get props => [
        predictedType,
        confidence,
        reasoningFactors,
        outcomeMetadata,
      ];
}

enum ProficiencyLevel {
  @JsonValue('beginner')
  beginner,
  @JsonValue('intermediate')
  intermediate,
  @JsonValue('advanced')
  advanced,
  @JsonValue('native')
  native,
}

enum OutcomeType {
  @JsonValue('successful_resolution')
  successfulResolution,
  @JsonValue('partial_agreement')
  partialAgreement,
  @JsonValue('ongoing_discussion')
  ongoingDiscussion,
  @JsonValue('unresolved_conflict')
  unresolvedConflict,
  @JsonValue('natural_conclusion')
  naturalConclusion,
}

enum FeedbackType {
  @JsonValue('positive')
  positive,
  @JsonValue('negative')
  negative,
  @JsonValue('neutral')
  neutral,
  @JsonValue('suggestion')
  suggestion,
  @JsonValue('correction')
  correction,
}
