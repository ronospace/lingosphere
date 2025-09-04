// ⚡ LingoSphere - Neural Intelligence Performance Optimizer
// Advanced optimization for memory usage, caching, and performance of AI features

import 'dart:async';
import 'dart:collection';
import 'package:logger/logger.dart';

import '../models/neural_conversation_models.dart';

/// Performance optimizer for neural intelligence features
class NeuralPerformanceOptimizer {
  static final NeuralPerformanceOptimizer _instance =
      NeuralPerformanceOptimizer._internal();
  factory NeuralPerformanceOptimizer() => _instance;
  NeuralPerformanceOptimizer._internal();

  final Logger _logger = Logger();

  // Memory management
  static const int _maxCachedContexts = 50;
  static const int _maxCachedAnalyses = 200;
  static const Duration _cacheExpiryDuration = Duration(hours: 2);
  static const Duration _cleanupInterval = Duration(minutes: 30);

  // Cache storage with LRU eviction
  final _contextCache =
      LRUCache<String, CachedConversationContext>(_maxCachedContexts);
  final _analysisCache = LRUCache<String, CachedAnalysis>(_maxCachedAnalyses);
  final _predictionCache =
      LRUCache<String, CachedPredictions>(_maxCachedContexts);

  // Performance metrics
  final _performanceMetrics = PerformanceMetrics();
  Timer? _cleanupTimer;
  Timer? _metricsTimer;

  /// Initialize the performance optimizer
  Future<void> initialize() async {
    try {
      _startBackgroundOptimization();
      _startPerformanceMonitoring();
      _logger.i('Neural Performance Optimizer initialized');
    } catch (e) {
      _logger.e('Failed to initialize Neural Performance Optimizer: $e');
    }
  }

  /// Optimize conversation context for storage and retrieval
  Future<NeuralConversationContext?> getOptimizedContext(
      String conversationId) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Check cache first
      final cached = _contextCache.get(conversationId);
      if (cached != null && !cached.isExpired) {
        _performanceMetrics.recordCacheHit('context');
        _performanceMetrics.recordOperationTime(
            'context_retrieval', stopwatch.elapsedMicroseconds);
        return cached.context;
      }

      _performanceMetrics.recordCacheMiss('context');
      return null;
    } finally {
      stopwatch.stop();
    }
  }

  /// Cache conversation context with optimization
  Future<void> cacheOptimizedContext(
    String conversationId,
    NeuralConversationContext context,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Optimize context before caching
      final optimizedContext = _optimizeContextForCache(context);

      // Cache with expiry
      _contextCache.put(
        conversationId,
        CachedConversationContext(
          context: optimizedContext,
          cachedAt: DateTime.now(),
        ),
      );

      _performanceMetrics.recordCacheWrite('context');
      _performanceMetrics.recordOperationTime(
          'context_caching', stopwatch.elapsedMicroseconds);

      _logger.d('Cached optimized context for conversation: $conversationId');
    } catch (e) {
      _logger.w('Failed to cache context: $e');
    } finally {
      stopwatch.stop();
    }
  }

  /// Get cached turn analysis
  Future<TurnAnalysis?> getCachedAnalysis(String turnId) async {
    final stopwatch = Stopwatch()..start();

    try {
      final cached = _analysisCache.get(turnId);
      if (cached != null && !cached.isExpired) {
        _performanceMetrics.recordCacheHit('analysis');
        _performanceMetrics.recordOperationTime(
            'analysis_retrieval', stopwatch.elapsedMicroseconds);
        return cached.analysis;
      }

      _performanceMetrics.recordCacheMiss('analysis');
      return null;
    } finally {
      stopwatch.stop();
    }
  }

  /// Cache turn analysis
  Future<void> cacheAnalysis(String turnId, TurnAnalysis analysis) async {
    final stopwatch = Stopwatch()..start();

    try {
      _analysisCache.put(
        turnId,
        CachedAnalysis(
          analysis: analysis,
          cachedAt: DateTime.now(),
        ),
      );

      _performanceMetrics.recordCacheWrite('analysis');
      _performanceMetrics.recordOperationTime(
          'analysis_caching', stopwatch.elapsedMicroseconds);
    } catch (e) {
      _logger.w('Failed to cache analysis: $e');
    } finally {
      stopwatch.stop();
    }
  }

  /// Get cached predictions
  Future<PredictiveInsights?> getCachedPredictions(String contextKey) async {
    final stopwatch = Stopwatch()..start();

    try {
      final cached = _predictionCache.get(contextKey);
      if (cached != null && !cached.isExpired) {
        _performanceMetrics.recordCacheHit('predictions');
        _performanceMetrics.recordOperationTime(
            'prediction_retrieval', stopwatch.elapsedMicroseconds);
        return cached.predictions;
      }

      _performanceMetrics.recordCacheMiss('predictions');
      return null;
    } finally {
      stopwatch.stop();
    }
  }

  /// Cache predictions
  Future<void> cachePredictions(
      String contextKey, PredictiveInsights predictions) async {
    final stopwatch = Stopwatch()..start();

    try {
      _predictionCache.put(
        contextKey,
        CachedPredictions(
          predictions: predictions,
          cachedAt: DateTime.now(),
        ),
      );

      _performanceMetrics.recordCacheWrite('predictions');
      _performanceMetrics.recordOperationTime(
          'prediction_caching', stopwatch.elapsedMicroseconds);
    } catch (e) {
      _logger.w('Failed to cache predictions: $e');
    } finally {
      stopwatch.stop();
    }
  }

  /// Optimize memory usage by compacting data structures
  Future<void> optimizeMemoryUsage() async {
    final stopwatch = Stopwatch()..start();

    try {
      final beforeMemory = _calculateMemoryUsage();

      // Clean expired entries
      _cleanupExpiredEntries();

      // Compact conversation histories
      _compactConversationHistories();

      // Optimize emotional trajectories
      _optimizeEmotionalTrajectories();

      final afterMemory = _calculateMemoryUsage();
      final savedMemory = beforeMemory - afterMemory;

      _performanceMetrics.recordMemoryOptimization(savedMemory);
      _logger.i('Memory optimization saved ${_formatBytes(savedMemory)}');
    } catch (e) {
      _logger.w('Memory optimization failed: $e');
    } finally {
      stopwatch.stop();
      _performanceMetrics.recordOperationTime(
          'memory_optimization', stopwatch.elapsedMicroseconds);
    }
  }

  /// Get performance metrics
  PerformanceMetrics get performanceMetrics => _performanceMetrics;

  /// Get cache statistics
  CacheStatistics getCacheStatistics() {
    return CacheStatistics(
      contextCacheSize: _contextCache.size,
      contextCacheHitRate: _performanceMetrics.getCacheHitRate('context'),
      analysisCacheSize: _analysisCache.size,
      analysisCacheHitRate: _performanceMetrics.getCacheHitRate('analysis'),
      predictionCacheSize: _predictionCache.size,
      predictionCacheHitRate:
          _performanceMetrics.getCacheHitRate('predictions'),
    );
  }

  /// Clear all caches
  Future<void> clearAllCaches() async {
    _contextCache.clear();
    _analysisCache.clear();
    _predictionCache.clear();
    _logger.i('All caches cleared');
  }

  /// Dispose optimizer and cleanup resources
  Future<void> dispose() async {
    _cleanupTimer?.cancel();
    _metricsTimer?.cancel();
    await clearAllCaches();
    _logger.i('Neural Performance Optimizer disposed');
  }

  // Private optimization methods

  NeuralConversationContext _optimizeContextForCache(
      NeuralConversationContext context) {
    // Limit conversation history to recent turns
    const maxHistorySize = 20;
    final optimizedHistory = context.conversationHistory.length > maxHistorySize
        ? context.conversationHistory
            .sublist(context.conversationHistory.length - maxHistorySize)
        : context.conversationHistory;

    // Simplify emotional trajectory
    final optimizedTrajectory =
        _optimizeEmotionalTrajectory(context.emotionalFlow.emotionalTrajectory);

    // TODO: Implement copyWith methods in neural conversation models
    // For now, return context as-is to avoid compilation errors
    return context;

    // Create optimized context (when copyWith is implemented)
    // return context.copyWith(
    //   conversationHistory: optimizedHistory,
    //   emotionalFlow: context.emotionalFlow.copyWith(
    //     emotionalTrajectory: optimizedTrajectory,
    //   ),
    // );
  }

  List<EmotionVector> _optimizeEmotionalTrajectory(
      List<EmotionVector> trajectory) {
    if (trajectory.length <= 10) return trajectory;

    // Keep significant emotional changes and recent entries
    const maxTrajectorySize = 10;
    final recentEntries = trajectory.sublist(trajectory.length - 5);

    // Find significant changes in the rest
    final significantChanges = <EmotionVector>[];
    for (int i = 1; i < trajectory.length - 5; i++) {
      final current = trajectory[i];
      final previous = trajectory[i - 1];

      if (current.distanceTo(previous) > 0.3) {
        significantChanges.add(current);
      }
    }

    // Combine and limit
    final optimized = [...significantChanges, ...recentEntries];
    return optimized.length > maxTrajectorySize
        ? optimized.sublist(optimized.length - maxTrajectorySize)
        : optimized;
  }

  void _startBackgroundOptimization() {
    _cleanupTimer = Timer.periodic(_cleanupInterval, (_) async {
      await _performBackgroundCleanup();
    });
  }

  void _startPerformanceMonitoring() {
    _metricsTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _logPerformanceMetrics();
    });
  }

  Future<void> _performBackgroundCleanup() async {
    try {
      _cleanupExpiredEntries();

      // Optimize memory if usage is high
      final memoryUsage = _calculateMemoryUsage();
      if (memoryUsage > 50 * 1024 * 1024) {
        // 50MB threshold
        await optimizeMemoryUsage();
      }

      _logger.d('Background cleanup completed');
    } catch (e) {
      _logger.w('Background cleanup failed: $e');
    }
  }

  void _cleanupExpiredEntries() {
    final now = DateTime.now();

    _contextCache.removeWhere((key, value) => value.isExpired);
    _analysisCache.removeWhere((key, value) => value.isExpired);
    _predictionCache.removeWhere((key, value) => value.isExpired);
  }

  void _compactConversationHistories() {
    _contextCache.forEach((key, value) {
      if (value.context.conversationHistory.length > 20) {
        // This would trigger re-optimization when accessed
        value.markForReoptimization();
      }
    });
  }

  void _optimizeEmotionalTrajectories() {
    _contextCache.forEach((key, value) {
      final trajectory = value.context.emotionalFlow.emotionalTrajectory;
      if (trajectory.length > 15) {
        // Mark for trajectory optimization
        value.markForReoptimization();
      }
    });
  }

  int _calculateMemoryUsage() {
    // Simplified memory calculation
    int usage = 0;

    usage += _contextCache.size * 1024; // Estimated 1KB per context
    usage += _analysisCache.size * 512; // Estimated 512B per analysis
    usage += _predictionCache.size * 2048; // Estimated 2KB per prediction set

    return usage;
  }

  void _logPerformanceMetrics() {
    final stats = getCacheStatistics();
    _logger.i('Performance Stats: '
        'Context cache: ${stats.contextCacheSize} items (${(stats.contextCacheHitRate * 100).round()}% hit rate), '
        'Analysis cache: ${stats.analysisCacheSize} items (${(stats.analysisCacheHitRate * 100).round()}% hit rate), '
        'Memory usage: ${_formatBytes(_calculateMemoryUsage())}');
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// LRU Cache implementation
class LRUCache<K, V> {
  final int maxSize;
  final LinkedHashMap<K, V> _cache = LinkedHashMap<K, V>();

  LRUCache(this.maxSize);

  V? get(K key) {
    final value = _cache.remove(key);
    if (value != null) {
      _cache[key] = value;
    }
    return value;
  }

  void put(K key, V value) {
    _cache.remove(key);
    _cache[key] = value;

    if (_cache.length > maxSize) {
      _cache.remove(_cache.keys.first);
    }
  }

  void clear() => _cache.clear();
  int get size => _cache.length;

  void removeWhere(bool Function(K key, V value) test) {
    _cache.removeWhere(test);
  }

  void forEach(void Function(K key, V value) action) {
    _cache.forEach(action);
  }
}

/// Cached conversation context
class CachedConversationContext {
  final NeuralConversationContext context;
  final DateTime cachedAt;
  bool _needsReoptimization = false;

  CachedConversationContext({
    required this.context,
    required this.cachedAt,
  });

  bool get isExpired =>
      DateTime.now().difference(cachedAt) >
      NeuralPerformanceOptimizer._cacheExpiryDuration;
  bool get needsReoptimization => _needsReoptimization;

  void markForReoptimization() => _needsReoptimization = true;
}

/// Cached turn analysis
class CachedAnalysis {
  final TurnAnalysis analysis;
  final DateTime cachedAt;

  CachedAnalysis({
    required this.analysis,
    required this.cachedAt,
  });

  bool get isExpired =>
      DateTime.now().difference(cachedAt) >
      NeuralPerformanceOptimizer._cacheExpiryDuration;
}

/// Cached predictions
class CachedPredictions {
  final PredictiveInsights predictions;
  final DateTime cachedAt;

  CachedPredictions({
    required this.predictions,
    required this.cachedAt,
  });

  bool get isExpired =>
      DateTime.now().difference(cachedAt) >
      NeuralPerformanceOptimizer._cacheExpiryDuration;
}

/// Performance metrics tracking
class PerformanceMetrics {
  final Map<String, int> _cacheHits = {};
  final Map<String, int> _cacheMisses = {};
  final Map<String, int> _cacheWrites = {};
  final Map<String, List<int>> _operationTimes = {};
  int _memoryOptimizations = 0;
  int _memorySaved = 0;

  void recordCacheHit(String cacheType) {
    _cacheHits[cacheType] = (_cacheHits[cacheType] ?? 0) + 1;
  }

  void recordCacheMiss(String cacheType) {
    _cacheMisses[cacheType] = (_cacheMisses[cacheType] ?? 0) + 1;
  }

  void recordCacheWrite(String cacheType) {
    _cacheWrites[cacheType] = (_cacheWrites[cacheType] ?? 0) + 1;
  }

  void recordOperationTime(String operation, int microseconds) {
    _operationTimes.putIfAbsent(operation, () => <int>[]);
    _operationTimes[operation]!.add(microseconds);

    // Keep only recent measurements
    if (_operationTimes[operation]!.length > 100) {
      _operationTimes[operation]!.removeAt(0);
    }
  }

  void recordMemoryOptimization(int bytesSaved) {
    _memoryOptimizations++;
    _memorySaved += bytesSaved;
  }

  double getCacheHitRate(String cacheType) {
    final hits = _cacheHits[cacheType] ?? 0;
    final misses = _cacheMisses[cacheType] ?? 0;
    final total = hits + misses;
    return total > 0 ? hits / total : 0.0;
  }

  double getAverageOperationTime(String operation) {
    final times = _operationTimes[operation];
    if (times == null || times.isEmpty) return 0.0;

    return times.reduce((a, b) => a + b) /
        times.length /
        1000.0; // Convert to milliseconds
  }

  Map<String, dynamic> toMap() {
    return {
      'cache_hits': _cacheHits,
      'cache_misses': _cacheMisses,
      'cache_writes': _cacheWrites,
      'memory_optimizations': _memoryOptimizations,
      'memory_saved_bytes': _memorySaved,
      'average_operation_times': _operationTimes.map(
        (operation, times) =>
            MapEntry(operation, getAverageOperationTime(operation)),
      ),
    };
  }
}

/// Cache statistics
class CacheStatistics {
  final int contextCacheSize;
  final double contextCacheHitRate;
  final int analysisCacheSize;
  final double analysisCacheHitRate;
  final int predictionCacheSize;
  final double predictionCacheHitRate;

  const CacheStatistics({
    required this.contextCacheSize,
    required this.contextCacheHitRate,
    required this.analysisCacheSize,
    required this.analysisCacheHitRate,
    required this.predictionCacheSize,
    required this.predictionCacheHitRate,
  });

  double get overallHitRate {
    return (contextCacheHitRate +
            analysisCacheHitRate +
            predictionCacheHitRate) /
        3;
  }

  Map<String, dynamic> toMap() {
    return {
      'context_cache_size': contextCacheSize,
      'context_cache_hit_rate': contextCacheHitRate,
      'analysis_cache_size': analysisCacheSize,
      'analysis_cache_hit_rate': analysisCacheHitRate,
      'prediction_cache_size': predictionCacheSize,
      'prediction_cache_hit_rate': predictionCacheHitRate,
      'overall_hit_rate': overallHitRate,
    };
  }
}
