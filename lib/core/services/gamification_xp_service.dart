// 🎮 LingoSphere - Gamification XP Service
// Experience points, levels, and gamification mechanics

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/gamification_models.dart';
import '../models/social_models.dart';

/// XP and level management service
class GamificationXPService extends ChangeNotifier {
  static final GamificationXPService _instance = GamificationXPService._internal();
  factory GamificationXPService() => _instance;
  GamificationXPService._internal();

  // Current user XP state
  int _currentXP = 0;
  int _currentLevel = 1;
  int _totalLifetimeXP = 0;
  Map<String, int> _categoryXP = {};
  List<XPTransaction> _recentTransactions = [];
  Map<String, DateTime> _cooldowns = {};

  // XP multipliers and bonuses
  double _baseMultiplier = 1.0;
  Map<String, double> _categoryMultipliers = {
    'translation': 1.0,
    'conversation': 1.2,
    'camera': 1.1,
    'learning': 1.5,
    'social': 1.3,
    'achievement': 2.0,
  };

  // Level progression settings
  static const int _baseXPRequired = 100;
  static const double _levelMultiplier = 1.5;
  static const int _maxLevel = 100;

  // Getters
  int get currentXP => _currentXP;
  int get currentLevel => _currentLevel;
  int get totalLifetimeXP => _totalLifetimeXP;
  Map<String, int> get categoryXP => Map.unmodifiable(_categoryXP);
  List<XPTransaction> get recentTransactions => List.unmodifiable(_recentTransactions);

  /// Initialize XP service with user data
  Future<void> initialize({
    int currentXP = 0,
    int totalLifetimeXP = 0,
    Map<String, int>? categoryXP,
  }) async {
    _currentXP = currentXP;
    _totalLifetimeXP = totalLifetimeXP;
    _categoryXP = categoryXP ?? {};
    
    // Calculate current level from XP
    _currentLevel = _calculateLevelFromXP(_currentXP);
    
    notifyListeners();
  }

  /// Award XP for an action
  Future<XPAward> awardXP({
    required String action,
    required String category,
    int baseAmount = 10,
    Map<String, dynamic>? context,
  }) async {
    // Check cooldown
    final cooldownKey = '$action-$category';
    if (_cooldowns.containsKey(cooldownKey)) {
      final cooldownEnd = _cooldowns[cooldownKey]!;
      if (DateTime.now().isBefore(cooldownEnd)) {
        return XPAward(
          action: action,
          category: category,
          baseAmount: baseAmount,
          finalAmount: 0,
          multiplier: 0,
          reason: 'Cooldown active',
          timestamp: DateTime.now(),
        );
      }
    }

    // Calculate final XP amount with multipliers
    double multiplier = _baseMultiplier;
    if (_categoryMultipliers.containsKey(category)) {
      multiplier *= _categoryMultipliers[category]!;
    }

    // Apply context-based bonuses
    multiplier *= _calculateContextBonus(action, category, context ?? {});

    final finalAmount = (baseAmount * multiplier).round();
    final previousLevel = _currentLevel;

    // Award the XP
    _currentXP += finalAmount;
    _totalLifetimeXP += finalAmount;
    _categoryXP[category] = (_categoryXP[category] ?? 0) + finalAmount;

    // Check for level up
    final newLevel = _calculateLevelFromXP(_currentXP);
    final leveledUp = newLevel > previousLevel;
    _currentLevel = newLevel;

    // Add to recent transactions
    final transaction = XPTransaction(
      action: action,
      category: category,
      amount: finalAmount,
      timestamp: DateTime.now(),
      context: context ?? {},
    );
    _recentTransactions.insert(0, transaction);
    if (_recentTransactions.length > 50) {
      _recentTransactions = _recentTransactions.take(50).toList();
    }

    // Set cooldown if applicable
    _setCooldown(action, category);

    final award = XPAward(
      action: action,
      category: category,
      baseAmount: baseAmount,
      finalAmount: finalAmount,
      multiplier: multiplier,
      reason: _getAwardReason(action, category),
      timestamp: DateTime.now(),
      leveledUp: leveledUp,
      newLevel: leveledUp ? newLevel : null,
    );

    notifyListeners();
    return award;
  }

  /// Calculate XP required for a specific level
  int getXPRequiredForLevel(int level) {
    if (level <= 1) return 0;
    
    int totalXP = 0;
    for (int i = 1; i < level; i++) {
      totalXP += (_baseXPRequired * pow(_levelMultiplier, i - 1)).round();
    }
    return totalXP;
  }

  /// Calculate XP required for next level
  int getXPRequiredForNextLevel() {
    if (_currentLevel >= _maxLevel) return 0;
    return getXPRequiredForLevel(_currentLevel + 1) - _currentXP;
  }

  /// Get progress percentage to next level
  double getProgressToNextLevel() {
    if (_currentLevel >= _maxLevel) return 1.0;
    
    final currentLevelXP = getXPRequiredForLevel(_currentLevel);
    final nextLevelXP = getXPRequiredForLevel(_currentLevel + 1);
    final progress = (_currentXP - currentLevelXP) / (nextLevelXP - currentLevelXP);
    
    return progress.clamp(0.0, 1.0);
  }

  /// Set XP multiplier for a category
  void setCategoryMultiplier(String category, double multiplier) {
    _categoryMultipliers[category] = multiplier;
    notifyListeners();
  }

  /// Set base multiplier (for events, premium, etc.)
  void setBaseMultiplier(double multiplier) {
    _baseMultiplier = multiplier;
    notifyListeners();
  }

  /// Get XP breakdown by category
  Map<String, XPBreakdown> getXPBreakdown() {
    final breakdown = <String, XPBreakdown>{};
    
    for (final entry in _categoryXP.entries) {
      final category = entry.key;
      final xp = entry.value;
      final percentage = _totalLifetimeXP > 0 ? (xp / _totalLifetimeXP) * 100 : 0.0;
      
      breakdown[category] = XPBreakdown(
        category: category,
        totalXP: xp,
        percentage: percentage,
        averagePerAction: _calculateAverageXPPerAction(category),
        multiplier: _categoryMultipliers[category] ?? 1.0,
      );
    }
    
    return breakdown;
  }

  /// Get user's rank among friends
  Future<UserRank> getUserRank(List<SocialProfile> friends) async {
    final userXP = _totalLifetimeXP;
    int rank = 1;
    
    for (final friend in friends) {
      if (friend.totalPoints > userXP) {
        rank++;
      }
    }
    
    return UserRank(
      userId: 'current_user',
      rank: rank,
      totalUsers: friends.length + 1,
      percentile: ((friends.length + 1 - rank) / (friends.length + 1)) * 100,
      xp: userXP,
      level: _currentLevel,
    );
  }

  /// Calculate level from total XP
  int _calculateLevelFromXP(int xp) {
    if (xp <= 0) return 1;
    
    int level = 1;
    int requiredXP = 0;
    
    while (level < _maxLevel) {
      final nextLevelXP = (_baseXPRequired * pow(_levelMultiplier, level - 1)).round();
      if (requiredXP + nextLevelXP > xp) break;
      
      requiredXP += nextLevelXP;
      level++;
    }
    
    return level;
  }

  /// Calculate context-based bonus multiplier
  double _calculateContextBonus(String action, String category, Map<String, dynamic> context) {
    double bonus = 1.0;
    
    // Streak bonus
    if (context.containsKey('streak')) {
      final streak = context['streak'] as int;
      bonus *= 1.0 + (streak * 0.1).clamp(0.0, 2.0); // Max 200% bonus for streaks
    }
    
    // Quality bonus
    if (context.containsKey('quality')) {
      final quality = context['quality'] as double;
      bonus *= 1.0 + (quality * 0.5); // Up to 50% bonus for high quality
    }
    
    // Speed bonus
    if (context.containsKey('speed_bonus')) {
      bonus *= context['speed_bonus'] as double;
    }
    
    // First time bonus
    if (context.containsKey('first_time') && context['first_time'] == true) {
      bonus *= 1.5;
    }
    
    // Perfect score bonus
    if (context.containsKey('perfect') && context['perfect'] == true) {
      bonus *= 2.0;
    }
    
    return bonus;
  }

  /// Set action cooldown to prevent XP farming
  void _setCooldown(String action, String category) {
    final cooldownKey = '$action-$category';
    const cooldownDurations = {
      'translation': Duration(seconds: 30),
      'conversation': Duration(minutes: 1),
      'camera': Duration(seconds: 45),
      'learning': Duration(minutes: 2),
      'social': Duration(minutes: 5),
    };
    
    if (cooldownDurations.containsKey(category)) {
      _cooldowns[cooldownKey] = DateTime.now().add(cooldownDurations[category]!);
    }
  }

  /// Get human-readable award reason
  String _getAwardReason(String action, String category) {
    final reasons = {
      'translation-translation': 'Text translation completed',
      'camera-camera': 'Image translated with camera',
      'conversation-conversation': 'Conversation turn completed',
      'achievement-achievement': 'Achievement unlocked',
      'daily_login-social': 'Daily login bonus',
      'streak-social': 'Learning streak maintained',
      'perfect_translation-learning': 'Perfect translation accuracy',
    };
    
    return reasons['$action-$category'] ?? 'XP earned for $action in $category';
  }

  /// Calculate average XP per action for a category
  double _calculateAverageXPPerAction(String category) {
    final categoryTransactions = _recentTransactions
        .where((t) => t.category == category)
        .toList();
    
    if (categoryTransactions.isEmpty) return 0.0;
    
    final totalXP = categoryTransactions.fold(0, (sum, t) => sum + t.amount);
    return totalXP / categoryTransactions.length;
  }

  /// Reset XP data (for testing or account reset)
  void resetXP() {
    _currentXP = 0;
    _currentLevel = 1;
    _totalLifetimeXP = 0;
    _categoryXP.clear();
    _recentTransactions.clear();
    _cooldowns.clear();
    notifyListeners();
  }

  /// Export XP data
  Map<String, dynamic> exportData() {
    return {
      'currentXP': _currentXP,
      'currentLevel': _currentLevel,
      'totalLifetimeXP': _totalLifetimeXP,
      'categoryXP': _categoryXP,
      'recentTransactions': _recentTransactions.map((t) => t.toJson()).toList(),
      'baseMultiplier': _baseMultiplier,
      'categoryMultipliers': _categoryMultipliers,
    };
  }

  /// Import XP data
  void importData(Map<String, dynamic> data) {
    _currentXP = data['currentXP'] ?? 0;
    _currentLevel = data['currentLevel'] ?? 1;
    _totalLifetimeXP = data['totalLifetimeXP'] ?? 0;
    _categoryXP = Map<String, int>.from(data['categoryXP'] ?? {});
    
    final transactions = data['recentTransactions'] as List?;
    if (transactions != null) {
      _recentTransactions = transactions
          .map((t) => XPTransaction.fromJson(t as Map<String, dynamic>))
          .toList();
    }
    
    _baseMultiplier = data['baseMultiplier'] ?? 1.0;
    _categoryMultipliers = Map<String, double>.from(data['categoryMultipliers'] ?? {});
    
    notifyListeners();
  }
}

/// XP award result
class XPAward {
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
}

/// XP breakdown by category
class XPBreakdown {
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
}

/// User rank information
class UserRank {
  final String userId;
  final int rank;
  final int totalUsers;
  final double percentile;
  final int xp;
  final int level;

  const UserRank({
    required this.userId,
    required this.rank,
    required this.totalUsers,
    required this.percentile,
    required this.xp,
    required this.level,
  });
}
