// 🌐 LingoSphere - Splash Screen
// Modern animated splash screen with initialization progress

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/theme/app_theme.dart';
import '../../home/presentation/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _progressController;
  late AnimationController _textController;
  
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _progressValue;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  
  String _initializationText = 'Initializing LingoSphere...';
  double _progress = 0.0;
  
  final List<String> _initSteps = [
    'Initializing LingoSphere...',
    'Loading translation engines...',
    'Connecting to services...',
    'Preparing AI models...',
    'Optimizing for your device...',
    'Almost ready...',
  ];
  
  int _currentStep = 0;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialization();
  }
  
  @override
  void dispose() {
    _logoController.dispose();
    _progressController.dispose();
    _textController.dispose();
    super.dispose();
  }
  
  void _initializeAnimations() {
    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Progress animation controller
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Logo animations
    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));
    
    // Progress animation
    _progressValue = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    // Text animations
    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));
    
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));
  }
  
  Future<void> _startInitialization() async {
    // Start logo animation
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    
    // Wait for logo to settle
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Start text animation
    _textController.forward();
    
    // Start progress animation
    await Future.delayed(const Duration(milliseconds: 500));
    _progressController.forward();
    
    // Simulate initialization steps
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted && _currentStep < _initSteps.length - 1) {
        setState(() {
          _currentStep++;
          _initializationText = _initSteps[_currentStep];
          _progress = (_currentStep + 1) / _initSteps.length;
        });
        
        // Animate text change
        _textController.reset();
        _textController.forward();
      } else {
        timer.cancel();
        _completeInitialization();
      }
    });
  }
  
  Future<void> _completeInitialization() async {
    // Wait a moment before navigating
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (mounted) {
      // Navigate to home screen
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // Logo Section
                AnimationLimiter(
                  child: AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScale.value,
                        child: Opacity(
                          opacity: _logoOpacity.value,
                          child: Column(
                            children: AnimationConfiguration.toStaggeredList(
                              duration: const Duration(milliseconds: 600),
                              childAnimationBuilder: (widget) => SlideAnimation(
                                verticalOffset: 30.0,
                                child: FadeInAnimation(child: widget),
                              ),
                              children: [
                                // App Icon/Logo
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: AppTheme.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.translate_rounded,
                                    size: 60,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // App Name
                                Text(
                                  AppConstants.appName,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.white,
                                    fontFamily: AppTheme.headingFontFamily,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                
                                const SizedBox(height: 8),
                                
                                // App Description
                                Text(
                                  'Seamless multilingual communication',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppTheme.white.withOpacity(0.9),
                                    fontFamily: AppTheme.primaryFontFamily,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const Spacer(flex: 2),
                
                // Progress Section
                Column(
                  children: [
                    // Initialization Text
                    AnimatedBuilder(
                      animation: _textController,
                      builder: (context, child) {
                        return SlideTransition(
                          position: _textSlide,
                          child: FadeTransition(
                            opacity: _textOpacity,
                            child: Text(
                              _initializationText,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.white.withOpacity(0.9),
                                fontFamily: AppTheme.primaryFontFamily,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Progress Bar
                    AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return Column(
                          children: [
                            Container(
                              width: screenSize.width * 0.6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppTheme.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: LinearProgressIndicator(
                                value: _progressValue.value,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.white,
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Progress Percentage
                            Text(
                              '${(_progressValue.value * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.white.withOpacity(0.7),
                                fontFamily: AppTheme.primaryFontFamily,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // Footer
                Text(
                  '© 2024 LingoSphere • Version ${AppConstants.appVersion}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.white.withOpacity(0.6),
                    fontFamily: AppTheme.primaryFontFamily,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
