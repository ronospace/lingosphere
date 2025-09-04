// 👥 LingoSphere - Social Models
// Data models for social features, leaderboards, and collaborative learning

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'social_models.g.dart';

/// User profile for social features
@JsonSerializable()
class SocialProfile extends Equatable {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final int level;
  final int totalPoints;
  final List<String> languages;
  final List<String> badges;
  final DateTime joinDate;
  final bool isOnline;
  final String? status;

  const SocialProfile({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.level,
    required this.totalPoints,
    required this.languages,
    required this.badges,
    required this.joinDate,
    this.isOnline = false,
    this.status,
  });

  factory SocialProfile.fromJson(Map<String, dynamic> json) =>
      _$SocialProfileFromJson(json);

  Map<String, dynamic> toJson() => _$SocialProfileToJson(this);

  @override
  List<Object?> get props => [
        userId,
        displayName,
        avatarUrl,
        level,
        totalPoints,
        languages,
        badges,
        joinDate,
        isOnline,
        status,
      ];
}

/// Leaderboard entry
@JsonSerializable()
class LeaderboardEntry extends Equatable {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final int score;
  final int rank;
  final int level;
  final String category;
  final DateTime lastActivity;

  const LeaderboardEntry({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.score,
    required this.rank,
    required this.level,
    required this.category,
    required this.lastActivity,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryFromJson(json);

  Map<String, dynamic> toJson() => _$LeaderboardEntryToJson(this);

  @override
  List<Object?> get props => [
        userId,
        displayName,
        avatarUrl,
        score,
        rank,
        level,
        category,
        lastActivity,
      ];
}

/// Tournament definition
@JsonSerializable()
class Tournament extends Equatable {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String category;
  final int maxParticipants;
  final int currentParticipants;
  final List<String> prizes;
  final Map<String, dynamic> rules;
  final bool isActive;

  const Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.category,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.prizes,
    required this.rules,
    required this.isActive,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) =>
      _$TournamentFromJson(json);

  Map<String, dynamic> toJson() => _$TournamentToJson(this);

  bool get isOpen => 
      isActive && 
      currentParticipants < maxParticipants &&
      DateTime.now().isBefore(endDate);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        startDate,
        endDate,
        category,
        maxParticipants,
        currentParticipants,
        prizes,
        rules,
        isActive,
      ];
}

/// Collaborative project
@JsonSerializable()
class CollaborativeProject extends Equatable {
  final String id;
  final String title;
  final String description;
  final String sourceLanguage;
  final String targetLanguage;
  final String creatorId;
  final List<String> collaboratorIds;
  final int progress;
  final DateTime createdAt;
  final DateTime? deadline;
  final bool isPublic;
  final Map<String, dynamic> metadata;

  const CollaborativeProject({
    required this.id,
    required this.title,
    required this.description,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.creatorId,
    required this.collaboratorIds,
    required this.progress,
    required this.createdAt,
    this.deadline,
    required this.isPublic,
    this.metadata = const {},
  });

  factory CollaborativeProject.fromJson(Map<String, dynamic> json) =>
      _$CollaborativeProjectFromJson(json);

  Map<String, dynamic> toJson() => _$CollaborativeProjectToJson(this);

  bool get isComplete => progress >= 100;
  bool get isOverdue => deadline != null && DateTime.now().isAfter(deadline!);

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        sourceLanguage,
        targetLanguage,
        creatorId,
        collaboratorIds,
        progress,
        createdAt,
        deadline,
        isPublic,
        metadata,
      ];
}

/// Social achievement
@JsonSerializable()
class SocialAchievement extends Equatable {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final int pointsReward;
  final String category;
  final Map<String, dynamic> requirements;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const SocialAchievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.pointsReward,
    required this.category,
    required this.requirements,
    required this.isUnlocked,
    this.unlockedAt,
  });

  factory SocialAchievement.fromJson(Map<String, dynamic> json) =>
      _$SocialAchievementFromJson(json);

  Map<String, dynamic> toJson() => _$SocialAchievementToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        iconUrl,
        pointsReward,
        category,
        requirements,
        isUnlocked,
        unlockedAt,
      ];
}

/// Friend connection
@JsonSerializable()
class FriendConnection extends Equatable {
  final String userId;
  final String friendId;
  final DateTime connectedAt;
  final String status; // 'pending', 'accepted', 'blocked'
  final Map<String, dynamic> sharedStats;

  const FriendConnection({
    required this.userId,
    required this.friendId,
    required this.connectedAt,
    required this.status,
    this.sharedStats = const {},
  });

  factory FriendConnection.fromJson(Map<String, dynamic> json) =>
      _$FriendConnectionFromJson(json);

  Map<String, dynamic> toJson() => _$FriendConnectionToJson(this);

  bool get isAccepted => status == 'accepted';
  bool get isPending => status == 'pending';

  @override
  List<Object?> get props => [
        userId,
        friendId,
        connectedAt,
        status,
        sharedStats,
      ];
}
