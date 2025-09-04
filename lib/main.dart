// 🌐 LingoSphere - Advanced Multilingual Translation App
// Real-time group chat translation with AI-powered insights

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'firebase_options.dart';
import 'core/constants/app_constants.dart';
import 'core/navigation/app_navigation.dart';
import 'core/services/translation_service.dart';
import 'core/services/firebase_analytics_service.dart';
import 'core/services/firebase_performance_service.dart';
import 'core/optimization/app_performance_service.dart';
import 'shared/theme/app_theme.dart';
import 'features/onboarding/presentation/splash_screen.dart';
import 'core/providers/app_providers.dart';

// Global logger instance
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    printTime: true,
  ),
);

void main() async {
  // Ensure proper Flutter binding initialization
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize error handling
  await _initializeErrorHandling();

  // Initialize core services
  await _initializeCoreServices();

  // Run the app with comprehensive error boundary
  runZonedGuarded(
    () => runApp(
      ProviderScope(
        child: const LingoSphereApp(),
      ),
    ),
    _handleZoneError,
  );
}

/// Initialize comprehensive error handling and crash reporting
Future<void> _initializeErrorHandling() async {
  // Initialize Firebase first
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Enable Crashlytics collection
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    
    // Set up Flutter error handling with Firebase
    FlutterError.onError = (errorDetails) {
      logger.e('Flutter Error: ${errorDetails.exceptionAsString()}');
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    
    // Handle platform dispatcher errors
    PlatformDispatcher.instance.onError = (error, stack) {
      logger.e('Platform Error: $error');
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    
    logger.i('✅ Firebase initialized successfully with project: cyclesync-2025-d2592');
  } catch (e, stackTrace) {
    logger.e('Failed to initialize Firebase: $e');
    
    // Fallback to basic error handling
    FlutterError.onError = (errorDetails) {
      logger.e('Flutter Error: ${errorDetails.exceptionAsString()}');
    };
    
    PlatformDispatcher.instance.onError = (error, stack) {
      logger.e('Platform Error: $error');
      return true;
    };
  }
}

/// Initialize all core services and dependencies
Future<void> _initializeCoreServices() async {
  try {
    // Initialize local storage (Hive)
    await Hive.initFlutter();

    // Initialize Firebase Services
    final analyticsService = FirebaseAnalyticsService();
    final performanceService = FirebasePerformanceService();
    
    await analyticsService.initialize();
    await performanceService.initialize();
    
    logger.i('✅ Firebase Analytics and Performance services initialized');
    
    // Set user properties
    await analyticsService.setUserProperty('device_platform', 'flutter_mobile');
    await analyticsService.setUserProperty('app_name', 'LingoSphere');
    await analyticsService.setUserProperty('app_version', AppConstants.appVersion);

    // Initialize translation service
    await TranslationService().initialize(
      googleApiKey: const String.fromEnvironment('GOOGLE_API_KEY', defaultValue: ''),
      deepLApiKey: const String.fromEnvironment('DEEPL_API_KEY', defaultValue: ''),
      openAIApiKey: const String.fromEnvironment('OPENAI_API_KEY', defaultValue: ''),
    );

    // Initialize comprehensive performance service
    await AppPerformanceService().initialize(
      enableAdaptiveOptimization: true,
      enablePerformanceReporting: true, // Now enabled with Firebase
      reportingInterval: const Duration(minutes: 5),
      adaptiveCheckInterval: const Duration(seconds: 30),
    );

    // Check network connectivity
    final connectivity = await Connectivity().checkConnectivity();
    logger.i('Network connectivity: $connectivity');
    
    // Log app initialization to Firebase
    await analyticsService.logEvent('app_initialized', {
      'success': true,
      'connectivity': connectivity.name,
      'init_time': DateTime.now().millisecondsSinceEpoch,
      'firebase_project': 'cyclesync-2025-d2592',
      'services_count': 4,
    });

    logger.i('All core services initialized successfully with Firebase integration');
  } catch (e, stackTrace) {
    logger.e('Failed to initialize core services: $e',
        error: e, stackTrace: stackTrace);
    
    // Record non-fatal error to Firebase if available
    try {
      await FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        fatal: false,
        information: ['Service initialization failed'],
      );
    } catch (_) {
      // Firebase not available, continue with local logging
    }
    
    // Log error event to analytics if available
    try {
      await FirebaseAnalyticsService().logEvent(
        'app_initialization_error',
        {
          'error': e.toString(),
          'error_type': e.runtimeType.toString(),
          'stack_trace': stackTrace.toString().substring(0, 500), // Truncate for analytics
        },
      );
    } catch (_) {
      // Analytics not available, continue
    }
  }
}

/// Handle zone errors that escape Flutter's error handling
void _handleZoneError(Object error, StackTrace stackTrace) {
  logger.e('Zone Error: $error', error: error, stackTrace: stackTrace);
  
  // Report to Firebase Crashlytics
  try {
    FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      fatal: true,
      information: [
        'Uncaught zone error',
        'Firebase Project: cyclesync-2025-d2592',
        'App: LingoSphere',
        'Time: ${DateTime.now().toIso8601String()}',
      ],
    );
    logger.i('Zone error reported to Firebase Crashlytics');
  } catch (e) {
    logger.e('Failed to report zone error to Firebase: $e');
  }
}

/// Main LingoSphere application widget with advanced configuration
class LingoSphereApp extends ConsumerStatefulWidget {
  const LingoSphereApp({super.key});

  @override
  ConsumerState<LingoSphereApp> createState() => _LingoSphereAppState();
}

class _LingoSphereAppState extends ConsumerState<LingoSphereApp>
    with WidgetsBindingObserver {
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  late FirebaseAnalytics _analytics;
  late FirebaseAnalyticsObserver _observer;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Initialize app-specific configurations
  Future<void> _initializeApp() async {
    try {
      // Add lifecycle observer
      WidgetsBinding.instance.addObserver(this);

      // Initialize Firebase Analytics
      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics);
      
      // Set initial user properties
      await _analytics.setUserProperty(
        name: 'app_name',
        value: 'LingoSphere',
      );
      
      await _analytics.setUserProperty(
        name: 'app_version',
        value: AppConstants.appVersion,
      );
      
      await _analytics.setUserProperty(
        name: 'user_type',
        value: 'mobile_user',
      );
      
      // Log app open event
      await _analytics.logAppOpen();
      
      logger.i('✅ Firebase Analytics initialized and app open event logged');

      // Monitor connectivity changes with Firebase analytics
      Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
        setState(() {
          _connectivityResult = result;
        });
        
        // Log connectivity changes for analytics
        _analytics.logEvent(
          name: 'connectivity_changed',
          parameters: {
            'new_status': result.name,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          },
        );
        _handleConnectivityChange(result);
      });

      // Set system UI overlay style
      SystemChrome.setSystemUIOverlayStyle(
        AppTheme.getSystemUIOverlayStyle(
            false), // Will be updated based on theme
      );

      logger.i('LingoSphere app initialized successfully with Firebase Analytics');
    } catch (e, stackTrace) {
      logger.e('Failed to initialize app: $e',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        logger.d('App resumed');
        // TODO: _analytics.logEvent(name: 'app_resumed');
        break;
      case AppLifecycleState.paused:
        logger.d('App paused');
        // TODO: _analytics.logEvent(name: 'app_paused');
        break;
      case AppLifecycleState.detached:
        logger.d('App detached');
        break;
      case AppLifecycleState.inactive:
        logger.d('App inactive');
        break;
      case AppLifecycleState.hidden:
        logger.d('App hidden');
        break;
    }
  }

  /// Handle connectivity changes
  void _handleConnectivityChange(ConnectivityResult result) {
    logger.i('Connectivity changed: $result');

    // TODO: Re-enable after Firebase setup
    // _analytics.logEvent(
    //   name: 'connectivity_changed',
    //   parameters: {
    //     'connection_type': result.toString(),
    //     'has_internet': result != ConnectivityResult.none,
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    return ServiceStatusListener(
      child: MaterialApp(
        // App Configuration
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,

        // Theme Configuration
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Will be managed by state later

        // Localization (will be enhanced later)
        locale: const Locale('en', 'US'),
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('es', 'ES'),
          Locale('fr', 'FR'),
          Locale('de', 'DE'),
          Locale('it', 'IT'),
          Locale('pt', 'PT'),
          Locale('ru', 'RU'),
          Locale('ja', 'JP'),
          Locale('ko', 'KR'),
          Locale('zh', 'CN'),
        ],

        // Navigation Configuration
        home: const SplashScreen(),

        // Named routes
        onGenerateRoute: AppRouteGenerator.generateRoute,

        // Analytics Navigation Observer
        navigatorObservers: [
          _observer,
        ],

        // Error Handling
        builder: (context, widget) {
          // Handle errors in widget tree
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            return _buildErrorWidget(context, errorDetails);
          };

          // Return the normal widget tree
          return widget ?? const SizedBox.shrink();
        },
      ),
    );
  }

  /// Build custom error widget for better user experience
  Widget _buildErrorWidget(
      BuildContext context, FlutterErrorDetails errorDetails) {
    // Log the error
    logger.e('Widget Error: ${errorDetails.exceptionAsString()}');

    // Return user-friendly error widget
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        backgroundColor: AppTheme.gray50,
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.gray200,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.errorRed,
                ),
                const SizedBox(height: 16),
                Text(
                  'Oops! Something went wrong',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.gray900,
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'We\'re working to fix this issue. Please restart the app.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.gray600,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Restart the app
                    SystemNavigator.pop();
                  },
                  child: const Text('Restart App'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
