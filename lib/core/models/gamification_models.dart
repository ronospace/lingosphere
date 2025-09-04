// 🎮 LingoSphere - Gamification Models
// Data models for achievements, challenges, rewards, and social engagement features

import 'package:equatable/equatable.dart';

/// User's complete gamification profile
class UserGamificationProfile extends Equatable {
  final String userId;
  final int level;
  final int totalPoints;
  final int currentStreak;
  final int longestStreak;
  final int translationsCompleted;
  final int challengesCompleted;
  final List<String> badges;
  final List<String> achievements;
  final List<String> favoriteLanguagePairs;
  final SocialStats socialStats;
  final GamePreferences preferences;
  final DateTime createdAt;
  final DateTime lastActive;

  const UserGamificationProfile({
    required this.userId,
    required this.level,
    required this.totalPoints,
    required this.currentStreak,
    required this.longestStreak,
    required this.translationsCompleted,
    required this.challengesCompleted,
    required this.badges,
    required this.achievements,
    this.favoriteLanguagePairs = const [],
    required this.socialStats,
    required this.preferences,
    required this.createdAt,
    required this.lastActive,
  });

  @override
  List<Object?> get props => [
        userId,
        level,
        totalPoints,
        currentStreak,
        longestStreak,
        translationsCompleted,
        challengesCompleted,
        badges,
        achievements,
        favoriteLanguagePairs,
        socialStats,
        preferences,
        createdAt,
        lastActive,
      ];

  UserGamificationProfile copyWith({
    int? level,
    int? totalPoints,
    int? currentStreak,
    int? longestStreak,
    int? translationsCompleted,
    int? challengesCompleted,
    List<String>? badges,
    List<String>? achievements,
    List<String>? favoriteLanguagePairs,
    SocialStats? socialStats,
    GamePreferences? preferences,
    DateTime? lastActive,
  }) {
    return UserGamificationProfile(
      userId: userId,
      level: level ?? this.level,
      totalPoints: totalPoints ?? this.totalPoints,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      translationsCompleted:
          translationsCompleted ?? this.translationsCompleted,
      challengesCompleted: challengesCompleted ?? this.challengesCompleted,
      badges: badges ?? this.badges,
      achievements: achievements ?? this.achievements,
      favoriteLanguagePairs:
          favoriteLanguagePairs ?? this.favoriteLanguagePairs,
      socialStats: socialStats ?? this.socialStats,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}

/// Social engagement statistics
class SocialStats extends Equatable {
  final int totalShares;
  final int totalLikes;
  final int totalComments;
  final int followers;
  final int following;
  final double viralScore;
  final List<String> recentActivity;

  const SocialStats({
    required this.totalShares,
    required this.totalLikes,
    required this.totalComments,
    required this.followers,
    required this.following,
    required this.viralScore,
    required this.recentActivity,
  });

  static SocialStats initial() {
    return const SocialStats(
      totalShares: 0,
      totalLikes: 0,
      totalComments: 0,
      followers: 0,
      following: 0,
      viralScore: 0.0,
      recentActivity: [],
    );
  }

  @override
  List<Object?> get props => [
        totalShares,
        totalLikes,
        totalComments,
        followers,
        following,
        viralScore,
        recentActivity,
      ];
}

/// User's gaming preferences
class GamePreferences extends Equatable {
  final bool enableNotifications;
  final bool enableSocialSharing;
  final bool enableCompetition;
  final String difficultyPreference; // 'auto', 'easy', 'medium', 'hard'
  final List<String> preferredChallengeTypes;
  final bool enableStreakReminders;
  final Map<String, dynamic> customSettings;

  const GamePreferences({
    required this.enableNotifications,
    required this.enableSocialSharing,
    required this.enableCompetition,
    required this.difficultyPreference,
    required this.preferredChallengeTypes,
    required this.enableStreakReminders,
    required this.customSettings,
  });

  static GamePreferences defaultPreferences() {
    return const GamePreferences(
      enableNotifications: true,
      enableSocialSharing: true,
      enableCompetition: true,
      difficultyPreference: 'auto',
      preferredChallengeTypes: ['daily', 'streak', 'quality'],
      enableStreakReminders: true,
      customSettings: {},
    );
  }

  @override
  List<Object?> get props => [
        enableNotifications,
        enableSocialSharing,
        enableCompetition,
        difficultyPreference,
        preferredChallengeTypes,
        enableStreakReminders,
        customSettings,
      ];
}

/// Translation challenge definition
class TranslationChallenge extends Equatable {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final ChallengeDifficulty difficulty;
  final int targetCount;
  final int currentProgress;
  final ChallengeRewards rewards;
  final Duration timeLimit;
  final Map<String, dynamic> requirements;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isCompleted;
  final bool isFeatured;

  const TranslationChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.targetCount,
    required this.currentProgress,
    required this.rewards,
    required this.timeLimit,
    required this.requirements,
    required this.createdAt,
    required this.expiresAt,
    this.isCompleted = false,
    this.isFeatured = false,
  });

  double get progressPercentage => currentProgress / targetCount;
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  Duration get timeRemaining => expiresAt.difference(DateTime.now());

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        difficulty,
        targetCount,
        currentProgress,
        rewards,
        timeLimit,
        requirements,
        createdAt,
        expiresAt,
        isCompleted,
        isFeatured,
      ];
}

/// Rewards for completing challenges
class ChallengeRewards extends Equatable {
  final int points;
  final String? badge;
  final String? title;
  final Map<String, dynamic>? bonusRewards;

  const ChallengeRewards({
    required this.points,
    this.badge,
    this.title,
    this.bonusRewards,
  });

  @override
  List<Object?> get props => [points, badge, title, bonusRewards];
}

/// Achievement definition
class Achievement extends Equatable {
  final String id;
  final String title;
  final String description;
  final AchievementCategory category;
  final AchievementRarity rarity;
  final int points;
  final String iconUrl;
  final Map<String, dynamic> metadata;
  final DateTime unlockedAt;
  final bool isHidden;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.rarity,
    required this.points,
    required this.iconUrl,
    this.metadata = const {},
    required this.unlockedAt,
    this.isHidden = false,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        rarity,
        points,
        iconUrl,
        metadata,
        unlockedAt,
        isHidden,
      ];
}

/// Badge definition
class Badge extends Equatable {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final BadgeType type;
  final DateTime earnedAt;
  final Map<String, dynamic> criteria;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.type,
    required this.earnedAt,
    required this.criteria,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        iconUrl,
        type,
        earnedAt,
        criteria,
      ];
}

/// Complete gamification reward result
class GamificationReward extends Equatable {
  final String userId;
  final int pointsEarned;
  final int newLevel;
  final bool leveledUp;
  final List<Achievement> newAchievements;
  final List<Badge> newBadges;
  final List<ChallengeUpdate> challengeUpdates;
  final List<CelebrationEffect> celebrationEffects;
  final StreakInfo streakInfo;
  final SocialStats socialStats;
  final DateTime timestamp;

  const GamificationReward({
    required this.userId,
    required this.pointsEarned,
    required this.newLevel,
    required this.leveledUp,
    required this.newAchievements,
    required this.newBadges,
    required this.challengeUpdates,
    required this.celebrationEffects,
    required this.streakInfo,
    required this.socialStats,
    required this.timestamp,
  });

  bool get hasAnyRewards =>
      pointsEarned > 0 ||
      newAchievements.isNotEmpty ||
      newBadges.isNotEmpty ||
      challengeUpdates.isNotEmpty ||
      leveledUp;

  @override
  List<Object?> get props => [
        userId,
        pointsEarned,
        newLevel,
        leveledUp,
        newAchievements,
        newBadges,
        challengeUpdates,
        celebrationEffects,
        streakInfo,
        socialStats,
        timestamp,
      ];
}

/// Streak information
class StreakInfo extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final double streakBonus;
  final bool isOnFire; // 7+ day streak
  final DateTime lastActiveDate;

  const StreakInfo({
    required this.currentStreak,
    required this.longestStreak,
    required this.streakBonus,
    required this.lastActiveDate,
  })  : isOnFire = currentStreak >= 7;

  @override
  List<Object?> get props => [
        currentStreak,
        longestStreak,
        streakBonus,
        isOnFire,
        lastActiveDate,
      ];
}

/// Challenge progress update
class ChallengeUpdate extends Equatable {
  final String challengeId;
  final String challengeTitle;
  final int oldProgress;
  final int newProgress;
  final bool completed;
  final ChallengeRewards? rewardsEarned;

  const ChallengeUpdate({
    required this.challengeId,
    required this.challengeTitle,
    required this.oldProgress,
    required this.newProgress,
    required this.completed,
    this.rewardsEarned,
  });

  int get progressGained => newProgress - oldProgress;

  @override
  List<Object?> get props => [
        challengeId,
        challengeTitle,
        oldProgress,
        newProgress,
        completed,
        rewardsEarned,
      ];
}

/// Visual celebration effects
class CelebrationEffect extends Equatable {
  final CelebrationEffectType type;
  final String title;
  final String message;
  final String iconUrl;
  final Map<String, dynamic> animationData;
  final Duration duration;

  const CelebrationEffect({
    required this.type,
    required this.title,
    required this.message,
    required this.iconUrl,
    required this.animationData,
    required this.duration,
  });

  @override
  List<Object?> get props => [
        type,
        title,
        message,
        iconUrl,
        animationData,
        duration,
      ];
}

/// Leaderboard position and ranking
class LeaderboardPosition extends Equatable {
  final String userId;
  final int globalRank;
  final double globalPercentile;
  final int friendsRank;
  final int friendsTotal;
  final int localRank;
  final int localTotal;
  final int weeklyRank;
  final int weeklyTotal;
  final List<LeaderboardUser> nearbyUsers;
  final CompetitionLevel competitionLevel;
  final DateTime lastUpdated;

  const LeaderboardPosition({
    required this.userId,
    required this.globalRank,
    required this.globalPercentile,
    required this.friendsRank,
    required this.friendsTotal,
    required this.localRank,
    required this.localTotal,
    required this.weeklyRank,
    required this.weeklyTotal,
    required this.nearbyUsers,
    required this.competitionLevel,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
        userId,
        globalRank,
        globalPercentile,
        friendsRank,
        friendsTotal,
        localRank,
        localTotal,
        weeklyRank,
        weeklyTotal,
        nearbyUsers,
        competitionLevel,
        lastUpdated,
      ];
}

/// Leaderboard user entry
class LeaderboardUser extends Equatable {
  final String userId;
  final String displayName;
  final String avatarUrl;
  final int level;
  final int totalPoints;
  final int rank;
  final List<String> topBadges;
  final bool isFriend;

  const LeaderboardUser({
    required this.userId,
    required this.displayName,
    required this.avatarUrl,
    required this.level,
    required this.totalPoints,
    required this.rank,
    required this.topBadges,
    required this.isFriend,
  });

  @override
  List<Object?> get props => [
        userId,
        displayName,
        avatarUrl,
        level,
        totalPoints,
        rank,
        topBadges,
        isFriend,
      ];
}

/// Achievement gallery display
class AchievementGallery extends Equatable {
  final String userId;
  final int totalAchievements;
  final Map<AchievementCategory, List<Achievement>> categories;
  final AchievementStats statistics;
  final List<Achievement> nextToUnlock;
  final List<Achievement> rareAchievements;
  final List<Achievement> featuredAchievements;
  final double completionPercentage;
  final DateTime lastUpdated;

  const AchievementGallery({
    required this.userId,
    required this.totalAchievements,
    required this.categories,
    required this.statistics,
    required this.nextToUnlock,
    required this.rareAchievements,
    required this.featuredAchievements,
    required this.completionPercentage,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
        userId,
        totalAchievements,
        categories,
        statistics,
        nextToUnlock,
        rareAchievements,
        featuredAchievements,
        completionPercentage,
        lastUpdated,
      ];
}

/// Social sharing result
class SocialShareResult extends Equatable {
  final String userId;
  final String achievementId;
  final SocialPlatform platform;
  final SocialShareContent shareContent;
  final String shareUrl;
  final List<String> viralHooks;
  final double socialImpact;
  final DateTime sharedAt;

  const SocialShareResult({
    required this.userId,
    required this.achievementId,
    required this.platform,
    required this.shareContent,
    required this.shareUrl,
    required this.viralHooks,
    required this.socialImpact,
    required this.sharedAt,
  });

  @override
  List<Object?> get props => [
        userId,
        achievementId,
        platform,
        shareContent,
        shareUrl,
        viralHooks,
        socialImpact,
        sharedAt,
      ];
}

/// Social sharing content
class SocialShareContent extends Equatable {
  final String title;
  final String description;
  final String imageUrl;
  final List<String> hashtags;
  final Map<String, String> platformSpecificContent;

  const SocialShareContent({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.hashtags,
    required this.platformSpecificContent,
  });

  static SocialShareContent empty() {
    return const SocialShareContent(
      title: '',
      description: '',
      imageUrl: '',
      hashtags: [],
      platformSpecificContent: {},
    );
  }

  @override
  List<Object?> get props => [
        title,
        description,
        imageUrl,
        hashtags,
        platformSpecificContent,
      ];
}

/// Badge collection for user
class BadgeCollection extends Equatable {
  final String userId;
  final List<Badge> badges;
  final Map<BadgeType, List<Badge>> categorizedBadges;
  final int totalBadges;
  final List<Badge> featuredBadges;

  const BadgeCollection({
    required this.userId,
    required this.badges,
    required this.categorizedBadges,
    required this.totalBadges,
    required this.featuredBadges,
  });

  @override
  List<Object?> get props => [
        userId,
        badges,
        categorizedBadges,
        totalBadges,
        featuredBadges,
      ];
}

/// Social engagement tracker
class SocialEngagementTracker extends Equatable {
  final String userId;
  final Map<SocialPlatform, int> platformEngagement;
  final List<SocialEngagementEvent> recentEvents;
  final double viralityScore;
  final int totalReach;

  const SocialEngagementTracker({
    required this.userId,
    required this.platformEngagement,
    required this.recentEvents,
    required this.viralityScore,
    required this.totalReach,
  });

  @override
  List<Object?> get props => [
        userId,
        platformEngagement,
        recentEvents,
        viralityScore,
        totalReach,
      ];
}

/// Social engagement event
class SocialEngagementEvent extends Equatable {
  final String eventId;
  final String userId;
  final SocialEngagementType type;
  final SocialPlatform platform;
  final String contentId;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const SocialEngagementEvent({
    required this.eventId,
    required this.userId,
    required this.type,
    required this.platform,
    required this.contentId,
    required this.timestamp,
    required this.metadata,
  });

  @override
  List<Object?> get props => [
        eventId,
        userId,
        type,
        platform,
        contentId,
        timestamp,
        metadata,
      ];
}

/// XP Transaction record
class XPTransaction extends Equatable {
  final String action;
  final String category;
  final int amount;
  final DateTime timestamp;
  final Map<String, dynamic> context;

  const XPTransaction({
    required this.action,
    required this.category,
    required this.amount,
    required this.timestamp,
    this.context = const {},
  });

  @override
  List<Object?> get props => [
        action,
        category,
        amount,
        timestamp,
        context,
      ];

  Map<String, dynamic> toJson() => {
        'action': action,
        'category': category,
        'amount': amount,
        'timestamp': timestamp.toIso8601String(),
        'context': context,
      };

  factory XPTransaction.fromJson(Map<String, dynamic> json) => XPTransaction(
        action: json['action'] as String,
        category: json['category'] as String,
        amount: json['amount'] as int,
        timestamp: DateTime.parse(json['timestamp'] as String),
        context: json['context'] as Map<String, dynamic>? ?? {},
      );
}

/// XP Award result
class XPAward extends Equatable {
  final String action;
  final String category;
  final int baseAmount;
  final int finalAmount;
  final double multiplier;
  final String reason;
  final DateTime timestamp;
  final bool leveledUp;
  final int? newLevel;

  const XPAward({
    required this.action,
    required this.category,
    required this.baseAmount,
    required this.finalAmount,
    required this.multiplier,
    required this.reason,
    required this.timestamp,
    this.leveledUp = false,
    this.newLevel,
  });

  @override
  List<Object?> get props => [
        action,
        category,
        baseAmount,
        finalAmount,
        multiplier,
        reason,
        timestamp,
        leveledUp,
        newLevel,
      ];
}

/// XP Breakdown by category
class XPBreakdown extends Equatable {
  final String category;
  final int totalXP;
  final double percentage;
  final double averagePerAction;
  final double multiplier;

  const XPBreakdown({
    required this.category,
    required this.totalXP,
    required this.percentage,
    required this.averagePerAction,
    required this.multiplier,
  });

  @override
  List<Object?> get props => [
        category,
        totalXP,
        percentage,
        averagePerAction,
        multiplier,
      ];
}

// ===== ENUMS =====

enum ChallengeType {
  daily,
  weekly,
  monthly,
  special,
  languagePair,
  quality,
  streak,
  social
}

enum ChallengeDifficulty { easy, medium, hard, extreme }

enum AchievementCategory { milestone, quality, special, social, streak }

enum AchievementRarity { common, uncommon, rare, epic, legendary }

enum BadgeType { skill, milestone, special, seasonal, social, quality }

enum CelebrationEffectType { levelUp, achievement, badge, streak, challenge }

enum SocialPlatform { twitter, instagram, facebook, tiktok, snapchat }

enum SocialEngagementType { share, like, comment, follow }

enum SocialAction { share, like, comment }

enum CompetitionLevel { casual, competitive, hardcore, legend }

/// Achievement statistics
class AchievementStats extends Equatable {
  final int totalAchievements;
  final int commonAchievements;
  final int rareAchievements;
  final int epicAchievements;
  final int legendaryAchievements;
  final double completionPercentage;
  final DateTime lastUnlocked;

  const AchievementStats({
    required this.totalAchievements,
    required this.commonAchievements,
    required this.rareAchievements,
    required this.epicAchievements,
    required this.legendaryAchievements,
    required this.completionPercentage,
    required this.lastUnlocked,
  });

  @override
  List<Object?> get props => [
        totalAchievements,
        commonAchievements,
        rareAchievements,
        epicAchievements,
        legendaryAchievements,
        completionPercentage,
        lastUnlocked,
      ];
}
