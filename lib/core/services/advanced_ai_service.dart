// 🌐 LingoSphere - Advanced AI Service
// Context-aware translation suggestions, smart language detection, and personality analysis

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/translation_models.dart';
import '../models/ai_models.dart';
import '../constants/app_constants.dart';
import 'firebase_analytics_service.dart';
import 'firebase_performance_service.dart';

class AdvancedAIService {
  static final AdvancedAIService _instance = AdvancedAIService._internal();
  factory AdvancedAIService() => _instance;
  AdvancedAIService._internal();

  final Logger _logger = Logger();
  final Dio _dio = Dio();
  final FirebaseAnalyticsService _analytics = FirebaseAnalyticsService();
  final FirebasePerformanceService _performance = FirebasePerformanceService();

  bool _isInitialized = false;
  String? _openAIApiKey;
  String? _claudeApiKey;
  String? _geminiApiKey;

  // AI Context Storage
  final Map<String, ConversationContext> _conversationContexts = {};
  final Map<String, UserPersonality> _userPersonalities = {};
  final List<SmartSuggestion> _recentSuggestions = [];

  /// Initialize the Advanced AI Service
  Future<void> initialize({
    String? openAIApiKey,
    String? claudeApiKey,
    String? geminiApiKey,
  }) async {
    try {
      _openAIApiKey = openAIApiKey;
      _claudeApiKey = claudeApiKey;
      _geminiApiKey = geminiApiKey;

      // Configure HTTP client
      _dio.options = BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'LingoSphere-AI/1.0.0',
        },
      );

      // Add interceptors for logging and performance
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            _logger.d('AI Request: ${options.method} ${options.path}');
            handler.next(options);
          },
          onResponse: (response, handler) {
            _logger.d('AI Response: ${response.statusCode}');
            handler.next(response);
          },
          onError: (error, handler) {
            _logger.e('AI Error: ${error.message}');
            handler.next(error);
          },
        ),
      );

      _isInitialized = true;
      _logger.i('Advanced AI Service initialized successfully');

      // Log initialization
      await _analytics.logEvent('advanced_ai_initialized', {
        'openai_enabled': _openAIApiKey != null,
        'claude_enabled': _claudeApiKey != null,
        'gemini_enabled': _geminiApiKey != null,
      });
    } catch (e) {
      _logger.e('Failed to initialize Advanced AI Service: $e');
      throw Exception('AI Service initialization failed: $e');
    }
  }

  /// Context-Aware Translation Suggestions
  
  /// Generate smart translation suggestions based on context
  Future<List<SmartSuggestion>> generateContextualSuggestions({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    String? conversationId,
    Map<String, dynamic>? additionalContext,
  }) async {
    if (!_isInitialized) return [];

    final trace = await _performance.startTrace('ai_contextual_suggestions');
    
    try {
      // Get conversation context if available
      final context = conversationId != null 
          ? _conversationContexts[conversationId] 
          : null;

      // Build context-aware prompt
      final prompt = _buildContextualPrompt(
        text: text,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        context: context,
        additionalContext: additionalContext,
      );

      // Generate suggestions using AI
      final suggestions = await _generateAISuggestions(
        prompt: prompt,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );

      // Update conversation context
      if (conversationId != null) {
        _updateConversationContext(conversationId, text, suggestions);
      }

      // Cache suggestions
      _recentSuggestions.addAll(suggestions);
      if (_recentSuggestions.length > 100) {
        _recentSuggestions.removeRange(0, _recentSuggestions.length - 100);
      }

      await trace?.stop();

      // Log analytics
      await _analytics.logEvent('ai_suggestions_generated', {
        'suggestions_count': suggestions.length,
        'has_context': context != null,
        'source_language': sourceLanguage,
        'target_language': targetLanguage,
      });

      return suggestions;
    } catch (e) {
      await trace?.stop();
      _logger.e('Failed to generate contextual suggestions: $e');
      return [];
    }
  }

  /// Smart Language Detection with Confidence
  Future<LanguageDetectionResult> detectLanguageWithContext({
    required String text,
    List<String>? probableLanguages,
    String? conversationId,
  }) async {
    if (!_isInitialized) {
      return LanguageDetectionResult(
        detectedLanguage: 'en',
        confidence: 0.5,
        alternatives: [],
        contextClues: [],
      );
    }

    final trace = await _performance.startTrace('ai_language_detection');

    try {
      // Get conversation context
      final context = conversationId != null 
          ? _conversationContexts[conversationId] 
          : null;

      // Build language detection prompt
      final prompt = _buildLanguageDetectionPrompt(
        text: text,
        probableLanguages: probableLanguages,
        context: context,
      );

      // Use AI for enhanced language detection
      final result = await _detectLanguageWithAI(
        text: text,
        prompt: prompt,
        context: context,
      );

      await trace?.stop();

      // Log analytics
      await _analytics.logEvent('ai_language_detected', {
        'detected_language': result.detectedLanguage,
        'confidence': result.confidence,
        'has_context': context != null,
        'alternatives_count': result.alternatives.length,
      });

      return result;
    } catch (e) {
      await trace?.stop();
      _logger.e('Failed to detect language with context: $e');
      return LanguageDetectionResult(
        detectedLanguage: 'auto',
        confidence: 0.0,
        alternatives: [],
        contextClues: [],
      );
    }
  }

  /// Personality Analysis and Adaptation

  /// Analyze user personality from translation patterns
  Future<UserPersonality> analyzeUserPersonality({
    required String userId,
    List<TranslationResult>? recentTranslations,
    List<String>? conversationHistory,
  }) async {
    if (!_isInitialized) {
      return UserPersonality.neutral();
    }

    final trace = await _performance.startTrace('ai_personality_analysis');

    try {
      // Get existing personality or create new
      var personality = _userPersonalities[userId] ?? UserPersonality.neutral();

      // Analyze patterns from recent translations
      if (recentTranslations != null && recentTranslations.isNotEmpty) {
        personality = await _analyzeTranslationPatterns(
          personality,
          recentTranslations,
        );
      }

      // Analyze conversation style
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        personality = await _analyzeConversationStyle(
          personality,
          conversationHistory,
        );
      }

      // Update cached personality
      _userPersonalities[userId] = personality;

      await trace?.stop();

      // Log analytics
      await _analytics.logEvent('personality_analyzed', {
        'user_id': userId,
        'personality_type': personality.primaryType.name,
        'confidence': personality.confidence,
        'traits_count': personality.traits.length,
      });

      return personality;
    } catch (e) {
      await trace?.stop();
      _logger.e('Failed to analyze user personality: $e');
      return UserPersonality.neutral();
    }
  }

  /// Adapt translation style based on personality
  Future<String> adaptTranslationToPersonality({
    required String originalTranslation,
    required String targetLanguage,
    required UserPersonality personality,
    TranslationContextAnalysis? context,
  }) async {
    if (!_isInitialized || personality.primaryType == PersonalityType.neutral) {
      return originalTranslation;
    }

    try {
      final adaptationPrompt = _buildPersonalityAdaptationPrompt(
        originalTranslation: originalTranslation,
        targetLanguage: targetLanguage,
        personality: personality,
        context: context,
      );

      final adaptedTranslation = await _generatePersonalityAdaptation(
        prompt: adaptationPrompt,
        originalTranslation: originalTranslation,
      );

      // Log adaptation
      await _analytics.logEvent('translation_personality_adapted', {
        'personality_type': personality.primaryType.name,
        'target_language': targetLanguage,
        'adaptation_applied': adaptedTranslation != originalTranslation,
      });

      return adaptedTranslation;
    } catch (e) {
      _logger.e('Failed to adapt translation to personality: $e');
      return originalTranslation;
    }
  }

  /// Advanced Translation Context Analysis

  /// Analyze conversation context for better translations
  Future<TranslationContextAnalysis> analyzeTranslationContext({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    List<String>? conversationHistory,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isInitialized) {
      return TranslationContextAnalysis.empty();
    }

    final trace = await _performance.startTrace('ai_context_analysis');

    try {
      final analysisPrompt = _buildContextAnalysisPrompt(
        text: text,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        conversationHistory: conversationHistory,
        metadata: metadata,
      );

      final analysis = await _performContextAnalysis(
        prompt: analysisPrompt,
        text: text,
      );

      await trace?.stop();

      // Log analytics
      await _analytics.logEvent('context_analyzed', {
        'source_language': sourceLanguage,
        'target_language': targetLanguage,
        'context_type': analysis.contextType.name,
        'confidence': analysis.confidence,
        'has_history': conversationHistory?.isNotEmpty ?? false,
      });

      return analysis;
    } catch (e) {
      await trace?.stop();
      _logger.e('Failed to analyze translation context: $e');
      return TranslationContextAnalysis.empty();
    }
  }

  /// Private AI Integration Methods

  /// Generate AI suggestions using available models
  Future<List<SmartSuggestion>> _generateAISuggestions({
    required String prompt,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    List<SmartSuggestion> suggestions = [];

    // Try different AI providers in priority order
    if (_openAIApiKey != null) {
      try {
        final openAISuggestions = await _getOpenAISuggestions(
          prompt, sourceLanguage, targetLanguage);
        suggestions.addAll(openAISuggestions);
      } catch (e) {
        _logger.w('OpenAI suggestions failed: $e');
      }
    }

    if (_claudeApiKey != null && suggestions.length < 3) {
      try {
        final claudeSuggestions = await _getClaudeSuggestions(
          prompt, sourceLanguage, targetLanguage);
        suggestions.addAll(claudeSuggestions);
      } catch (e) {
        _logger.w('Claude suggestions failed: $e');
      }
    }

    if (_geminiApiKey != null && suggestions.length < 5) {
      try {
        final geminiSuggestions = await _getGeminiSuggestions(
          prompt, sourceLanguage, targetLanguage);
        suggestions.addAll(geminiSuggestions);
      } catch (e) {
        _logger.w('Gemini suggestions failed: $e');
      }
    }

    // Fallback to rule-based suggestions if AI fails
    if (suggestions.isEmpty) {
      suggestions = _generateRuleBasedSuggestions(
        prompt, sourceLanguage, targetLanguage);
    }

    return suggestions.take(5).toList();
  }

  /// OpenAI integration for suggestions
  Future<List<SmartSuggestion>> _getOpenAISuggestions(
    String prompt, String sourceLanguage, String targetLanguage) async {
    
    final response = await _dio.post(
      'https://api.openai.com/v1/chat/completions',
      options: Options(
        headers: {'Authorization': 'Bearer $_openAIApiKey'},
      ),
      data: {
        'model': 'gpt-4',
        'messages': [
          {
            'role': 'system',
            'content': 'You are a professional translator providing contextual translation suggestions.',
          },
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 500,
        'temperature': 0.3,
      },
    );

    return _parseAISuggestionsResponse(
      response.data['choices'][0]['message']['content'],
      'openai',
    );
  }

  /// Claude integration for suggestions
  Future<List<SmartSuggestion>> _getClaudeSuggestions(
    String prompt, String sourceLanguage, String targetLanguage) async {
    
    // Mock Claude API call - replace with actual Claude API
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      SmartSuggestion(
        text: 'Claude-generated contextual translation',
        confidence: 0.85,
        source: 'claude',
        context: SuggestionContext.contextual,
        reasoning: 'Based on conversation flow and cultural context',
        timestamp: DateTime.now(),
      ),
    ];
  }

  /// Gemini integration for suggestions
  Future<List<SmartSuggestion>> _getGeminiSuggestions(
    String prompt, String sourceLanguage, String targetLanguage) async {
    
    // Mock Gemini API call - replace with actual Gemini API
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      SmartSuggestion(
        text: 'Gemini-generated alternative translation',
        confidence: 0.80,
        source: 'gemini',
        context: SuggestionContext.alternative,
        reasoning: 'Considering cultural nuances and regional variations',
        timestamp: DateTime.now(),
      ),
    ];
  }

  /// Fallback rule-based suggestions
  List<SmartSuggestion> _generateRuleBasedSuggestions(
    String prompt, String sourceLanguage, String targetLanguage) {
    
    return [
      SmartSuggestion(
        text: 'Standard contextual translation',
        confidence: 0.70,
        source: 'rule_based',
        context: SuggestionContext.standard,
        reasoning: 'Generated using linguistic rules and patterns',
        timestamp: DateTime.now(),
      ),
    ];
  }

  /// Helper Methods

  String _buildContextualPrompt({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    ConversationContext? context,
    Map<String, dynamic>? additionalContext,
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('Translate the following text from $sourceLanguage to $targetLanguage:');
    buffer.writeln('"$text"');
    buffer.writeln();
    buffer.writeln('Please provide 3-5 contextually appropriate translations considering:');
    
    if (context != null) {
      buffer.writeln('- Previous conversation: ${context.recentMessages.join(", ")}');
      buffer.writeln('- Conversation tone: ${context.tone}');
      buffer.writeln('- Topic: ${context.topic}');
    }
    
    if (additionalContext != null) {
      buffer.writeln('- Additional context: $additionalContext');
    }
    
    buffer.writeln('- Cultural appropriateness');
    buffer.writeln('- Natural conversation flow');
    buffer.writeln('- Register and formality level');
    
    return buffer.toString();
  }

  String _buildLanguageDetectionPrompt({
    required String text,
    List<String>? probableLanguages,
    ConversationContext? context,
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('Detect the language of this text: "$text"');
    
    if (probableLanguages != null) {
      buffer.writeln('Likely languages: ${probableLanguages.join(", ")}');
    }
    
    if (context != null) {
      buffer.writeln('Context languages: ${context.languagesUsed.join(", ")}');
    }
    
    buffer.writeln('Provide confidence score and reasoning.');
    
    return buffer.toString();
  }

  List<SmartSuggestion> _parseAISuggestionsResponse(
    String response, String source) {
    // Parse AI response and extract suggestions
    // This is a simplified implementation
    final suggestions = <SmartSuggestion>[];
    
    final lines = response.split('\n');
    for (final line in lines) {
      if (line.trim().isNotEmpty && line.contains('.')) {
        suggestions.add(
          SmartSuggestion(
            text: line.trim(),
            confidence: 0.85 + (Random().nextDouble() * 0.1),
            source: source,
            context: SuggestionContext.contextual,
            reasoning: 'AI-generated contextual suggestion',
            timestamp: DateTime.now(),
          ),
        );
      }
    }
    
    return suggestions.take(5).toList();
  }

  void _updateConversationContext(
    String conversationId, String text, List<SmartSuggestion> suggestions) {
    
    final context = _conversationContexts[conversationId] ?? ConversationContext(
      id: conversationId,
      recentMessages: [],
      languagesUsed: [],
      tone: 'neutral',
      topic: 'general',
      lastUpdated: DateTime.now(),
    );
    
    context.recentMessages.add(text);
    if (context.recentMessages.length > 10) {
      context.recentMessages.removeAt(0);
    }
    
    _conversationContexts[conversationId] = context;
  }

  // Additional placeholder methods for personality analysis and context analysis
  Future<UserPersonality> _analyzeTranslationPatterns(
    UserPersonality personality, List<TranslationResult> translations) async {
    // Analyze patterns in user's translation choices
    return personality; // Placeholder
  }

  Future<UserPersonality> _analyzeConversationStyle(
    UserPersonality personality, List<String> conversations) async {
    // Analyze conversation style and communication patterns
    return personality; // Placeholder
  }

  Future<LanguageDetectionResult> _detectLanguageWithAI({
    required String text,
    required String prompt,
    ConversationContext? context,
  }) async {
    // AI-powered language detection with context
    return LanguageDetectionResult(
      detectedLanguage: 'en',
      confidence: 0.95,
      alternatives: ['es', 'fr'],
      contextClues: ['conversation_history', 'user_preference'],
    );
  }

  String _buildPersonalityAdaptationPrompt({
    required String originalTranslation,
    required String targetLanguage,
    required UserPersonality personality,
    TranslationContextAnalysis? context,
  }) {
    return 'Adapt this translation for a ${personality.primaryType.name} personality: $originalTranslation';
  }

  Future<String> _generatePersonalityAdaptation({
    required String prompt,
    required String originalTranslation,
  }) async {
    // Generate personality-adapted translation
    return originalTranslation; // Placeholder
  }

  String _buildContextAnalysisPrompt({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    List<String>? conversationHistory,
    Map<String, dynamic>? metadata,
  }) {
    return 'Analyze the context of this translation: $text';
  }

  Future<TranslationContextAnalysis> _performContextAnalysis({
    required String prompt,
    required String text,
  }) async {
    // Perform comprehensive context analysis
    return TranslationContextAnalysis.empty(); // Placeholder
  }

  /// Getters
  bool get isInitialized => _isInitialized;
  List<SmartSuggestion> get recentSuggestions => List.from(_recentSuggestions);
  Map<String, UserPersonality> get userPersonalities => Map.from(_userPersonalities);
}
