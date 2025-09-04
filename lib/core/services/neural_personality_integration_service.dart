// 🎯 LingoSphere - Neural Personality Integration Service
// Connects Neural Conversation Intelligence with AI Personality Engine for advanced translations

import 'dart:async';
import 'dart:convert';
import 'package:logger/logger.dart';

import '../models/neural_conversation_models.dart';
import '../models/personality_models.dart';
import '../exceptions/translation_exceptions.dart';
import 'neural_context_engine.dart';
import 'ai_personality_engine.dart';
import 'predictive_translation_service.dart';

/// Integration service for Neural Conversation Intelligence and AI Personality Engine
/// Provides context-aware, personality-adapted translations with predictive capabilities
class NeuralPersonalityIntegrationService {
  static final NeuralPersonalityIntegrationService _instance =
      NeuralPersonalityIntegrationService._internal();
  factory NeuralPersonalityIntegrationService() => _instance;
  NeuralPersonalityIntegrationService._internal();

  final Logger _logger = Logger();

  // Core AI services
  final NeuralContextEngine _neuralEngine = NeuralContextEngine();
  final AIPersonalityEngine _personalityEngine = AIPersonalityEngine();
  final PredictiveTranslationService _predictiveService =
      PredictiveTranslationService();

  // Integration cache for performance
  final Map<String, IntegratedTranslationResult> _integrationCache = {};
  final Map<String, PersonalityContextMapping> _contextMappings = {};

  /// Initialize the integration service
  Future<void> initialize({
    required String openAIApiKey,
    Map<String, dynamic>? integrationConfig,
  }) async {
    try {
      // Initialize all underlying services
      await Future.wait([
        _neuralEngine.initialize(openAIApiKey: openAIApiKey),
        _personalityEngine.initialize(openAIApiKey: openAIApiKey),
        _predictiveService.initialize(openAIApiKey: openAIApiKey),
      ]);

      _logger.i('Neural Personality Integration Service initialized');
    } catch (e) {
      _logger.e('Failed to initialize Neural Personality Integration: $e');
      throw TranslationServiceException(
          'Integration initialization failed: ${e.toString()}');
    }
  }

  /// Process translation with full neural and personality integration
  Future<IntegratedTranslationResult> processIntegratedTranslation({
    required String userId,
    required String conversationId,
    required String originalText,
    required String sourceLanguage,
    required String targetLanguage,
    Map<String, dynamic>? additionalContext,
  }) async {
    try {
      // Check cache first
      final cacheKey = _generateCacheKey(
          userId, conversationId, originalText, targetLanguage);
      if (_integrationCache.containsKey(cacheKey)) {
        return _integrationCache[cacheKey]!;
      }

      // 1. Process with Neural Context Engine
      final neuralResult = await _neuralEngine.processConversationTurn(
        conversationId: conversationId,
        speakerId: userId,
        originalText: originalText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        metadata: additionalContext,
      );

      // 2. Get or create user personality profile
      final personalityProfile =
          await _personalityEngine.getPersonalityProfile(userId);

      // 3. Generate personality-adapted translation using neural context
      final personalityResult = await _generatePersonalityAdaptedTranslation(
        neuralResult: neuralResult,
        personalityProfile: personalityProfile,
        originalText: originalText,
        targetLanguage: targetLanguage,
      );

      // 4. Get predictive suggestions for future interactions
      final predictiveSuggestions =
          await _predictiveService.getProactiveTranslationSuggestions(
        userId: userId,
        conversationId: conversationId,
        targetLanguage: targetLanguage,
      );

      // 5. Generate avatar animation based on context and personality
      final avatarAnimation = await _personalityEngine.generateAvatarAnimation(
        profile: personalityProfile,
        content: originalText,
        translatedContent: neuralResult.translatedText,
      );

      // 6. Create comprehensive insights
      final integratedInsights = await _generateIntegratedInsights(
        neuralResult: neuralResult,
        personalityResult: personalityResult,
        personalityProfile: personalityProfile,
      );

      // 7. Learn from this interaction for future improvements
      await _learnFromIntegratedInteraction(
        userId: userId,
        conversationId: conversationId,
        neuralResult: neuralResult,
        personalityResult: personalityResult,
        originalText: originalText,
        targetLanguage: targetLanguage,
      );

      // 8. Create integrated result
      final result = IntegratedTranslationResult(
        originalText: originalText,
        translatedText: personalityResult.translatedText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        confidence:
            _calculateIntegratedConfidence(neuralResult, personalityResult),
        neuralResult: neuralResult,
        personalityResult: personalityResult,
        predictiveSuggestions: predictiveSuggestions,
        avatarAnimation: avatarAnimation,
        integratedInsights: integratedInsights,
        timestamp: DateTime.now(),
      );

      // Cache the result
      _integrationCache[cacheKey] = result;
      _cleanIntegrationCache();

      return result;
    } catch (e) {
      _logger.e('Integrated translation processing failed: $e');
      throw TranslationServiceException(
          'Integrated processing failed: ${e.toString()}');
    }
  }

  /// Get advanced conversation analytics combining neural and personality insights
  Future<IntegratedConversationAnalytics> getIntegratedConversationAnalytics({
    required String userId,
    required String conversationId,
  }) async {
    try {
      // Get neural conversation metrics
      final neuralMetrics =
          await _neuralEngine.getConversationMetrics(conversationId);

      // Get personality profile and learning progress
      final personalityProfile =
          await _personalityEngine.getPersonalityProfile(userId);

      // Get predictive analytics
      final predictiveAnalytics =
          await _predictiveService.getPredictionAnalytics(userId);

      // Get conversation context for analysis
      final conversationContext =
          await _neuralEngine.getConversationContext(conversationId);

      // Analyze personality-context alignment
      final alignmentAnalysis = conversationContext != null
          ? await _analyzePersonalityContextAlignment(
              personalityProfile, conversationContext)
          : PersonalityContextAlignment.defaultAlignment();

      // Generate improvement recommendations
      final recommendations = await _generateIntegratedRecommendations(
        neuralMetrics: neuralMetrics,
        personalityProfile: personalityProfile,
        predictiveAnalytics: predictiveAnalytics,
        alignmentAnalysis: alignmentAnalysis,
      );

      return IntegratedConversationAnalytics(
        userId: userId,
        conversationId: conversationId,
        neuralMetrics: neuralMetrics,
        personalityProfile: personalityProfile,
        predictiveAnalytics: predictiveAnalytics,
        alignmentAnalysis: alignmentAnalysis,
        recommendations: recommendations,
        overallScore: _calculateOverallScore(
            neuralMetrics, personalityProfile, predictiveAnalytics),
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      _logger.e('Integrated analytics generation failed: $e');
      throw TranslationServiceException(
          'Analytics generation failed: ${e.toString()}');
    }
  }

  /// Get smart suggestions that combine neural context with personality preferences
  Future<List<SmartSuggestion>> getSmartSuggestions({
    required String userId,
    required String conversationId,
    String? targetLanguage,
    int maxSuggestions = 5,
  }) async {
    try {
      final suggestions = <SmartSuggestion>[];

      // Get neural context-based suggestions
      final neuralSuggestions = await _neuralEngine.getPredictiveSuggestions(
        conversationId: conversationId,
        targetLanguage: targetLanguage,
        maxSuggestions: maxSuggestions,
      );

      // Get personality-based communication suggestions
      final personalitySuggestions =
          await _personalityEngine.getCommunicationSuggestions(
        userId: userId,
        context: 'conversation_$conversationId',
      );

      // Get predictive auto-complete suggestions
      final predictiveSuggestions =
          await _predictiveService.getPredictivePhrases(
        userId: userId,
        sourceLanguage: 'auto', // Will be detected from context
        targetLanguage: targetLanguage ?? 'auto',
        conversationContext: conversationId,
        maxPhrases: maxSuggestions,
      );

      // Combine and rank all suggestions
      suggestions.addAll(_convertToSmartSuggestions(
        neuralSuggestions,
        SuggestionSource.neural,
      ));

      suggestions.addAll(_convertPersonalitySuggestions(
        personalitySuggestions,
        SuggestionSource.personality,
      ));

      suggestions.addAll(_convertPredictiveSuggestions(
        predictiveSuggestions,
        SuggestionSource.predictive,
      ));

      // Rank by relevance and user preferences
      final rankedSuggestions =
          await _rankSmartSuggestions(suggestions, userId);

      return rankedSuggestions.take(maxSuggestions).toList();
    } catch (e) {
      _logger.e('Smart suggestions generation failed: $e');
      return [];
    }
  }

  /// Real-time context awareness update
  Future<void> updateContextAwareness({
    required String userId,
    required String conversationId,
    Map<String, dynamic>? contextUpdate,
  }) async {
    try {
      // Update the context mapping for better integration
      final mapping = _contextMappings[conversationId] ??
          PersonalityContextMapping(
            conversationId: conversationId,
            userId: userId,
            personalityAlignment: {},
            contextFactors: {},
            lastUpdated: DateTime.now(),
          );

      if (contextUpdate != null) {
        mapping.contextFactors.addAll(contextUpdate);
        mapping.lastUpdated = DateTime.now();
        _contextMappings[conversationId] = mapping;
      }

      _logger.d('Updated context awareness for conversation: $conversationId');
    } catch (e) {
      _logger.e('Context awareness update failed: $e');
    }
  }

  // ===== PRIVATE INTEGRATION METHODS =====

  Future<PersonalizedTranslationResult> _generatePersonalityAdaptedTranslation({
    required NeuralTranslationResult neuralResult,
    required UserPersonalityProfile personalityProfile,
    required String originalText,
    required String targetLanguage,
  }) async {
    // Use the personality engine to adapt the neural translation result
    // based on the user's personality profile and conversation context

    // Extract conversation context factors
    final contextFactors = {
      'conversation_phase':
          neuralResult.conversationContext.currentState.phase.name,
      'emotional_state': neuralResult
          .conversationContext.emotionalFlow.currentEmotion
          .toJson(),
      'topics': neuralResult.conversationContext.topicEvolution.currentTopics,
      'confidence': neuralResult.confidence,
    };

    // Adapt translation using personality context
    return await _personalityEngine.translateWithPersonality(
      userId: personalityProfile.userId,
      text: originalText,
      targetLanguage: targetLanguage,
      context: contextFactors,
    );
  }

  Future<IntegratedInsights> _generateIntegratedInsights({
    required NeuralTranslationResult neuralResult,
    required PersonalizedTranslationResult personalityResult,
    required UserPersonalityProfile personalityProfile,
  }) async {
    // Combine insights from neural and personality analysis
    final neuralInsights = neuralResult.culturalInsights;
    final personalityInsights = personalityResult.personalityInsights;

    // Analyze how neural context influenced personality adaptation
    final contextInfluence = await _analyzeContextPersonalityInfluence(
      neuralResult.conversationContext,
      personalityProfile,
    );

    // Generate recommendations for better communication
    final communicationRecommendations =
        await _generateCommunicationRecommendations(
      neuralResult: neuralResult,
      personalityResult: personalityResult,
      personalityProfile: personalityProfile,
    );

    return IntegratedInsights(
      neuralContextInfluence: contextInfluence,
      personalityAdaptations: personalityInsights.personalityInfluence,
      culturalConsiderations: _mergeCulturalInsights(
          neuralInsights, personalityInsights.culturalNotes),
      communicationRecommendations: communicationRecommendations,
      confidenceFactors:
          await _analyzeConfidenceFactors(neuralResult, personalityResult),
      improvementOpportunities:
          _identifyImprovementOpportunities(neuralResult, personalityResult),
    );
  }

  Future<PersonalityContextAlignment> _analyzePersonalityContextAlignment(
    UserPersonalityProfile personalityProfile,
    NeuralConversationContext conversationContext,
  ) async {
    final alignment = <String, double>{};

    // Analyze how well the personality traits align with conversation context
    final currentMood = conversationContext.emotionalFlow.overallMood;
    final conversationPhase = conversationContext.currentState.phase;

    // Alignment scoring (0.0 to 1.0)
    switch (currentMood) {
      case ConversationMood.professional:
        alignment['mood_personality'] =
            personalityProfile.primaryType == PersonalityType.professional
                ? 1.0
                : 0.6;
        break;
      case ConversationMood.friendly:
        alignment['mood_personality'] =
            personalityProfile.primaryType == PersonalityType.casual
                ? 1.0
                : 0.7;
        break;
      case ConversationMood.analytical:
        alignment['mood_personality'] =
            personalityProfile.primaryType == PersonalityType.technical
                ? 1.0
                : 0.5;
        break;
      default:
        alignment['mood_personality'] = 0.7; // Neutral alignment
    }

    // Communication style alignment
    final contextFormality =
        conversationContext.currentState.mode == ConversationMode.formal
            ? 1.0
            : 0.3;
    final personalityFormality =
        personalityProfile.communicationStyle.formality;
    alignment['communication_style'] =
        1.0 - (contextFormality - personalityFormality).abs();

    // Overall alignment score
    final overallAlignment =
        alignment.values.reduce((a, b) => a + b) / alignment.length;

    return PersonalityContextAlignment(
      overallScore: overallAlignment,
      alignmentFactors: alignment,
      recommendations: _generateAlignmentRecommendations(alignment),
      lastAnalyzed: DateTime.now(),
    );
  }

  Future<void> _learnFromIntegratedInteraction({
    required String userId,
    required String conversationId,
    required NeuralTranslationResult neuralResult,
    required PersonalizedTranslationResult personalityResult,
    required String originalText,
    required String targetLanguage,
  }) async {
    try {
      // Learn from predictive service
      await _predictiveService.learnFromInteraction(
        userId: userId,
        originalText: originalText,
        translatedText: personalityResult.translatedText,
        sourceLanguage: neuralResult.sourceLanguage,
        targetLanguage: targetLanguage,
        conversationId: conversationId,
        wasAccepted:
            true, // Assume accepted for now - would get from user feedback
      );

      // Update context mapping with learned insights
      final mapping = _contextMappings[conversationId] ??
          PersonalityContextMapping(
            conversationId: conversationId,
            userId: userId,
            personalityAlignment: {},
            contextFactors: {},
            lastUpdated: DateTime.now(),
          );

      // Update personality alignment based on successful integration
      final alignmentKey =
          '${neuralResult.conversationContext.currentState.phase.name}_${personalityResult.personalityProfile.primaryType.name}';
      mapping.personalityAlignment[alignmentKey] =
          (mapping.personalityAlignment[alignmentKey] ?? 0.5) + 0.1;
      mapping.lastUpdated = DateTime.now();

      _contextMappings[conversationId] = mapping;

      _logger.d('Learned from integrated interaction: $userId');
    } catch (e) {
      _logger.e('Learning from integrated interaction failed: $e');
    }
  }

  // ===== UTILITY METHODS =====

  double _calculateIntegratedConfidence(
    NeuralTranslationResult neuralResult,
    PersonalizedTranslationResult personalityResult,
  ) {
    // Combine confidence scores from both systems
    final neuralConfidence = neuralResult.confidence;
    final personalityConfidence = personalityResult.confidence;

    // Weighted average favoring neural context slightly
    return (neuralConfidence * 0.6 + personalityConfidence * 0.4);
  }

  String _generateCacheKey(
      String userId, String conversationId, String text, String targetLang) {
    return '$userId:$conversationId:${text.hashCode}:$targetLang';
  }

  void _cleanIntegrationCache() {
    if (_integrationCache.length > 500) {
      final keysToRemove = _integrationCache.keys.take(100).toList();
      for (final key in keysToRemove) {
        _integrationCache.remove(key);
      }
    }
  }

  List<SmartSuggestion> _convertToSmartSuggestions(
    List<TranslationSuggestion> suggestions,
    SuggestionSource source,
  ) {
    return suggestions
        .map((s) => SmartSuggestion(
              text: s.suggestedTranslation,
              sourcePhrase: s.sourcePhrase,
              confidence: s.relevanceScore,
              reasoning: s.reasoning,
              source: source,
              contextFactors: s.contextFactors,
              isProactive: s.isProactive,
            ))
        .toList();
  }

  List<SmartSuggestion> _convertPersonalitySuggestions(
    List<CommunicationSuggestion> suggestions,
    SuggestionSource source,
  ) {
    return suggestions
        .map((s) => SmartSuggestion(
              text: s.title,
              sourcePhrase: s.description,
              confidence: s.priority,
              reasoning: s.description,
              source: source,
              contextFactors: s.actionData ?? {},
              isProactive: true,
            ))
        .toList();
  }

  List<SmartSuggestion> _convertPredictiveSuggestions(
    List<PredictivePhrase> suggestions,
    SuggestionSource source,
  ) {
    return suggestions
        .map((s) => SmartSuggestion(
              text: s.phrase,
              sourcePhrase: s.phrase,
              confidence: s.confidence,
              reasoning: s.usage,
              source: source,
              contextFactors: {'category': s.category.name},
              isProactive: true,
            ))
        .toList();
  }

  Future<List<SmartSuggestion>> _rankSmartSuggestions(
    List<SmartSuggestion> suggestions,
    String userId,
  ) async {
    // Rank suggestions by confidence, source reliability, and user preferences
    suggestions.sort((a, b) {
      double aScore = a.confidence;
      double bScore = b.confidence;

      // Boost neural suggestions slightly as they have context
      if (a.source == SuggestionSource.neural) aScore += 0.1;
      if (b.source == SuggestionSource.neural) bScore += 0.1;

      // Boost personality suggestions for personalization
      if (a.source == SuggestionSource.personality) aScore += 0.05;
      if (b.source == SuggestionSource.personality) bScore += 0.05;

      return bScore.compareTo(aScore);
    });

    return suggestions;
  }

  // ===== ANALYSIS HELPER METHODS =====

  Future<String> _analyzeContextPersonalityInfluence(
    NeuralConversationContext context,
    UserPersonalityProfile profile,
  ) async {
    final influences = <String>[];

    if (context.currentState.phase == ConversationPhase.opening &&
        profile.personalityTraits.enthusiasm > 0.7) {
      influences.add('High enthusiasm enhanced greeting warmth');
    }

    if (context.emotionalFlow.overallMood == ConversationMood.professional &&
        profile.primaryType == PersonalityType.professional) {
      influences.add('Professional personality aligned with conversation tone');
    }

    return influences.isEmpty
        ? 'Minimal context influence detected'
        : influences.join('. ');
  }

  Future<List<String>> _generateCommunicationRecommendations({
    required NeuralTranslationResult neuralResult,
    required PersonalizedTranslationResult personalityResult,
    required UserPersonalityProfile personalityProfile,
  }) async {
    final recommendations = <String>[];

    // Low confidence recommendations
    if (neuralResult.confidence < 0.7) {
      recommendations
          .add('Consider providing more context for better accuracy');
    }

    // Personality-context mismatch recommendations
    final contextMood =
        neuralResult.conversationContext.emotionalFlow.overallMood;
    if (contextMood == ConversationMood.professional &&
        personalityProfile.primaryType != PersonalityType.professional) {
      recommendations
          .add('Consider adjusting tone for more professional context');
    }

    return recommendations;
  }

  String _mergeCulturalInsights(
    Map<String, dynamic> neuralInsights,
    String personalityInsights,
  ) {
    final combined = <String>[];

    if (neuralInsights.containsKey('cultural_markers')) {
      combined.add('Neural: ${neuralInsights['cultural_markers']}');
    }

    if (personalityInsights.isNotEmpty) {
      combined.add('Personality: $personalityInsights');
    }

    return combined.isEmpty
        ? 'No specific cultural considerations'
        : combined.join('. ');
  }

  Future<Map<String, dynamic>> _analyzeConfidenceFactors(
    NeuralTranslationResult neuralResult,
    PersonalizedTranslationResult personalityResult,
  ) async {
    return {
      'neural_confidence': neuralResult.confidence,
      'personality_confidence': personalityResult.confidence,
      'context_clarity':
          neuralResult.conversationContext.currentState.coherence,
      'emotional_stability':
          neuralResult.conversationContext.emotionalFlow.emotionalVolatility,
      'personality_match':
          personalityResult.personalityProfile.learningModel.adaptationLevel,
    };
  }

  List<String> _identifyImprovementOpportunities(
    NeuralTranslationResult neuralResult,
    PersonalizedTranslationResult personalityResult,
  ) {
    final opportunities = <String>[];

    if (neuralResult.confidence < personalityResult.confidence) {
      opportunities.add('Neural context understanding can be improved');
    } else if (personalityResult.confidence < neuralResult.confidence) {
      opportunities.add('Personality adaptation could be enhanced');
    }

    if (neuralResult.conversationContext.currentState.engagement < 0.7) {
      opportunities.add('Conversation engagement could be increased');
    }

    return opportunities.isEmpty
        ? ['No immediate improvements identified']
        : opportunities;
  }

  List<String> _generateAlignmentRecommendations(
      Map<String, double> alignment) {
    final recommendations = <String>[];

    alignment.forEach((factor, score) {
      if (score < 0.6) {
        switch (factor) {
          case 'mood_personality':
            recommendations.add(
                'Consider adjusting personality expression to better match conversation mood');
            break;
          case 'communication_style':
            recommendations.add(
                'Communication style could be better aligned with context');
            break;
        }
      }
    });

    return recommendations.isEmpty
        ? ['Good alignment detected']
        : recommendations;
  }

  Future<List<IntegratedRecommendation>> _generateIntegratedRecommendations({
    required ConversationMetrics neuralMetrics,
    required UserPersonalityProfile personalityProfile,
    required PredictionAnalytics predictiveAnalytics,
    required PersonalityContextAlignment alignmentAnalysis,
  }) async {
    final recommendations = <IntegratedRecommendation>[];

    // Neural-based recommendations
    if (neuralMetrics.coherenceScore < 0.7) {
      recommendations.add(IntegratedRecommendation(
        type: RecommendationType.contextImprovement,
        title: 'Improve Conversation Coherence',
        description: 'Provide more context to maintain conversation flow',
        priority: RecommendationPriority.medium,
        expectedImpact: 'Better context understanding and translation accuracy',
      ));
    }

    // Personality-based recommendations
    if (personalityProfile.learningModel.adaptationLevel < 0.5) {
      recommendations.add(IntegratedRecommendation(
        type: RecommendationType.personalityTuning,
        title: 'Personality Adaptation Training',
        description:
            'Continue using the app to improve personality-based translations',
        priority: RecommendationPriority.low,
        expectedImpact: 'More personalized and natural translations',
      ));
    }

    // Predictive-based recommendations
    if (predictiveAnalytics.overallAccuracy < 0.7) {
      recommendations.add(IntegratedRecommendation(
        type: RecommendationType.predictionImprovement,
        title: 'Enhance Predictive Accuracy',
        description: 'Provide feedback on suggestions to improve predictions',
        priority: RecommendationPriority.high,
        expectedImpact: 'Better auto-complete and proactive suggestions',
      ));
    }

    return recommendations;
  }

  double _calculateOverallScore(
    ConversationMetrics neuralMetrics,
    UserPersonalityProfile personalityProfile,
    PredictionAnalytics predictiveAnalytics,
  ) {
    final neuralScore = neuralMetrics.overallScore;
    final personalityScore = personalityProfile.maturityLevel;
    final predictiveScore = predictiveAnalytics.overallAccuracy;

    return (neuralScore + personalityScore + predictiveScore) / 3;
  }
}

// ===== INTEGRATION DATA MODELS =====

/// Comprehensive result combining neural and personality analysis
class IntegratedTranslationResult {
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final double confidence;
  final NeuralTranslationResult neuralResult;
  final PersonalizedTranslationResult personalityResult;
  final List<TranslationSuggestion> predictiveSuggestions;
  final AvatarAnimation avatarAnimation;
  final IntegratedInsights integratedInsights;
  final DateTime timestamp;

  const IntegratedTranslationResult({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.confidence,
    required this.neuralResult,
    required this.personalityResult,
    required this.predictiveSuggestions,
    required this.avatarAnimation,
    required this.integratedInsights,
    required this.timestamp,
  });
}

/// Advanced insights combining all AI systems
class IntegratedInsights {
  final String neuralContextInfluence;
  final String personalityAdaptations;
  final String culturalConsiderations;
  final List<String> communicationRecommendations;
  final Map<String, dynamic> confidenceFactors;
  final List<String> improvementOpportunities;

  const IntegratedInsights({
    required this.neuralContextInfluence,
    required this.personalityAdaptations,
    required this.culturalConsiderations,
    required this.communicationRecommendations,
    required this.confidenceFactors,
    required this.improvementOpportunities,
  });
}

/// Analytics combining neural, personality, and predictive insights
class IntegratedConversationAnalytics {
  final String userId;
  final String conversationId;
  final ConversationMetrics neuralMetrics;
  final UserPersonalityProfile personalityProfile;
  final PredictionAnalytics predictiveAnalytics;
  final PersonalityContextAlignment alignmentAnalysis;
  final List<IntegratedRecommendation> recommendations;
  final double overallScore;
  final DateTime generatedAt;

  const IntegratedConversationAnalytics({
    required this.userId,
    required this.conversationId,
    required this.neuralMetrics,
    required this.personalityProfile,
    required this.predictiveAnalytics,
    required this.alignmentAnalysis,
    required this.recommendations,
    required this.overallScore,
    required this.generatedAt,
  });
}

/// Analysis of personality-context alignment
class PersonalityContextAlignment {
  final double overallScore;
  final Map<String, double> alignmentFactors;
  final List<String> recommendations;
  final DateTime lastAnalyzed;

  const PersonalityContextAlignment({
    required this.overallScore,
    required this.alignmentFactors,
    required this.recommendations,
    required this.lastAnalyzed,
  });

  factory PersonalityContextAlignment.defaultAlignment() {
    return PersonalityContextAlignment(
      overallScore: 0.7,
      alignmentFactors: {'default': 0.7},
      recommendations: ['Continue using the app to improve alignment'],
      lastAnalyzed: DateTime.now(),
    );
  }
}

/// Mapping between personality and conversation context
class PersonalityContextMapping {
  final String conversationId;
  final String userId;
  final Map<String, double> personalityAlignment;
  final Map<String, dynamic> contextFactors;
  DateTime lastUpdated;

  PersonalityContextMapping({
    required this.conversationId,
    required this.userId,
    required this.personalityAlignment,
    required this.contextFactors,
    required this.lastUpdated,
  });
}

/// Smart suggestion combining multiple AI sources
class SmartSuggestion {
  final String text;
  final String sourcePhrase;
  final double confidence;
  final String reasoning;
  final SuggestionSource source;
  final Map<String, dynamic> contextFactors;
  final bool isProactive;

  const SmartSuggestion({
    required this.text,
    required this.sourcePhrase,
    required this.confidence,
    required this.reasoning,
    required this.source,
    required this.contextFactors,
    required this.isProactive,
  });
}

/// Integrated recommendation for improvement
class IntegratedRecommendation {
  final RecommendationType type;
  final String title;
  final String description;
  final RecommendationPriority priority;
  final String expectedImpact;

  const IntegratedRecommendation({
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
    required this.expectedImpact,
  });
}

// ===== ENUMS =====

enum SuggestionSource {
  neural,
  personality,
  predictive,
  integrated,
}

enum RecommendationType {
  contextImprovement,
  personalityTuning,
  predictionImprovement,
  culturalAdaptation,
  engagementIncrease,
}

enum RecommendationPriority {
  low,
  medium,
  high,
  critical,
}
