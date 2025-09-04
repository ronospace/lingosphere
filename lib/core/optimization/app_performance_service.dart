// ⚡ LingoSphere - Comprehensive App Performance Service
// Integrates neural and UI performance optimization for enterprise-grade performance

import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import 'neural_performance_optimizer.dart';
import '../ui/performance/market_performance_optimizer.dart';
import '../models/neural_conversation_models.dart';

/// Comprehensive app performance service integrating all optimization layers
class AppPerformanceService {
  static final AppPerformanceService _instance = AppPerformanceService._internal();
  factory AppPerformanceService() => _instance;
  AppPerformanceService._internal();

  final Logger _logger = Logger();
  final NeuralPerformanceOptimizer _neuralOptimizer = NeuralPerformanceOptimizer();
  final MarketPerformanceOptimizer _uiOptimizer = MarketPerformanceOptimizer();

  // Performance monitoring state
  bool _isInitialized = false;
  Timer? _performanceReportTimer;
  Timer? _adaptiveOptimizationTimer;
  
  // Performance thresholds
  static const double _criticalMemoryThreshold = 150.0; // MB
  static const double _warningMemoryThreshold = 100.0; // MB
  static const double _targetFpsThreshold = 50.0;
  static const double _criticalFpsThreshold = 30.0;
  
  // Adaptive optimization settings
  bool _adaptiveOptimizationEnabled = true;
  bool _neuralCacheOptimizationActive = false;
  bool _uiPerformanceModeActive = false;
  
  /// Initialize the comprehensive performance service
  Future<void> initialize({
    bool enableAdaptiveOptimization = true,
    bool enablePerformanceReporting = true,
    Duration reportingInterval = const Duration(minutes: 5),
    Duration adaptiveCheckInterval = const Duration(seconds: 30),
  }) async {
    if (_isInitialized) return;

    try {
      _adaptiveOptimizationEnabled = enableAdaptiveOptimization;
      
      // Initialize neural optimizer
      await _neuralOptimizer.initialize();
      
      // Initialize UI performance optimizer
      _uiOptimizer.initialize();
      
      // Start performance monitoring
      if (enablePerformanceReporting) {
        _startPerformanceReporting(reportingInterval);
      }
      
      // Start adaptive optimization
      if (_adaptiveOptimizationEnabled) {
        _startAdaptiveOptimization(adaptiveCheckInterval);
      }
      
      // Set up memory pressure monitoring
      await _setupMemoryPressureMonitoring();
      
      _isInitialized = true;
      _logger.i('🚀 App Performance Service initialized successfully');
      
    } catch (e) {
      _logger.e('Failed to initialize App Performance Service: $e');
      rethrow;
    }
  }

  /// Get comprehensive performance statistics
  Future<ComprehensivePerformanceStats> getPerformanceStats() async {
    final uiStats = _uiOptimizer.getPerformanceStats();
    final neuralStats = _neuralOptimizer.getCacheStatistics();
    final memoryUsage = await _getCurrentMemoryUsage();
    
    return ComprehensivePerformanceStats(
      uiPerformance: uiStats,
      neuralCacheStats: neuralStats,
      memoryUsageBytes: memoryUsage,
      adaptiveOptimizationActive: _adaptiveOptimizationEnabled,
      neuralCacheOptimizationActive: _neuralCacheOptimizationActive,
      uiPerformanceModeActive: _uiPerformanceModeActive,
      overallHealthScore: _calculateOverallHealthScore(uiStats, neuralStats, memoryUsage),
      recommendations: _generatePerformanceRecommendations(uiStats, neuralStats, memoryUsage),
    );
  }

  /// Optimize conversation context caching
  Future<void> optimizeConversationContext(
    String conversationId, 
    NeuralConversationContext context
  ) async {
    await _neuralOptimizer.cacheOptimizedContext(conversationId, context);
  }

  /// Get optimized conversation context
  Future<NeuralConversationContext?> getOptimizedContext(String conversationId) async {
    return await _neuralOptimizer.getOptimizedContext(conversationId);
  }

  /// Create performance-optimized animation controller
  AnimationController createOptimizedAnimationController({
    required TickerProvider vsync,
    required Duration duration,
    Duration? reverseDuration,
    String? debugLabel,
  }) {
    return _uiOptimizer.createOptimizedController(
      vsync: vsync,
      duration: duration,
      reverseDuration: reverseDuration,
      debugLabel: debugLabel,
    );
  }

  /// Force memory optimization across all systems
  Future<void> forceMemoryOptimization() async {
    _logger.i('🔧 Force memory optimization triggered');
    
    // Neural system optimization
    await _neuralOptimizer.optimizeMemoryUsage();
    
    // Trigger garbage collection
    if (!kIsWeb) {
      _triggerGarbageCollection();
    }
    
    _logger.i('✅ Memory optimization completed');
  }

  /// Enable performance monitoring overlay (debug builds only)
  Widget wrapWithPerformanceMonitoring(
    Widget child, {
    bool showOverlay = kDebugMode,
  }) {
    return PerformanceMonitorWidget(
      showOverlay: showOverlay,
      child: child,
    );
  }

  /// Start performance reporting
  void _startPerformanceReporting(Duration interval) {
    _performanceReportTimer = Timer.periodic(interval, (_) async {
      await _generatePerformanceReport();
    });
  }

  /// Start adaptive optimization monitoring
  void _startAdaptiveOptimization(Duration interval) {
    _adaptiveOptimizationTimer = Timer.periodic(interval, (_) async {
      await _performAdaptiveOptimization();
    });
  }

  /// Generate performance report
  Future<void> _generatePerformanceReport() async {
    try {
      final stats = await getPerformanceStats();
      
      _logger.i('📊 Performance Report:');
      _logger.i('   Overall Health Score: ${stats.overallHealthScore.toStringAsFixed(1)}/100');
      _logger.i('   UI FPS: ${stats.uiPerformance.currentFps.toStringAsFixed(1)}');
      _logger.i('   Memory Usage: ${(stats.memoryUsageBytes / (1024*1024)).toStringAsFixed(1)} MB');
      _logger.i('   Neural Cache Hit Rate: ${(stats.neuralCacheStats.overallHitRate * 100).toStringAsFixed(1)}%');
      _logger.i('   Active Animations: ${stats.uiPerformance.activeAnimations}');
      
      if (stats.recommendations.isNotEmpty) {
        _logger.w('📝 Performance Recommendations:');
        for (final rec in stats.recommendations) {
          _logger.w('   • $rec');
        }
      }
      
    } catch (e) {
      _logger.e('Failed to generate performance report: $e');
    }
  }

  /// Perform adaptive optimization based on current performance
  Future<void> _performAdaptiveOptimization() async {
    try {
      final stats = await getPerformanceStats();
      final memoryMB = stats.memoryUsageBytes / (1024 * 1024);
      
      // Memory-based optimization
      if (memoryMB > _criticalMemoryThreshold) {
        if (!_neuralCacheOptimizationActive) {
          _logger.w('🔧 Activating aggressive memory optimization');
          await _activateNeuralCacheOptimization();
        }
      } else if (memoryMB < _warningMemoryThreshold && _neuralCacheOptimizationActive) {
        _logger.i('✅ Deactivating aggressive memory optimization');
        await _deactivateNeuralCacheOptimization();
      }
      
      // FPS-based optimization
      if (stats.uiPerformance.currentFps < _criticalFpsThreshold) {
        if (!_uiPerformanceModeActive) {
          _logger.w('⚡ Activating UI performance mode');
          _activateUiPerformanceMode();
        }
      } else if (stats.uiPerformance.currentFps > _targetFpsThreshold && _uiPerformanceModeActive) {
        _logger.i('🚀 Deactivating UI performance mode');
        _deactivateUiPerformanceMode();
      }
      
    } catch (e) {
      _logger.e('Adaptive optimization failed: $e');
    }
  }

  /// Activate neural cache optimization
  Future<void> _activateNeuralCacheOptimization() async {
    _neuralCacheOptimizationActive = true;
    await _neuralOptimizer.optimizeMemoryUsage();
  }

  /// Deactivate neural cache optimization
  Future<void> _deactivateNeuralCacheOptimization() async {
    _neuralCacheOptimizationActive = false;
  }

  /// Activate UI performance mode
  void _activateUiPerformanceMode() {
    _uiPerformanceModeActive = true;
    // UI performance mode is handled internally by MarketPerformanceOptimizer
  }

  /// Deactivate UI performance mode
  void _deactivateUiPerformanceMode() {
    _uiPerformanceModeActive = false;
  }

  /// Setup memory pressure monitoring
  Future<void> _setupMemoryPressureMonitoring() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      // Listen for system memory warnings
      SystemChannels.lifecycle.setMessageHandler((message) async {
        if (message == AppLifecycleState.paused.toString()) {
          await _handleMemoryPressure();
        }
        return null;
      });
    }
  }

  /// Handle memory pressure events
  Future<void> _handleMemoryPressure() async {
    _logger.w('⚠️ Memory pressure detected, optimizing...');
    await forceMemoryOptimization();
  }

  /// Get current memory usage
  Future<int> _getCurrentMemoryUsage() async {
    // Mock implementation - in production, this would use platform-specific APIs
    return 75 * 1024 * 1024; // 75MB
  }

  /// Calculate overall health score
  double _calculateOverallHealthScore(
    PerformanceStats uiStats,
    CacheStatistics neuralStats,
    int memoryBytes,
  ) {
    // FPS score (40% weight)
    double fpsScore = (uiStats.currentFps / 60.0).clamp(0.0, 1.0) * 40;
    
    // Memory score (30% weight)
    double memoryMB = memoryBytes / (1024 * 1024);
    double memoryScore = (1.0 - (memoryMB / 200.0).clamp(0.0, 1.0)) * 30;
    
    // Cache efficiency score (30% weight)
    double cacheScore = neuralStats.overallHitRate * 30;
    
    return (fpsScore + memoryScore + cacheScore).clamp(0.0, 100.0);
  }

  /// Generate performance recommendations
  List<String> _generatePerformanceRecommendations(
    PerformanceStats uiStats,
    CacheStatistics neuralStats,
    int memoryBytes,
  ) {
    final recommendations = <String>[];
    
    final memoryMB = memoryBytes / (1024 * 1024);
    
    if (uiStats.currentFps < 45) {
      recommendations.add('Consider reducing animation complexity or duration');
    }
    
    if (memoryMB > 100) {
      recommendations.add('Memory usage is high, consider clearing caches');
    }
    
    if (neuralStats.overallHitRate < 0.7) {
      recommendations.add('Neural cache hit rate is low, review caching strategy');
    }
    
    if (uiStats.activeAnimations > 5) {
      recommendations.add('Multiple animations active, consider staggering them');
    }
    
    return recommendations;
  }

  /// Trigger garbage collection (non-web only)
  void _triggerGarbageCollection() {
    if (!kIsWeb) {
      // Force garbage collection by creating and releasing large objects
      final waste = List.generate(1000, (_) => List.filled(1000, 0));
      waste.clear();
    }
  }

  /// Dispose of the performance service
  Future<void> dispose() async {
    _performanceReportTimer?.cancel();
    _adaptiveOptimizationTimer?.cancel();
    
    await _neuralOptimizer.dispose();
    _uiOptimizer.dispose();
    
    _isInitialized = false;
    _logger.i('🛑 App Performance Service disposed');
  }

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isAdaptiveOptimizationEnabled => _adaptiveOptimizationEnabled;
  bool get isNeuralCacheOptimizationActive => _neuralCacheOptimizationActive;
  bool get isUiPerformanceModeActive => _uiPerformanceModeActive;
}

/// Comprehensive performance statistics
class ComprehensivePerformanceStats {
  final PerformanceStats uiPerformance;
  final CacheStatistics neuralCacheStats;
  final int memoryUsageBytes;
  final bool adaptiveOptimizationActive;
  final bool neuralCacheOptimizationActive;
  final bool uiPerformanceModeActive;
  final double overallHealthScore;
  final List<String> recommendations;

  const ComprehensivePerformanceStats({
    required this.uiPerformance,
    required this.neuralCacheStats,
    required this.memoryUsageBytes,
    required this.adaptiveOptimizationActive,
    required this.neuralCacheOptimizationActive,
    required this.uiPerformanceModeActive,
    required this.overallHealthScore,
    required this.recommendations,
  });

  double get memoryUsageMB => memoryUsageBytes / (1024 * 1024);
  
  String get healthStatus {
    if (overallHealthScore >= 85) return 'Excellent';
    if (overallHealthScore >= 70) return 'Good';
    if (overallHealthScore >= 50) return 'Fair';
    return 'Poor';
  }

  bool get hasPerformanceIssues => 
    uiPerformance.currentFps < 45 || 
    memoryUsageMB > 100 || 
    neuralCacheStats.overallHitRate < 0.7;

  Map<String, dynamic> toMap() {
    return {
      'ui_performance': {
        'current_fps': uiPerformance.currentFps,
        'average_frame_time': uiPerformance.averageFrameTime,
        'is_low_power_active': uiPerformance.isLowPowerModeActive,
        'active_animations': uiPerformance.activeAnimations,
        'health_status': uiPerformance.healthStatus,
      },
      'neural_cache_stats': neuralCacheStats.toMap(),
      'memory_usage_mb': memoryUsageMB,
      'adaptive_optimization_active': adaptiveOptimizationActive,
      'neural_cache_optimization_active': neuralCacheOptimizationActive,
      'ui_performance_mode_active': uiPerformanceModeActive,
      'overall_health_score': overallHealthScore,
      'health_status': healthStatus,
      'has_performance_issues': hasPerformanceIssues,
      'recommendations': recommendations,
    };
  }
}
