// 🌐 LingoSphere - Advanced AI Translation Engine
// Neural translation with context awareness, domain specialization, and quality optimization

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/translation_models.dart';
import '../constants/app_constants.dart';
import '../exceptions/translation_exceptions.dart';

/// Domain-specific translation contexts
enum TranslationDomain {
  general,
  business,
  medical,
  legal,
  technical,
  academic,
  casual,
  formal,
}

/// Translation quality levels
enum QualityLevel {
  fast, // Speed optimized
  balanced, // Balance between speed and quality
  premium, // Highest quality, slower
}

/// Context-aware translation request
class ContextualTranslationRequest {
  final String text;
  final String sourceLanguage;
  final String targetLanguage;
  final TranslationDomain domain;
  final QualityLevel quality;
  final Map<String, dynamic> context;
  final List<String> previousConversation;
  final String? userPreferences;

  const ContextualTranslationRequest({
    required this.text,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.domain = TranslationDomain.general,
    this.quality = QualityLevel.balanced,
    this.context = const {},
    this.previousConversation = const [],
    this.userPreferences,
  });
}

/// Enhanced translation result with AI insights
class AITranslationResult extends TranslationResult {
  final TranslationDomain domain;
  final QualityLevel quality;
  final double contextRelevance;
  final List<String> alternativeTranslations;
  final Map<String, double> confidenceBreakdown;
  final List<TranslationSuggestion> suggestions;
  final CulturalContext culturalNotes;

  const AITranslationResult({
    required super.originalText,
    required super.translatedText,
    required super.sourceLanguage,
    required super.targetLanguage,
    required super.confidence,
    required super.provider,
    required super.sentiment,
    required super.context,
    required super.metadata,
    required this.domain,
    required this.quality,
    required this.contextRelevance,
    required this.alternativeTranslations,
    required this.confidenceBreakdown,
    required this.suggestions,
    required this.culturalNotes,
  });
}

/// Translation suggestion with reasoning
class TranslationSuggestion {
  final String suggestion;
  final String reasoning;
  final double confidence;
  final TranslationDomain applicableDomain;

  const TranslationSuggestion({
    required this.suggestion,
    required this.reasoning,
    required this.confidence,
    required this.applicableDomain,
  });
}

/// Cultural context information
class CulturalContext {
  final List<String> culturalNotes;
  final Map<String, String> idiomExplanations;
  final List<String> formalityIndicators;
  final String? regionalVariant;

  const CulturalContext({
    this.culturalNotes = const [],
    this.idiomExplanations = const {},
    this.formalityIndicators = const [],
    this.regionalVariant,
  });
}

/// Advanced AI Translation Engine
class AITranslationEngine {
  static final AITranslationEngine _instance = AITranslationEngine._internal();
  factory AITranslationEngine() => _instance;
  AITranslationEngine._internal();

  final Dio _dio = Dio();
  final Logger _logger = Logger();

  // Neural model configurations
  final Map<TranslationDomain, String> _domainModels = {
    TranslationDomain.general: 'neural-general-v2',
    TranslationDomain.business: 'neural-business-v1',
    TranslationDomain.medical: 'neural-medical-v1',
    TranslationDomain.legal: 'neural-legal-v1',
    TranslationDomain.technical: 'neural-tech-v1',
    TranslationDomain.academic: 'neural-academic-v1',
    TranslationDomain.casual: 'neural-casual-v1',
    TranslationDomain.formal: 'neural-formal-v1',
  };

  // Context analysis cache
  final Map<String, AnalyzedContext> _contextCache = {};

  // Conversation memory for context continuity
  final Map<String, List<String>> _conversationMemory = {};

  /// Initialize the AI translation engine
  Future<void> initialize({
    required String openAIApiKey,
    String? customModelEndpoint,
  }) async {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 2),
      headers: {
        'Authorization': 'Bearer $openAIApiKey',
        'Content-Type': 'application/json',
      },
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.d('AI Translation Request: ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d('AI Translation Response: ${response.statusCode}');
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('AI Translation Error: ${error.message}');
          handler.next(error);
        },
      ),
    );

    _logger.i('AI Translation Engine initialized');
  }

  /// Main contextual translation method
  Future<AITranslationResult> translateWithContext(
    ContextualTranslationRequest request,
  ) async {
    try {
      final stopwatch = Stopwatch()..start();

      // Analyze input context
      final analyzedContext = await _analyzeInputContext(request);

      // Detect domain if not specified
      final detectedDomain = request.domain == TranslationDomain.general
          ? await _detectDomain(request.text, analyzedContext)
          : request.domain;

      // Build neural translation prompt
      final prompt =
          await _buildNeuralPrompt(request, analyzedContext, detectedDomain);

      // Execute translation with selected model
      final translationResponse = await _executeNeuralTranslation(
        prompt,
        detectedDomain,
        request.quality,
      );

      // Post-process and enhance result
      final enhancedResult = await _enhanceTranslationResult(
        request,
        translationResponse,
        analyzedContext,
        detectedDomain,
      );

      stopwatch.stop();

      // Update conversation memory
      _updateConversationMemory(request, enhancedResult);

      return enhancedResult.copyWith(
        metadata: enhancedResult.metadata.copyWith(
          processingTime: stopwatch.elapsed,
        ),
      ) as AITranslationResult;
    } catch (e) {
      _logger.e('AI translation failed: $e');
      throw TranslationServiceException(
          'AI translation failed: ${e.toString()}');
    }
  }

  /// Analyze input context for better translation
  Future<AnalyzedContext> _analyzeInputContext(
    ContextualTranslationRequest request,
  ) async {
    final cacheKey = '${request.text}_${request.sourceLanguage}';
    if (_contextCache.containsKey(cacheKey)) {
      return _contextCache[cacheKey]!;
    }

    final analysis = AnalyzedContext(
      sentiment: await _analyzeSentiment(request.text),
      formality: await _analyzeFormality(request.text),
      complexity: _analyzeComplexity(request.text),
      entities: await _extractEntities(request.text),
      keywords: _extractKeywords(request.text),
      textType: _classifyTextType(request.text),
    );

    _contextCache[cacheKey] = analysis;
    return analysis;
  }

  /// Detect translation domain using AI classification
  Future<TranslationDomain> _detectDomain(
    String text,
    AnalyzedContext context,
  ) async {
    final domainPrompt = '''
Analyze the following text and classify it into one of these domains:
- general: everyday conversation, basic communication
- business: professional, corporate, commercial content
- medical: healthcare, symptoms, treatments, medical terms
- legal: contracts, laws, regulations, legal documents
- technical: engineering, IT, software, technical documentation
- academic: research, scholarly, educational content
- casual: informal, slang, social media, chat
- formal: official documents, ceremonies, diplomatic

Text: "$text"
Context: ${context.toString()}

Respond with just the domain name.
''';

    try {
      final response = await _dio.post(
        'https://api.openai.com/v1/chat/completions',
        data: {
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a domain classification expert.'
            },
            {'role': 'user', 'content': domainPrompt},
          ],
          'temperature': 0.1,
          'max_tokens': 50,
        },
      );

      final domainStr = response.data['choices'][0]['message']['content']
          .trim()
          .toLowerCase();
      return TranslationDomain.values.firstWhere(
        (domain) => domain.name == domainStr,
        orElse: () => TranslationDomain.general,
      );
    } catch (e) {
      _logger.w('Domain detection failed: $e');
      return TranslationDomain.general;
    }
  }

  /// Build neural translation prompt with context
  Future<String> _buildNeuralPrompt(
    ContextualTranslationRequest request,
    AnalyzedContext context,
    TranslationDomain domain,
  ) async {
    final conversationContext = request.previousConversation.isNotEmpty
        ? 'Previous conversation:\n${request.previousConversation.join('\n')}\n\n'
        : '';

    final domainInstructions = _getDomainInstructions(domain);
    final qualityInstructions = _getQualityInstructions(request.quality);

    return '''
You are an expert translator specializing in ${domain.name} content.

$domainInstructions

$qualityInstructions

Context Analysis:
- Sentiment: ${context.sentiment.sentiment.name} (${context.sentiment.score.toStringAsFixed(2)})
- Formality: ${context.formality}
- Text Type: ${context.textType}
- Key Entities: ${context.entities.join(', ')}

$conversationContext

Translate the following text from ${request.sourceLanguage} to ${request.targetLanguage}:
"${request.text}"

Requirements:
1. Maintain the original tone and style
2. Consider cultural context and idioms
3. Preserve formatting and punctuation
4. Provide the most natural translation for the target audience
5. Consider the conversation context if provided

Provide your response in this JSON format:
{
  "translation": "your translation here",
  "alternatives": ["alternative 1", "alternative 2", "alternative 3"],
  "confidence_breakdown": {
    "grammar": 0.95,
    "vocabulary": 0.90,
    "context": 0.85,
    "cultural": 0.80
  },
  "suggestions": [
    {
      "suggestion": "alternative phrasing",
      "reasoning": "why this might be better",
      "confidence": 0.88
    }
  ],
  "cultural_notes": {
    "notes": ["cultural insight 1", "cultural insight 2"],
    "idioms": {"original idiom": "explanation"},
    "formality": ["formality indicators"],
    "regional_variant": "specific regional considerations"
  }
}
''';
  }

  /// Execute neural translation with selected model
  Future<Map<String, dynamic>> _executeNeuralTranslation(
    String prompt,
    TranslationDomain domain,
    QualityLevel quality,
  ) async {
    final modelConfig = _getModelConfig(domain, quality);

    final response = await _dio.post(
      'https://api.openai.com/v1/chat/completions',
      data: {
        'model': modelConfig.model,
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a professional translator with expertise in neural machine translation.',
          },
          {'role': 'user', 'content': prompt},
        ],
        'temperature': modelConfig.temperature,
        'max_tokens': modelConfig.maxTokens,
        'top_p': modelConfig.topP,
        'frequency_penalty': modelConfig.frequencyPenalty,
        'presence_penalty': modelConfig.presencePenalty,
      },
    );

    final content = response.data['choices'][0]['message']['content'];
    try {
      return json.decode(content);
    } catch (e) {
      // Fallback if JSON parsing fails
      return {
        'translation': content,
        'alternatives': [],
        'confidence_breakdown': {
          'grammar': 0.85,
          'vocabulary': 0.85,
          'context': 0.80,
          'cultural': 0.75,
        },
        'suggestions': [],
        'cultural_notes': {
          'notes': [],
          'idioms': {},
          'formality': [],
          'regional_variant': null,
        },
      };
    }
  }

  /// Enhance translation result with AI insights
  Future<AITranslationResult> _enhanceTranslationResult(
    ContextualTranslationRequest request,
    Map<String, dynamic> translationResponse,
    AnalyzedContext context,
    TranslationDomain domain,
  ) async {
    final confidenceBreakdown = Map<String, double>.from(
      translationResponse['confidence_breakdown'] ?? {},
    );

    final overallConfidence = confidenceBreakdown.values.isNotEmpty
        ? confidenceBreakdown.values.reduce((a, b) => a + b) /
            confidenceBreakdown.length
        : 0.85;

    final suggestions = (translationResponse['suggestions'] as List?)
            ?.map((s) => TranslationSuggestion(
                  suggestion: s['suggestion'] ?? '',
                  reasoning: s['reasoning'] ?? '',
                  confidence: (s['confidence'] as num?)?.toDouble() ?? 0.0,
                  applicableDomain: domain,
                ))
            .toList() ??
        [];

    final culturalNotesData = translationResponse['cultural_notes'] ?? {};
    final culturalNotes = CulturalContext(
      culturalNotes: List<String>.from(culturalNotesData['notes'] ?? []),
      idiomExplanations:
          Map<String, String>.from(culturalNotesData['idioms'] ?? {}),
      formalityIndicators:
          List<String>.from(culturalNotesData['formality'] ?? []),
      regionalVariant: culturalNotesData['regional_variant'],
    );

    return AITranslationResult(
      originalText: request.text,
      translatedText: translationResponse['translation'] ?? request.text,
      sourceLanguage: request.sourceLanguage,
      targetLanguage: request.targetLanguage,
      confidence: _mapConfidence(overallConfidence),
      provider: 'ai-neural-${domain.name}',
      sentiment: context.sentiment,
      context: ContextAnalysis(
        formality: context.formality == 'formal'
            ? FormalityLevel.formal
            : context.formality == 'informal'
                ? FormalityLevel.informal
                : FormalityLevel.neutral,
        domain: _mapDomainToTextDomain(domain),
        culturalMarkers: [],
        slangLevel: 0.0,
        additionalContext: {},
      ),
      metadata: TranslationMetadata(
        timestamp: DateTime.now(),
        processingTime: Duration.zero, // Will be set by caller
      ),
      domain: domain,
      quality: request.quality,
      contextRelevance: _calculateContextRelevance(request, context),
      alternativeTranslations:
          List<String>.from(translationResponse['alternatives'] ?? []),
      confidenceBreakdown: confidenceBreakdown,
      suggestions: suggestions,
      culturalNotes: culturalNotes,
    );
  }

  /// Update conversation memory for context continuity
  void _updateConversationMemory(
    ContextualTranslationRequest request,
    AITranslationResult result,
  ) {
    final sessionId = '${request.sourceLanguage}_${request.targetLanguage}';
    _conversationMemory.putIfAbsent(sessionId, () => []);

    final conversationEntry = '${request.text} -> ${result.translatedText}';
    _conversationMemory[sessionId]!.add(conversationEntry);

    // Keep only last 10 entries to prevent memory bloat
    if (_conversationMemory[sessionId]!.length > 10) {
      _conversationMemory[sessionId]!.removeAt(0);
    }
  }

  // Helper methods for analysis
  Future<SentimentAnalysis> _analyzeSentiment(String text) async {
    // Simplified sentiment analysis - in production, use a dedicated service
    final positiveWords = [
      'good',
      'great',
      'excellent',
      'amazing',
      'wonderful',
      'fantastic'
    ];
    final negativeWords = [
      'bad',
      'terrible',
      'awful',
      'horrible',
      'disappointing'
    ];

    var score = 0.5; // neutral
    final words = text.toLowerCase().split(RegExp(r'\W+'));

    for (final word in words) {
      if (positiveWords.contains(word)) score += 0.1;
      if (negativeWords.contains(word)) score -= 0.1;
    }

    score = score.clamp(0.0, 1.0);

    SentimentType type;
    if (score > 0.6) {
      type = SentimentType.positive;
    } else if (score < 0.4) {
      type = SentimentType.negative;
    } else {
      type = SentimentType.neutral;
    }

    return SentimentAnalysis(
      sentiment: type,
      score: score,
      confidence: score.abs() * 100,
    );
  }

  Future<String> _analyzeFormality(String text) async {
    // Simple formality detection
    final formalMarkers = ['please', 'kindly', 'respectfully', 'sincerely'];
    final casualMarkers = ['hey', 'hi', 'yeah', 'ok', 'cool'];

    final lowerText = text.toLowerCase();
    var formalCount = 0;
    var casualCount = 0;

    for (final marker in formalMarkers) {
      if (lowerText.contains(marker)) formalCount++;
    }

    for (final marker in casualMarkers) {
      if (lowerText.contains(marker)) casualCount++;
    }

    if (formalCount > casualCount) return 'formal';
    if (casualCount > formalCount) return 'casual';
    return 'neutral';
  }

  double _analyzeComplexity(String text) {
    final words = text.split(RegExp(r'\W+'));
    final avgWordLength =
        words.fold<double>(0, (sum, word) => sum + word.length) / words.length;
    final sentenceCount = text.split(RegExp(r'[.!?]')).length;
    final wordsPerSentence = words.length / sentenceCount;

    // Normalize complexity score between 0 and 1
    return ((avgWordLength / 10) + (wordsPerSentence / 20)).clamp(0.0, 1.0);
  }

  Future<List<String>> _extractEntities(String text) async {
    // Simple entity extraction - in production, use NER service
    final entities = <String>[];
    final words = text.split(RegExp(r'\W+'));

    for (final word in words) {
      if (word.length > 1 && word[0] == word[0].toUpperCase()) {
        entities.add(word);
      }
    }

    return entities.take(5).toList();
  }

  List<String> _extractKeywords(String text) {
    final words = text.toLowerCase().split(RegExp(r'\W+'));
    final stopWords = {
      'the',
      'and',
      'or',
      'but',
      'in',
      'on',
      'at',
      'to',
      'for',
      'of',
      'with',
      'by',
      'a',
      'an'
    };

    return words
        .where((word) => word.length > 3 && !stopWords.contains(word))
        .take(10)
        .toList();
  }

  String _classifyTextType(String text) {
    if (text.contains('?')) return 'question';
    if (text.contains('!')) return 'exclamation';
    if (text.split('.').length > 3) return 'paragraph';
    if (text.split(' ').length < 5) return 'phrase';
    return 'sentence';
  }

  String _getDomainInstructions(TranslationDomain domain) {
    switch (domain) {
      case TranslationDomain.business:
        return 'Focus on professional terminology and maintain formal business tone.';
      case TranslationDomain.medical:
        return 'Use precise medical terminology and maintain clinical accuracy.';
      case TranslationDomain.legal:
        return 'Preserve legal terminology and maintain juridical precision.';
      case TranslationDomain.technical:
        return 'Keep technical terms accurate and maintain procedural clarity.';
      case TranslationDomain.academic:
        return 'Use scholarly language and maintain academic rigor.';
      case TranslationDomain.casual:
        return 'Use natural, conversational language and local expressions.';
      case TranslationDomain.formal:
        return 'Maintain formal register and respectful tone.';
      default:
        return 'Provide natural, accurate translation suitable for general use.';
    }
  }

  String _getQualityInstructions(QualityLevel quality) {
    switch (quality) {
      case QualityLevel.fast:
        return 'Prioritize speed while maintaining basic accuracy.';
      case QualityLevel.premium:
        return 'Provide the highest quality translation with careful attention to nuance, style, and cultural appropriateness.';
      default:
        return 'Balance accuracy and naturalness for everyday use.';
    }
  }

  ModelConfig _getModelConfig(TranslationDomain domain, QualityLevel quality) {
    switch (quality) {
      case QualityLevel.fast:
        return ModelConfig(
          model: 'gpt-3.5-turbo',
          temperature: 0.3,
          maxTokens: 500,
          topP: 0.9,
          frequencyPenalty: 0.0,
          presencePenalty: 0.0,
        );
      case QualityLevel.premium:
        return ModelConfig(
          model: 'gpt-4',
          temperature: 0.2,
          maxTokens: 1000,
          topP: 0.95,
          frequencyPenalty: 0.1,
          presencePenalty: 0.1,
        );
      default:
        return ModelConfig(
          model: 'gpt-3.5-turbo',
          temperature: 0.2,
          maxTokens: 750,
          topP: 0.95,
          frequencyPenalty: 0.0,
          presencePenalty: 0.0,
        );
    }
  }

  TranslationConfidence _mapConfidence(double score) {
    if (score >= 0.9) return TranslationConfidence.high;
    if (score >= 0.7) return TranslationConfidence.medium;
    return TranslationConfidence.low;
  }

  double _calculateContextRelevance(
      ContextualTranslationRequest request, AnalyzedContext context) {
    // Simple relevance calculation based on available context
    var relevance = 0.5; // base relevance

    if (request.previousConversation.isNotEmpty) relevance += 0.2;
    if (request.context.isNotEmpty) relevance += 0.2;
    if (context.entities.isNotEmpty) relevance += 0.1;

    return relevance.clamp(0.0, 1.0);
  }

  /// Map TranslationDomain to TextDomain
  TextDomain _mapDomainToTextDomain(TranslationDomain domain) {
    switch (domain) {
      case TranslationDomain.business:
        return TextDomain.business;
      case TranslationDomain.technical:
        return TextDomain.technical;
      case TranslationDomain.academic:
        return TextDomain.academic;
      case TranslationDomain.casual:
        return TextDomain.casual;
      case TranslationDomain.general:
      case TranslationDomain.medical:
      case TranslationDomain.legal:
      case TranslationDomain.formal:
        return TextDomain.general;
    }
  }
}

/// Translation context for AI results
class TranslationContext {
  final String domain;
  final String formality;
  final double complexity;
  final List<String> entities;

  const TranslationContext({
    required this.domain,
    required this.formality,
    required this.complexity,
    required this.entities,
  });
}

/// Context analysis result
class AnalyzedContext {
  final SentimentAnalysis sentiment;
  final String formality;
  final double complexity;
  final List<String> entities;
  final List<String> keywords;
  final String textType;

  const AnalyzedContext({
    required this.sentiment,
    required this.formality,
    required this.complexity,
    required this.entities,
    required this.keywords,
    required this.textType,
  });

  @override
  String toString() {
    return 'AnalyzedContext(sentiment: $sentiment, formality: $formality, complexity: $complexity, entities: $entities, textType: $textType)';
  }
}

/// Model configuration for different quality levels
class ModelConfig {
  final String model;
  final double temperature;
  final int maxTokens;
  final double topP;
  final double frequencyPenalty;
  final double presencePenalty;

  const ModelConfig({
    required this.model,
    required this.temperature,
    required this.maxTokens,
    required this.topP,
    required this.frequencyPenalty,
    required this.presencePenalty,
  });
}
