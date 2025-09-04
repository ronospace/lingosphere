// 📊 LingoSphere - Conversation Analytics Service
// Advanced analytics and insights for conversation patterns, translation quality, and user engagement

import 'dart:async';
import 'dart:math';
import 'package:logger/logger.dart';

import '../models/neural_conversation_models.dart';
import '../models/personality_models.dart';
import '../exceptions/translation_exceptions.dart';
import 'neural_context_engine.dart';
import 'ai_personality_engine.dart';
import 'predictive_translation_service.dart';

/// Comprehensive analytics service for conversation insights
class ConversationAnalyticsService {
  static final ConversationAnalyticsService _instance =
      ConversationAnalyticsService._internal();
  factory ConversationAnalyticsService() => _instance;
  ConversationAnalyticsService._internal();

  final Logger _logger = Logger();

  // Core services for data collection
  final NeuralContextEngine _neuralEngine = NeuralContextEngine();
  final AIPersonalityEngine _personalityEngine = AIPersonalityEngine();
  final PredictiveTranslationService _predictiveService =
      PredictiveTranslationService();

  // Analytics data storage
  final Map<String, UserAnalytics> _userAnalytics = {};
  final Map<String, ConversationInsights> _conversationInsights = {};
  final Map<String, List<EngagementEvent>> _engagementEvents = {};
  final Map<String, QualityMetrics> _qualityMetrics = {};

  // Real-time analytics tracking
  final Map<String, StreamController<AnalyticsEvent>> _analyticsStreams = {};

  /// Initialize the analytics service
  Future<void> initialize() async {
    try {
      _logger.i('Conversation Analytics Service initialized');

      // Start background analytics processing
      _startBackgroundAnalytics();
    } catch (e) {
      _logger.e('Failed to initialize Analytics Service: $e');
      throw TranslationServiceException(
          'Analytics initialization failed: ${e.toString()}');
    }
  }

  /// Record a conversation event for analytics
  Future<void> recordConversationEvent({
    required String userId,
    required String conversationId,
    required ConversationEventType eventType,
    Map<String, dynamic>? eventData,
  }) async {
    try {
      final event = ConversationEvent(
        userId: userId,
        conversationId: conversationId,
        eventType: eventType,
        timestamp: DateTime.now(),
        eventData: eventData ?? {},
      );

      await _processConversationEvent(event);
      _logger.d('Recorded conversation event: $eventType for user: $userId');
    } catch (e) {
      _logger.e('Failed to record conversation event: $e');
    }
  }

  /// Record a translation quality event
  Future<void> recordTranslationQuality({
    required String userId,
    required String conversationId,
    required String originalText,
    required String translatedText,
    required double confidence,
    required Map<String, dynamic> qualityFactors,
  }) async {
    try {
      final qualityEvent = TranslationQualityEvent(
        userId: userId,
        conversationId: conversationId,
        originalText: originalText,
        translatedText: translatedText,
        confidence: confidence,
        qualityFactors: qualityFactors,
        timestamp: DateTime.now(),
      );

      await _processQualityEvent(qualityEvent);
    } catch (e) {
      _logger.e('Failed to record translation quality: $e');
    }
  }

  /// Record user engagement activity
  Future<void> recordEngagement({
    required String userId,
    required EngagementType engagementType,
    required Duration duration,
    Map<String, dynamic>? context,
  }) async {
    try {
      final engagement = EngagementEvent(
        userId: userId,
        type: engagementType,
        duration: duration,
        timestamp: DateTime.now(),
        context: context ?? {},
      );

      _engagementEvents.putIfAbsent(userId, () => []);
      _engagementEvents[userId]!.add(engagement);

      // Keep only recent engagement events (last 1000)
      if (_engagementEvents[userId]!.length > 1000) {
        _engagementEvents[userId]!.removeAt(0);
      }

      await _updateUserEngagementMetrics(userId);
    } catch (e) {
      _logger.e('Failed to record engagement: $e');
    }
  }

  /// Get comprehensive analytics for a user
  Future<UserAnalytics> getUserAnalytics(String userId) async {
    try {
      // Check if we have cached analytics
      if (_userAnalytics.containsKey(userId)) {
        final analytics = _userAnalytics[userId]!;
        // Return cached if recent (less than 1 hour old)
        if (DateTime.now().difference(analytics.lastUpdated).inHours < 1) {
          return analytics;
        }
      }

      // Generate fresh analytics
      return await _generateUserAnalytics(userId);
    } catch (e) {
      _logger.e('Failed to get user analytics: $e');
      return UserAnalytics.empty(userId);
    }
  }

  /// Get conversation insights for a specific conversation
  Future<ConversationInsights> getConversationInsights(
      String conversationId) async {
    try {
      if (_conversationInsights.containsKey(conversationId)) {
        return _conversationInsights[conversationId]!;
      }

      // Generate insights for this conversation
      return await _generateConversationInsights(conversationId);
    } catch (e) {
      _logger.e('Failed to get conversation insights: $e');
      return ConversationInsights.empty(conversationId);
    }
  }

  /// Get real-time analytics stream for a user
  Stream<AnalyticsEvent> getAnalyticsStream(String userId) {
    _analyticsStreams.putIfAbsent(
        userId, () => StreamController<AnalyticsEvent>.broadcast());
    return _analyticsStreams[userId]!.stream;
  }

  /// Get translation quality trends
  Future<QualityTrends> getQualityTrends({
    required String userId,
    Duration? timeframe,
  }) async {
    try {
      final qualityMetrics = _qualityMetrics[userId];
      if (qualityMetrics == null) {
        return QualityTrends.empty();
      }

      final endTime = DateTime.now();
      final startTime = timeframe != null
          ? endTime.subtract(timeframe)
          : endTime.subtract(const Duration(days: 30));

      return await _calculateQualityTrends(qualityMetrics, startTime, endTime);
    } catch (e) {
      _logger.e('Failed to get quality trends: $e');
      return QualityTrends.empty();
    }
  }

  /// Get engagement analytics
  Future<EngagementAnalytics> getEngagementAnalytics(String userId) async {
    try {
      final engagements = _engagementEvents[userId] ?? [];
      return await _analyzeEngagementPatterns(userId, engagements);
    } catch (e) {
      _logger.e('Failed to get engagement analytics: $e');
      return EngagementAnalytics.empty(userId);
    }
  }

  /// Get conversation flow analysis
  Future<ConversationFlowAnalysis> analyzeConversationFlow(
      String conversationId) async {
    try {
      final context =
          await _neuralEngine.getConversationContext(conversationId);
      if (context == null) {
        return ConversationFlowAnalysis.empty(conversationId);
      }

      return await _analyzeFlowPatterns(context);
    } catch (e) {
      _logger.e('Failed to analyze conversation flow: $e');
      return ConversationFlowAnalysis.empty(conversationId);
    }
  }

  /// Get predictive insights about user behavior
  Future<PredictiveUserInsights> getPredictiveInsights(String userId) async {
    try {
      final userAnalytics = await getUserAnalytics(userId);
      final engagementAnalytics = await getEngagementAnalytics(userId);

      return await _generatePredictiveInsights(
          userAnalytics, engagementAnalytics);
    } catch (e) {
      _logger.e('Failed to generate predictive insights: $e');
      return PredictiveUserInsights.empty(userId);
    }
  }

  // ===== PRIVATE ANALYTICS METHODS =====

  Future<void> _processConversationEvent(ConversationEvent event) async {
    // Update user analytics
    final analytics =
        _userAnalytics[event.userId] ?? UserAnalytics.empty(event.userId);

    // Update conversation count
    if (event.eventType == ConversationEventType.conversationStarted) {
      analytics.totalConversations++;
    }

    // Update turn count
    if (event.eventType == ConversationEventType.turnCompleted) {
      analytics.totalTurns++;
    }

    // Update language usage
    if (event.eventData.containsKey('sourceLanguage') &&
        event.eventData.containsKey('targetLanguage')) {
      final languagePair =
          '${event.eventData['sourceLanguage']}-${event.eventData['targetLanguage']}';
      analytics.languageUsage[languagePair] =
          (analytics.languageUsage[languagePair] ?? 0) + 1;
    }

    analytics.lastUpdated = DateTime.now();
    _userAnalytics[event.userId] = analytics;

    // Emit real-time analytics event
    _emitAnalyticsEvent(
        event.userId,
        AnalyticsEvent(
          type: AnalyticsEventType.conversationActivity,
          data: {
            'event_type': event.eventType.name,
            'conversation_id': event.conversationId,
            ...event.eventData,
          },
          timestamp: event.timestamp,
        ));
  }

  Future<void> _processQualityEvent(TranslationQualityEvent event) async {
    final metrics =
        _qualityMetrics[event.userId] ?? QualityMetrics.empty(event.userId);

    // Update quality scores
    metrics.qualityScores.add(QualityScore(
      confidence: event.confidence,
      timestamp: event.timestamp,
      factors: event.qualityFactors,
    ));

    // Keep only recent quality scores (last 1000)
    if (metrics.qualityScores.length > 1000) {
      metrics.qualityScores.removeAt(0);
    }

    // Update averages
    final recentScores = metrics.qualityScores.take(100);
    metrics.averageConfidence =
        recentScores.map((s) => s.confidence).reduce((a, b) => a + b) /
            recentScores.length;

    metrics.lastUpdated = DateTime.now();
    _qualityMetrics[event.userId] = metrics;

    // Emit quality analytics event
    _emitAnalyticsEvent(
        event.userId,
        AnalyticsEvent(
          type: AnalyticsEventType.qualityUpdate,
          data: {
            'confidence': event.confidence,
            'average_confidence': metrics.averageConfidence,
            'quality_factors': event.qualityFactors,
          },
          timestamp: event.timestamp,
        ));
  }

  Future<UserAnalytics> _generateUserAnalytics(String userId) async {
    final analytics = _userAnalytics[userId] ?? UserAnalytics.empty(userId);

    // Get personality profile for insights
    final personalityProfile =
        await _personalityEngine.getPersonalityProfile(userId);

    // Get predictive analytics
    final predictiveAnalytics =
        await _predictiveService.getPredictionAnalytics(userId);

    // Calculate usage patterns
    final engagements = _engagementEvents[userId] ?? [];
    final usagePatterns = _calculateUsagePatterns(engagements);

    // Calculate satisfaction score
    final satisfactionScore = await _calculateSatisfactionScore(userId);

    // Update analytics
    analytics.personalityProfile = personalityProfile;
    analytics.usagePatterns = usagePatterns;
    analytics.satisfactionScore = satisfactionScore;
    analytics.predictionAccuracy = predictiveAnalytics.overallAccuracy;
    analytics.lastUpdated = DateTime.now();

    _userAnalytics[userId] = analytics;
    return analytics;
  }

  Future<ConversationInsights> _generateConversationInsights(
      String conversationId) async {
    // Get conversation context from neural engine
    final context = await _neuralEngine.getConversationContext(conversationId);
    if (context == null) {
      return ConversationInsights.empty(conversationId);
    }

    // Analyze conversation flow
    final flowAnalysis = await _analyzeFlowPatterns(context);

    // Analyze emotional journey
    final emotionalJourney = _analyzeEmotionalJourney(context.emotionalFlow);

    // Calculate engagement metrics
    final engagementScore = _calculateConversationEngagement(context);

    // Identify key moments
    final keyMoments = _identifyKeyMoments(context);

    // Generate improvement suggestions
    final suggestions = _generateConversationSuggestions(context);

    final insights = ConversationInsights(
      conversationId: conversationId,
      flowAnalysis: flowAnalysis,
      emotionalJourney: emotionalJourney,
      engagementScore: engagementScore,
      keyMoments: keyMoments,
      suggestions: suggestions,
      generatedAt: DateTime.now(),
    );

    _conversationInsights[conversationId] = insights;
    return insights;
  }

  Future<void> _updateUserEngagementMetrics(String userId) async {
    final analytics = _userAnalytics[userId] ?? UserAnalytics.empty(userId);
    final engagements = _engagementEvents[userId] ?? [];

    if (engagements.isNotEmpty) {
      // Calculate average session duration
      final sessions =
          engagements.where((e) => e.type == EngagementType.session);
      if (sessions.isNotEmpty) {
        analytics.averageSessionDuration = Duration(
            milliseconds: sessions
                    .map((s) => s.duration.inMilliseconds)
                    .reduce((a, b) => a + b) ~/
                sessions.length);
      }

      // Calculate streak
      analytics.streakDays = _calculateEngagementStreak(engagements);
    }

    analytics.lastUpdated = DateTime.now();
    _userAnalytics[userId] = analytics;
  }

  void _emitAnalyticsEvent(String userId, AnalyticsEvent event) {
    if (_analyticsStreams.containsKey(userId)) {
      _analyticsStreams[userId]!.add(event);
    }
  }

  void _startBackgroundAnalytics() {
    // Start periodic analytics processing
    Timer.periodic(const Duration(minutes: 5), (timer) {
      _processBackgroundAnalytics();
    });
  }

  Future<void> _processBackgroundAnalytics() async {
    try {
      // Clean up old data
      _cleanupOldAnalytics();

      // Generate insights for active users
      final activeUserIds = _userAnalytics.keys.where((userId) {
        final analytics = _userAnalytics[userId]!;
        return DateTime.now().difference(analytics.lastUpdated).inHours < 24;
      });

      for (final userId in activeUserIds) {
        await _updateUserAnalytics(userId);
      }
    } catch (e) {
      _logger.e('Background analytics processing failed: $e');
    }
  }

  // ===== ANALYTICS CALCULATION METHODS =====

  UsagePatterns _calculateUsagePatterns(List<EngagementEvent> engagements) {
    if (engagements.isEmpty) {
      return UsagePatterns.empty();
    }

    final hourlyUsage = <int, int>{};
    final dailyUsage = <int, int>{}; // Day of week
    final featureUsage = <String, int>{};

    for (final engagement in engagements) {
      final hour = engagement.timestamp.hour;
      final dayOfWeek = engagement.timestamp.weekday;

      hourlyUsage[hour] = (hourlyUsage[hour] ?? 0) + 1;
      dailyUsage[dayOfWeek] = (dailyUsage[dayOfWeek] ?? 0) + 1;

      // Feature usage from context
      final feature = engagement.context['feature'] as String?;
      if (feature != null) {
        featureUsage[feature] = (featureUsage[feature] ?? 0) + 1;
      }
    }

    // Find peak hours
    final peakHour =
        hourlyUsage.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // Find most active day
    final mostActiveDay =
        dailyUsage.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return UsagePatterns(
      peakUsageHour: peakHour,
      mostActiveDay: mostActiveDay,
      hourlyDistribution: hourlyUsage,
      dailyDistribution: dailyUsage,
      featureUsage: featureUsage,
      totalSessions:
          engagements.where((e) => e.type == EngagementType.session).length,
    );
  }

  Future<double> _calculateSatisfactionScore(String userId) async {
    // Combine various factors to calculate satisfaction
    final qualityMetrics = _qualityMetrics[userId];
    final engagements = _engagementEvents[userId] ?? [];

    double score = 0.5; // Base score

    // Quality factor (30% weight)
    if (qualityMetrics != null && qualityMetrics.averageConfidence > 0) {
      score += qualityMetrics.averageConfidence * 0.3;
    }

    // Engagement factor (40% weight)
    if (engagements.isNotEmpty) {
      final recentEngagements = engagements
          .where((e) => DateTime.now().difference(e.timestamp).inDays < 7)
          .length;
      final engagementScore = (recentEngagements / 7).clamp(0.0, 1.0);
      score += engagementScore * 0.4;
    }

    // Feature usage diversity factor (30% weight)
    final usagePatterns = _calculateUsagePatterns(engagements);
    final featureCount = usagePatterns.featureUsage.length;
    final diversityScore =
        (featureCount / 10).clamp(0.0, 1.0); // Assuming max 10 features
    score += diversityScore * 0.3;

    return score.clamp(0.0, 1.0);
  }

  EmotionalJourney _analyzeEmotionalJourney(EmotionalContext emotionalFlow) {
    final trajectory = emotionalFlow.emotionalTrajectory;
    if (trajectory.isEmpty) {
      return EmotionalJourney.empty();
    }

    // Calculate emotional progression
    final progression = <EmotionalStateChange>[];
    for (int i = 1; i < trajectory.length; i++) {
      final from = trajectory[i - 1];
      final to = trajectory[i];

      progression.add(EmotionalStateChange(
        from: from,
        to: to,
        change: to.distanceTo(from),
        timestamp: DateTime.now(), // Would use actual timestamps in production
      ));
    }

    // Find dominant emotions
    final dominantEmotion = emotionalFlow.dominantEmotion;

    // Calculate emotional stability
    final volatility = emotionalFlow.emotionalVolatility;

    return EmotionalJourney(
      progression: progression,
      dominantEmotion: dominantEmotion,
      volatility: volatility,
      milestones: emotionalFlow.milestones,
      overallMood: emotionalFlow.overallMood,
    );
  }

  double _calculateConversationEngagement(NeuralConversationContext context) {
    double engagement = 0.5; // Base engagement

    // Factor in conversation length
    final turnCount = context.conversationHistory.length;
    engagement +=
        (turnCount / 20).clamp(0.0, 0.3); // More turns = higher engagement

    // Factor in coherence
    engagement += context.currentState.coherence * 0.3;

    // Factor in topic diversity
    final topicCount = context.topicEvolution.currentTopics.length;
    engagement += (topicCount / 5).clamp(0.0, 0.2);

    return engagement.clamp(0.0, 1.0);
  }

  List<ConversationKeyMoment> _identifyKeyMoments(
      NeuralConversationContext context) {
    final keyMoments = <ConversationKeyMoment>[];

    // Add emotional milestones as key moments
    for (final milestone in context.emotionalFlow.milestones) {
      keyMoments.add(ConversationKeyMoment(
        type: KeyMomentType.emotionalShift,
        timestamp: milestone.timestamp,
        description: milestone.description,
        significance: milestone.significance,
        relatedData: {
          'milestone_type': milestone.type.name,
          'emotion': milestone.emotion.toJson(),
        },
      ));
    }

    // Add topic transitions as key moments
    for (final transition in context.topicEvolution.topicHistory) {
      if (transition.smoothness < 0.5) {
        // Significant topic changes
        keyMoments.add(ConversationKeyMoment(
          type: KeyMomentType.topicShift,
          timestamp: transition.timestamp,
          description:
              'Topic changed from ${transition.fromTopic} to ${transition.toTopic}',
          significance: 1.0 - transition.smoothness,
          relatedData: {
            'from_topic': transition.fromTopic,
            'to_topic': transition.toTopic,
            'trigger': transition.trigger,
          },
        ));
      }
    }

    // Sort by significance
    keyMoments.sort((a, b) => b.significance.compareTo(a.significance));

    return keyMoments.take(10).toList(); // Return top 10 key moments
  }

  List<String> _generateConversationSuggestions(
      NeuralConversationContext context) {
    final suggestions = <String>[];

    // Low engagement suggestions
    if (context.currentState.engagement < 0.6) {
      suggestions.add(
          'Try asking more engaging questions to improve conversation flow');
    }

    // Low coherence suggestions
    if (context.currentState.coherence < 0.7) {
      suggestions
          .add('Provide more context to maintain conversation coherence');
    }

    // High volatility suggestions
    if (context.emotionalFlow.emotionalVolatility > 0.7) {
      suggestions.add(
          'Consider moderating emotional intensity for smoother communication');
    }

    return suggestions;
  }

  Future<ConversationFlowAnalysis> _analyzeFlowPatterns(
      NeuralConversationContext context) async {
    final turns = context.conversationHistory;
    if (turns.isEmpty) {
      return ConversationFlowAnalysis.empty(context.conversationId);
    }

    // Analyze turn patterns
    final turnDurations = <Duration>[];
    for (int i = 1; i < turns.length; i++) {
      final duration = turns[i].timestamp.difference(turns[i - 1].timestamp);
      turnDurations.add(duration);
    }

    final averageTurnDuration = turnDurations.isNotEmpty
        ? Duration(
            milliseconds: turnDurations
                    .map((d) => d.inMilliseconds)
                    .reduce((a, b) => a + b) ~/
                turnDurations.length)
        : Duration.zero;

    // Analyze conversation phases
    final phases = _identifyConversationPhases(turns);

    // Calculate flow quality metrics
    final flowQuality = _calculateFlowQuality(context);

    return ConversationFlowAnalysis(
      conversationId: context.conversationId,
      totalTurns: turns.length,
      averageTurnDuration: averageTurnDuration,
      phases: phases,
      flowQuality: flowQuality,
      coherenceScore: context.currentState.coherence,
      engagementScore: context.currentState.engagement,
    );
  }

  List<ConversationPhaseInfo> _identifyConversationPhases(
      List<ConversationTurn> turns) {
    final phases = <ConversationPhaseInfo>[];

    if (turns.isEmpty) return phases;

    // Simple phase identification based on turn count
    final totalTurns = turns.length;

    if (totalTurns >= 1) {
      phases.add(ConversationPhaseInfo(
        phase: ConversationPhase.opening,
        startTurn: 0,
        endTurn: min(2, totalTurns - 1),
        duration: turns.length > 1
            ? turns[min(2, totalTurns - 1)]
                .timestamp
                .difference(turns[0].timestamp)
            : Duration.zero,
      ));
    }

    if (totalTurns >= 3) {
      phases.add(ConversationPhaseInfo(
        phase: ConversationPhase.building,
        startTurn: 3,
        endTurn: (totalTurns * 0.8).floor(),
        duration: turns[(totalTurns * 0.8).floor()]
            .timestamp
            .difference(turns[3].timestamp),
      ));
    }

    if (totalTurns >= 5) {
      phases.add(ConversationPhaseInfo(
        phase: ConversationPhase.closing,
        startTurn: (totalTurns * 0.8).floor() + 1,
        endTurn: totalTurns - 1,
        duration: turns[totalTurns - 1]
            .timestamp
            .difference(turns[(totalTurns * 0.8).floor() + 1].timestamp),
      ));
    }

    return phases;
  }

  double _calculateFlowQuality(NeuralConversationContext context) {
    double quality = 0.0;

    // Coherence factor (40%)
    quality += context.currentState.coherence * 0.4;

    // Engagement factor (30%)
    quality += context.currentState.engagement * 0.3;

    // Emotional stability factor (30%)
    quality += (1.0 - context.emotionalFlow.emotionalVolatility) * 0.3;

    return quality.clamp(0.0, 1.0);
  }

  int _calculateEngagementStreak(List<EngagementEvent> engagements) {
    if (engagements.isEmpty) return 0;

    // Sort by timestamp descending
    final sortedEngagements = List<EngagementEvent>.from(engagements)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    int streak = 0;
    final today = DateTime.now();
    final uniqueDays = <String>{};

    for (final engagement in sortedEngagements) {
      final dayKey =
          '${engagement.timestamp.year}-${engagement.timestamp.month}-${engagement.timestamp.day}';

      if (uniqueDays.add(dayKey)) {
        final daysDifference = today.difference(engagement.timestamp).inDays;
        if (daysDifference <= streak + 1) {
          streak++;
        } else {
          break;
        }
      }
    }

    return streak;
  }

  Future<QualityTrends> _calculateQualityTrends(
    QualityMetrics metrics,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final relevantScores = metrics.qualityScores
        .where((score) =>
            score.timestamp.isAfter(startTime) &&
            score.timestamp.isBefore(endTime))
        .toList();

    if (relevantScores.isEmpty) {
      return QualityTrends.empty();
    }

    // Calculate trend over time
    final dailyAverages = <DateTime, double>{};

    for (final score in relevantScores) {
      final day = DateTime(
          score.timestamp.year, score.timestamp.month, score.timestamp.day);

      if (dailyAverages.containsKey(day)) {
        dailyAverages[day] = (dailyAverages[day]! + score.confidence) / 2;
      } else {
        dailyAverages[day] = score.confidence;
      }
    }

    // Calculate trend direction
    final sortedDays = dailyAverages.keys.toList()..sort();
    TrendDirection trend = TrendDirection.stable;

    if (sortedDays.length >= 2) {
      final firstHalf = sortedDays.take(sortedDays.length ~/ 2);
      final secondHalf = sortedDays.skip(sortedDays.length ~/ 2);

      final firstAvg =
          firstHalf.map((day) => dailyAverages[day]!).reduce((a, b) => a + b) /
              firstHalf.length;
      final secondAvg =
          secondHalf.map((day) => dailyAverages[day]!).reduce((a, b) => a + b) /
              secondHalf.length;

      final difference = secondAvg - firstAvg;
      if (difference > 0.05) {
        trend = TrendDirection.improving;
      } else if (difference < -0.05) {
        trend = TrendDirection.declining;
      }
    }

    return QualityTrends(
      timeframe: endTime.difference(startTime),
      averageQuality:
          relevantScores.map((s) => s.confidence).reduce((a, b) => a + b) /
              relevantScores.length,
      trendDirection: trend,
      dailyAverages: dailyAverages,
      totalDataPoints: relevantScores.length,
    );
  }

  Future<EngagementAnalytics> _analyzeEngagementPatterns(
      String userId, List<EngagementEvent> engagements) async {
    if (engagements.isEmpty) {
      return EngagementAnalytics.empty(userId);
    }

    final totalSessions =
        engagements.where((e) => e.type == EngagementType.session).length;
    final averageSessionDuration = engagements
            .where((e) => e.type == EngagementType.session)
            .map((e) => e.duration.inMinutes)
            .fold<int>(0, (sum, duration) => sum + duration) /
        max(totalSessions, 1);

    final streak = _calculateEngagementStreak(engagements);

    final usagePatterns = _calculateUsagePatterns(engagements);

    return EngagementAnalytics(
      userId: userId,
      totalSessions: totalSessions,
      averageSessionDuration: Duration(minutes: averageSessionDuration.round()),
      streakDays: streak,
      usagePatterns: usagePatterns,
      lastEngagement:
          engagements.isNotEmpty ? engagements.last.timestamp : DateTime.now(),
      generatedAt: DateTime.now(),
    );
  }

  Future<PredictiveUserInsights> _generatePredictiveInsights(
    UserAnalytics userAnalytics,
    EngagementAnalytics engagementAnalytics,
  ) async {
    final predictions = <String>[];
    final recommendations = <String>[];

    // Predict based on engagement patterns
    if (engagementAnalytics.streakDays > 7) {
      predictions.add('User likely to continue high engagement');
      recommendations.add('Introduce advanced features to maintain interest');
    } else if (engagementAnalytics.streakDays < 3) {
      predictions.add('Risk of user disengagement');
      recommendations.add('Send engagement notifications or offer tutorials');
    }

    // Predict based on satisfaction score
    if (userAnalytics.satisfactionScore > 0.8) {
      predictions.add('High satisfaction indicates strong user retention');
      recommendations.add('Consider asking for app review or referrals');
    } else if (userAnalytics.satisfactionScore < 0.6) {
      predictions.add('Lower satisfaction may lead to churn');
      recommendations.add('Investigate user pain points and provide support');
    }

    // Predict based on usage patterns
    final peakHour = engagementAnalytics.usagePatterns.peakUsageHour;
    predictions.add('User most active around ${peakHour}:00');
    recommendations
        .add('Schedule notifications and updates around peak usage time');

    return PredictiveUserInsights(
      userId: userAnalytics.userId,
      predictions: predictions,
      recommendations: recommendations,
      confidenceScore: 0.75, // Would be calculated based on data quality
      generatedAt: DateTime.now(),
    );
  }

  Future<void> _updateUserAnalytics(String userId) async {
    try {
      await _generateUserAnalytics(userId);
    } catch (e) {
      _logger.e('Failed to update user analytics for $userId: $e');
    }
  }

  void _cleanupOldAnalytics() {
    final cutoffTime = DateTime.now().subtract(const Duration(days: 30));

    // Clean up old engagement events
    _engagementEvents.forEach((userId, events) {
      _engagementEvents[userId] =
          events.where((event) => event.timestamp.isAfter(cutoffTime)).toList();
    });

    // Clean up old quality metrics
    _qualityMetrics.forEach((userId, metrics) {
      metrics.qualityScores
          .removeWhere((score) => score.timestamp.isBefore(cutoffTime));
    });
  }

  /// Dispose resources
  void dispose() {
    for (final controller in _analyticsStreams.values) {
      controller.close();
    }
    _analyticsStreams.clear();
  }
}

// ===== ANALYTICS DATA MODELS =====

/// Comprehensive user analytics
class UserAnalytics {
  final String userId;
  int totalConversations;
  int totalTurns;
  Map<String, int> languageUsage;
  UserPersonalityProfile? personalityProfile;
  UsagePatterns usagePatterns;
  double satisfactionScore;
  double predictionAccuracy;
  Duration averageSessionDuration;
  int streakDays;
  DateTime lastUpdated;

  UserAnalytics({
    required this.userId,
    this.totalConversations = 0,
    this.totalTurns = 0,
    this.languageUsage = const {},
    this.personalityProfile,
    required this.usagePatterns,
    this.satisfactionScore = 0.0,
    this.predictionAccuracy = 0.0,
    this.averageSessionDuration = Duration.zero,
    this.streakDays = 0,
    required this.lastUpdated,
  });

  factory UserAnalytics.empty(String userId) {
    return UserAnalytics(
      userId: userId,
      usagePatterns: UsagePatterns.empty(),
      lastUpdated: DateTime.now(),
    );
  }
}

/// Usage patterns analysis
class UsagePatterns {
  final int peakUsageHour;
  final int mostActiveDay;
  final Map<int, int> hourlyDistribution;
  final Map<int, int> dailyDistribution;
  final Map<String, int> featureUsage;
  final int totalSessions;

  const UsagePatterns({
    required this.peakUsageHour,
    required this.mostActiveDay,
    required this.hourlyDistribution,
    required this.dailyDistribution,
    required this.featureUsage,
    required this.totalSessions,
  });

  factory UsagePatterns.empty() {
    return const UsagePatterns(
      peakUsageHour: 12,
      mostActiveDay: 1,
      hourlyDistribution: {},
      dailyDistribution: {},
      featureUsage: {},
      totalSessions: 0,
    );
  }
}

/// Conversation insights
class ConversationInsights {
  final String conversationId;
  final ConversationFlowAnalysis flowAnalysis;
  final EmotionalJourney emotionalJourney;
  final double engagementScore;
  final List<ConversationKeyMoment> keyMoments;
  final List<String> suggestions;
  final DateTime generatedAt;

  const ConversationInsights({
    required this.conversationId,
    required this.flowAnalysis,
    required this.emotionalJourney,
    required this.engagementScore,
    required this.keyMoments,
    required this.suggestions,
    required this.generatedAt,
  });

  factory ConversationInsights.empty(String conversationId) {
    return ConversationInsights(
      conversationId: conversationId,
      flowAnalysis: ConversationFlowAnalysis.empty(conversationId),
      emotionalJourney: EmotionalJourney.empty(),
      engagementScore: 0.0,
      keyMoments: [],
      suggestions: [],
      generatedAt: DateTime.now(),
    );
  }
}

/// Quality metrics tracking
class QualityMetrics {
  final String userId;
  final List<QualityScore> qualityScores;
  double averageConfidence;
  DateTime lastUpdated;

  QualityMetrics({
    required this.userId,
    required this.qualityScores,
    this.averageConfidence = 0.0,
    required this.lastUpdated,
  });

  factory QualityMetrics.empty(String userId) {
    return QualityMetrics(
      userId: userId,
      qualityScores: [],
      lastUpdated: DateTime.now(),
    );
  }
}

/// Individual quality score
class QualityScore {
  final double confidence;
  final DateTime timestamp;
  final Map<String, dynamic> factors;

  const QualityScore({
    required this.confidence,
    required this.timestamp,
    required this.factors,
  });
}

/// Quality trends analysis
class QualityTrends {
  final Duration timeframe;
  final double averageQuality;
  final TrendDirection trendDirection;
  final Map<DateTime, double> dailyAverages;
  final int totalDataPoints;

  const QualityTrends({
    required this.timeframe,
    required this.averageQuality,
    required this.trendDirection,
    required this.dailyAverages,
    required this.totalDataPoints,
  });

  factory QualityTrends.empty() {
    return const QualityTrends(
      timeframe: Duration.zero,
      averageQuality: 0.0,
      trendDirection: TrendDirection.stable,
      dailyAverages: {},
      totalDataPoints: 0,
    );
  }
}

/// Engagement analytics
class EngagementAnalytics {
  final String userId;
  final int totalSessions;
  final Duration averageSessionDuration;
  final int streakDays;
  final UsagePatterns usagePatterns;
  final DateTime lastEngagement;
  final DateTime generatedAt;

  const EngagementAnalytics({
    required this.userId,
    required this.totalSessions,
    required this.averageSessionDuration,
    required this.streakDays,
    required this.usagePatterns,
    required this.lastEngagement,
    required this.generatedAt,
  });

  factory EngagementAnalytics.empty(String userId) {
    return EngagementAnalytics(
      userId: userId,
      totalSessions: 0,
      averageSessionDuration: Duration.zero,
      streakDays: 0,
      usagePatterns: UsagePatterns.empty(),
      lastEngagement: DateTime.now(),
      generatedAt: DateTime.now(),
    );
  }
}

/// Conversation flow analysis
class ConversationFlowAnalysis {
  final String conversationId;
  final int totalTurns;
  final Duration averageTurnDuration;
  final List<ConversationPhaseInfo> phases;
  final double flowQuality;
  final double coherenceScore;
  final double engagementScore;

  const ConversationFlowAnalysis({
    required this.conversationId,
    required this.totalTurns,
    required this.averageTurnDuration,
    required this.phases,
    required this.flowQuality,
    required this.coherenceScore,
    required this.engagementScore,
  });

  factory ConversationFlowAnalysis.empty(String conversationId) {
    return ConversationFlowAnalysis(
      conversationId: conversationId,
      totalTurns: 0,
      averageTurnDuration: Duration.zero,
      phases: [],
      flowQuality: 0.0,
      coherenceScore: 0.0,
      engagementScore: 0.0,
    );
  }
}

/// Conversation phase information
class ConversationPhaseInfo {
  final ConversationPhase phase;
  final int startTurn;
  final int endTurn;
  final Duration duration;

  const ConversationPhaseInfo({
    required this.phase,
    required this.startTurn,
    required this.endTurn,
    required this.duration,
  });
}

/// Emotional journey analysis
class EmotionalJourney {
  final List<EmotionalStateChange> progression;
  final EmotionVector dominantEmotion;
  final double volatility;
  final List<EmotionalMilestone> milestones;
  final ConversationMood overallMood;

  const EmotionalJourney({
    required this.progression,
    required this.dominantEmotion,
    required this.volatility,
    required this.milestones,
    required this.overallMood,
  });

  factory EmotionalJourney.empty() {
    return EmotionalJourney(
      progression: [],
      dominantEmotion:
          EmotionVector(valence: 0, arousal: 0, dominance: 0, certainty: 0),
      volatility: 0.0,
      milestones: [],
      overallMood: ConversationMood.friendly,
    );
  }
}

/// Emotional state change
class EmotionalStateChange {
  final EmotionVector from;
  final EmotionVector to;
  final double change;
  final DateTime timestamp;

  const EmotionalStateChange({
    required this.from,
    required this.to,
    required this.change,
    required this.timestamp,
  });
}

/// Conversation key moment
class ConversationKeyMoment {
  final KeyMomentType type;
  final DateTime timestamp;
  final String description;
  final double significance;
  final Map<String, dynamic> relatedData;

  const ConversationKeyMoment({
    required this.type,
    required this.timestamp,
    required this.description,
    required this.significance,
    required this.relatedData,
  });
}

/// Predictive user insights
class PredictiveUserInsights {
  final String userId;
  final List<String> predictions;
  final List<String> recommendations;
  final double confidenceScore;
  final DateTime generatedAt;

  const PredictiveUserInsights({
    required this.userId,
    required this.predictions,
    required this.recommendations,
    required this.confidenceScore,
    required this.generatedAt,
  });

  factory PredictiveUserInsights.empty(String userId) {
    return PredictiveUserInsights(
      userId: userId,
      predictions: [],
      recommendations: [],
      confidenceScore: 0.0,
      generatedAt: DateTime.now(),
    );
  }
}

/// Analytics events
class ConversationEvent {
  final String userId;
  final String conversationId;
  final ConversationEventType eventType;
  final DateTime timestamp;
  final Map<String, dynamic> eventData;

  const ConversationEvent({
    required this.userId,
    required this.conversationId,
    required this.eventType,
    required this.timestamp,
    required this.eventData,
  });
}

/// Translation quality event
class TranslationQualityEvent {
  final String userId;
  final String conversationId;
  final String originalText;
  final String translatedText;
  final double confidence;
  final Map<String, dynamic> qualityFactors;
  final DateTime timestamp;

  const TranslationQualityEvent({
    required this.userId,
    required this.conversationId,
    required this.originalText,
    required this.translatedText,
    required this.confidence,
    required this.qualityFactors,
    required this.timestamp,
  });
}

/// Engagement event
class EngagementEvent {
  final String userId;
  final EngagementType type;
  final Duration duration;
  final DateTime timestamp;
  final Map<String, dynamic> context;

  const EngagementEvent({
    required this.userId,
    required this.type,
    required this.duration,
    required this.timestamp,
    required this.context,
  });
}

/// Real-time analytics event
class AnalyticsEvent {
  final AnalyticsEventType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const AnalyticsEvent({
    required this.type,
    required this.data,
    required this.timestamp,
  });
}

// ===== ENUMS =====

enum ConversationEventType {
  conversationStarted,
  turnCompleted,
  conversationEnded,
  translationRequested,
  suggestionAccepted,
  feedbackProvided,
}

enum EngagementType {
  session,
  translation,
  feature,
  interaction,
}

enum AnalyticsEventType {
  conversationActivity,
  qualityUpdate,
  engagementChange,
  personalityUpdate,
}

enum TrendDirection {
  improving,
  declining,
  stable,
}

enum KeyMomentType {
  emotionalShift,
  topicShift,
  qualityChange,
  engagementSpike,
}
