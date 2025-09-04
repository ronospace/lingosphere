// 🔮 LingoSphere - Predictive Translation Service
// ML-powered predictive suggestions, smart auto-complete, and proactive translation recommendations

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../models/neural_conversation_models.dart';
import 'neural_context_engine.dart';

/// Predictive Translation Service
/// Provides ML-powered predictions, auto-complete, and proactive translation suggestions
class PredictiveTranslationService {
  static final PredictiveTranslationService _instance =
      PredictiveTranslationService._internal();
  factory PredictiveTranslationService() => _instance;
  PredictiveTranslationService._internal();

  final Dio _dio = Dio();
  final Logger _logger = Logger();
  final NeuralContextEngine _neuralEngine = NeuralContextEngine();

  // Prediction caches for performance
  final Map<String, List<PredictivePhrase>> _phraseCache = {};
  final Map<String, List<AutoCompleteResult>> _autoCompleteCache = {};
  final Map<String, PredictionModel> _userPredictionModels = {};

  // Learning data for prediction improvement
  final Map<String, List<PredictionInteraction>> _interactionHistory = {};
  final Map<String, UserUsagePattern> _usagePatterns = {};

  /// Initialize the predictive translation service
  Future<void> initialize({
    required String openAIApiKey,
    Map<String, dynamic>? predictionConfig,
  }) async {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 3),
      headers: {
        'Authorization': 'Bearer $openAIApiKey',
        'Content-Type': 'application/json',
        'User-Agent': 'LingoSphere-Predictive/2.0',
      },
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.d('Predictive API Request: ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d('Predictive API Response: ${response.statusCode}');
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('Predictive API Error: ${error.message}');
          handler.next(error);
        },
      ),
    );

    _logger.i('Predictive Translation Service initialized');
  }

  /// Get smart auto-complete suggestions as user types
  Future<List<AutoCompleteResult>> getAutoCompleteSuggestions({
    required String userId,
    required String partialText,
    required String sourceLanguage,
    required String targetLanguage,
    String? conversationId,
    int maxSuggestions = 5,
  }) async {
    try {
      // Check cache first for performance
      final cacheKey = '$userId:$partialText:$sourceLanguage:$targetLanguage';
      if (_autoCompleteCache.containsKey(cacheKey)) {
        return _autoCompleteCache[cacheKey]!.take(maxSuggestions).toList();
      }

      // Get user's prediction model and usage patterns
      final predictionModel = await _getUserPredictionModel(userId);
      final usagePattern = await _getUserUsagePattern(userId);

      // Get conversation context if available
      NeuralConversationContext? conversationContext;
      if (conversationId != null) {
        conversationContext =
            await _neuralEngine.getConversationContext(conversationId);
      }

      // Generate context-aware auto-complete suggestions
      final suggestions = await _generateAutoCompleteSuggestions(
        partialText: partialText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        predictionModel: predictionModel,
        usagePattern: usagePattern,
        conversationContext: conversationContext,
      );

      // Cache results for performance
      _autoCompleteCache[cacheKey] = suggestions;

      // Clean cache periodically (keep only recent entries)
      _cleanAutoCompleteCache();

      return suggestions.take(maxSuggestions).toList();
    } catch (e) {
      _logger.e('Auto-complete generation failed: $e');
      return [];
    }
  }

  /// Get proactive translation suggestions before user requests them
  Future<List<TranslationSuggestion>> getProactiveTranslationSuggestions({
    required String userId,
    required String conversationId,
    String? targetLanguage,
    int maxSuggestions = 3,
  }) async {
    try {
      // Get conversation context and predictions
      final conversationContext =
          await _neuralEngine.getConversationContext(conversationId);
      if (conversationContext == null) return [];

      // Analyze conversation flow and predict likely next translations
      final predictions =
          await _analyzeConversationFlow(conversationContext, userId);

      // Generate proactive suggestions based on predictions
      final suggestions = await _generateProactiveSuggestions(
        conversationContext: conversationContext,
        predictions: predictions,
        targetLanguage: targetLanguage,
        userId: userId,
      );

      // Filter and rank suggestions
      final rankedSuggestions = await _rankProactiveSuggestions(
        suggestions,
        conversationContext,
        userId,
      );

      return rankedSuggestions.take(maxSuggestions).toList();
    } catch (e) {
      _logger.e('Proactive suggestions generation failed: $e');
      return [];
    }
  }

  /// Get predictive phrases based on user's conversation patterns
  Future<List<PredictivePhrase>> getPredictivePhrases({
    required String userId,
    required String sourceLanguage,
    required String targetLanguage,
    String? conversationContext,
    int maxPhrases = 10,
  }) async {
    try {
      final cacheKey =
          '$userId:$sourceLanguage:$targetLanguage:${conversationContext ?? "general"}';

      // Check cache first
      if (_phraseCache.containsKey(cacheKey)) {
        return _phraseCache[cacheKey]!.take(maxPhrases).toList();
      }

      // Get user's usage patterns and prediction model
      final usagePattern = await _getUserUsagePattern(userId);
      final predictionModel = await _getUserPredictionModel(userId);

      // Generate predictive phrases based on patterns
      final phrases = await _generatePredictivePhrases(
        userId: userId,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        context: conversationContext,
        usagePattern: usagePattern,
        predictionModel: predictionModel,
      );

      // Cache results
      _phraseCache[cacheKey] = phrases;

      return phrases.take(maxPhrases).toList();
    } catch (e) {
      _logger.e('Predictive phrases generation failed: $e');
      return [];
    }
  }

  /// Learn from user interactions to improve predictions
  Future<void> learnFromInteraction({
    required String userId,
    required String originalText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
    String? conversationId,
    bool wasAccepted = true,
    double? userRating,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Record the interaction
      final interaction = PredictionInteraction(
        userId: userId,
        originalText: originalText,
        translatedText: translatedText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        conversationId: conversationId,
        wasAccepted: wasAccepted,
        userRating: userRating,
        timestamp: DateTime.now(),
        metadata: metadata ?? {},
      );

      // Add to interaction history
      _interactionHistory.putIfAbsent(userId, () => []);
      _interactionHistory[userId]!.add(interaction);

      // Keep only recent interactions (last 1000 per user)
      if (_interactionHistory[userId]!.length > 1000) {
        _interactionHistory[userId]!.removeAt(0);
      }

      // Update user's prediction model and usage patterns
      await _updatePredictionModel(userId, interaction);
      await _updateUsagePattern(userId, interaction);

      // Clear relevant caches to reflect learning
      _clearUserCaches(userId);

      _logger.d('Learned from interaction for user: $userId');
    } catch (e) {
      _logger.e('Learning from interaction failed: $e');
    }
  }

  /// Get prediction accuracy analytics for a user
  Future<PredictionAnalytics> getPredictionAnalytics(String userId) async {
    final interactions = _interactionHistory[userId] ?? [];
    if (interactions.isEmpty) {
      return PredictionAnalytics.empty(userId);
    }

    final totalInteractions = interactions.length;
    final acceptedInteractions =
        interactions.where((i) => i.wasAccepted).length;
    final accuracy = acceptedInteractions / totalInteractions;

    final languagePairAccuracy = <String, double>{};
    final recentPerformance = <DateTime, double>{};

    // Calculate accuracy by language pair
    final languagePairs = interactions
        .map((i) => '${i.sourceLanguage}-${i.targetLanguage}')
        .toSet();

    for (final pair in languagePairs) {
      final pairInteractions = interactions
          .where((i) => '${i.sourceLanguage}-${i.targetLanguage}' == pair);
      final pairAccepted = pairInteractions.where((i) => i.wasAccepted).length;
      languagePairAccuracy[pair] = pairAccepted / pairInteractions.length;
    }

    // Calculate recent performance (last 7 days)
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayInteractions = interactions
          .where((interaction) =>
              interaction.timestamp.isAfter(dayStart) &&
              interaction.timestamp.isBefore(dayEnd))
          .toList();

      if (dayInteractions.isNotEmpty) {
        final dayAccepted = dayInteractions.where((i) => i.wasAccepted).length;
        recentPerformance[dayStart] = dayAccepted / dayInteractions.length;
      }
    }

    return PredictionAnalytics(
      userId: userId,
      totalPredictions: totalInteractions,
      acceptedPredictions: acceptedInteractions,
      overallAccuracy: accuracy,
      languagePairAccuracy: languagePairAccuracy,
      recentPerformance: recentPerformance,
      averageRating: _calculateAverageRating(interactions),
      topPhrases: await _getTopPredictedPhrases(userId),
      improvementSuggestions: _generateImprovementSuggestions(interactions),
      generatedAt: DateTime.now(),
    );
  }

  // ===== PRIVATE HELPER METHODS =====

  Future<List<AutoCompleteResult>> _generateAutoCompleteSuggestions({
    required String partialText,
    required String sourceLanguage,
    required String targetLanguage,
    required PredictionModel predictionModel,
    required UserUsagePattern usagePattern,
    NeuralConversationContext? conversationContext,
  }) async {
    final suggestions = <AutoCompleteResult>[];

    // 1. Pattern-based suggestions from user's history
    final patternSuggestions = await _generatePatternBasedSuggestions(
      partialText,
      sourceLanguage,
      predictionModel,
    );
    suggestions.addAll(patternSuggestions);

    // 2. Context-aware suggestions from conversation
    if (conversationContext != null) {
      final contextSuggestions = await _generateContextBasedSuggestions(
        partialText,
        sourceLanguage,
        targetLanguage,
        conversationContext,
      );
      suggestions.addAll(contextSuggestions);
    }

    // 3. AI-powered completion using GPT
    final aiSuggestions = await _generateAIBasedSuggestions(
      partialText,
      sourceLanguage,
      targetLanguage,
      conversationContext,
    );
    suggestions.addAll(aiSuggestions);

    // Rank and deduplicate suggestions
    return _rankAndDeduplicateAutoComplete(suggestions, usagePattern);
  }

  Future<List<AutoCompleteResult>> _generatePatternBasedSuggestions(
    String partialText,
    String sourceLanguage,
    PredictionModel predictionModel,
  ) async {
    final suggestions = <AutoCompleteResult>[];
    final lowerPartial = partialText.toLowerCase();

    // Look for patterns in user's prediction model
    for (final phrase in predictionModel.commonPhrases) {
      if (phrase.text.toLowerCase().startsWith(lowerPartial) &&
          phrase.language == sourceLanguage) {
        suggestions.add(AutoCompleteResult(
          completedText: phrase.text,
          confidence: phrase.frequency * 0.8, // Pattern-based confidence
          suggestionType: AutoCompleteSuggestionType.pattern,
          reasoning: 'Based on your usage patterns',
          metadata: {
            'frequency': phrase.frequency,
            'pattern_type': 'user_history'
          },
        ));
      }
    }

    return suggestions;
  }

  Future<List<AutoCompleteResult>> _generateContextBasedSuggestions(
    String partialText,
    String sourceLanguage,
    String targetLanguage,
    NeuralConversationContext conversationContext,
  ) async {
    final suggestions = <AutoCompleteResult>[];

    // Analyze conversation topics and suggest contextually relevant completions
    final currentTopics = conversationContext.topicEvolution.currentTopics;
    final recentTurns = conversationContext.conversationHistory.take(3);

    // Simple context-based completion (in production, use more sophisticated NLP)
    final contextKeywords = <String>[];
    for (final topic in currentTopics) {
      contextKeywords.add(topic);
    }

    for (final turn in recentTurns) {
      final words = turn.originalText.split(' ');
      contextKeywords.addAll(words.where((w) => w.length > 4));
    }

    // Generate contextually relevant completions
    final topicBasedCompletions = _generateTopicBasedCompletions(
      partialText,
      contextKeywords,
      sourceLanguage,
    );

    suggestions.addAll(topicBasedCompletions);

    return suggestions;
  }

  List<AutoCompleteResult> _generateTopicBasedCompletions(
    String partialText,
    List<String> contextKeywords,
    String sourceLanguage,
  ) {
    // Simplified topic-based completion - in production use more advanced NLP
    final suggestions = <AutoCompleteResult>[];

    // Common completions by topic
    final topicCompletions = <String, List<String>>{
      'business': [
        'meeting',
        'presentation',
        'proposal',
        'deadline',
        'project'
      ],
      'travel': ['flight', 'hotel', 'reservation', 'passport', 'luggage'],
      'food': ['restaurant', 'delicious', 'hungry', 'recipe', 'ingredients'],
      'technology': [
        'computer',
        'software',
        'internet',
        'application',
        'digital'
      ],
    };

    for (final keyword in contextKeywords) {
      for (final topic in topicCompletions.keys) {
        if (keyword.toLowerCase().contains(topic)) {
          for (final completion in topicCompletions[topic]!) {
            if (completion.startsWith(partialText.toLowerCase())) {
              suggestions.add(AutoCompleteResult(
                completedText: completion,
                confidence: 0.7,
                suggestionType: AutoCompleteSuggestionType.contextual,
                reasoning: 'Contextually relevant to current topic: $topic',
                metadata: {'topic': topic, 'keyword': keyword},
              ));
            }
          }
        }
      }
    }

    return suggestions;
  }

  Future<List<AutoCompleteResult>> _generateAIBasedSuggestions(
    String partialText,
    String sourceLanguage,
    String targetLanguage,
    NeuralConversationContext? conversationContext,
  ) async {
    if (partialText.length < 3) return []; // Don't use AI for very short text

    final contextSummary = conversationContext != null
        ? _summarizeConversationForAI(conversationContext)
        : 'General conversation';

    final prompt = '''
Complete the following partial text with 3 most likely completions:

PARTIAL TEXT: "$partialText"
LANGUAGE: $sourceLanguage
CONTEXT: $contextSummary

Provide completions that:
1. Are natural and grammatically correct
2. Fit the conversation context
3. Are commonly used in $sourceLanguage

Format as JSON:
{
  "completions": [
    {
      "text": "completed text here",
      "confidence": 0.9,
      "reasoning": "why this completion makes sense"
    }
  ]
}
''';

    try {
      final response = await _dio.post(
        'https://api.openai.com/v1/chat/completions',
        data: {
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are an expert in natural language completion and prediction.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.5,
          'max_tokens': 400,
        },
      );

      final content = response.data['choices'][0]['message']['content'];
      final data = json.decode(content);

      return (data['completions'] as List<dynamic>)
          .map((completion) => AutoCompleteResult(
                completedText: completion['text'],
                confidence: completion['confidence']?.toDouble() ?? 0.7,
                suggestionType: AutoCompleteSuggestionType.ai,
                reasoning: completion['reasoning'] ?? 'AI-generated completion',
                metadata: {'ai_model': 'gpt-4'},
              ))
          .toList();
    } catch (e) {
      _logger.w('AI-based auto-complete failed: $e');
      return [];
    }
  }

  Future<List<TranslationSuggestion>> _generateProactiveSuggestions({
    required NeuralConversationContext conversationContext,
    required ConversationPredictions predictions,
    String? targetLanguage,
    required String userId,
  }) async {
    final suggestions = <TranslationSuggestion>[];

    // 1. Predict likely next phrases based on conversation flow
    final nextPhrasePredictions = await _predictNextPhrases(
      conversationContext,
      predictions,
      targetLanguage,
    );

    for (final phrase in nextPhrasePredictions) {
      // Generate translation for the predicted text
      final translatedText = await _translatePredictedText(
        phrase.predictedText,
        phrase.predictedLanguage,
        targetLanguage ?? 'auto',
      );
      
      suggestions.add(TranslationSuggestion(
        type: SuggestionType.predictive,
        suggestedTranslation: translatedText,
        sourcePhrase: phrase.predictedText,
        targetLanguage: targetLanguage ?? 'auto',
        relevanceScore: phrase.probability,
        reasoning: 'Predicted based on conversation flow',
        contextFactors: phrase.reasoning,
        isProactive: true,
      ));
    }

    // 2. Suggest common responses based on last message
    if (conversationContext.conversationHistory.isNotEmpty) {
      final lastTurn = conversationContext.conversationHistory.last;
      final commonResponses = await _getCommonResponses(
        lastTurn,
        targetLanguage,
        userId,
      );
      suggestions.addAll(commonResponses);
    }

    // 3. Cultural and contextual suggestions
    final culturalSuggestions = await _generateCulturalSuggestions(
      conversationContext,
      targetLanguage,
    );
    suggestions.addAll(culturalSuggestions);

    return suggestions;
  }

  Future<List<PredictivePhrase>> _generatePredictivePhrases({
    required String userId,
    required String sourceLanguage,
    required String targetLanguage,
    String? context,
    required UserUsagePattern usagePattern,
    required PredictionModel predictionModel,
  }) async {
    final phrases = <PredictivePhrase>[];

    // 1. User's most frequently used phrases
    final frequentPhrases = predictionModel.commonPhrases
        .where((p) => p.language == sourceLanguage)
        .take(5)
        .map((p) => PredictivePhrase(
              phrase: p.text,
              sourceLanguage: sourceLanguage,
              targetLanguage: targetLanguage,
              confidence: p.frequency,
              category: PredictivePhraseCategory.frequent,
              usage: 'You use this phrase often',
            ));
    phrases.addAll(frequentPhrases);

    // 2. Context-specific phrases
    if (context != null) {
      final contextPhrases = await _getContextSpecificPhrases(
        context,
        sourceLanguage,
        targetLanguage,
      );
      phrases.addAll(contextPhrases);
    }

    // 3. Time-based suggestions (e.g., greetings based on time of day)
    final timePhrases = _getTimeBasedPhrases(sourceLanguage, targetLanguage);
    phrases.addAll(timePhrases);

    return phrases;
  }

  // ===== LEARNING AND ANALYTICS METHODS =====

  Future<PredictionModel> _getUserPredictionModel(String userId) async {
    if (_userPredictionModels.containsKey(userId)) {
      return _userPredictionModels[userId]!;
    }

    // Create initial model
    final model = PredictionModel(
      userId: userId,
      commonPhrases: [],
      languagePatterns: {},
      topicPreferences: {},
      accuracy: 0.0,
      lastUpdated: DateTime.now(),
    );

    _userPredictionModels[userId] = model;
    return model;
  }

  Future<UserUsagePattern> _getUserUsagePattern(String userId) async {
    if (_usagePatterns.containsKey(userId)) {
      return _usagePatterns[userId]!;
    }

    // Create initial usage pattern
    final pattern = UserUsagePattern(
      userId: userId,
      preferredLanguages: [],
      commonTranslationPairs: {},
      usageFrequency: {},
      activeHours: [],
      lastAnalyzed: DateTime.now(),
    );

    _usagePatterns[userId] = pattern;
    return pattern;
  }

  Future<void> _updatePredictionModel(
      String userId, PredictionInteraction interaction) async {
    final model = await _getUserPredictionModel(userId);

    // Update common phrases
    final existingPhrase = model.commonPhrases
        .where((p) =>
            p.text == interaction.originalText &&
            p.language == interaction.sourceLanguage)
        .firstOrNull;

    if (existingPhrase != null) {
      existingPhrase.frequency += interaction.wasAccepted ? 1 : 0.5;
    } else if (interaction.wasAccepted) {
      model.commonPhrases.add(CommonPhrase(
        text: interaction.originalText,
        language: interaction.sourceLanguage,
        frequency: 1.0,
        category: _categorizePhrase(interaction.originalText),
      ));
    }

    // Update language patterns
    final languagePair =
        '${interaction.sourceLanguage}-${interaction.targetLanguage}';
    model.languagePatterns[languagePair] =
        (model.languagePatterns[languagePair] ?? 0) + 1;

    // Update accuracy
    final interactions = _interactionHistory[userId] ?? [];
    double newAccuracy = model.accuracy;
    if (interactions.isNotEmpty) {
      final accepted = interactions.where((i) => i.wasAccepted).length;
      newAccuracy = accepted / interactions.length;
    }

    // Replace the model with updated values
    _userPredictionModels[userId] = model.copyWith(
      accuracy: newAccuracy,
      lastUpdated: DateTime.now(),
    );
  }

  Future<void> _updateUsagePattern(
      String userId, PredictionInteraction interaction) async {
    final pattern = await _getUserUsagePattern(userId);

    // Update preferred languages
    final updatedPreferredLanguages = List<String>.from(pattern.preferredLanguages);
    if (!updatedPreferredLanguages.contains(interaction.sourceLanguage)) {
      updatedPreferredLanguages.add(interaction.sourceLanguage);
    }

    // Update common translation pairs
    final updatedTranslationPairs = Map<String, int>.from(pattern.commonTranslationPairs);
    final pair = '${interaction.sourceLanguage}-${interaction.targetLanguage}';
    updatedTranslationPairs[pair] = (updatedTranslationPairs[pair] ?? 0) + 1;

    // Update usage frequency by hour
    final updatedUsageFrequency = Map<int, int>.from(pattern.usageFrequency);
    final hour = interaction.timestamp.hour;
    updatedUsageFrequency[hour] = (updatedUsageFrequency[hour] ?? 0) + 1;

    // Update active hours
    final updatedActiveHours = List<int>.from(pattern.activeHours);
    if (!updatedActiveHours.contains(hour)) {
      updatedActiveHours.add(hour);
    }

    // Replace the pattern with updated values
    _usagePatterns[userId] = pattern.copyWith(
      preferredLanguages: updatedPreferredLanguages,
      commonTranslationPairs: updatedTranslationPairs,
      usageFrequency: updatedUsageFrequency,
      activeHours: updatedActiveHours,
      lastAnalyzed: DateTime.now(),
    );
  }

  // ===== UTILITY METHODS =====

  List<AutoCompleteResult> _rankAndDeduplicateAutoComplete(
    List<AutoCompleteResult> suggestions,
    UserUsagePattern usagePattern,
  ) {
    // Remove duplicates
    final seenTexts = <String>{};
    final uniqueSuggestions = suggestions.where((s) {
      if (seenTexts.contains(s.completedText.toLowerCase())) {
        return false;
      }
      seenTexts.add(s.completedText.toLowerCase());
      return true;
    }).toList();

    // Rank by confidence and user preferences
    uniqueSuggestions.sort((a, b) {
      // Boost suggestions that match user's patterns
      double aScore = a.confidence;
      double bScore = b.confidence;

      // Prefer AI suggestions slightly
      if (a.suggestionType == AutoCompleteSuggestionType.ai) aScore += 0.1;
      if (b.suggestionType == AutoCompleteSuggestionType.ai) bScore += 0.1;

      // Prefer pattern-based suggestions for power users
      final userInteractionCount = usagePattern.usageFrequency.values
          .fold<int>(0, (sum, count) => sum + count);
      if (userInteractionCount > 100) {
        if (a.suggestionType == AutoCompleteSuggestionType.pattern)
          aScore += 0.15;
        if (b.suggestionType == AutoCompleteSuggestionType.pattern)
          bScore += 0.15;
      }

      return bScore.compareTo(aScore);
    });

    return uniqueSuggestions;
  }

  void _cleanAutoCompleteCache() {
    // Keep cache size reasonable
    if (_autoCompleteCache.length > 1000) {
      final keysToRemove = _autoCompleteCache.keys.take(200).toList();
      for (final key in keysToRemove) {
        _autoCompleteCache.remove(key);
      }
    }
  }

  void _clearUserCaches(String userId) {
    // Clear caches related to this user to reflect learning updates
    _autoCompleteCache.removeWhere((key, _) => key.startsWith('$userId:'));
    _phraseCache.removeWhere((key, _) => key.startsWith('$userId:'));
  }

  String _summarizeConversationForAI(NeuralConversationContext context) {
    if (context.conversationHistory.isEmpty) return 'New conversation';

    final recentTurns = context.conversationHistory.take(3);
    final topics = context.topicEvolution.currentTopics.join(', ');
    final mood = context.emotionalFlow.overallMood.name;

    return 'Recent conversation about: $topics, Mood: $mood, ${recentTurns.length} recent turns';
  }

  String _categorizePhrase(String phrase) {
    // Simple phrase categorization
    if (phrase.toLowerCase().contains('hello') ||
        phrase.toLowerCase().contains('hi')) {
      return 'greeting';
    } else if (phrase.contains('?')) {
      return 'question';
    } else if (phrase.toLowerCase().contains('thank')) {
      return 'gratitude';
    } else {
      return 'general';
    }
  }

  double _calculateAverageRating(List<PredictionInteraction> interactions) {
    final ratingsInteractions = interactions.where((i) => i.userRating != null);
    if (ratingsInteractions.isEmpty) return 0.0;

    final totalRating =
        ratingsInteractions.map((i) => i.userRating!).reduce((a, b) => a + b);

    return totalRating / ratingsInteractions.length;
  }

  Future<List<String>> _getTopPredictedPhrases(String userId) async {
    final model = await _getUserPredictionModel(userId);
    return model.commonPhrases
        .where((p) => p.frequency > 2)
        .take(10)
        .map((p) => p.text)
        .toList();
  }

  List<String> _generateImprovementSuggestions(
      List<PredictionInteraction> interactions) {
    final suggestions = <String>[];

    if (interactions.isEmpty) {
      return ['Use the app more to improve predictions'];
    }

    final accuracy =
        interactions.where((i) => i.wasAccepted).length / interactions.length;

    if (accuracy < 0.7) {
      suggestions.add('Provide feedback on predictions to improve accuracy');
    }

    final languagePairs = interactions
        .map((i) => '${i.sourceLanguage}-${i.targetLanguage}')
        .toSet();

    if (languagePairs.length < 3) {
      suggestions.add(
          'Try translating between more language pairs for better predictions');
    }

    return suggestions;
  }

  // Placeholder implementations for remaining methods
  Future<ConversationPredictions> _analyzeConversationFlow(
    NeuralConversationContext context,
    String userId,
  ) async {
    return ConversationPredictions(
      nextTurnPredictions: [],
      topicPredictions: [],
      responsePatterns: [],
      confidence: 0.7,
    );
  }

  Future<List<NextTurnPrediction>> _predictNextPhrases(
    NeuralConversationContext context,
    ConversationPredictions predictions,
    String? targetLanguage,
  ) async {
    return []; // Simplified placeholder
  }

  Future<List<TranslationSuggestion>> _getCommonResponses(
    ConversationTurn lastTurn,
    String? targetLanguage,
    String userId,
  ) async {
    return []; // Simplified placeholder
  }

  Future<List<TranslationSuggestion>> _generateCulturalSuggestions(
    NeuralConversationContext context,
    String? targetLanguage,
  ) async {
    return []; // Simplified placeholder
  }

  Future<List<PredictivePhrase>> _getContextSpecificPhrases(
    String context,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    return []; // Simplified placeholder
  }

  List<PredictivePhrase> _getTimeBasedPhrases(
    String sourceLanguage,
    String targetLanguage,
  ) {
    final now = DateTime.now();
    final phrases = <PredictivePhrase>[];

    // Simple time-based suggestions
    if (now.hour < 12) {
      phrases.add(PredictivePhrase(
        phrase: 'Good morning',
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        confidence: 0.8,
        category: PredictivePhraseCategory.greeting,
        usage: 'Common morning greeting',
      ));
    } else if (now.hour < 17) {
      phrases.add(PredictivePhrase(
        phrase: 'Good afternoon',
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        confidence: 0.8,
        category: PredictivePhraseCategory.greeting,
        usage: 'Common afternoon greeting',
      ));
    } else {
      phrases.add(PredictivePhrase(
        phrase: 'Good evening',
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        confidence: 0.8,
        category: PredictivePhraseCategory.greeting,
        usage: 'Common evening greeting',
      ));
    }

    return phrases;
  }

  Future<List<TranslationSuggestion>> _rankProactiveSuggestions(
    List<TranslationSuggestion> suggestions,
    NeuralConversationContext context,
    String userId,
  ) async {
    // Rank suggestions by relevance and user preferences
    suggestions.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
    return suggestions;
  }

  Future<String> _translatePredictedText(
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    if (targetLanguage == 'auto' || targetLanguage == sourceLanguage) {
      return text; // No translation needed
    }

    try {
      final response = await _dio.post(
        'https://api.openai.com/v1/chat/completions',
        data: {
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a professional translator. Translate the given text accurately while preserving meaning and tone.',
            },
            {
              'role': 'user',
              'content': 'Translate "$text" from $sourceLanguage to $targetLanguage. Provide only the translation.',
            },
          ],
          'temperature': 0.2,
          'max_tokens': 200,
        },
      );

      final content = response.data['choices'][0]['message']['content'];
      return content.trim();
    } catch (e) {
      _logger.w('Translation of predicted text failed: $e');
      return text; // Return original text as fallback
    }
  }
}

// ===== SUPPORTING DATA CLASSES =====

/// Auto-complete result with metadata
class AutoCompleteResult {
  final String completedText;
  final double confidence;
  final AutoCompleteSuggestionType suggestionType;
  final String reasoning;
  final Map<String, dynamic> metadata;

  const AutoCompleteResult({
    required this.completedText,
    required this.confidence,
    required this.suggestionType,
    required this.reasoning,
    this.metadata = const {},
  });
}

/// Types of auto-complete suggestions
enum AutoCompleteSuggestionType {
  pattern, // Based on user patterns
  contextual, // Based on conversation context
  ai, // AI-generated
  popular, // Popular phrases
}

/// Predictive phrase suggestion
class PredictivePhrase {
  final String phrase;
  final String sourceLanguage;
  final String targetLanguage;
  final double confidence;
  final PredictivePhraseCategory category;
  final String usage;

  const PredictivePhrase({
    required this.phrase,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.confidence,
    required this.category,
    required this.usage,
  });
}

/// Categories for predictive phrases
enum PredictivePhraseCategory {
  greeting,
  question,
  response,
  gratitude,
  apology,
  frequent,
}

/// User's prediction interaction record
class PredictionInteraction {
  final String userId;
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final String? conversationId;
  final bool wasAccepted;
  final double? userRating;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const PredictionInteraction({
    required this.userId,
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.conversationId,
    required this.wasAccepted,
    this.userRating,
    required this.timestamp,
    this.metadata = const {},
  });
}

/// User's prediction model
class PredictionModel {
  final String userId;
  final List<CommonPhrase> commonPhrases;
  final Map<String, int> languagePatterns;
  final Map<String, double> topicPreferences;
  final double accuracy;
  final DateTime lastUpdated;

  PredictionModel({
    required this.userId,
    required this.commonPhrases,
    required this.languagePatterns,
    required this.topicPreferences,
    required this.accuracy,
    required this.lastUpdated,
  });

  PredictionModel copyWith({
    String? userId,
    List<CommonPhrase>? commonPhrases,
    Map<String, int>? languagePatterns,
    Map<String, double>? topicPreferences,
    double? accuracy,
    DateTime? lastUpdated,
  }) {
    return PredictionModel(
      userId: userId ?? this.userId,
      commonPhrases: commonPhrases ?? this.commonPhrases,
      languagePatterns: languagePatterns ?? this.languagePatterns,
      topicPreferences: topicPreferences ?? this.topicPreferences,
      accuracy: accuracy ?? this.accuracy,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Common phrase with usage frequency
class CommonPhrase {
  final String text;
  final String language;
  double frequency;
  final String category;

  CommonPhrase({
    required this.text,
    required this.language,
    required this.frequency,
    required this.category,
  });
}

/// User's usage patterns
class UserUsagePattern {
  final String userId;
  final List<String> preferredLanguages;
  final Map<String, int> commonTranslationPairs;
  final Map<int, int> usageFrequency; // Hour -> Count
  final List<int> activeHours;
  final DateTime lastAnalyzed;

  UserUsagePattern({
    required this.userId,
    required this.preferredLanguages,
    required this.commonTranslationPairs,
    required this.usageFrequency,
    required this.activeHours,
    required this.lastAnalyzed,
  });

  UserUsagePattern copyWith({
    String? userId,
    List<String>? preferredLanguages,
    Map<String, int>? commonTranslationPairs,
    Map<int, int>? usageFrequency,
    List<int>? activeHours,
    DateTime? lastAnalyzed,
  }) {
    return UserUsagePattern(
      userId: userId ?? this.userId,
      preferredLanguages: preferredLanguages ?? this.preferredLanguages,
      commonTranslationPairs: commonTranslationPairs ?? this.commonTranslationPairs,
      usageFrequency: usageFrequency ?? this.usageFrequency,
      activeHours: activeHours ?? this.activeHours,
      lastAnalyzed: lastAnalyzed ?? this.lastAnalyzed,
    );
  }
}

/// Conversation predictions
class ConversationPredictions {
  final List<NextTurnPrediction> nextTurnPredictions;
  final List<TopicPrediction> topicPredictions;
  final List<String> responsePatterns;
  final double confidence;

  const ConversationPredictions({
    required this.nextTurnPredictions,
    required this.topicPredictions,
    required this.responsePatterns,
    required this.confidence,
  });
}

/// Analytics for prediction accuracy
class PredictionAnalytics {
  final String userId;
  final int totalPredictions;
  final int acceptedPredictions;
  final double overallAccuracy;
  final Map<String, double> languagePairAccuracy;
  final Map<DateTime, double> recentPerformance;
  final double averageRating;
  final List<String> topPhrases;
  final List<String> improvementSuggestions;
  final DateTime generatedAt;

  const PredictionAnalytics({
    required this.userId,
    required this.totalPredictions,
    required this.acceptedPredictions,
    required this.overallAccuracy,
    required this.languagePairAccuracy,
    required this.recentPerformance,
    required this.averageRating,
    required this.topPhrases,
    required this.improvementSuggestions,
    required this.generatedAt,
  });

  factory PredictionAnalytics.empty(String userId) {
    return PredictionAnalytics(
      userId: userId,
      totalPredictions: 0,
      acceptedPredictions: 0,
      overallAccuracy: 0.0,
      languagePairAccuracy: {},
      recentPerformance: {},
      averageRating: 0.0,
      topPhrases: [],
      improvementSuggestions: ['Start using predictions to see analytics'],
      generatedAt: DateTime.now(),
    );
  }
}
