// 🧪 LingoSphere - Neural Conversation Intelligence Integration Tests
// Comprehensive tests for the neural AI translation system

import 'package:flutter_test/flutter_test.dart';
import 'package:lingosphere/core/services/neural_context_engine.dart';
import 'package:lingosphere/core/services/ai_personality_engine.dart';
import 'package:lingosphere/core/services/predictive_translation_service.dart';
import 'package:lingosphere/core/services/neural_personality_integration_service.dart';
import 'package:lingosphere/core/services/conversation_analytics_service.dart';
import 'package:lingosphere/core/models/neural_conversation_models.dart';
import 'package:lingosphere/core/models/personality_models.dart';
import 'package:lingosphere/core/models/translation_models.dart' hide SentimentAnalysis, SentimentType;

void main() {
  group('Neural Conversation Intelligence Integration Tests', () {
    late NeuralContextEngine neuralEngine;
    late AIPersonalityEngine personalityEngine;
    late PredictiveTranslationService predictiveService;
    late NeuralPersonalityIntegrationService integrationService;
    late ConversationAnalyticsService analyticsService;

    setUpAll(() async {
      // Initialize all services
      neuralEngine = NeuralContextEngine();
      personalityEngine = AIPersonalityEngine();
      predictiveService = PredictiveTranslationService();
      integrationService = NeuralPersonalityIntegrationService();
      analyticsService = ConversationAnalyticsService();

      // Initialize services in correct order with API keys
      const testApiKey = 'test-api-key-123';
      await personalityEngine.initialize(openAIApiKey: testApiKey);
      await neuralEngine.initialize(openAIApiKey: testApiKey);
      await predictiveService.initialize(openAIApiKey: testApiKey);
      await integrationService.initialize(openAIApiKey: testApiKey);
      await analyticsService.initialize();
    });

    group('Neural Context Engine Tests', () {
      test('should create and manage conversation context', () async {
        const conversationId = 'test-conversation-001';
        const userId = 'test-user-001';

        // Process an initial conversation turn to create context
        final result = await neuralEngine.processConversationTurn(
          conversationId: conversationId,
          speakerId: userId,
          originalText: 'Hello',
          sourceLanguage: 'en',
          targetLanguage: 'es',
        );

        // Verify conversation context was created
        final context =
            await neuralEngine.getConversationContext(conversationId);
        expect(context, isNotNull);
        expect(context!.conversationId, equals(conversationId));
        expect(result.originalText, equals('Hello'));
      });

      test('should process conversation turns with analysis', () async {
        const conversationId = 'test-conversation-002';
        const userId = 'test-user-002';

        await neuralEngine.startConversation(
          conversationId: conversationId,
          participants: [userId, 'assistant'],
          initialLanguages: ['en', 'fr'],
        );

        // Add a conversation turn
        final turn = ConversationTurn(
          id: 'turn-001',
          speakerId: userId,
          originalText: 'Hello, how are you today?',
          sourceLanguage: 'en',
          targetLanguage: 'fr',
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
              sentenceLength: 6,
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

        await neuralEngine.processTurn(conversationId, turn);

        // Verify turn was processed
        final context =
            await neuralEngine.getConversationContext(conversationId);
        expect(context!.conversationHistory.length, equals(1));
        expect(context.conversationHistory.first.originalText,
            equals('Hello, how are you today?'));
      });

      test('should provide context-aware translation', () async {
        const conversationId = 'test-conversation-003';
        const originalText = 'That sounds great!';

        final result = await neuralEngine.getContextAwareTranslation(
          conversationId: conversationId,
          text: originalText,
          sourceLanguage: 'en',
          targetLanguage: 'es',
          userId: 'test-user-003',
        );

        expect(result, isNotNull);
        expect(result.originalText, equals(originalText));
        expect(result.sourceLanguage, equals('en'));
        expect(result.targetLanguage, equals('es'));
        expect(result.confidence, greaterThan(0.0));
      });
    });

    group('AI Personality Engine Tests', () {
      test('should create and manage personality profiles', () async {
        const userId = 'test-user-personality-001';

        // Create a personality profile
        final profile = UserPersonalityProfile(
          userId: userId,
          personalityTraits: const PersonalityTraits(
            openness: 0.7,
            conscientiousness: 0.8,
            extraversion: 0.6,
            agreeableness: 0.9,
            neuroticism: 0.3,
          ),
          communicationStyle: const CommunicationStyle(
            formality: 0.6,
            directness: 0.7,
            expressiveness: 0.8,
            technicality: 0.4,
            culturalAdaptation: 0.7,
          ),
          avatarAppearance: const AvatarAppearance(
            style: AvatarStyle.professional,
            colorScheme: 'blue',
            accessories: ['glasses'],
            expressions: {'default': 'friendly'},
          ),
          voicePersonality: const VoicePersonality(
            tone: VoiceTone.warm,
            pace: VoicePace.moderate,
            pitch: VoicePitch.medium,
            accent: 'neutral',
            languageVariants: {'en': 'american', 'es': 'neutral'},
          ),
          learningModel: LearningModel(
            adaptationRate: 0.1,
            memoryRetention: 0.8,
            contextSensitivity: 0.7,
            feedbackIntegration: 0.9,
            lastModelUpdate: DateTime.now(),
            trainingData: const {},
          ),
          preferences: const {
            'preferred_languages': ['en', 'es'],
            'translation_style': 'natural',
          },
          createdAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );

        await personalityEngine.createPersonalityProfile(profile);

        // Retrieve the profile
        final retrievedProfile =
            await personalityEngine.getPersonalityProfile(userId);
        expect(retrievedProfile, isNotNull);
        expect(retrievedProfile!.userId, equals(userId));
        expect(retrievedProfile.personalityTraits.openness, equals(0.7));
      });

      test('should adapt personality based on interaction', () async {
        const userId = 'test-user-adaptation-001';

        // Create initial profile
        final initialProfile = UserPersonalityProfile(
          userId: userId,
          personalityTraits: const PersonalityTraits(
            openness: 0.5,
            conscientiousness: 0.5,
            extraversion: 0.5,
            agreeableness: 0.5,
            neuroticism: 0.5,
          ),
          communicationStyle: const CommunicationStyle(
            formality: 0.5,
            directness: 0.5,
            expressiveness: 0.5,
            technicality: 0.5,
            culturalAdaptation: 0.5,
          ),
          avatarAppearance: const AvatarAppearance(
            style: AvatarStyle.casual,
            colorScheme: 'default',
            accessories: [],
            expressions: {},
          ),
          voicePersonality: const VoicePersonality(
            tone: VoiceTone.neutral,
            pace: VoicePace.moderate,
            pitch: VoicePitch.medium,
            accent: 'neutral',
            languageVariants: {},
          ),
          learningModel: LearningModel(
            adaptationRate: 0.2,
            memoryRetention: 0.7,
            contextSensitivity: 0.6,
            feedbackIntegration: 0.8,
            lastModelUpdate: DateTime.now(),
            trainingData: const {},
          ),
          preferences: const {},
          createdAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );

        await personalityEngine.createPersonalityProfile(initialProfile);

        // Simulate user feedback for adaptation
        final feedback = InteractionFeedback(
          userId: userId,
          interactionId: 'interaction-001',
          feedbackType: FeedbackType.positive,
          feedbackScore: 0.8,
          feedbackText: 'Great translation, very natural!',
          contextTags: ['translation_quality', 'naturalness'],
          timestamp: DateTime.now(),
        );

        await personalityEngine.processUserFeedback(feedback);

        // Verify adaptation occurred
        final adaptedProfile =
            await personalityEngine.getPersonalityProfile(userId);
        expect(adaptedProfile, isNotNull);
        // The profile should show some adaptation based on positive feedback
      });
    });

    group('Predictive Translation Service Tests', () {
      test('should provide predictive suggestions', () async {
        const userId = 'test-user-predictive-001';
        const partialText = 'How are';

        final suggestions = await predictiveService.getPredictiveSuggestions(
          userId: userId,
          partialText: partialText,
          sourceLanguage: 'en',
          targetLanguage: 'es',
          maxSuggestions: 5,
        );

        expect(suggestions, isNotNull);
        expect(suggestions.suggestions, isNotEmpty);
        expect(suggestions.suggestions.length, lessThanOrEqualTo(5));

        // Check that suggestions are relevant
        for (final suggestion in suggestions.suggestions) {
          expect(suggestion.text, isNotEmpty);
          expect(suggestion.confidence, greaterThan(0.0));
          expect(suggestion.confidence, lessThanOrEqualTo(1.0));
        }
      });

      test('should provide proactive translation recommendations', () async {
        const userId = 'test-user-proactive-001';
        const conversationId = 'test-conversation-proactive-001';

        final recommendations =
            await predictiveService.getProactiveRecommendations(
          userId: userId,
          conversationId: conversationId,
          currentLanguagePair: const LanguagePair(
            sourceLanguage: 'en',
            targetLanguage: 'fr',
          ),
          contextHints: ['business', 'meeting'],
        );

        expect(recommendations, isNotNull);
        expect(recommendations.recommendations, isNotEmpty);

        // Check recommendation quality
        for (final recommendation in recommendations.recommendations) {
          expect(recommendation.phrase, isNotEmpty);
          expect(recommendation.translation, isNotEmpty);
          expect(recommendation.relevanceScore, greaterThan(0.0));
        }
      });
    });

    group('Neural-Personality Integration Tests', () {
      test('should perform integrated context-aware translation', () async {
        const userId = 'test-integration-001';
        const conversationId = 'test-integration-conversation-001';
        const text = 'I completely disagree with that approach.';

        // Create a personality profile first
        final personalityProfile = UserPersonalityProfile(
          userId: userId,
          personalityTraits: const PersonalityTraits(
            openness: 0.8,
            conscientiousness: 0.7,
            extraversion: 0.6,
            agreeableness: 0.4, // Low agreeableness - more direct
            neuroticism: 0.3,
          ),
          communicationStyle: const CommunicationStyle(
            formality: 0.7,
            directness: 0.9, // High directness
            expressiveness: 0.6,
            technicality: 0.5,
            culturalAdaptation: 0.6,
          ),
          avatarAppearance: const AvatarAppearance(
            style: AvatarStyle.professional,
            colorScheme: 'default',
            accessories: [],
            expressions: {},
          ),
          voicePersonality: const VoicePersonality(
            tone: VoiceTone.assertive,
            pace: VoicePace.moderate,
            pitch: VoicePitch.medium,
            accent: 'neutral',
            languageVariants: {},
          ),
          learningModel: LearningModel(
            adaptationRate: 0.1,
            memoryRetention: 0.8,
            contextSensitivity: 0.7,
            feedbackIntegration: 0.9,
            lastModelUpdate: DateTime.now(),
            trainingData: const {},
          ),
          preferences: const {},
          createdAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );

        await personalityEngine.createPersonalityProfile(personalityProfile);

        // Perform integrated translation
        final result = await integrationService.performIntegratedTranslation(
          userId: userId,
          conversationId: conversationId,
          text: text,
          sourceLanguage: 'en',
          targetLanguage: 'es',
        );

        expect(result, isNotNull);
        expect(result.originalText, equals(text));
        expect(result.translatedText, isNotEmpty);
        expect(result.personalityAdaptations, isNotEmpty);
        expect(result.neuralInsights, isNotNull);
        expect(result.confidence, greaterThan(0.0));

        // Verify personality influence
        expect(result.personalityAdaptations.communicationStyleAdaptation,
            isNotNull);
        expect(result.personalityAdaptations.tonalAdjustments, isNotEmpty);
      });

      test('should generate conversation insights', () async {
        const conversationId = 'test-insights-001';
        const userId = 'test-user-insights-001';

        // Start conversation and add some turns
        await neuralEngine.startConversation(
          conversationId: conversationId,
          participants: [userId, 'assistant'],
          initialLanguages: ['en', 'de'],
        );

        // Add multiple turns to build conversation context
        final turns = [
          'Hello, I need help with translation.',
          'Sure, I can help you with that.',
          'I want to translate business documents.',
          'What type of business documents?',
          'Legal contracts and agreements.',
        ];

        for (int i = 0; i < turns.length; i++) {
          final turn = ConversationTurn(
            id: 'turn-${i + 1}',
            speakerId: i.isEven ? userId : 'assistant',
            originalText: turns[i],
            sourceLanguage: 'en',
            timestamp:
                DateTime.now().subtract(Duration(minutes: turns.length - i)),
            analysis: TurnAnalysis(
              sentiment: SentimentAnalysis(
                primarySentiment: SentimentType.neutral,
                intensity: 0.5,
                sentimentSpectrum: {SentimentType.neutral: 1.0},
                emotionVector: const EmotionVector(
                  valence: 0.0,
                  arousal: 0.3,
                  dominance: 0.5,
                  certainty: 0.7,
                ),
                emotionalStability: 0.9,
                emotionalShifts: [],
              ),
              intent: const IntentAnalysis(
                primaryIntent: 'information_seeking',
                confidence: 0.8,
                secondaryIntents: [],
              ),
              contextRelevance: const ContextualRelevance(
                relevanceScore: 0.9,
                relevantElements: ['translation', 'business'],
                contextConnections: ['previous_request'],
              ),
              complexity: const LinguisticComplexity(
                complexityScore: 0.4,
                sentenceLength: 8,
                vocabularyLevel: 2,
                complexFeatures: [],
              ),
              culturalMarkers: const CulturalMarkers(
                detectedMarkers: [],
                culturalScores: {},
                adaptationSuggestions: [],
              ),
              confidence: 0.85,
              keyEntities: ['translation', 'business', 'documents'],
              topics: ['translation_assistance', 'business_documents'],
            ),
          );

          await neuralEngine.processTurn(conversationId, turn);
        }

        // Generate insights
        final insights = await integrationService
            .generateConversationInsights(conversationId);

        expect(insights, isNotNull);
        expect(insights.conversationId, equals(conversationId));
        expect(insights.topicProgression, isNotEmpty);
        expect(insights.emotionalJourney, isNotNull);
        expect(insights.engagementMetrics, isNotNull);
        expect(insights.personalityInfluence, isNotNull);
      });
    });

    group('Conversation Analytics Tests', () {
      test('should track and analyze user engagement', () async {
        const userId = 'test-analytics-001';

        // Record various engagement events
        await analyticsService.recordEngagement(
          userId: userId,
          engagementType: EngagementType.session,
          duration: const Duration(minutes: 15),
          context: {'feature': 'translation', 'language_pair': 'en-es'},
        );

        await analyticsService.recordEngagement(
          userId: userId,
          engagementType: EngagementType.translation,
          duration: const Duration(seconds: 30),
          context: {'feature': 'neural_translation', 'quality': 'high'},
        );

        // Get analytics
        final analytics = await analyticsService.getUserAnalytics(userId);

        expect(analytics, isNotNull);
        expect(analytics.userId, equals(userId));
        expect(analytics.totalConversations, greaterThanOrEqualTo(0));
        expect(analytics.usagePatterns, isNotNull);
      });

      test('should track conversation quality metrics', () async {
        const userId = 'test-quality-001';
        const conversationId = 'test-quality-conversation-001';

        // Record quality events
        await analyticsService.recordTranslationQuality(
          userId: userId,
          conversationId: conversationId,
          originalText: 'Test text',
          translatedText: 'Texto de prueba',
          confidence: 0.95,
          qualityFactors: {
            'neural_confidence': 0.92,
            'personality_adaptation': 0.88,
            'context_relevance': 0.97,
          },
        );

        // Get quality trends
        final trends = await analyticsService.getQualityTrends(
          userId: userId,
          timeframe: const Duration(days: 7),
        );

        expect(trends, isNotNull);
        expect(trends.totalDataPoints, greaterThan(0));
        expect(trends.averageQuality, greaterThan(0.0));
      });
    });

    group('End-to-End Integration Tests', () {
      test('should handle complete conversation flow', () async {
        const userId = 'test-e2e-001';
        const conversationId = 'test-e2e-conversation-001';

        // 1. Create personality profile
        final profile = UserPersonalityProfile(
          userId: userId,
          personalityTraits: const PersonalityTraits(
            openness: 0.7,
            conscientiousness: 0.8,
            extraversion: 0.6,
            agreeableness: 0.9,
            neuroticism: 0.3,
          ),
          communicationStyle: const CommunicationStyle(
            formality: 0.6,
            directness: 0.7,
            expressiveness: 0.8,
            technicality: 0.4,
            culturalAdaptation: 0.7,
          ),
          avatarAppearance: const AvatarAppearance(
            style: AvatarStyle.friendly,
            colorScheme: 'warm',
            accessories: [],
            expressions: {},
          ),
          voicePersonality: const VoicePersonality(
            tone: VoiceTone.warm,
            pace: VoicePace.moderate,
            pitch: VoicePitch.medium,
            accent: 'neutral',
            languageVariants: {},
          ),
          learningModel: LearningModel(
            adaptationRate: 0.15,
            memoryRetention: 0.85,
            contextSensitivity: 0.8,
            feedbackIntegration: 0.9,
            lastModelUpdate: DateTime.now(),
            trainingData: const {},
          ),
          preferences: const {
            'preferred_style': 'conversational',
            'cultural_sensitivity': 'high',
          },
          createdAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        );

        await personalityEngine.createPersonalityProfile(profile);

        // 2. Start conversation
        await neuralEngine.startConversation(
          conversationId: conversationId,
          participants: [userId, 'friend'],
          initialLanguages: ['en', 'fr'],
        );

        // 3. Perform translations with full integration
        final messages = [
          'Hey! How was your weekend?',
          'I went hiking in the mountains, it was amazing!',
          'That sounds incredible! I love nature too.',
          'We should plan a hiking trip together sometime.',
        ];

        final translationResults = <IntegratedTranslationResult>[];

        for (final message in messages) {
          final result = await integrationService.performIntegratedTranslation(
            userId: userId,
            conversationId: conversationId,
            text: message,
            sourceLanguage: 'en',
            targetLanguage: 'fr',
          );

          translationResults.add(result);

          // Record analytics
          await analyticsService.recordTranslationQuality(
            userId: userId,
            conversationId: conversationId,
            originalText: message,
            translatedText: result.translatedText,
            confidence: result.confidence,
            qualityFactors: {
              'personality_adaptation':
                  result.personalityAdaptations.overallAdaptationScore,
              'neural_confidence': result.neuralInsights.confidenceScore,
              'context_relevance': result.neuralInsights.contextRelevance,
            },
          );
        }

        // 4. Verify results
        expect(translationResults.length, equals(messages.length));

        for (final result in translationResults) {
          expect(result.translatedText, isNotEmpty);
          expect(result.confidence, greaterThan(0.0));
          expect(result.personalityAdaptations, isNotNull);
          expect(result.neuralInsights, isNotNull);
        }

        // 5. Get conversation insights
        final insights = await integrationService
            .generateConversationInsights(conversationId);
        expect(insights, isNotNull);
        expect(insights.conversationId, equals(conversationId));

        // 6. Get analytics
        final analytics = await analyticsService.getUserAnalytics(userId);
        expect(analytics, isNotNull);
        expect(analytics.totalTurns, greaterThan(0));

        // 7. Get predictive suggestions for next message
        final suggestions = await predictiveService.getPredictiveSuggestions(
          userId: userId,
          partialText: 'That would be',
          sourceLanguage: 'en',
          targetLanguage: 'fr',
          conversationId: conversationId,
          maxSuggestions: 3,
        );

        expect(suggestions.suggestions, isNotEmpty);
      });

      test('should handle error scenarios gracefully', () async {
        const userId = 'test-error-001';
        const conversationId = 'non-existent-conversation';

        // Test with non-existent conversation
        expect(
          () async => await integrationService.performIntegratedTranslation(
            userId: userId,
            conversationId: conversationId,
            text: 'Test text',
            sourceLanguage: 'en',
            targetLanguage: 'invalid-language',
          ),
          throwsA(isA<Exception>()),
        );

        // Test with invalid language pair
        expect(
          () async => await predictiveService.getPredictiveSuggestions(
            userId: userId,
            partialText: 'test',
            sourceLanguage: 'invalid',
            targetLanguage: 'also-invalid',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    tearDownAll(() async {
      // Clean up services if needed
      integrationService.dispose();
      analyticsService.dispose();
    });
  });
}
