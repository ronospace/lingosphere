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

import 'core/constants/app_constants.dart';
import 'core/services/translation_service.dart';
import 'shared/theme/app_theme.dart';
import 'features/onboarding/presentation/splash_screen.dart';
import 'firebase_options.dart';

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
  try {
    // Initialize Firebase for crash reporting
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Enable Crashlytics collection
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
    
    logger.i('Error handling initialized successfully');
  } catch (e, stackTrace) {
    logger.e('Failed to initialize error handling: $e', error: e, stackTrace: stackTrace);
  }
}

/// Initialize all core services and dependencies
Future<void> _initializeCoreServices() async {
  try {
    // Initialize local storage (Hive)
    await Hive.initFlutter();
    
    // Initialize Firebase services
    await Firebase.initializeApp();
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    
    // Initialize translation service
    await TranslationService().initialize(
      // API keys should be loaded from secure storage or environment
      googleApiKey: const String.fromEnvironment('GOOGLE_API_KEY'),
      deepLApiKey: const String.fromEnvironment('DEEPL_API_KEY'),
      openAIApiKey: const String.fromEnvironment('OPENAI_API_KEY'),
    );
    
    // Check network connectivity
    final connectivity = await Connectivity().checkConnectivity();
    logger.i('Network connectivity: $connectivity');
    
    logger.i('All core services initialized successfully');
  } catch (e, stackTrace) {
    logger.e('Failed to initialize core services: $e', error: e, stackTrace: stackTrace);
    
    // Record non-fatal error for analytics
    FirebaseCrashlytics.instance.recordError(
      e,
      stackTrace,
      fatal: false,
      information: ['Service initialization failed'],
    );
  }
}

/// Handle zone errors that escape Flutter's error handling
void _handleZoneError(Object error, StackTrace stackTrace) {
  logger.e('Zone Error: $error', error: error, stackTrace: stackTrace);
  
  // Report to Crashlytics
  FirebaseCrashlytics.instance.recordError(
    error,
    stackTrace,
    fatal: true,
    information: ['Uncaught zone error'],
  );
}

/// Main LingoSphere application widget with advanced configuration
class LingoSphereApp extends ConsumerStatefulWidget {
  const LingoSphereApp({super.key});

  @override
  ConsumerState<LingoSphereApp> createState() => _LingoSphereAppState();
}

class _LingoSphereAppState extends ConsumerState<LingoSphereApp> with WidgetsBindingObserver {
  late FirebaseAnalytics _analytics;
  late ConnectivityResult _connectivityResult;
  
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
      
      // Set initial user properties
      await _analytics.setUserProperty(
        name: 'app_version',
        value: AppConstants.appVersion,
      );
      
      // Monitor connectivity changes
      Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
        setState(() {
          _connectivityResult = result;
        });
        _handleConnectivityChange(result);
      });
      
      // Set system UI overlay style
      SystemChrome.setSystemUIOverlayStyle(
        AppTheme.getSystemUIOverlayStyle(false), // Will be updated based on theme
      );
      
      logger.i('LingoSphere app initialized successfully');
    } catch (e, stackTrace) {
      logger.e('Failed to initialize app: $e', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        logger.d('App resumed');
        _analytics.logEvent(name: 'app_resumed');
        break;
      case AppLifecycleState.paused:
        logger.d('App paused');
        _analytics.logEvent(name: 'app_paused');
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
    
    _analytics.logEvent(
      name: 'connectivity_changed',
      parameters: {
        'connection_type': result.toString(),
        'has_internet': result != ConnectivityResult.none,
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      
      // Analytics Navigation Observer
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: _analytics),
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
    );
  }
  
  /// Build custom error widget for better user experience
  Widget _buildErrorWidget(BuildContext context, FlutterErrorDetails errorDetails) {
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
