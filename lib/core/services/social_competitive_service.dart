// 🌟 LingoSphere - Social Sharing & Competitive Leaderboards
// Community features and social learning tools designed for Gen Z engagement

import 'dart:async';
import 'dart:math';
import 'package:logger/logger.dart';

import '../models/social_models.dart';
import '../exceptions/translation_exceptions.dart';
import 'gamification_xp_service.dart';
import 'learning_streaks_xp_service.dart';

/// Social & Competitive Service
/// Provides social sharing, competitive leaderboards, community challenges, and collaboration tools
class SocialCompetitiveService {
  static final SocialCompetitiveService _instance =
      SocialCompetitiveService._internal();
  factory SocialCompetitiveService() => _instance;
  SocialCompetitiveService._internal();

  final Logger _logger = Logger();

  // User social profiles and connections
  final Map<String, SocialProfile> _userProfiles = {};
  final Map<String, Set<String>> _userFollowers = {};
  final Map<String, Set<String>> _userFollowing = {};

  // Translation sharing and social feeds
  final Map<String, List<SharedTranslation>> _userSharedTranslations = {};
  final Map<String, List<SharedTranslation>> _communityFeed = {};

  // Competitive leaderboards (multiple categories)
  final Map<LeaderboardCategory, List<LeaderboardEntry>> _leaderboards = {};
  final Map<String, Map<LeaderboardCategory, int>> _userRankings = {};

  // Community challenges and tournaments
  final Map<String, CommunityChallenge> _activeChallenges = {};
  final Map<String, List<String>> _challengeParticipants = {};
  final Map<String, Tournament> _activeTournaments = {};

  // Social interactions (likes, comments, shares)
  final Map<String, List<SocialInteraction>> _translationInteractions = {};
  final Map<String, UserEngagementMetrics> _engagementMetrics = {};

  // Friend and rival systems
  final Map<String, List<FriendConnection>> _friendConnections = {};
  final Map<String, List<RivalConnection>> _rivalConnections = {};

  // Collaboration features
  final Map<String, CollaborativeProject> _collaborativeProjects = {};
  final Map<String, List<String>> _projectMembers = {};

  // Social learning groups
  final Map<String, LearningGroup> _learningGroups = {};
  final Map<String, Set<String>> _groupMembers = {};

  /// Initialize the social competitive system
  Future<void> initialize() async {
    // Initialize leaderboard categories
    await _initializeLeaderboards();

    // Initialize community challenges
    await _initializeCommunitySystem();

    // Initialize social interaction system
    await _initializeSocialFeatures();

    _logger.i(
        '🌟 Social & Competitive System initialized with community features');
  }

  /// Create or update user social profile
  Future<SocialProfile> createOrUpdateSocialProfile({
    required String userId,
    required String displayName,
    String? bio,
    String? avatarUrl,
    List<String>? languageInterests,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final existingProfile = _userProfiles[userId];

      final profile = SocialProfile(
        userId: userId,
        displayName: displayName,
        bio: bio ?? existingProfile?.bio ?? '',
        avatarUrl: avatarUrl ?? existingProfile?.avatarUrl,
        languageInterests:
            languageInterests ?? existingProfile?.languageInterests ?? [],
        socialPreferences: SocialPreferences.fromMap(
            preferences ?? existingProfile?.socialPreferences.toMap() ?? {}),
        stats: existingProfile?.stats ?? SocialStats.initial(),
        reputation: existingProfile?.reputation ?? UserReputation.initial(),
        badges: existingProfile?.badges ?? [],
        createdAt: existingProfile?.createdAt ?? DateTime.now(),
        lastActive: DateTime.now(),
      );

      _userProfiles[userId] = profile;

      // Initialize user's social connections if new
      if (existingProfile == null) {
        _userFollowers[userId] = <String>{};
        _userFollowing[userId] = <String>{};
        _userSharedTranslations[userId] = <SharedTranslation>[];
        _engagementMetrics[userId] = UserEngagementMetrics.initial();
      }

      _logger.i('Social profile updated for user: $displayName');
      return profile;
    } catch (e) {
      _logger.e('Social profile creation failed: $e');
      throw TranslationServiceException(
          'Social profile creation failed: ${e.toString()}');
    }
  }

  /// Share a translation to the community
  Future<SharedTranslation> shareTranslation({
    required String userId,
    required String originalText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
    required double qualityScore,
    String? caption,
    List<String>? tags,
    ShareVisibility visibility = ShareVisibility.public,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final userProfile = _userProfiles[userId];
      if (userProfile == null) {
        throw TranslationServiceException('User profile not found');
      }

      final shareId = _generateShareId();
      final sharedTranslation = SharedTranslation(
        shareId: shareId,
        userId: userId,
        userDisplayName: userProfile.displayName,
        userAvatarUrl: userProfile.avatarUrl,
        originalText: originalText,
        translatedText: translatedText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        qualityScore: qualityScore,
        caption: caption ?? '',
        tags: tags ?? [],
        visibility: visibility,
        metadata: metadata ?? {},
        interactions: SocialInteractions.empty(),
        createdAt: DateTime.now(),
      );

      // Add to user's shared translations
      _userSharedTranslations[userId]!.add(sharedTranslation);

      // Add to community feed if public
      if (visibility == ShareVisibility.public) {
        _addToCommunityFeed(sharedTranslation);
      }

      // Update user stats
      await _updateUserSocialStats(userId, SharedTranslationAction.create);

      // Initialize interaction tracking
      _translationInteractions[shareId] = <SocialInteraction>[];

      _logger.i(
          'Translation shared by ${userProfile.displayName}: ${originalText.substring(0, min(50, originalText.length))}...');
      return sharedTranslation;
    } catch (e) {
      _logger.e('Translation sharing failed: $e');
      throw TranslationServiceException(
          'Translation sharing failed: ${e.toString()}');
    }
  }

  /// Get personalized community feed for user
  Future<CommunityFeed> getCommunityFeed({
    required String userId,
    int limit = 20,
    String? cursor,
    FeedFilter? filter,
  }) async {
    try {
      final userProfile = _userProfiles[userId];
      if (userProfile == null) {
        throw TranslationServiceException('User profile not found');
      }

      // Get user's language interests and following list
      final languageInterests = userProfile.languageInterests;
      final followingList = _userFollowing[userId] ?? <String>{};

      // Generate personalized feed
      final feedItems = <FeedItem>[];

      // Add translations from followed users (higher priority)
      for (final followedUserId in followingList) {
        final followedUserTranslations =
            _userSharedTranslations[followedUserId] ?? [];
        for (final translation in followedUserTranslations.take(5)) {
          if (_matchesFilter(translation, filter) &&
              _matchesLanguageInterest(translation, languageInterests)) {
            feedItems.add(FeedItem.fromSharedTranslation(
                translation, FeedItemType.followedUser));
          }
        }
      }

      // Add trending translations from community
      final trendingTranslations =
          await _getTrendingTranslations(limit: 10, filter: filter);
      for (final translation in trendingTranslations) {
        if (_matchesLanguageInterest(translation, languageInterests)) {
          feedItems.add(FeedItem.fromSharedTranslation(
              translation, FeedItemType.trending));
        }
      }

      // Add recommended translations based on user activity
      final recommendedTranslations =
          await _getRecommendedTranslations(userId, limit: 10);
      for (final translation in recommendedTranslations) {
        feedItems.add(FeedItem.fromSharedTranslation(
            translation, FeedItemType.recommended));
      }

      // Sort by relevance and engagement
      feedItems.sort((a, b) => _calculateFeedItemScore(b, userId)
          .compareTo(_calculateFeedItemScore(a, userId)));

      // Apply pagination
      final paginatedItems = _applyFeedPagination(feedItems, cursor, limit);

      return CommunityFeed(
        userId: userId,
        items: paginatedItems,
        hasMore: feedItems.length > limit,
        nextCursor: paginatedItems.isNotEmpty ? paginatedItems.last.id : null,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      _logger.e('Community feed generation failed: $e');
      throw TranslationServiceException(
          'Community feed failed: ${e.toString()}');
    }
  }

  /// Get competitive leaderboards
  Future<Map<LeaderboardCategory, LeaderboardData>> getLeaderboards({
    required String userId,
    LeaderboardScope scope = LeaderboardScope.global,
    LeaderboardTimeframe timeframe = LeaderboardTimeframe.weekly,
  }) async {
    try {
      final leaderboards = <LeaderboardCategory, LeaderboardData>{};

      for (final category in LeaderboardCategory.values) {
        final entries = await _getLeaderboardEntries(
          category: category,
          scope: scope,
          timeframe: timeframe,
          userId: userId,
        );

        final userRank =
            await _getUserRankInLeaderboard(userId, category, scope, timeframe);
        final userEntry = entries.firstWhere(
          (entry) => entry.userId == userId,
          orElse: () => LeaderboardEntry.empty(userId),
        );

        leaderboards[category] = LeaderboardData(
          category: category,
          scope: scope,
          timeframe: timeframe,
          entries: entries.take(100).toList(), // Top 100
          userRank: userRank,
          userEntry: userEntry,
          totalParticipants: entries.length,
          lastUpdated: DateTime.now(),
        );
      }

      return leaderboards;
    } catch (e) {
      _logger.e('Leaderboard generation failed: $e');
      throw TranslationServiceException(
          'Leaderboard generation failed: ${e.toString()}');
    }
  }

  /// Create community challenge
  Future<CommunityChallenge> createCommunityChallenge({
    required String creatorId,
    required String title,
    required String description,
    required ChallengeType type,
    required DateTime startDate,
    required DateTime endDate,
    required Map<String, dynamic> rules,
    ChallengeRewards? rewards,
    int? maxParticipants,
    List<String>? languagePairs,
  }) async {
    try {
      final challengeId = _generateChallengeId();

      final challenge = CommunityChallenge(
        id: challengeId,
        creatorId: creatorId,
        title: title,
        description: description,
        type: type,
        status: ChallengeStatus.upcoming,
        startDate: startDate,
        endDate: endDate,
        rules: rules,
        rewards: rewards ?? ChallengeRewards.standard(),
        maxParticipants: maxParticipants,
        languagePairs: languagePairs ?? [],
        participants: <String>[],
        leaderboard: <ChallengeLeaderboardEntry>[],
        createdAt: DateTime.now(),
      );

      _activeChallenges[challengeId] = challenge;
      _challengeParticipants[challengeId] = <String>[];

      // Schedule challenge start/end
      await _scheduleChallengeEvents(challenge);

      _logger.i('Community challenge created: $title');
      return challenge;
    } catch (e) {
      _logger.e('Community challenge creation failed: $e');
      throw TranslationServiceException(
          'Challenge creation failed: ${e.toString()}');
    }
  }

  /// Join a community challenge
  Future<ChallengeParticipation> joinCommunityChallenge({
    required String userId,
    required String challengeId,
  }) async {
    try {
      final challenge = _activeChallenges[challengeId];
      if (challenge == null) {
        throw TranslationServiceException('Challenge not found');
      }

      if (challenge.status != ChallengeStatus.active &&
          challenge.status != ChallengeStatus.upcoming) {
        throw TranslationServiceException(
            'Challenge is not available for joining');
      }

      if (challenge.maxParticipants != null &&
          challenge.participants.length >= challenge.maxParticipants!) {
        throw TranslationServiceException('Challenge is full');
      }

      final participants = _challengeParticipants[challengeId]!;
      if (participants.contains(userId)) {
        throw TranslationServiceException('Already participating in challenge');
      }

      participants.add(userId);
      challenge.participants.add(userId);

      // Create participation record
      final participation = ChallengeParticipation(
        userId: userId,
        challengeId: challengeId,
        joinedAt: DateTime.now(),
        currentScore: 0,
        currentRank: participants.length,
        progress: ChallengeProgress.initial(),
        completedTasks: <String>[],
        achievements: <String>[],
      );

      _logger
          .i('User joined community challenge: $userId -> ${challenge.title}');
      return participation;
    } catch (e) {
      _logger.e('Challenge participation failed: $e');
      throw TranslationServiceException(
          'Challenge participation failed: ${e.toString()}');
    }
  }

  /// Create a learning group
  Future<LearningGroup> createLearningGroup({
    required String creatorId,
    required String name,
    required String description,
    required List<String> languagePairs,
    GroupType type = GroupType.study,
    GroupVisibility visibility = GroupVisibility.public,
    int? maxMembers,
    Map<String, dynamic>? groupRules,
  }) async {
    try {
      final groupId = _generateGroupId();

      final group = LearningGroup(
        id: groupId,
        name: name,
        description: description,
        creatorId: creatorId,
        type: type,
        visibility: visibility,
        languagePairs: languagePairs,
        maxMembers: maxMembers,
        groupRules: groupRules ?? {},
        members: <GroupMember>[
          GroupMember(
            userId: creatorId,
            role: GroupRole.admin,
            joinedAt: DateTime.now(),
            contributionScore: 0,
          ),
        ],
        stats: GroupStats.initial(),
        activities: <GroupActivity>[],
        createdAt: DateTime.now(),
      );

      _learningGroups[groupId] = group;
      _groupMembers[groupId] = <String>{creatorId};

      _logger.i('Learning group created: $name by $creatorId');
      return group;
    } catch (e) {
      _logger.e('Learning group creation failed: $e');
      throw TranslationServiceException(
          'Learning group creation failed: ${e.toString()}');
    }
  }

  /// Process social interaction (like, comment, share)
  Future<InteractionResult> processSocialInteraction({
    required String userId,
    required String shareId,
    required InteractionType type,
    String? content,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final interaction = SocialInteraction(
        id: _generateInteractionId(),
        userId: userId,
        shareId: shareId,
        type: type,
        content: content,
        metadata: metadata ?? {},
        timestamp: DateTime.now(),
      );

      // Add to interactions list
      _translationInteractions[shareId]!.add(interaction);

      // Update shared translation interactions
      final sharedTranslation = await _findSharedTranslation(shareId);
      if (sharedTranslation != null) {
        await _updateTranslationInteractions(sharedTranslation, interaction);

        // Update user engagement metrics
        await _updateEngagementMetrics(userId, type);

        // Award reputation points
        await _updateUserReputation(userId, sharedTranslation.userId, type);
      }

      return InteractionResult(
        success: true,
        interaction: interaction,
        updatedStats: await _getUpdatedInteractionStats(shareId),
      );
    } catch (e) {
      _logger.e('Social interaction processing failed: $e');
      throw TranslationServiceException(
          'Social interaction failed: ${e.toString()}');
    }
  }

  /// Follow/unfollow user
  Future<FollowResult> followUser({
    required String followerId,
    required String followeeId,
    bool follow = true,
  }) async {
    try {
      if (followerId == followeeId) {
        throw TranslationServiceException('Cannot follow yourself');
      }

      final followerSet = _userFollowing[followerId] ?? <String>{};
      final followeeSet = _userFollowers[followeeId] ?? <String>{};

      if (follow) {
        followerSet.add(followeeId);
        followeeSet.add(followerId);

        // Create friend connection if mutual
        if (_userFollowing[followeeId]?.contains(followerId) == true) {
          await _createFriendConnection(followerId, followeeId);
        }
      } else {
        followerSet.remove(followeeId);
        followeeSet.remove(followerId);

        // Remove friend connection if exists
        await _removeFriendConnection(followerId, followeeId);
      }

      _userFollowing[followerId] = followerSet;
      _userFollowers[followeeId] = followeeSet;

      // Update social stats
      await _updateFollowStats(followerId, followeeId, follow);

      return FollowResult(
        success: true,
        isFollowing: follow,
        isMutualFollow:
            _userFollowing[followeeId]?.contains(followerId) == true,
        followerCount: followeeSet.length,
        followingCount: followerSet.length,
      );
    } catch (e) {
      _logger.e('Follow operation failed: $e');
      throw TranslationServiceException(
          'Follow operation failed: ${e.toString()}');
    }
  }

  /// Get user's social connections
  Future<SocialConnections> getUserSocialConnections(String userId) async {
    try {
      final followers = _userFollowers[userId] ?? <String>{};
      final following = _userFollowing[userId] ?? <String>{};
      final friends = _friendConnections[userId] ?? <FriendConnection>[];
      final rivals = _rivalConnections[userId] ?? <RivalConnection>[];

      // Get profiles for connections
      final followerProfiles = <SocialProfile>[];
      for (final followerId in followers) {
        final profile = _userProfiles[followerId];
        if (profile != null) followerProfiles.add(profile);
      }

      final followingProfiles = <SocialProfile>[];
      for (final followingId in following) {
        final profile = _userProfiles[followingId];
        if (profile != null) followingProfiles.add(profile);
      }

      return SocialConnections(
        userId: userId,
        followers: followerProfiles,
        following: followingProfiles,
        friends: friends,
        rivals: rivals,
        mutualConnections: _getMutualConnections(userId),
        suggestedConnections: await _getSuggestedConnections(userId),
        connectionStats: ConnectionStats(
          followersCount: followers.length,
          followingCount: following.length,
          friendsCount: friends.length,
          rivalsCount: rivals.length,
        ),
      );
    } catch (e) {
      _logger.e('Social connections retrieval failed: $e');
      throw TranslationServiceException(
          'Social connections failed: ${e.toString()}');
    }
  }

  // ===== UTILITY METHODS =====

  String _generateShareId() =>
      'share_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  String _generateChallengeId() =>
      'challenge_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  String _generateGroupId() =>
      'group_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  String _generateInteractionId() =>
      'interaction_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';

  void _addToCommunityFeed(SharedTranslation translation) {
    final feedKey = 'global';
    _communityFeed.putIfAbsent(feedKey, () => <SharedTranslation>[]);
    _communityFeed[feedKey]!.insert(0, translation);

    // Keep only recent translations in feed (last 1000)
    if (_communityFeed[feedKey]!.length > 1000) {
      _communityFeed[feedKey] = _communityFeed[feedKey]!.take(1000).toList();
    }
  }

  bool _matchesFilter(SharedTranslation translation, FeedFilter? filter) {
    if (filter == null) return true;

    // Language filter
    if (filter.languages != null && filter.languages!.isNotEmpty) {
      if (!filter.languages!.contains(translation.sourceLanguage) &&
          !filter.languages!.contains(translation.targetLanguage)) {
        return false;
      }
    }

    // Quality filter
    if (filter.minQuality != null &&
        translation.qualityScore < filter.minQuality!) {
      return false;
    }

    // Tag filter
    if (filter.tags != null && filter.tags!.isNotEmpty) {
      final hasMatchingTag =
          filter.tags!.any((tag) => translation.tags.contains(tag));
      if (!hasMatchingTag) return false;
    }

    return true;
  }

  bool _matchesLanguageInterest(
      SharedTranslation translation, List<String> interests) {
    if (interests.isEmpty) return true;
    return interests.contains(translation.sourceLanguage) ||
        interests.contains(translation.targetLanguage);
  }

  double _calculateFeedItemScore(FeedItem item, String userId) {
    double score = 0.0;

    // Recency score (newer = higher score)
    final hoursAgo = DateTime.now().difference(item.createdAt).inHours;
    score += max(0, 100 - hoursAgo) / 100.0 * 0.3;

    // Engagement score
    score += item.engagementScore * 0.4;

    // Type-based score
    switch (item.type) {
      case FeedItemType.followedUser:
        score += 0.5;
        break;
      case FeedItemType.trending:
        score += 0.3;
        break;
      case FeedItemType.recommended:
        score += 0.2;
        break;
    }

    // Quality score
    score += item.qualityScore * 0.2;

    return score;
  }

  List<FeedItem> _applyFeedPagination(
      List<FeedItem> items, String? cursor, int limit) {
    if (cursor == null) {
      return items.take(limit).toList();
    }

    final startIndex = items.indexWhere((item) => item.id == cursor);
    if (startIndex == -1) {
      return items.take(limit).toList();
    }

    return items.skip(startIndex + 1).take(limit).toList();
  }

  List<SocialProfile> _getMutualConnections(String userId) {
    // Implementation to find mutual connections
    return [];
  }

  // ===== PLACEHOLDER METHODS FOR COMPILATION =====

  Future<void> _initializeLeaderboards() async {}
  Future<void> _initializeCommunitySystem() async {}
  Future<void> _initializeSocialFeatures() async {}
  Future<void> _updateUserSocialStats(
      String userId, SharedTranslationAction action) async {}
  Future<List<SharedTranslation>> _getTrendingTranslations(
          {required int limit, FeedFilter? filter}) async =>
      [];
  Future<List<SharedTranslation>> _getRecommendedTranslations(String userId,
          {required int limit}) async =>
      [];
  Future<List<LeaderboardEntry>> _getLeaderboardEntries(
          {required LeaderboardCategory category,
          required LeaderboardScope scope,
          required LeaderboardTimeframe timeframe,
          required String userId}) async =>
      [];
  Future<int> _getUserRankInLeaderboard(
          String userId,
          LeaderboardCategory category,
          LeaderboardScope scope,
          LeaderboardTimeframe timeframe) async =>
      0;
  Future<void> _scheduleChallengeEvents(CommunityChallenge challenge) async {}
  Future<SharedTranslation?> _findSharedTranslation(String shareId) async =>
      null;
  Future<void> _updateTranslationInteractions(
      SharedTranslation translation, SocialInteraction interaction) async {}
  Future<void> _updateEngagementMetrics(
      String userId, InteractionType type) async {}
  Future<void> _updateUserReputation(
      String userId, String authorId, InteractionType type) async {}
  Future<SocialInteractions> _getUpdatedInteractionStats(
          String shareId) async =>
      SocialInteractions.empty();
  Future<void> _createFriendConnection(String userId1, String userId2) async {}
  Future<void> _removeFriendConnection(String userId1, String userId2) async {}
  Future<void> _updateFollowStats(
      String followerId, String followeeId, bool follow) async {}
  Future<List<SocialProfile>> _getSuggestedConnections(String userId) async =>
      [];
}

// ===== ENUMS AND DATA CLASSES =====

enum ShareVisibility { public, friends, private }

enum SharedTranslationAction { create, like, share, comment }

enum LeaderboardCategory {
  totalXP,
  weeklyXP,
  streaks,
  quality,
  speed,
  translations
}

enum LeaderboardScope { global, friends, region, group }

enum LeaderboardTimeframe { daily, weekly, monthly, allTime }

enum ChallengeType { translation, speed, quality, streak, collaborative }

enum ChallengeStatus { upcoming, active, completed, cancelled }

enum FeedItemType { followedUser, trending, recommended }

enum InteractionType { like, comment, share, report }

enum GroupType { study, practice, competitive, social }

enum GroupVisibility { public, private, inviteOnly }

enum GroupRole { member, moderator, admin }

class SocialProfile {
  final String userId;
  final String displayName;
  final String bio;
  final String? avatarUrl;
  final List<String> languageInterests;
  final SocialPreferences socialPreferences;
  final SocialStats stats;
  final UserReputation reputation;
  final List<String> badges;
  final DateTime createdAt;
  final DateTime lastActive;

  SocialProfile({
    required this.userId,
    required this.displayName,
    required this.bio,
    this.avatarUrl,
    required this.languageInterests,
    required this.socialPreferences,
    required this.stats,
    required this.reputation,
    required this.badges,
    required this.createdAt,
    required this.lastActive,
  });
}

class SharedTranslation {
  final String shareId;
  final String userId;
  final String userDisplayName;
  final String? userAvatarUrl;
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final double qualityScore;
  final String caption;
  final List<String> tags;
  final ShareVisibility visibility;
  final Map<String, dynamic> metadata;
  final SocialInteractions interactions;
  final DateTime createdAt;

  SharedTranslation({
    required this.shareId,
    required this.userId,
    required this.userDisplayName,
    this.userAvatarUrl,
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.qualityScore,
    required this.caption,
    required this.tags,
    required this.visibility,
    required this.metadata,
    required this.interactions,
    required this.createdAt,
  });
}

class CommunityFeed {
  final String userId;
  final List<FeedItem> items;
  final bool hasMore;
  final String? nextCursor;
  final DateTime generatedAt;

  CommunityFeed({
    required this.userId,
    required this.items,
    required this.hasMore,
    this.nextCursor,
    required this.generatedAt,
  });
}

class FeedItem {
  final String id;
  final FeedItemType type;
  final SharedTranslation translation;
  final double engagementScore;
  final double qualityScore;
  final DateTime createdAt;

  FeedItem({
    required this.id,
    required this.type,
    required this.translation,
    required this.engagementScore,
    required this.qualityScore,
    required this.createdAt,
  });

  static FeedItem fromSharedTranslation(
      SharedTranslation translation, FeedItemType type) {
    return FeedItem(
      id: translation.shareId,
      type: type,
      translation: translation,
      engagementScore: 0.5,
      qualityScore: translation.qualityScore,
      createdAt: translation.createdAt,
    );
  }
}

class CommunityChallenge {
  final String id;
  final String creatorId;
  final String title;
  final String description;
  final ChallengeType type;
  final ChallengeStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic> rules;
  final ChallengeRewards rewards;
  final int? maxParticipants;
  final List<String> languagePairs;
  final List<String> participants;
  final List<ChallengeLeaderboardEntry> leaderboard;
  final DateTime createdAt;

  CommunityChallenge({
    required this.id,
    required this.creatorId,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.rules,
    required this.rewards,
    this.maxParticipants,
    required this.languagePairs,
    required this.participants,
    required this.leaderboard,
    required this.createdAt,
  });
}

class LearningGroup {
  final String id;
  final String name;
  final String description;
  final String creatorId;
  final GroupType type;
  final GroupVisibility visibility;
  final List<String> languagePairs;
  final int? maxMembers;
  final Map<String, dynamic> groupRules;
  final List<GroupMember> members;
  final GroupStats stats;
  final List<GroupActivity> activities;
  final DateTime createdAt;

  LearningGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    required this.type,
    required this.visibility,
    required this.languagePairs,
    this.maxMembers,
    required this.groupRules,
    required this.members,
    required this.stats,
    required this.activities,
    required this.createdAt,
  });
}

// ===== PLACEHOLDER CLASSES FOR COMPILATION =====

class SocialPreferences {
  static SocialPreferences fromMap(Map<String, dynamic> map) =>
      SocialPreferences();
  Map<String, dynamic> toMap() => {};
}

class SocialStats {
  static SocialStats initial() => SocialStats();
}

class UserReputation {
  static UserReputation initial() => UserReputation();
}

class SocialInteractions {
  static SocialInteractions empty() => SocialInteractions();
}

class UserEngagementMetrics {
  static UserEngagementMetrics initial() => UserEngagementMetrics();
}

class FeedFilter {
  final List<String>? languages;
  final double? minQuality;
  final List<String>? tags;

  FeedFilter({this.languages, this.minQuality, this.tags});
}

class LeaderboardData {
  final LeaderboardCategory category;
  final LeaderboardScope scope;
  final LeaderboardTimeframe timeframe;
  final List<LeaderboardEntry> entries;
  final int userRank;
  final LeaderboardEntry userEntry;
  final int totalParticipants;
  final DateTime lastUpdated;

  LeaderboardData({
    required this.category,
    required this.scope,
    required this.timeframe,
    required this.entries,
    required this.userRank,
    required this.userEntry,
    required this.totalParticipants,
    required this.lastUpdated,
  });
}

class LeaderboardEntry {
  final String userId;

  LeaderboardEntry({required this.userId});
  static LeaderboardEntry empty(String userId) =>
      LeaderboardEntry(userId: userId);
}

class ChallengeRewards {
  static ChallengeRewards standard() => ChallengeRewards();
}

class ChallengeParticipation {
  final String userId;
  final String challengeId;
  final DateTime joinedAt;
  final int currentScore;
  final int currentRank;
  final ChallengeProgress progress;
  final List<String> completedTasks;
  final List<String> achievements;

  ChallengeParticipation({
    required this.userId,
    required this.challengeId,
    required this.joinedAt,
    required this.currentScore,
    required this.currentRank,
    required this.progress,
    required this.completedTasks,
    required this.achievements,
  });
}

class ChallengeProgress {
  static ChallengeProgress initial() => ChallengeProgress();
}

class ChallengeLeaderboardEntry {}

class GroupMember {
  final String userId;
  final GroupRole role;
  final DateTime joinedAt;
  final int contributionScore;

  GroupMember({
    required this.userId,
    required this.role,
    required this.joinedAt,
    required this.contributionScore,
  });
}

class GroupStats {
  static GroupStats initial() => GroupStats();
}

class GroupActivity {}

class SocialInteraction {
  final String id;
  final String userId;
  final String shareId;
  final InteractionType type;
  final String? content;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;

  SocialInteraction({
    required this.id,
    required this.userId,
    required this.shareId,
    required this.type,
    this.content,
    required this.metadata,
    required this.timestamp,
  });
}

class InteractionResult {
  final bool success;
  final SocialInteraction interaction;
  final SocialInteractions updatedStats;

  InteractionResult({
    required this.success,
    required this.interaction,
    required this.updatedStats,
  });
}

class FollowResult {
  final bool success;
  final bool isFollowing;
  final bool isMutualFollow;
  final int followerCount;
  final int followingCount;

  FollowResult({
    required this.success,
    required this.isFollowing,
    required this.isMutualFollow,
    required this.followerCount,
    required this.followingCount,
  });
}

class SocialConnections {
  final String userId;
  final List<SocialProfile> followers;
  final List<SocialProfile> following;
  final List<FriendConnection> friends;
  final List<RivalConnection> rivals;
  final List<SocialProfile> mutualConnections;
  final List<SocialProfile> suggestedConnections;
  final ConnectionStats connectionStats;

  SocialConnections({
    required this.userId,
    required this.followers,
    required this.following,
    required this.friends,
    required this.rivals,
    required this.mutualConnections,
    required this.suggestedConnections,
    required this.connectionStats,
  });
}

class FriendConnection {}

class RivalConnection {}

class ConnectionStats {
  final int followersCount;
  final int followingCount;
  final int friendsCount;
  final int rivalsCount;

  ConnectionStats({
    required this.followersCount,
    required this.followingCount,
    required this.friendsCount,
    required this.rivalsCount,
  });
}
