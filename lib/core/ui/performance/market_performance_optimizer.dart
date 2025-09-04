import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Market-ready performance optimizer implementing hardware-accelerated
/// animation management for smooth 60fps experiences and battery efficiency
class MarketPerformanceOptimizer {
  static final MarketPerformanceOptimizer _instance = MarketPerformanceOptimizer._internal();
  factory MarketPerformanceOptimizer() => _instance;
  MarketPerformanceOptimizer._internal();

  // Performance tracking
  final Queue<double> _frameTimes = Queue<double>();
  final Queue<int> _memoryReadings = Queue<int>();
  int _frameCount = 0;
  double _currentFps = 60.0;
  bool _isMonitoring = false;
  
  // Animation management
  final Set<AnimationController> _activeControllers = <AnimationController>{};
  final Map<String, PerformanceMetrics> _animationMetrics = <String, PerformanceMetrics>{};
  
  // Battery optimization
  bool _lowPowerModeEnabled = false;
  bool _adaptiveQualityEnabled = true;
  
  // Performance thresholds
  static const double _targetFps = 60.0;
  static const double _minimumAcceptableFps = 45.0;
  static const int _maxMemoryThreshold = 100 * 1024 * 1024; // 100MB
  static const int _sampleSize = 60; // 1 second at 60fps

  /// Initialize performance monitoring
  void initialize() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _startPerformanceMonitoring();
    
    debugPrint('🚀 Market Performance Optimizer initialized');
    debugPrint('   Target FPS: ${_targetFps.toInt()}');
    debugPrint('   Adaptive Quality: $_adaptiveQualityEnabled');
    debugPrint('   Low Power Mode: $_lowPowerModeEnabled');
  }

  /// Start monitoring frame timing and memory usage
  void _startPerformanceMonitoring() {
    SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
  }

  /// Handle frame timing callbacks for FPS calculation
  void _onFrameTimings(List<FrameTiming> timings) {
    if (!_isMonitoring) return;

    for (final timing in timings) {
      final frameTime = timing.totalSpan.inMicroseconds / 1000.0; // Convert to milliseconds
      _frameTimes.add(frameTime);
      
      if (_frameTimes.length > _sampleSize) {
        _frameTimes.removeFirst();
      }
      
      _frameCount++;
      
      // Calculate FPS every 60 frames
      if (_frameCount % 60 == 0) {
        _calculateFps();
        _checkPerformanceHealth();
      }
    }
  }

  /// Calculate current FPS from frame timings
  void _calculateFps() {
    if (_frameTimes.isEmpty) return;

    final averageFrameTime = _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
    _currentFps = 1000.0 / averageFrameTime; // Convert ms to fps
    
    // Clamp to reasonable values
    _currentFps = _currentFps.clamp(0.0, 120.0);
  }

  /// Check overall performance health and adapt accordingly
  void _checkPerformanceHealth() {
    if (_currentFps < _minimumAcceptableFps) {
      _activateLowPowerMode();
    } else if (_currentFps > _targetFps * 0.9) {
      _deactivateLowPowerMode();
    }
  }

  /// Activate low power mode for performance optimization
  void _activateLowPowerMode() {
    if (_lowPowerModeEnabled) return;
    
    _lowPowerModeEnabled = true;
    debugPrint('⚡ Low Power Mode activated (FPS: ${_currentFps.toStringAsFixed(1)})');
    
    // Reduce animation quality for active controllers
    for (final controller in _activeControllers) {
      if (controller.isAnimating) {
        _optimizeAnimationForPerformance(controller);
      }
    }
  }

  /// Deactivate low power mode when performance improves
  void _deactivateLowPowerMode() {
    if (!_lowPowerModeEnabled) return;
    
    _lowPowerModeEnabled = false;
    debugPrint('🚀 Low Power Mode deactivated (FPS: ${_currentFps.toStringAsFixed(1)})');
  }

  /// Register an animation controller for performance monitoring
  void registerAnimationController(AnimationController controller, String name) {
    _activeControllers.add(controller);
    _animationMetrics[name] = PerformanceMetrics();
    
    // Add listener to track animation performance
    controller.addListener(() {
      _trackAnimationMetrics(name, controller);
    });
    
    // Remove from tracking when disposed
    controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed || status == AnimationStatus.completed) {
        _activeControllers.remove(controller);
      }
    });
  }

  /// Track performance metrics for a specific animation
  void _trackAnimationMetrics(String name, AnimationController controller) {
    final metrics = _animationMetrics[name];
    if (metrics == null) return;

    metrics.frameCount++;
    metrics.lastUpdateTime = DateTime.now();
  }

  /// Optimize animation for current performance conditions
  void _optimizeAnimationForPerformance(AnimationController controller) {
    // Reduce animation duration for better performance
    final originalDuration = controller.duration;
    if (originalDuration != null && originalDuration.inMilliseconds > 500) {
      controller.duration = Duration(
        milliseconds: (originalDuration.inMilliseconds * 0.7).round(),
      );
    }
  }

  /// Create an optimized animation controller
  AnimationController createOptimizedController({
    required TickerProvider vsync,
    required Duration duration,
    Duration? reverseDuration,
    String? debugLabel,
  }) {
    final controller = AnimationController(
      vsync: vsync,
      duration: _lowPowerModeEnabled 
          ? Duration(milliseconds: (duration.inMilliseconds * 0.8).round())
          : duration,
      reverseDuration: reverseDuration,
      debugLabel: debugLabel,
    );

    if (debugLabel != null) {
      registerAnimationController(controller, debugLabel);
    }

    return controller;
  }

  /// Get current performance stats
  PerformanceStats getPerformanceStats() {
    return PerformanceStats(
      currentFps: _currentFps,
      averageFrameTime: _frameTimes.isNotEmpty 
          ? _frameTimes.reduce((a, b) => a + b) / _frameTimes.length
          : 16.67, // Default to 60fps
      isLowPowerModeActive: _lowPowerModeEnabled,
      activeAnimations: _activeControllers.length,
      memoryUsage: _getCurrentMemoryUsage(),
    );
  }

  /// Get current memory usage (mock implementation)
  int _getCurrentMemoryUsage() {
    // In a real implementation, this would use platform-specific methods
    // to get actual memory usage
    return 50 * 1024 * 1024; // Mock 50MB usage
  }

  /// Dispose of performance optimizer
  void dispose() {
    _isMonitoring = false;
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
    _activeControllers.clear();
    _animationMetrics.clear();
    _frameTimes.clear();
    _memoryReadings.clear();
  }

  // Getters for performance state
  double get currentFps => _currentFps;
  bool get isLowPowerModeActive => _lowPowerModeEnabled;
  bool get isPerformanceHealthy => _currentFps >= _minimumAcceptableFps;
  int get activeAnimationCount => _activeControllers.length;
}

/// Performance metrics for individual animations
class PerformanceMetrics {
  int frameCount = 0;
  DateTime? lastUpdateTime;
  Duration? totalDuration;

  double get averageFps => frameCount > 0 && lastUpdateTime != null
      ? frameCount / (DateTime.now().difference(lastUpdateTime!).inSeconds + 1)
      : 0.0;
}

/// Overall performance statistics
class PerformanceStats {
  final double currentFps;
  final double averageFrameTime;
  final bool isLowPowerModeActive;
  final int activeAnimations;
  final int memoryUsage;

  PerformanceStats({
    required this.currentFps,
    required this.averageFrameTime,
    required this.isLowPowerModeActive,
    required this.activeAnimations,
    required this.memoryUsage,
  });

  bool get isHealthy => currentFps >= 45.0 && memoryUsage < 100 * 1024 * 1024;
  
  String get healthStatus {
    if (currentFps >= 55.0) return 'Excellent';
    if (currentFps >= 45.0) return 'Good';
    if (currentFps >= 30.0) return 'Fair';
    return 'Poor';
  }
}

/// Performance-optimized animated widget base class
abstract class PerformanceOptimizedWidget extends StatefulWidget {
  const PerformanceOptimizedWidget({Key? key}) : super(key: key);

  @override
  PerformanceOptimizedWidgetState createState();
}

abstract class PerformanceOptimizedWidgetState<T extends PerformanceOptimizedWidget> 
    extends State<T> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final MarketPerformanceOptimizer _optimizer = MarketPerformanceOptimizer();

  @override
  void initState() {
    super.initState();
    
    _controller = _optimizer.createOptimizedController(
      vsync: this,
      duration: getAnimationDuration(),
      debugLabel: widget.runtimeType.toString(),
    );
    
    initializeAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Abstract methods to be implemented by subclasses
  Duration getAnimationDuration();
  void initializeAnimation();
  
  // Getters for subclasses
  AnimationController get controller => _controller;
  MarketPerformanceOptimizer get optimizer => _optimizer;
}

/// Performance monitoring widget for debugging
class PerformanceMonitorWidget extends StatefulWidget {
  final Widget child;
  final bool showOverlay;

  const PerformanceMonitorWidget({
    Key? key,
    required this.child,
    this.showOverlay = false,
  }) : super(key: key);

  @override
  State<PerformanceMonitorWidget> createState() => _PerformanceMonitorWidgetState();
}

class _PerformanceMonitorWidgetState extends State<PerformanceMonitorWidget> {
  final MarketPerformanceOptimizer _optimizer = MarketPerformanceOptimizer();
  Timer? _updateTimer;
  PerformanceStats? _stats;

  @override
  void initState() {
    super.initState();
    _optimizer.initialize();
    
    if (widget.showOverlay) {
      _startMonitoring();
    }
  }

  void _startMonitoring() {
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _stats = _optimizer.getPerformanceStats();
        });
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RepaintBoundary(child: widget.child),
        if (widget.showOverlay && _stats != null && kDebugMode)
          Positioned(
            top: MediaQuery.of(context).padding.top + 50,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'FPS: ${_stats!.currentFps.toStringAsFixed(1)}',
                    style: TextStyle(
                      color: _getPerformanceColor(_stats!.currentFps),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Status: ${_stats!.healthStatus}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  Text(
                    'Animations: ${_stats!.activeAnimations}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  if (_stats!.isLowPowerModeActive)
                    const Text(
                      '⚡ Low Power',
                      style: TextStyle(color: Colors.orange, fontSize: 10),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Color _getPerformanceColor(double fps) {
    if (fps >= 55) return Colors.green;
    if (fps >= 45) return Colors.yellow;
    if (fps >= 30) return Colors.orange;
    return Colors.red;
  }
}
