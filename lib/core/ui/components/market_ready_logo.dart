import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Market-ready animated logo implementing advanced visual techniques
/// Showcases mathematical gradient animations, multi-layer shadows, 
/// and shader-based rendering for premium brand presentation
class MarketReadyLogo extends StatefulWidget {
  final double size;
  final bool enablePulse;
  final bool enableGradientAnimation;
  final Duration animationDuration;

  const MarketReadyLogo({
    Key? key,
    this.size = 120.0,
    this.enablePulse = true,
    this.enableGradientAnimation = true,
    this.animationDuration = const Duration(seconds: 3),
  }) : super(key: key);

  @override
  State<MarketReadyLogo> createState() => _MarketReadyLogoState();
}

class _MarketReadyLogoState extends State<MarketReadyLogo>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;

  // Color palette for the premium brand identity
  static const _primaryGradientColors = [
    Color(0xFF667EEA), // Soft Blue
    Color(0xFF764BA2), // Royal Purple
    Color(0xFFF093FB), // Pink Accent
    Color(0xFFF5576C), // Coral Red
  ];

  static const _secondaryGradientColors = [
    Color(0xFF4FACFE), // Sky Blue
    Color(0xFF00F2FE), // Cyan
    Color(0xFFA8EDEA), // Mint
    Color(0xFFFED6E3), // Light Pink
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _gradientController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _gradientController,
            _pulseController,
            _rotationController,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: widget.enablePulse 
                  ? 1.0 + (_pulseController.value * 0.05) // Subtle breathing effect
                  : 1.0,
              child: Transform.rotate(
                angle: _rotationController.value * 2 * pi * 0.1, // Slow rotation
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: _buildMultiLayerShadows(),
                    gradient: widget.enableGradientAnimation
                        ? _buildParametricGradient()
                        : _buildStaticGradient(),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2.0,
                      ),
                    ),
                    child: Center(
                      child: ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds);
                        },
                        child: Icon(
                          Icons.language,
                          size: widget.size * 0.4,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Creates multi-layer shadow system for 3D depth perception
  List<BoxShadow> _buildMultiLayerShadows() {
    final pulseIntensity = widget.enablePulse ? _pulseController.value : 0.5;
    
    return [
      // Primary shadow (deepest)
      BoxShadow(
        color: _primaryGradientColors[0].withValues(alpha: 0.4 * pulseIntensity),
        blurRadius: 20.0,
        offset: const Offset(0, 8),
        spreadRadius: 2.0,
      ),
      // Secondary shadow (mid-depth)
      BoxShadow(
        color: _primaryGradientColors[1].withValues(alpha: 0.3 * pulseIntensity),
        blurRadius: 15.0,
        offset: const Offset(0, 4),
        spreadRadius: 1.0,
      ),
      // Tertiary shadow (surface)
      BoxShadow(
        color: _primaryGradientColors[2].withValues(alpha: 0.2 * pulseIntensity),
        blurRadius: 8.0,
        offset: const Offset(0, 2),
        spreadRadius: 0.5,
      ),
      // Ambient glow
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.1 * pulseIntensity),
        blurRadius: 25.0,
        offset: Offset.zero,
        spreadRadius: 3.0,
      ),
    ];
  }

  /// Creates parametric color morphing using trigonometric functions
  Gradient _buildParametricGradient() {
    final t = _gradientController.value;
    
    // Primary color interpolation using sine waves
    final primaryColor = Color.lerp(
      _primaryGradientColors[0],
      _primaryGradientColors[1],
      (sin(t * 2 * pi) + 1) / 2,
    )!;

    // Secondary color interpolation using cosine waves
    final secondaryColor = Color.lerp(
      _primaryGradientColors[2],
      _primaryGradientColors[3],
      (cos(t * 2 * pi + pi / 4) + 1) / 2,
    )!;

    // Accent color using phase-shifted sine
    final accentColor = Color.lerp(
      _secondaryGradientColors[0],
      _secondaryGradientColors[1],
      (sin(t * 3 * pi + pi / 2) + 1) / 2,
    )!;

    // Create radial gradient with off-center positioning for lighting simulation
    return RadialGradient(
      center: Alignment(
        0.3 * sin(t * 2 * pi), // Dynamic center movement
        -0.3 * cos(t * 2 * pi),
      ),
      radius: 1.2,
      colors: [
        primaryColor.withValues(alpha: 0.9),
        secondaryColor.withValues(alpha: 0.8),
        accentColor.withValues(alpha: 0.7),
        _secondaryGradientColors[3].withValues(alpha: 0.6),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );
  }

  /// Static gradient for non-animated version
  Gradient _buildStaticGradient() {
    return const RadialGradient(
      center: Alignment(-0.3, -0.3),
      radius: 1.2,
      colors: [
        Color(0xFF667EEA),
        Color(0xFF764BA2),
        Color(0xFFF093FB),
        Color(0xFFF5576C),
      ],
      stops: [0.0, 0.3, 0.7, 1.0],
    );
  }
}

/// Floating particle system for ambient effects
class FloatingParticleSystem extends StatefulWidget {
  final int particleCount;
  final double size;
  final Duration animationDuration;

  const FloatingParticleSystem({
    Key? key,
    this.particleCount = 12,
    this.size = 200.0,
    this.animationDuration = const Duration(seconds: 10),
  }) : super(key: key);

  @override
  State<FloatingParticleSystem> createState() => _FloatingParticleSystemState();
}

class _FloatingParticleSystemState extends State<FloatingParticleSystem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat();

    _particles = List.generate(
      widget.particleCount,
      (index) => Particle.random(index, widget.size),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: ParticleSystemPainter(
              particles: _particles,
              animationValue: _controller.value,
            ),
            size: Size(widget.size, widget.size),
          );
        },
      ),
    );
  }
}

/// Individual particle with orbital motion
class Particle {
  final double radius;
  final double angle;
  final double speed;
  final double orbitRadius;
  final Color color;
  final double size;

  Particle({
    required this.radius,
    required this.angle,
    required this.speed,
    required this.orbitRadius,
    required this.color,
    required this.size,
  });

  factory Particle.random(int index, double containerSize) {
    final random = Random(index);
    return Particle(
      radius: random.nextDouble() * (containerSize * 0.4),
      angle: random.nextDouble() * 2 * pi,
      speed: 0.5 + random.nextDouble() * 1.5,
      orbitRadius: 20 + random.nextDouble() * 40,
      color: Color.lerp(
        const Color(0xFF667EEA),
        const Color(0xFFF093FB),
        random.nextDouble(),
      )!.withValues(alpha: 0.3 + random.nextDouble() * 0.4),
      size: 2 + random.nextDouble() * 4,
    );
  }

  /// Calculate position using parametric orbital equations
  Offset getPosition(double animationValue, double containerSize) {
    final currentAngle = angle + (animationValue * speed * 2 * pi);
    final centerX = containerSize / 2;
    final centerY = containerSize / 2;
    
    return Offset(
      centerX + cos(currentAngle) * orbitRadius,
      centerY + sin(currentAngle) * orbitRadius,
    );
  }
}

/// Custom painter for particle system rendering
class ParticleSystemPainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticleSystemPainter({
    required this.particles,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final position = particle.getPosition(animationValue, size.width);
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      // Add subtle glow effect
      final glowPaint = Paint()
        ..color = particle.color.withValues(alpha: 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

      // Draw glow
      canvas.drawCircle(position, particle.size * 2, glowPaint);
      
      // Draw particle
      canvas.drawCircle(position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(ParticleSystemPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// Glassmorphism container with backdrop filtering
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final double borderRadius;
  final double blur;
  final double opacity;

  const GlassmorphicContainer({
    Key? key,
    required this.child,
    this.width = 300,
    this.height = 200,
    this.borderRadius = 16.0,
    this.blur = 10.0,
    this.opacity = 0.2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
