// 🎮 LingoSphere - Gamification & Achievement System
// Advanced translation challenges, achievements, and engagement features for Gen Z users

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:logger/logger.dart';

import '../models/gamification_models.dart';
import '../exceptions/translation_exceptions.dart';

/// Gamification & Achievement Service
/// Provides translation challenges, achievements, point scoring, and badge systems for maximum user engagement
class GamificationAchievementService {
  static final GamificationAchievementService _instance =
      GamificationAchievementService._internal();
  factory GamificationAchievementService() => _instance;
  GamificationAchievementService._internal();

  final Logger _logger = Logger();

  // User gamification profiles
  final Map<String, UserGamificationProfile> _userProfiles = {};

  // Active challenges system
  final Map<String, List<TranslationChallenge>> _activeChallenges = {};

  // Achievement tracking system
  final Map<String, List<Achievement>> _userAchievements = {};

  // Point scoring engine
  final Map<String, PointScoringEngine> _scoringEngines = {};

  // Badge collection system
  final Map<String, BadgeCollection> _userBadges = {};

  // Challenge generation engine
  final ChallengeGenerationEngine _challengeEngine =
      ChallengeGenerationEngine();

  // Social engagement tracker
  final Map<String, SocialEngagementTracker> _socialTrackers = {};

  /// Initialize the gamification system
  Future<void> initialize() async {
    // Initialize challenge templates
    await _initializeChallengeTemplates();

    // Initialize achievement definitions
    await _initializeAchievementDefinitions();

    // Initialize badge system
    await _initializeBadgeSystem();

    _logger.i(
        '🎮 Gamification & Achievement System initialized with Gen Z engagement features');
  }

  /// Get or create user gamification profile
  Future<UserGamificationProfile> getOrCreateUserProfile(String userId) async {
    if (_userProfiles.containsKey(userId)) {
      return _userProfiles[userId]!;
    }

    final profile = UserGamificationProfile(
      userId: userId,
      level: 1,
      totalPoints: 0,
      currentStreak: 0,
      longestStreak: 0,
      translationsCompleted: 0,
      challengesCompleted: 0,
      badges: [],
      achievements: [],
      socialStats: SocialStats.initial(),
      preferences: GamePreferences.defaultPreferences(),
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
    );

    _userProfiles[userId] = profile;
    return profile;
  }

  /// Process translation completion for gamification rewards
  Future<GamificationReward> processTranslationCompletion({
    required String userId,
    required String originalText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
    required double translationQuality,
    Map<String, dynamic>? context,
  }) async {
    try {
      final profile = await getOrCreateUserProfile(userId);
      final scoringEngine = await _getOrCreateScoringEngine(userId);

      // Calculate base points for translation
      final basePoints = await _calculateBasePoints(
        originalText,
        translatedText,
        sourceLanguage,
        targetLanguage,
        translationQuality,
      );

      // Apply multipliers and bonuses
      final multipliedPoints = await _applyPointMultipliers(
        basePoints,
        profile,
        context,
      );

      // Check for achievements
      final newAchievements = await _checkForNewAchievements(
        userId,
        profile,
        originalText,
        translationQuality,
      );

      // Check for new badges
      final newBadges = await _checkForNewBadges(
        userId,
        profile,
        sourceLanguage,
        targetLanguage,
      );

      // Update challenge progress
      final challengeUpdates = await _updateChallengeProgress(
        userId,
        originalText,
        translatedText,
        sourceLanguage,
        targetLanguage,
        translationQuality,
      );

      // Check for level up
      final levelUpResult = await _checkForLevelUp(profile, multipliedPoints);

      // Update user profile
      final updatedProfile = await _updateUserProfile(
        profile,
        multipliedPoints,
        newAchievements,
        newBadges,
        levelUpResult,
        challengeUpdates,
      );

      // Generate celebration effects
      final celebrationEffects = await _generateCelebrationEffects(
        newAchievements,
        newBadges,
        levelUpResult,
        challengeUpdates,
      );

      return GamificationReward(
        userId: userId,
        pointsEarned: multipliedPoints,
        newLevel: updatedProfile.level,
        leveledUp: levelUpResult.leveledUp,
        newAchievements: newAchievements,
        newBadges: newBadges,
        challengeUpdates: challengeUpdates,
        celebrationEffects: celebrationEffects,
        streakInfo: StreakInfo(
          currentStreak: updatedProfile.currentStreak,
          longestStreak: updatedProfile.longestStreak,
          streakBonus: _calculateStreakBonus(updatedProfile.currentStreak),
          lastActiveDate: updatedProfile.lastActive,
        ),
        socialStats: updatedProfile.socialStats,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      _logger.e('Gamification processing failed: $e');
      throw TranslationServiceException(
          'Gamification processing failed: ${e.toString()}');
    }
  }

  /// Get available challenges for user
  Future<List<TranslationChallenge>> getAvailableChallenges(
      String userId) async {
    try {
      final profile = await getOrCreateUserProfile(userId);

      // Generate personalized challenges
      final personalizedChallenges =
          await _generatePersonalizedChallenges(profile);

      // Get daily challenges
      final dailyChallenges = await _getDailyChallenges(profile);

      // Get weekly challenges
      final weeklyChallenges = await _getWeeklyChallenges(profile);

      // Get special event challenges
      final eventChallenges = await _getEventChallenges(profile);

      // Combine all challenges
      final allChallenges = [
        ...personalizedChallenges,
        ...dailyChallenges,
        ...weeklyChallenges,
        ...eventChallenges,
      ];

      // Sort by priority and user preferences
      final sortedChallenges =
          await _sortChallengesByRelevance(allChallenges, profile);

      _activeChallenges[userId] = sortedChallenges;
      return sortedChallenges;
    } catch (e) {
      _logger.e('Challenge generation failed: $e');
      return [];
    }
  }

  /// Get user leaderboard position
  Future<LeaderboardPosition> getLeaderboardPosition(String userId) async {
    try {
      final profile = await getOrCreateUserProfile(userId);

      // Get global leaderboard position
      final globalPosition = await _calculateGlobalPosition(profile);

      // Get friends leaderboard position
      final friendsPosition = await _calculateFriendsPosition(userId, profile);

      // Get local leaderboard position (by country/region)
      final localPosition = await _calculateLocalPosition(profile);

      // Get weekly leaderboard position
      final weeklyPosition = await _calculateWeeklyPosition(profile);

      return LeaderboardPosition(
        userId: userId,
        globalRank: globalPosition.rank,
        globalPercentile: globalPosition.percentile,
        friendsRank: friendsPosition.rank,
        friendsTotal: friendsPosition.total,
        localRank: localPosition.rank,
        localTotal: localPosition.total,
        weeklyRank: weeklyPosition.rank,
        weeklyTotal: weeklyPosition.total,
        nearbyUsers: await _getNearbyLeaderboardUsers(userId, globalPosition),
        competitionLevel: _determineCompetitionLevel(profile),
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      _logger.e('Leaderboard calculation failed: $e');
      throw TranslationServiceException(
          'Leaderboard calculation failed: ${e.toString()}');
    }
  }

  /// Get achievement gallery for user
  Future<AchievementGallery> getAchievementGallery(String userId) async {
    try {
      final profile = await getOrCreateUserProfile(userId);
      final userAchievements = _userAchievements[userId] ?? [];

      // Categorize achievements
      final categories = await _categorizeAchievements(userAchievements);

      // Calculate achievement statistics
      final stats = await _calculateAchievementStats(userAchievements);

      // Get next achievements to unlock
      final nextToUnlock = await _getNextAchievementsToUnlock(userId, profile);

      // Get rare achievements
      final rareAchievements = await _getRareAchievements(userAchievements);

      // Get featured achievements
      final featuredAchievements =
          await _getFeaturedAchievements(userAchievements);

      return AchievementGallery(
        userId: userId,
        totalAchievements: userAchievements.length,
        categories: categories,
        statistics: stats,
        nextToUnlock: nextToUnlock,
        rareAchievements: rareAchievements,
        featuredAchievements: featuredAchievements,
        completionPercentage: stats.completionPercentage,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      _logger.e('Achievement gallery generation failed: $e');
      throw TranslationServiceException(
          'Achievement gallery failed: ${e.toString()}');
    }
  }

  /// Share achievement or milestone
  Future<SocialShareResult> shareAchievement({
    required String userId,
    required String achievementId,
    required SocialPlatform platform,
    String? customMessage,
  }) async {
    try {
      final profile = await getOrCreateUserProfile(userId);
      final achievement = await _getAchievementById(userId, achievementId);

      if (achievement == null) {
        throw TranslationServiceException(
            'Achievement not found: $achievementId');
      }

      // Generate share content
      final shareContent = await _generateShareContent(
        profile,
        achievement,
        platform,
        customMessage,
      );

      // Track social engagement
      await _trackSocialEngagement(
        userId,
        SocialEngagementType.share,
        platform,
        achievementId,
      );

      // Update social stats
      await _updateSocialStats(userId, SocialAction.share);

      // Generate viral hooks
      final viralHooks = await _generateViralHooks(achievement, profile);

      return SocialShareResult(
        userId: userId,
        achievementId: achievementId,
        platform: platform,
        shareContent: shareContent,
        shareUrl: await _generateShareUrl(userId, achievementId),
        viralHooks: viralHooks,
        socialImpact: await _calculateSocialImpact(userId, achievement),
        sharedAt: DateTime.now(),
      );
    } catch (e) {
      _logger.e('Social sharing failed: $e');
      throw TranslationServiceException(
          'Social sharing failed: ${e.toString()}');
    }
  }

  // ===== CHALLENGE GENERATION METHODS =====

  Future<List<TranslationChallenge>> _generatePersonalizedChallenges(
    UserGamificationProfile profile,
  ) async {
    final challenges = <TranslationChallenge>[];

    // Language pair challenges based on user history
    if (profile.favoriteLanguagePairs.isNotEmpty) {
      for (final pair in profile.favoriteLanguagePairs.take(3)) {
        challenges.add(TranslationChallenge(
          id: 'lang_pair_${pair.hashCode}',
          title:
              '${_getLanguageName(pair.split('-')[0])} → ${_getLanguageName(pair.split('-')[1])} Master',
          description:
              'Complete 10 high-quality translations in this language pair',
          type: ChallengeType.languagePair,
          difficulty: _calculateChallengeDifficulty(profile.level),
          targetCount: 10,
          currentProgress: 0,
          rewards: ChallengeRewards(
            points: 500 + (profile.level * 50),
            badge: 'Language Pair Specialist',
            title: '${_getLanguageName(pair.split('-')[0])} Expert',
          ),
          timeLimit: Duration(days: 7),
          requirements: {'language_pair': pair, 'min_quality': 0.8},
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(days: 7)),
        ));
      }
    }

    // Streak challenges
    challenges.add(TranslationChallenge(
      id: 'streak_challenge_${DateTime.now().millisecondsSinceEpoch}',
      title: '🔥 Fire Streak Challenge',
      description: 'Maintain a 7-day translation streak',
      type: ChallengeType.streak,
      difficulty: ChallengeDifficulty.medium,
      targetCount: 7,
      currentProgress: profile.currentStreak,
      rewards: ChallengeRewards(
        points: 1000,
        badge: 'Streak Master',
        title: 'Consistency King/Queen',
      ),
      timeLimit: Duration(days: 7),
      requirements: {'consecutive_days': 7},
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(days: 7)),
    ));

    // Quality challenges
    challenges.add(TranslationChallenge(
      id: 'quality_challenge_${DateTime.now().millisecondsSinceEpoch}',
      title: '⭐ Perfection Challenge',
      description: 'Complete 5 translations with 95%+ quality score',
      type: ChallengeType.quality,
      difficulty: ChallengeDifficulty.hard,
      targetCount: 5,
      currentProgress: 0,
      rewards: ChallengeRewards(
        points: 800,
        badge: 'Quality Master',
        title: 'Perfectionist',
      ),
      timeLimit: Duration(days: 3),
      requirements: {'min_quality': 0.95, 'count': 5},
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(days: 3)),
    ));

    return challenges;
  }

  Future<List<TranslationChallenge>> _getDailyChallenges(
    UserGamificationProfile profile,
  ) async {
    final today = DateTime.now();
    final dailyChallengeId = 'daily_${today.year}_${today.month}_${today.day}';

    // Generate different daily challenge based on day of week
    final dayOfWeek = today.weekday;

    switch (dayOfWeek) {
      case 1: // Monday - Motivation Monday
        return [_createMotivationMondayChallenge(dailyChallengeId, profile)];
      case 2: // Tuesday - Technique Tuesday
        return [_createTechniqueTuesdayChallenge(dailyChallengeId, profile)];
      case 3: // Wednesday - Wordplay Wednesday
        return [_createWordplayWednesdayChallenge(dailyChallengeId, profile)];
      case 4: // Thursday - Throwback Thursday
        return [_createThrowbackThursdayChallenge(dailyChallengeId, profile)];
      case 5: // Friday - Fun Friday
        return [_createFunFridayChallenge(dailyChallengeId, profile)];
      case 6: // Saturday - Social Saturday
        return [_createSocialSaturdayChallenge(dailyChallengeId, profile)];
      case 7: // Sunday - Summary Sunday
        return [_createSummarySundayChallenge(dailyChallengeId, profile)];
      default:
        return [_createDefaultDailyChallenge(dailyChallengeId, profile)];
    }
  }

  TranslationChallenge _createMotivationMondayChallenge(
    String id,
    UserGamificationProfile profile,
  ) {
    return TranslationChallenge(
      id: id,
      title: '💪 Motivation Monday',
      description:
          'Start your week strong! Complete 5 translations to boost your motivation',
      type: ChallengeType.daily,
      difficulty: ChallengeDifficulty.easy,
      targetCount: 5,
      currentProgress: 0,
      rewards: ChallengeRewards(
        points: 200,
        badge: 'Monday Warrior',
        title: 'Week Starter',
      ),
      timeLimit: Duration(hours: 24),
      requirements: {'count': 5, 'day': 'monday'},
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(hours: 24)),
    );
  }

  TranslationChallenge _createFunFridayChallenge(
    String id,
    UserGamificationProfile profile,
  ) {
    return TranslationChallenge(
      id: id,
      title: '🎉 Fun Friday',
      description:
          'Translate song lyrics, jokes, or memes for extra fun points!',
      type: ChallengeType.daily,
      difficulty: ChallengeDifficulty.medium,
      targetCount: 3,
      currentProgress: 0,
      rewards: ChallengeRewards(
        points: 300,
        badge: 'Fun Master',
        title: 'Comedy Translator',
      ),
      timeLimit: Duration(hours: 24),
      requirements: {'content_type': 'entertainment', 'count': 3},
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(hours: 24)),
    );
  }

  // ===== ACHIEVEMENT SYSTEM =====

  Future<List<Achievement>> _checkForNewAchievements(
    String userId,
    UserGamificationProfile profile,
    String originalText,
    double quality,
  ) async {
    final newAchievements = <Achievement>[];
    final existingAchievements = _userAchievements[userId] ?? [];
    final existingIds = existingAchievements.map((a) => a.id).toSet();

    // First Translation Achievement
    if (profile.translationsCompleted == 0 &&
        !existingIds.contains('first_translation')) {
      newAchievements.add(Achievement(
        id: 'first_translation',
        title: '🎯 First Steps',
        description: 'Complete your first translation',
        category: AchievementCategory.milestone,
        rarity: AchievementRarity.common,
        points: 50,
        iconUrl: '🎯',
        unlockedAt: DateTime.now(),
      ));
    }

    // Quality achievements
    if (quality >= 0.95 && !existingIds.contains('perfectionist')) {
      newAchievements.add(Achievement(
        id: 'perfectionist',
        title: '⭐ Perfectionist',
        description: 'Achieve 95%+ quality on a translation',
        category: AchievementCategory.quality,
        rarity: AchievementRarity.rare,
        points: 200,
        iconUrl: '⭐',
        unlockedAt: DateTime.now(),
      ));
    }

    // Milestone achievements
    final milestones = [10, 50, 100, 500, 1000, 5000];
    for (final milestone in milestones) {
      final achievementId = 'translations_$milestone';
      if (profile.translationsCompleted >= milestone &&
          !existingIds.contains(achievementId)) {
        newAchievements.add(Achievement(
          id: achievementId,
          title: '🏆 ${_formatMilestone(milestone)} Translations',
          description: 'Complete $milestone translations',
          category: AchievementCategory.milestone,
          rarity: _getMilestoneRarity(milestone),
          points: milestone * 2,
          iconUrl: '🏆',
          unlockedAt: DateTime.now(),
        ));
      }
    }

    // Text length achievements
    if (originalText.length > 500 &&
        !existingIds.contains('long_text_master')) {
      newAchievements.add(Achievement(
        id: 'long_text_master',
        title: '📚 Long Text Master',
        description: 'Translate a text with 500+ characters',
        category: AchievementCategory.special,
        rarity: AchievementRarity.uncommon,
        points: 150,
        iconUrl: '📚',
        unlockedAt: DateTime.now(),
      ));
    }

    return newAchievements;
  }

  // ===== UTILITY METHODS =====

  Future<int> _calculateBasePoints(
    String originalText,
    String translatedText,
    String sourceLanguage,
    String targetLanguage,
    double quality,
  ) async {
    int basePoints = 10; // Base points for any translation

    // Length bonus
    basePoints += (originalText.length / 10).floor();

    // Quality bonus
    basePoints = (basePoints * quality).round();

    // Language difficulty bonus
    final difficultyMultiplier =
        _getLanguageDifficultyMultiplier(sourceLanguage, targetLanguage);
    basePoints = (basePoints * difficultyMultiplier).round();

    return basePoints;
  }

  double _getLanguageDifficultyMultiplier(String source, String target) {
    // More difficult language pairs get higher multipliers
    final difficultPairs = {
      'en-zh': 1.5, // English to Chinese
      'en-ja': 1.5, // English to Japanese
      'en-ar': 1.4, // English to Arabic
      'zh-en': 1.5, // Chinese to English
      'ja-en': 1.5, // Japanese to English
      'ar-en': 1.4, // Arabic to English
    };

    final pair = '$source-$target';
    return difficultPairs[pair] ?? 1.0;
  }

  String _getLanguageName(String code) {
    final names = {
      'en': 'English',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'it': 'Italian',
      'pt': 'Portuguese',
      'zh': 'Chinese',
      'ja': 'Japanese',
      'ko': 'Korean',
      'ar': 'Arabic',
      'ru': 'Russian',
    };
    return names[code] ?? code.toUpperCase();
  }

  String _formatMilestone(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(number % 1000 == 0 ? 0 : 1)}K';
    }
    return number.toString();
  }

  AchievementRarity _getMilestoneRarity(int milestone) {
    if (milestone >= 5000) return AchievementRarity.legendary;
    if (milestone >= 1000) return AchievementRarity.epic;
    if (milestone >= 500) return AchievementRarity.rare;
    if (milestone >= 100) return AchievementRarity.uncommon;
    return AchievementRarity.common;
  }

  ChallengeDifficulty _calculateChallengeDifficulty(int userLevel) {
    if (userLevel < 5) return ChallengeDifficulty.easy;
    if (userLevel < 15) return ChallengeDifficulty.medium;
    if (userLevel < 30) return ChallengeDifficulty.hard;
    return ChallengeDifficulty.extreme;
  }

  double _calculateStreakBonus(int streak) {
    return min(streak * 0.1, 2.0); // Max 200% bonus
  }

  // ===== PLACEHOLDER METHODS FOR COMPILATION =====

  Future<void> _initializeChallengeTemplates() async {}
  Future<void> _initializeAchievementDefinitions() async {}
  Future<void> _initializeBadgeSystem() async {}
  Future<PointScoringEngine> _getOrCreateScoringEngine(String userId) async =>
      PointScoringEngine.create(userId);
  Future<int> _applyPointMultipliers(
          int basePoints,
          UserGamificationProfile profile,
          Map<String, dynamic>? context) async =>
      basePoints;
  Future<List<Badge>> _checkForNewBadges(
          String userId,
          UserGamificationProfile profile,
          String source,
          String target) async =>
      [];
  Future<List<ChallengeUpdate>> _updateChallengeProgress(
          String userId,
          String original,
          String translated,
          String source,
          String target,
          double quality) async =>
      [];
  Future<LevelUpResult> _checkForLevelUp(
          UserGamificationProfile profile, int points) async =>
      LevelUpResult.noLevelUp();
  Future<UserGamificationProfile> _updateUserProfile(
          UserGamificationProfile profile,
          int points,
          List<Achievement> achievements,
          List<Badge> badges,
          LevelUpResult levelUp,
          List<ChallengeUpdate> challenges) async =>
      profile;
  Future<List<CelebrationEffect>> _generateCelebrationEffects(
          List<Achievement> achievements,
          List<Badge> badges,
          LevelUpResult levelUp,
          List<ChallengeUpdate> challenges) async =>
      [];
  Future<List<TranslationChallenge>> _getWeeklyChallenges(
          UserGamificationProfile profile) async =>
      [];
  Future<List<TranslationChallenge>> _getEventChallenges(
          UserGamificationProfile profile) async =>
      [];
  Future<List<TranslationChallenge>> _sortChallengesByRelevance(
          List<TranslationChallenge> challenges,
          UserGamificationProfile profile) async =>
      challenges;
  Future<RankingPosition> _calculateGlobalPosition(
          UserGamificationProfile profile) async =>
      RankingPosition(rank: 100, total: 1000, percentile: 90.0);
  Future<RankingPosition> _calculateFriendsPosition(
          String userId, UserGamificationProfile profile) async =>
      RankingPosition(rank: 5, total: 20, percentile: 75.0);
  Future<RankingPosition> _calculateLocalPosition(
          UserGamificationProfile profile) async =>
      RankingPosition(rank: 50, total: 500, percentile: 90.0);
  Future<RankingPosition> _calculateWeeklyPosition(
          UserGamificationProfile profile) async =>
      RankingPosition(rank: 25, total: 200, percentile: 87.5);
  Future<List<LeaderboardUser>> _getNearbyLeaderboardUsers(
          String userId, RankingPosition position) async =>
      [];
  CompetitionLevel _determineCompetitionLevel(
          UserGamificationProfile profile) =>
      CompetitionLevel.competitive;
  Future<Map<AchievementCategory, List<Achievement>>> _categorizeAchievements(
          List<Achievement> achievements) async =>
      {};
  Future<AchievementStats> _calculateAchievementStats(
          List<Achievement> achievements) async =>
      AchievementStats(
        totalAchievements: achievements.length,
        commonAchievements: achievements.where((a) => a.rarity == AchievementRarity.common).length,
        rareAchievements: achievements.where((a) => a.rarity == AchievementRarity.rare).length,
        epicAchievements: achievements.where((a) => a.rarity == AchievementRarity.epic).length,
        legendaryAchievements: achievements.where((a) => a.rarity == AchievementRarity.legendary).length,
        completionPercentage: 0.0,
        lastUnlocked: achievements.isNotEmpty ? achievements.last.unlockedAt : DateTime.now(),
      );
  Future<List<Achievement>> _getNextAchievementsToUnlock(
          String userId, UserGamificationProfile profile) async =>
      [];
  Future<List<Achievement>> _getRareAchievements(
          List<Achievement> achievements) async =>
      [];
  Future<List<Achievement>> _getFeaturedAchievements(
          List<Achievement> achievements) async =>
      [];
  Future<Achievement?> _getAchievementById(
          String userId, String achievementId) async =>
      null;
  Future<SocialShareContent> _generateShareContent(
          UserGamificationProfile profile,
          Achievement achievement,
          SocialPlatform platform,
          String? message) async =>
      SocialShareContent.empty();
  Future<void> _trackSocialEngagement(String userId, SocialEngagementType type,
      SocialPlatform platform, String contentId) async {}
  Future<void> _updateSocialStats(String userId, SocialAction action) async {}
  Future<List<String>> _generateViralHooks(
          Achievement achievement, UserGamificationProfile profile) async =>
      [];
  Future<String> _generateShareUrl(String userId, String achievementId) async =>
      'https://lingosphere.com/share/$userId/$achievementId';
  Future<double> _calculateSocialImpact(
          String userId, Achievement achievement) async =>
      0.8;
  TranslationChallenge _createTechniqueTuesdayChallenge(
          String id, UserGamificationProfile profile) =>
      _createDefaultDailyChallenge(id, profile);
  TranslationChallenge _createWordplayWednesdayChallenge(
          String id, UserGamificationProfile profile) =>
      _createDefaultDailyChallenge(id, profile);
  TranslationChallenge _createThrowbackThursdayChallenge(
          String id, UserGamificationProfile profile) =>
      _createDefaultDailyChallenge(id, profile);
  TranslationChallenge _createSocialSaturdayChallenge(
          String id, UserGamificationProfile profile) =>
      _createDefaultDailyChallenge(id, profile);
  TranslationChallenge _createSummarySundayChallenge(
          String id, UserGamificationProfile profile) =>
      _createDefaultDailyChallenge(id, profile);

  TranslationChallenge _createDefaultDailyChallenge(
      String id, UserGamificationProfile profile) {
    return TranslationChallenge(
      id: id,
      title: '📅 Daily Challenge',
      description: 'Complete your daily translation goal',
      type: ChallengeType.daily,
      difficulty: ChallengeDifficulty.easy,
      targetCount: 3,
      currentProgress: 0,
      rewards: ChallengeRewards(
        points: 150,
        badge: 'Daily Achiever',
        title: 'Consistent',
      ),
      timeLimit: Duration(hours: 24),
      requirements: {'count': 3},
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(hours: 24)),
    );
  }
}

// ===== PLACEHOLDER CLASSES FOR COMPILATION =====

class PointScoringEngine {
  static PointScoringEngine create(String userId) => PointScoringEngine();
}

class ChallengeGenerationEngine {}

class LevelUpResult {
  final bool leveledUp;
  final int newLevel;
  final int oldLevel;

  LevelUpResult({
    required this.leveledUp,
    required this.newLevel,
    required this.oldLevel,
  });

  static LevelUpResult noLevelUp() =>
      LevelUpResult(leveledUp: false, newLevel: 1, oldLevel: 1);
}

class RankingPosition {
  final int rank;
  final int total;
  final double percentile;

  RankingPosition({
    required this.rank,
    required this.total,
    required this.percentile,
  });
}
