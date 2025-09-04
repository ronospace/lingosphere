// 🧪 LingoSphere - Basic Neural Intelligence Functionality Test
// Simple tests to verify core neural AI components work

import 'package:flutter_test/flutter_test.dart';
import 'package:lingosphere/core/models/neural_conversation_models.dart';

void main() {
  group('Neural Conversation Models Tests', () {
    test('should create EmotionVector correctly', () {
      const emotionVector = EmotionVector(
        valence: 0.6,
        arousal: 0.4,
        dominance: 0.5,
        certainty: 0.8,
      );

      expect(emotionVector.valence, equals(0.6));
      expect(emotionVector.arousal, equals(0.4));
      expect(emotionVector.dominance, equals(0.5));
      expect(emotionVector.certainty, equals(0.8));
    });

    test('should calculate emotional distance correctly', () {
      const vector1 = EmotionVector(
        valence: 0.6,
        arousal: 0.4,
        dominance: 0.5,
        certainty: 0.8,
      );

      const vector2 = EmotionVector(
        valence: 0.3,
        arousal: 0.6,
        dominance: 0.4,
        certainty: 0.9,
      );

      final distance = vector1.distanceTo(vector2);

      // Distance should be greater than 0 for different vectors
      expect(distance, greaterThan(0.0));

      // Distance to same vector should be 0
      final sameDistance = vector1.distanceTo(vector1);
      expect(sameDistance, equals(0.0));
    });

    test('should create ConversationTurn with analysis', () {
      final turn = ConversationTurn(
        id: 'turn-001',
        speakerId: 'user-123',
        originalText: 'Hello, how are you?',
        sourceLanguage: 'en',
        timestamp: DateTime.now(),
        analysis: TurnAnalysis(
          sentiment: SentimentAnalysis(
            primarySentiment: SentimentType.positive,
            intensity: 0.7,
            sentimentSpectrum: {
              SentimentType.positive: 0.7,
              SentimentType.neutral: 0.3
            },
            emotionVector: const EmotionVector(
              valence: 0.6,
              arousal: 0.4,
              dominance: 0.5,
              certainty: 0.8,
            ),
            emotionalStability: 0.8,
            emotionalShifts: [],
          ),
          intent: const IntentAnalysis(
            primaryIntent: 'greeting',
            confidence: 0.9,
            secondaryIntents: ['inquiry'],
          ),
          contextRelevance: const ContextualRelevance(
            relevanceScore: 0.8,
            relevantElements: ['greeting', 'wellbeing_inquiry'],
            contextConnections: [],
          ),
          complexity: const LinguisticComplexity(
            complexityScore: 0.3,
            sentenceLength: 4,
            vocabularyLevel: 1,
            complexFeatures: [],
          ),
          culturalMarkers: const CulturalMarkers(
            detectedMarkers: ['english_greeting'],
            culturalScores: {'formality': 0.5},
            adaptationSuggestions: [],
          ),
          confidence: 0.85,
          keyEntities: ['greeting'],
          topics: ['greeting', 'wellbeing'],
        ),
      );

      expect(turn.id, equals('turn-001'));
      expect(turn.speakerId, equals('user-123'));
      expect(turn.originalText, equals('Hello, how are you?'));
      expect(turn.sourceLanguage, equals('en'));
      expect(turn.analysis.confidence, equals(0.85));
      expect(turn.analysis.sentiment.primarySentiment,
          equals(SentimentType.positive));
    });

    test('should create NeuralConversationContext correctly', () {
      final now = DateTime.now();

      final context = NeuralConversationContext(
        conversationId: 'conv-123',
        conversationHistory: [],
        currentState: const ConversationState(
          phase: ConversationPhase.opening,
          mode: ConversationMode.casual,
          engagement: 0.7,
          coherence: 0.8,
          turnsUntilResolution: 5,
          activeTopics: ['greeting'],
        ),
        emotionalFlow: const EmotionalContext(
          emotionalTrajectory: [],
          currentEmotion: EmotionVector(
            valence: 0.5,
            arousal: 0.5,
            dominance: 0.5,
            certainty: 0.5,
          ),
          dominantEmotion: EmotionVector(
            valence: 0.5,
            arousal: 0.5,
            dominance: 0.5,
            certainty: 0.5,
          ),
          emotionalVolatility: 0.3,
          milestones: [],
          overallMood: ConversationMood.friendly,
        ),
        topicEvolution: const TopicContext(
          currentTopics: ['greeting'],
          topicHistory: [],
          topicImportance: {'greeting': 1.0},
          predictedTopics: [],
        ),
        participants: const ParticipantAnalysis(
          participants: {},
          dynamics: InteractionDynamics(
            collaborationScore: 0.8,
            dominanceBalance: 0.5,
            participationLevels: {},
            communicationPatterns: [],
          ),
          patterns: CommunicationPatterns(
            turnTakingPatterns: {},
            averageResponseTime: 2.5,
            commonPhrases: [],
            styleConsistency: {},
          ),
          languageProficiencies: LanguageProficiency(
            proficiencies: {},
            confidenceScores: {},
            improvementAreas: [],
          ),
        ),
        metrics: const ConversationMetrics(
          coherenceScore: 0.8,
          engagementScore: 0.7,
          translationQuality: 0.85,
          culturalAdaptation: 0.7,
          totalTurns: 0,
          avgResponseTime: Duration(seconds: 3),
          languageDistribution: {},
          qualityBreakdown: [],
        ),
        predictions: PredictiveInsights(
          nextTurnPredictions: [],
          topicPredictions: [],
          proactiveSuggestions: [],
          predictedOutcome: const ConversationOutcome(
            predictedType: OutcomeType.ongoingDiscussion,
            confidence: 0.6,
            reasoningFactors: [],
          ),
          predictionConfidence: 0.7,
          generatedAt: now,
        ),
        createdAt: now,
        lastUpdated: now,
      );

      expect(context.conversationId, equals('conv-123'));
      expect(context.conversationLength, equals(0));
      expect(context.currentState.engagement, equals(0.7));
      expect(
          context.emotionalFlow.overallMood, equals(ConversationMood.friendly));
      expect(context.metrics.coherenceScore, equals(0.8));
    });

    test('should calculate conversation duration correctly', () {
      final now = DateTime.now();
      final earlier = now.subtract(const Duration(minutes: 30));

      final turn1 = ConversationTurn(
        id: 'turn-001',
        speakerId: 'user-123',
        originalText: 'Hello',
        sourceLanguage: 'en',
        timestamp: earlier,
        analysis: TurnAnalysis(
          sentiment: SentimentAnalysis(
            primarySentiment: SentimentType.neutral,
            intensity: 0.5,
            sentimentSpectrum: {SentimentType.neutral: 1.0},
            emotionVector: const EmotionVector(
                valence: 0, arousal: 0, dominance: 0, certainty: 0),
            emotionalStability: 0.5,
            emotionalShifts: [],
          ),
          intent: const IntentAnalysis(
              primaryIntent: 'greeting', confidence: 0.8, secondaryIntents: []),
          contextRelevance: const ContextualRelevance(
              relevanceScore: 0.8,
              relevantElements: [],
              contextConnections: []),
          complexity: const LinguisticComplexity(
              complexityScore: 0.3,
              sentenceLength: 1,
              vocabularyLevel: 1,
              complexFeatures: []),
          culturalMarkers: const CulturalMarkers(
              detectedMarkers: [],
              culturalScores: {},
              adaptationSuggestions: []),
          confidence: 0.8,
          keyEntities: [],
          topics: [],
        ),
      );

      final turn2 = ConversationTurn(
        id: 'turn-002',
        speakerId: 'assistant',
        originalText: 'Hi there!',
        sourceLanguage: 'en',
        timestamp: now,
        analysis: TurnAnalysis(
          sentiment: SentimentAnalysis(
            primarySentiment: SentimentType.positive,
            intensity: 0.7,
            sentimentSpectrum: {SentimentType.positive: 1.0},
            emotionVector: const EmotionVector(
                valence: 0.7, arousal: 0.6, dominance: 0.5, certainty: 0.8),
            emotionalStability: 0.8,
            emotionalShifts: [],
          ),
          intent: const IntentAnalysis(
              primaryIntent: 'greeting_response',
              confidence: 0.9,
              secondaryIntents: []),
          contextRelevance: const ContextualRelevance(
              relevanceScore: 0.9,
              relevantElements: [],
              contextConnections: []),
          complexity: const LinguisticComplexity(
              complexityScore: 0.2,
              sentenceLength: 2,
              vocabularyLevel: 1,
              complexFeatures: []),
          culturalMarkers: const CulturalMarkers(
              detectedMarkers: [],
              culturalScores: {},
              adaptationSuggestions: []),
          confidence: 0.9,
          keyEntities: [],
          topics: [],
        ),
      );

      final context = NeuralConversationContext(
        conversationId: 'conv-duration-test',
        conversationHistory: [turn1, turn2],
        currentState: const ConversationState(
          phase: ConversationPhase.building,
          mode: ConversationMode.casual,
          engagement: 0.8,
          coherence: 0.9,
          turnsUntilResolution: 3,
          activeTopics: ['greeting'],
        ),
        emotionalFlow: const EmotionalContext(
          emotionalTrajectory: [],
          currentEmotion: EmotionVector(
              valence: 0.7, arousal: 0.6, dominance: 0.5, certainty: 0.8),
          dominantEmotion: EmotionVector(
              valence: 0.7, arousal: 0.6, dominance: 0.5, certainty: 0.8),
          emotionalVolatility: 0.2,
          milestones: [],
          overallMood: ConversationMood.friendly,
        ),
        topicEvolution: const TopicContext(
          currentTopics: ['greeting'],
          topicHistory: [],
          topicImportance: {'greeting': 1.0},
          predictedTopics: [],
        ),
        participants: const ParticipantAnalysis(
          participants: {},
          dynamics: InteractionDynamics(
            collaborationScore: 0.9,
            dominanceBalance: 0.5,
            participationLevels: {},
            communicationPatterns: [],
          ),
          patterns: CommunicationPatterns(
            turnTakingPatterns: {},
            averageResponseTime: 1.5,
            commonPhrases: [],
            styleConsistency: {},
          ),
          languageProficiencies: LanguageProficiency(
            proficiencies: {},
            confidenceScores: {},
            improvementAreas: [],
          ),
        ),
        metrics: const ConversationMetrics(
          coherenceScore: 0.9,
          engagementScore: 0.8,
          translationQuality: 0.9,
          culturalAdaptation: 0.8,
          totalTurns: 2,
          avgResponseTime: Duration(seconds: 2),
          languageDistribution: {'en': 2},
          qualityBreakdown: [],
        ),
        predictions: PredictiveInsights(
          nextTurnPredictions: [],
          topicPredictions: [],
          proactiveSuggestions: [],
          predictedOutcome: const ConversationOutcome(
            predictedType: OutcomeType.ongoingDiscussion,
            confidence: 0.8,
            reasoningFactors: [],
          ),
          predictionConfidence: 0.8,
          generatedAt: now,
        ),
        createdAt: earlier,
        lastUpdated: now,
      );

      final duration = context.conversationDuration;
      expect(duration.inMinutes, equals(30));
      expect(context.conversationLength, equals(2));
      expect(context.isActive,
          isTrue); // Should be active since last activity was recent
    });

    test('should handle JSON serialization correctly', () {
      const emotionVector = EmotionVector(
        valence: 0.6,
        arousal: 0.4,
        dominance: 0.5,
        certainty: 0.8,
      );

      // Test toJson
      final json = emotionVector.toJson();
      expect(json['valence'], equals(0.6));
      expect(json['arousal'], equals(0.4));
      expect(json['dominance'], equals(0.5));
      expect(json['certainty'], equals(0.8));

      // Test fromJson
      final recreatedVector = EmotionVector.fromJson(json);
      expect(recreatedVector.valence, equals(emotionVector.valence));
      expect(recreatedVector.arousal, equals(emotionVector.arousal));
      expect(recreatedVector.dominance, equals(emotionVector.dominance));
      expect(recreatedVector.certainty, equals(emotionVector.certainty));
    });

    test('should properly calculate conversation metrics overall score', () {
      const metrics = ConversationMetrics(
        coherenceScore: 0.8,
        engagementScore: 0.9,
        translationQuality: 0.85,
        culturalAdaptation: 0.75,
        totalTurns: 5,
        avgResponseTime: Duration(seconds: 2),
        languageDistribution: {'en': 3, 'es': 2},
        qualityBreakdown: [],
      );

      final overallScore = metrics.overallScore;
      final expectedScore = (0.8 + 0.9 + 0.85 + 0.75) / 4;

      expect(overallScore, closeTo(expectedScore, 0.001));
      expect(overallScore, closeTo(0.825, 0.001));
    });
  });
}
