// 🎭 LingoSphere - AI Personality Models
// Advanced data models for AI avatars, personality traits, and learning systems

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'personality_models.g.dart';

// ===== CORE PERSONALITY MODELS =====

/// User's communication style analysis
@JsonSerializable()
class CommunicationStyle extends Equatable {
  final double formality; // 0.0 = casual, 1.0 = formal
  final double directness; // 0.0 = indirect, 1.0 = direct
  final double expressiveness; // 0.0 = minimal, 1.0 = very expressive
  final double technicality; // 0.0 = simple, 1.0 = technical
  final double culturalAdaptation; // 0.0 = neutral, 1.0 = highly adaptive

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

  CommunicationStyle copyWith({
    double? formality,
    double? directness,
    double? expressiveness,
    double? technicality,
    double? culturalAdaptation,
  }) {
    return CommunicationStyle(
      formality: formality ?? this.formality,
      directness: directness ?? this.directness,
      expressiveness: expressiveness ?? this.expressiveness,
      technicality: technicality ?? this.technicality,
      culturalAdaptation: culturalAdaptation ?? this.culturalAdaptation,
    );
  }

  @override
  List<Object?> get props => [
        formality,
        directness,
        expressiveness,
        technicality,
        culturalAdaptation,
      ];
}

/// AI personality traits that define behavior
@JsonSerializable()
class PersonalityTraits extends Equatable {
  final String dominantTrait;
  final double creativity;
  final double empathy;
  final double precision;
  final double enthusiasm;
  final double culturalSensitivity;
  final double adaptability;
  final double humor;
  final Map<String, dynamic> customTraits;

  const PersonalityTraits({
    required this.dominantTrait,
    required this.creativity,
    required this.empathy,
    required this.precision,
    required this.enthusiasm,
    required this.culturalSensitivity,
    required this.adaptability,
    required this.humor,
    this.customTraits = const {},
  });

  factory PersonalityTraits.fromJson(Map<String, dynamic> json) =>
      _$PersonalityTraitsFromJson(json);

  Map<String, dynamic> toJson() => _$PersonalityTraitsToJson(this);

  PersonalityTraits copyWith({
    String? dominantTrait,
    double? creativity,
    double? empathy,
    double? precision,
    double? enthusiasm,
    double? culturalSensitivity,
    double? adaptability,
    double? humor,
    Map<String, dynamic>? customTraits,
  }) {
    return PersonalityTraits(
      dominantTrait: dominantTrait ?? this.dominantTrait,
      creativity: creativity ?? this.creativity,
      empathy: empathy ?? this.empathy,
      precision: precision ?? this.precision,
      enthusiasm: enthusiasm ?? this.enthusiasm,
      culturalSensitivity: culturalSensitivity ?? this.culturalSensitivity,
      adaptability: adaptability ?? this.adaptability,
      humor: humor ?? this.humor,
      customTraits: customTraits ?? this.customTraits,
    );
  }

  /// Get the overall personality intensity
  double get intensityScore {
    return (creativity +
            empathy +
            precision +
            enthusiasm +
            culturalSensitivity +
            adaptability +
            humor) /
        7;
  }

  /// Get the most dominant trait value
  double get dominantTraitValue {
    final values = [
      creativity,
      empathy,
      precision,
      enthusiasm,
      culturalSensitivity,
      adaptability,
      humor
    ];
    return values.reduce((a, b) => a > b ? a : b);
  }

  @override
  List<Object?> get props => [
        dominantTrait,
        creativity,
        empathy,
        precision,
        enthusiasm,
        culturalSensitivity,
        adaptability,
        humor,
        customTraits,
      ];
}

// ===== AVATAR APPEARANCE MODELS =====

/// Avatar visual appearance configuration
@JsonSerializable()
class AvatarAppearance extends Equatable {
  final AvatarStyle style;
  final String primaryColor;
  final String secondaryColor;
  final Map<String, dynamic> features;
  final List<String> animations;
  final List<String> accessories;
  final Map<String, dynamic> customizations;

  const AvatarAppearance({
    required this.style,
    required this.primaryColor,
    required this.secondaryColor,
    required this.features,
    required this.animations,
    required this.accessories,
    this.customizations = const {},
  });

  factory AvatarAppearance.fromJson(Map<String, dynamic> json) =>
      _$AvatarAppearanceFromJson(json);

  Map<String, dynamic> toJson() => _$AvatarAppearanceToJson(this);

  AvatarAppearance copyWith({
    AvatarStyle? style,
    String? primaryColor,
    String? secondaryColor,
    Map<String, dynamic>? features,
    List<String>? animations,
    List<String>? accessories,
    Map<String, dynamic>? customizations,
  }) {
    return AvatarAppearance(
      style: style ?? this.style,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      features: features ?? this.features,
      animations: animations ?? this.animations,
      accessories: accessories ?? this.accessories,
      customizations: customizations ?? this.customizations,
    );
  }

  @override
  List<Object?> get props => [
        style,
        primaryColor,
        secondaryColor,
        features,
        animations,
        accessories,
        customizations,
      ];
}

/// Avatar voice personality configuration
@JsonSerializable()
class PersonalityVoice extends Equatable {
  final String tone; // confident, expressive, friendly, etc.
  final String pace; // measured, dynamic, natural
  final String pitch; // warm, clear, natural
  final String accent; // regional accent preference
  final double emotionalRange; // 0.0 = monotone, 1.0 = very expressive
  final Map<String, dynamic> customizations;

  const PersonalityVoice({
    required this.tone,
    required this.pace,
    required this.pitch,
    required this.accent,
    required this.emotionalRange,
    this.customizations = const {},
  });

  factory PersonalityVoice.fromJson(Map<String, dynamic> json) =>
      _$PersonalityVoiceFromJson(json);

  Map<String, dynamic> toJson() => _$PersonalityVoiceToJson(this);

  PersonalityVoice copyWith({
    String? tone,
    String? pace,
    String? pitch,
    String? accent,
    double? emotionalRange,
    Map<String, dynamic>? customizations,
  }) {
    return PersonalityVoice(
      tone: tone ?? this.tone,
      pace: pace ?? this.pace,
      pitch: pitch ?? this.pitch,
      accent: accent ?? this.accent,
      emotionalRange: emotionalRange ?? this.emotionalRange,
      customizations: customizations ?? this.customizations,
    );
  }

  @override
  List<Object?> get props => [
        tone,
        pace,
        pitch,
        accent,
        emotionalRange,
        customizations,
      ];
}

// ===== LEARNING & ADAPTATION MODELS =====

/// Machine learning model for personality adaptation
@JsonSerializable()
class PersonalityLearningModel extends Equatable {
  final String userId;
  final Map<String, dynamic> initialPreferences;
  final double adaptationLevel; // How much the AI has adapted (0.0 to 1.0)
  final Map<String, double> learningWeights;
  final DateTime lastUpdated;
  final int interactionCount;

  const PersonalityLearningModel({
    required this.userId,
    required this.initialPreferences,
    required this.adaptationLevel,
    this.learningWeights = const {},
    required this.lastUpdated,
    this.interactionCount = 0,
  });

  factory PersonalityLearningModel.fromJson(Map<String, dynamic> json) =>
      _$PersonalityLearningModelFromJson(json);

  Map<String, dynamic> toJson() => _$PersonalityLearningModelToJson(this);

  PersonalityLearningModel copyWith({
    String? userId,
    Map<String, dynamic>? initialPreferences,
    double? adaptationLevel,
    Map<String, double>? learningWeights,
    DateTime? lastUpdated,
    int? interactionCount,
  }) {
    return PersonalityLearningModel(
      userId: userId ?? this.userId,
      initialPreferences: initialPreferences ?? this.initialPreferences,
      adaptationLevel: adaptationLevel ?? this.adaptationLevel,
      learningWeights: learningWeights ?? this.learningWeights,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      interactionCount: interactionCount ?? this.interactionCount,
    );
  }

  /// Check if the model is ready for adaptation
  bool get isReadyForAdaptation => interactionCount >= 10;

  /// Get learning progress percentage
  double get learningProgress => (adaptationLevel * 100).clamp(0.0, 100.0);

  @override
  List<Object?> get props => [
        userId,
        initialPreferences,
        adaptationLevel,
        learningWeights,
        lastUpdated,
        interactionCount,
      ];
}

// ===== COMPLETE USER PROFILE =====

/// Complete user personality profile
@JsonSerializable()
class UserPersonalityProfile extends Equatable {
  final String id;
  final String userId;
  final PersonalityType primaryType;
  final PersonalityTraits personalityTraits;
  final AvatarAppearance avatarAppearance;
  final CommunicationStyle communicationStyle;
  final PersonalityVoice voiceProfile;
  final PersonalityLearningModel learningModel;
  final Map<String, dynamic> customizations;
  final DateTime createdAt;
  final DateTime lastInteraction;

  const UserPersonalityProfile({
    required this.id,
    required this.userId,
    required this.primaryType,
    required this.personalityTraits,
    required this.avatarAppearance,
    required this.communicationStyle,
    required this.voiceProfile,
    required this.learningModel,
    this.customizations = const {},
    required this.createdAt,
    required this.lastInteraction,
  });

  factory UserPersonalityProfile.fromJson(Map<String, dynamic> json) =>
      _$UserPersonalityProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserPersonalityProfileToJson(this);

  UserPersonalityProfile copyWith({
    String? id,
    String? userId,
    PersonalityType? primaryType,
    PersonalityTraits? personalityTraits,
    AvatarAppearance? avatarAppearance,
    CommunicationStyle? communicationStyle,
    PersonalityVoice? voiceProfile,
    PersonalityLearningModel? learningModel,
    Map<String, dynamic>? customizations,
    DateTime? createdAt,
    DateTime? lastInteraction,
  }) {
    return UserPersonalityProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      primaryType: primaryType ?? this.primaryType,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      avatarAppearance: avatarAppearance ?? this.avatarAppearance,
      communicationStyle: communicationStyle ?? this.communicationStyle,
      voiceProfile: voiceProfile ?? this.voiceProfile,
      learningModel: learningModel ?? this.learningModel,
      customizations: customizations ?? this.customizations,
      createdAt: createdAt ?? this.createdAt,
      lastInteraction: lastInteraction ?? this.lastInteraction,
    );
  }

  /// Check if profile needs updates based on last interaction
  bool get needsUpdate {
    final daysSinceLastInteraction =
        DateTime.now().difference(lastInteraction).inDays;
    return daysSinceLastInteraction > 7; // Update weekly
  }

  /// Get profile maturity level (how developed the personality is)
  double get maturityLevel {
    final daysSinceCreation = DateTime.now().difference(createdAt).inDays;
    final interactionCount = learningModel.interactionCount;

    // Combine time and interaction factors
    final timeFactor =
        (daysSinceCreation / 30).clamp(0.0, 1.0); // 30 days to mature
    final interactionFactor =
        (interactionCount / 100).clamp(0.0, 1.0); // 100 interactions to mature

    return (timeFactor + interactionFactor) / 2;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        primaryType,
        personalityTraits,
        avatarAppearance,
        communicationStyle,
        voiceProfile,
        learningModel,
        customizations,
        createdAt,
        lastInteraction,
      ];
}

// ===== TRANSLATION RESULTS WITH PERSONALITY =====

/// Translation result enhanced with personality insights
@JsonSerializable()
class PersonalizedTranslationResult extends Equatable {
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final UserPersonalityProfile personalityProfile;
  final AvatarReaction avatarReaction;
  final PersonalityInsights personalityInsights;
  final double confidence;
  final List<String> alternatives;
  final Map<String, dynamic> culturalNotes;
  final DateTime timestamp;

  const PersonalizedTranslationResult({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.personalityProfile,
    required this.avatarReaction,
    required this.personalityInsights,
    required this.confidence,
    required this.alternatives,
    required this.culturalNotes,
    required this.timestamp,
  });

  factory PersonalizedTranslationResult.fromJson(Map<String, dynamic> json) =>
      _$PersonalizedTranslationResultFromJson(json);

  Map<String, dynamic> toJson() => _$PersonalizedTranslationResultToJson(this);

  @override
  List<Object?> get props => [
        originalText,
        translatedText,
        sourceLanguage,
        targetLanguage,
        personalityProfile,
        avatarReaction,
        personalityInsights,
        confidence,
        alternatives,
        culturalNotes,
        timestamp,
      ];
}

/// Avatar reaction to translation content
@JsonSerializable()
class AvatarReaction extends Equatable {
  final String expression; // excited_confidence, thoughtful_nod, etc.
  final String animation; // dynamic_gesture, professional_nod, etc.
  final Duration duration;
  final double intensity; // 0.0 to 1.0
  final Map<String, dynamic> metadata;

  const AvatarReaction({
    required this.expression,
    required this.animation,
    required this.duration,
    required this.intensity,
    this.metadata = const {},
  });

  factory AvatarReaction.fromJson(Map<String, dynamic> json) =>
      _$AvatarReactionFromJson(json);

  Map<String, dynamic> toJson() => _$AvatarReactionToJson(this);

  @override
  List<Object?> get props => [
        expression,
        animation,
        duration,
        intensity,
        metadata,
      ];
}

/// Personality insights from translation
@JsonSerializable()
class PersonalityInsights extends Equatable {
  final String personalityInfluence; // How personality affected translation
  final String culturalNotes; // Cultural considerations
  final List<String> communicationTips; // Tips for better communication
  final List<String> learningPoints; // What the AI learned
  final List<String> nextSteps; // Suggested next actions

  const PersonalityInsights({
    required this.personalityInfluence,
    required this.culturalNotes,
    required this.communicationTips,
    required this.learningPoints,
    required this.nextSteps,
  });

  factory PersonalityInsights.fromJson(Map<String, dynamic> json) =>
      _$PersonalityInsightsFromJson(json);

  Map<String, dynamic> toJson() => _$PersonalityInsightsToJson(this);

  @override
  List<Object?> get props => [
        personalityInfluence,
        culturalNotes,
        communicationTips,
        learningPoints,
        nextSteps,
      ];
}

// ===== INTERACTION & LEARNING MODELS =====

/// Record of personality interaction for learning
@JsonSerializable()
class PersonalityInteraction extends Equatable {
  final String userId;
  final String originalText;
  final String translation;
  final double confidence;
  final Map<String, dynamic> context;
  final DateTime timestamp;
  final Map<String, double>? userFeedback;

  const PersonalityInteraction({
    required this.userId,
    required this.originalText,
    required this.translation,
    required this.confidence,
    required this.context,
    required this.timestamp,
    this.userFeedback,
  });

  factory PersonalityInteraction.fromJson(Map<String, dynamic> json) =>
      _$PersonalityInteractionFromJson(json);

  Map<String, dynamic> toJson() => _$PersonalityInteractionToJson(this);

  PersonalityInteraction copyWith({
    Map<String, double>? userFeedback,
  }) {
    return PersonalityInteraction(
      userId: userId,
      originalText: originalText,
      translation: translation,
      confidence: confidence,
      context: context,
      timestamp: timestamp,
      userFeedback: userFeedback ?? this.userFeedback,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        originalText,
        translation,
        confidence,
        context,
        timestamp,
        userFeedback,
      ];
}

/// Conversation context for better personality adaptation
@JsonSerializable()
class ConversationContext extends Equatable {
  final List<PersonalityInteraction> previousMessages;
  final String currentTopic;
  final String emotionalState;
  final double urgency; // 0.0 = not urgent, 1.0 = very urgent
  final double formality; // 0.0 = casual, 1.0 = formal

  const ConversationContext({
    required this.previousMessages,
    required this.currentTopic,
    required this.emotionalState,
    required this.urgency,
    required this.formality,
  });

  factory ConversationContext.fromJson(Map<String, dynamic> json) =>
      _$ConversationContextFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationContextToJson(this);

  @override
  List<Object?> get props => [
        previousMessages,
        currentTopic,
        emotionalState,
        urgency,
        formality,
      ];
}

// ===== FEEDBACK & IMPROVEMENT MODELS =====

/// User feedback for personality improvement
@JsonSerializable()
class PersonalityFeedback extends Equatable {
  final String userId;
  final DateTime timestamp;
  final double? creativityFeedback;
  final double? empathyFeedback;
  final double? precisionFeedback;
  final double? enthusiasmFeedback;
  final Map<String, dynamic>? avatarFeedback;
  final String? generalComments;
  final int rating; // 1-5 star rating

  const PersonalityFeedback({
    required this.userId,
    required this.timestamp,
    this.creativityFeedback,
    this.empathyFeedback,
    this.precisionFeedback,
    this.enthusiasmFeedback,
    this.avatarFeedback,
    this.generalComments,
    required this.rating,
  });

  factory PersonalityFeedback.fromJson(Map<String, dynamic> json) =>
      _$PersonalityFeedbackFromJson(json);

  Map<String, dynamic> toJson() => _$PersonalityFeedbackToJson(this);

  /// Check if feedback is positive
  bool get isPositive => rating >= 4;

  /// Check if feedback suggests major changes
  bool get suggestsMajorChanges {
    final feedbacks = [
      creativityFeedback,
      empathyFeedback,
      precisionFeedback,
      enthusiasmFeedback
    ];
    final significantChanges =
        feedbacks.where((f) => f != null && (f < 0.3 || f > 0.7)).length;
    return significantChanges >= 2;
  }

  @override
  List<Object?> get props => [
        userId,
        timestamp,
        creativityFeedback,
        empathyFeedback,
        precisionFeedback,
        enthusiasmFeedback,
        avatarFeedback,
        generalComments,
        rating,
      ];
}

// ===== COMMUNICATION & SUGGESTION MODELS =====

/// AI-powered communication suggestions
@JsonSerializable()
class CommunicationSuggestion extends Equatable {
  final SuggestionType type;
  final String title;
  final String description;
  final bool actionable; // Can user take immediate action
  final double priority; // 0.0 = low, 1.0 = high priority
  final Map<String, dynamic>? actionData;

  const CommunicationSuggestion({
    required this.type,
    required this.title,
    required this.description,
    required this.actionable,
    required this.priority,
    this.actionData,
  });

  factory CommunicationSuggestion.fromJson(Map<String, dynamic> json) =>
      _$CommunicationSuggestionFromJson(json);

  Map<String, dynamic> toJson() => _$CommunicationSuggestionToJson(this);

  @override
  List<Object?> get props => [
        type,
        title,
        description,
        actionable,
        priority,
        actionData,
      ];
}

/// Communication patterns analysis
@JsonSerializable()
class CommunicationPatterns extends Equatable {
  final double averageConfidence;
  final List<String> preferredTopics;
  final Map<String, double> communicationTrends;
  final Map<String, int> languagePairUsage;
  final DateTime lastAnalyzed;

  const CommunicationPatterns({
    required this.averageConfidence,
    required this.preferredTopics,
    required this.communicationTrends,
    this.languagePairUsage = const {},
    required this.lastAnalyzed,
  });

  factory CommunicationPatterns.fromJson(Map<String, dynamic> json) =>
      _$CommunicationPatternsFromJson(json);

  Map<String, dynamic> toJson() => _$CommunicationPatternsToJson(this);

  @override
  List<Object?> get props => [
        averageConfidence,
        preferredTopics,
        communicationTrends,
        languagePairUsage,
        lastAnalyzed,
      ];
}

// ===== ANIMATION & VISUAL MODELS =====

/// Avatar animation configuration
@JsonSerializable()
class AvatarAnimation extends Equatable {
  final AnimationType type;
  final Duration duration;
  final List<FacialExpression> expressions;
  final List<Gesture> gestures;
  final List<VisualEffect> effects;
  final Map<String, dynamic> metadata;

  const AvatarAnimation({
    required this.type,
    required this.duration,
    required this.expressions,
    required this.gestures,
    required this.effects,
    this.metadata = const {},
  });

  factory AvatarAnimation.fromJson(Map<String, dynamic> json) =>
      _$AvatarAnimationFromJson(json);

  Map<String, dynamic> toJson() => _$AvatarAnimationToJson(this);

  /// Create a default animation for fallback
  factory AvatarAnimation.defaultAnimation() {
    return const AvatarAnimation(
      type: AnimationType.standard,
      duration: Duration(seconds: 2),
      expressions: [FacialExpression.smile],
      gestures: [Gesture.nod],
      effects: [],
    );
  }

  @override
  List<Object?> get props => [
        type,
        duration,
        expressions,
        gestures,
        effects,
        metadata,
      ];
}

/// Emotional analysis of content
@JsonSerializable()
class EmotionalAnalysis extends Equatable {
  final String primaryEmotion;
  final double intensity; // 0.0 to 1.0
  final Map<String, double> emotionalSpectrum;

  const EmotionalAnalysis({
    required this.primaryEmotion,
    required this.intensity,
    required this.emotionalSpectrum,
  });

  factory EmotionalAnalysis.fromJson(Map<String, dynamic> json) =>
      _$EmotionalAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$EmotionalAnalysisToJson(this);

  @override
  List<Object?> get props => [
        primaryEmotion,
        intensity,
        emotionalSpectrum,
      ];
}

// ===== GENERATED AVATAR MODEL =====

/// Generated avatar with all assets
@JsonSerializable()
class GeneratedAvatar extends Equatable {
  final String id;
  final String userId;
  final AvatarStyle style;
  final Map<String, String> assetUrls; // Asset type -> URL
  final List<String> animationFiles;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const GeneratedAvatar({
    required this.id,
    required this.userId,
    required this.style,
    required this.assetUrls,
    required this.animationFiles,
    this.metadata = const {},
    required this.createdAt,
  });

  factory GeneratedAvatar.fromJson(Map<String, dynamic> json) =>
      _$GeneratedAvatarFromJson(json);

  Map<String, dynamic> toJson() => _$GeneratedAvatarToJson(this);

  @override
  List<Object?> get props => [
        id,
        userId,
        style,
        assetUrls,
        animationFiles,
        metadata,
        createdAt,
      ];
}

// ===== ENUMS =====

/// Personality types for different use cases
enum PersonalityType {
  @JsonValue('professional')
  professional,
  @JsonValue('creative')
  creative,
  @JsonValue('academic')
  academic,
  @JsonValue('casual')
  casual,
  @JsonValue('technical')
  technical,
  @JsonValue('diplomatic')
  diplomatic,
  @JsonValue('energetic')
  energetic,
  @JsonValue('minimalist')
  minimalist,
}

/// Avatar visual styles
enum AvatarStyle {
  @JsonValue('realistic')
  realistic,
  @JsonValue('anime')
  anime,
  @JsonValue('cartoon')
  cartoon,
  @JsonValue('abstract')
  abstract,
  @JsonValue('holographic')
  holographic,
  @JsonValue('neon')
  neon,
  @JsonValue('glassmorphic')
  glassmorphic,
}

/// Suggestion types for communication improvement
enum SuggestionType {
  @JsonValue('confidence')
  confidence,
  @JsonValue('cultural')
  cultural,
  @JsonValue('accuracy')
  accuracy,
  @JsonValue('style')
  style,
  @JsonValue('efficiency')
  efficiency,
}

/// Animation types for avatars
enum AnimationType {
  @JsonValue('standard')
  standard,
  @JsonValue('energetic')
  energetic,
  @JsonValue('professional')
  professional,
  @JsonValue('creative')
  creative,
  @JsonValue('minimal')
  minimal,
}

/// Facial expressions for avatars
enum FacialExpression {
  @JsonValue('smile')
  smile,
  @JsonValue('think')
  think,
  @JsonValue('excited')
  excited,
  @JsonValue('confident')
  confident,
  @JsonValue('curious')
  curious,
  @JsonValue('concerned')
  concerned,
  @JsonValue('surprised')
  surprised,
  @JsonValue('neutral')
  neutral,
}

/// Gestures for avatars
enum Gesture {
  @JsonValue('nod')
  nod,
  @JsonValue('wave')
  wave,
  @JsonValue('point')
  point,
  @JsonValue('thumbs_up')
  thumbsUp,
  @JsonValue('shrug')
  shrug,
  @JsonValue('clap')
  clap,
  @JsonValue('peace')
  peace,
}

/// Visual effects for avatars
enum VisualEffect {
  @JsonValue('hologram_flicker')
  hologramFlicker,
  @JsonValue('data_stream')
  dataStream,
  @JsonValue('neon_glow')
  neonGlow,
  @JsonValue('cyberpunk_pulse')
  cyberpunkPulse,
  @JsonValue('sparkles')
  sparkles,
  @JsonValue('glow')
  glow,
  @JsonValue('particles')
  particles,
}
