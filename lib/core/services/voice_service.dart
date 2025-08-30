// 🌐 LingoSphere - Advanced Voice Translation Service
// Real-time speech recognition and voice translation with AI enhancement

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';
import '../exceptions/translation_exceptions.dart';
import '../models/translation_models.dart';
import 'translation_service.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final Logger _logger = Logger();
  final TranslationService _translationService = TranslationService();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  PlayerController? _playerController;
  RecorderController? _recorderController;
  
  // Voice recognition state
  bool _isListening = false;
  bool _speechEnabled = false;
  String _lastWords = '';
  double _confidence = 0.0;
  
  // TTS state
  bool _isSpeaking = false;
  
  // Voice translation settings
  VoiceSettings _settings = VoiceSettings();
  
  // Stream controllers for real-time updates
  final StreamController<VoiceRecognitionResult> _recognitionController = 
      StreamController<VoiceRecognitionResult>.broadcast();
  final StreamController<VoiceTranslationResult> _translationController = 
      StreamController<VoiceTranslationResult>.broadcast();
  final StreamController<double> _volumeController = 
      StreamController<double>.broadcast();
  
  // Getters for streams
  Stream<VoiceRecognitionResult> get recognitionStream => _recognitionController.stream;
  Stream<VoiceTranslationResult> get translationStream => _translationController.stream;
  Stream<double> get volumeStream => _volumeController.stream;
  
  /// Initialize voice services
  Future<void> initialize() async {
    try {
      // Request permissions
      await _requestPermissions();
      
      // Initialize speech recognition
      await _initializeSpeechRecognition();
      
      // Initialize text-to-speech
      await _initializeTTS();
      
      // Initialize audio controllers
      await _initializeAudioControllers();
      
      _logger.i('Voice service initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize voice service: $e');
      throw VoiceTranslationException(
        'Voice service initialization failed: ${e.toString()}',
      );
    }
  }
  
  /// Request necessary permissions
  Future<void> _requestPermissions() async {
    final permissions = [
      Permission.microphone,
      Permission.storage,
    ];
    
    for (final permission in permissions) {
      final status = await permission.request();
      if (status != PermissionStatus.granted) {
        throw MessagingPermissionException(
          'Permission denied: ${permission.toString()}',
          permission: permission.toString(),
          platform: 'Voice',
        );
      }
    }
  }
  
  /// Initialize speech recognition
  Future<void> _initializeSpeechRecognition() async {
    _speechEnabled = await _speech.initialize(
      onStatus: _onSpeechStatus,
      onError: _onSpeechError,
      debugLogging: kDebugMode,
    );
    
    if (!_speechEnabled) {
      throw SpeechRecognitionException(
        'Speech recognition not available on this device',
      );
    }
    
    _logger.i('Speech recognition initialized');
  }
  
  /// Initialize text-to-speech
  Future<void> _initializeTTS() async {
    await _flutterTts.setLanguage(_settings.outputLanguage);
    await _flutterTts.setSpeechRate(_settings.speechRate);
    await _flutterTts.setVolume(_settings.volume);
    await _flutterTts.setPitch(_settings.pitch);
    
    // Set up TTS callbacks
    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
      _logger.d('TTS started speaking');
    });
    
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      _logger.d('TTS finished speaking');
    });
    
    _flutterTts.setErrorHandler((message) {
      _isSpeaking = false;
      _logger.e('TTS error: $message');
    });
    
    _logger.i('Text-to-speech initialized');
  }
  
  /// Initialize audio controllers
  Future<void> _initializeAudioControllers() async {
    _recorderController = RecorderController();
    _playerController = PlayerController();
    
    // Initialize recorder
    await _recorderController?.initialize();
    await _playerController?.initialize();
    
    _logger.i('Audio controllers initialized');
  }
  
  /// Start listening for voice input
  Future<void> startListening({
    String? targetLanguage,
    bool enableRealTimeTranslation = true,
    VoiceRecognitionMode mode = VoiceRecognitionMode.continuous,
  }) async {
    try {
      if (!_speechEnabled) {
        throw SpeechRecognitionException('Speech recognition not initialized');
      }
      
      if (_isListening) {
        await stopListening();
      }
      
      _lastWords = '';
      _confidence = 0.0;
      
      final localeId = _getLocaleForLanguage(_settings.inputLanguage);
      
      await _speech.listen(
        onResult: (result) => _onSpeechResult(
          result, 
          targetLanguage, 
          enableRealTimeTranslation,
        ),
        listenFor: Duration(seconds: AppConstants.maxVoiceRecordingDuration),
        pauseFor: const Duration(seconds: 3),
        partialResults: mode == VoiceRecognitionMode.continuous,
        localeId: localeId,
        onSoundLevelChange: _onSoundLevelChange,
        cancelOnError: true,
        listenMode: mode == VoiceRecognitionMode.continuous 
          ? stt.ListenMode.confirmation 
          : stt.ListenMode.search,
      );
      
      _isListening = true;
      
      // Start recording for waveform visualization
      if (_recorderController != null) {
        await _recorderController!.record();
      }
      
      _logger.i('Started listening for voice input');
      
    } catch (e) {
      _logger.e('Failed to start listening: $e');
      throw VoiceTranslationException('Failed to start voice recognition: ${e.toString()}');
    }
  }
  
  /// Stop listening
  Future<void> stopListening() async {
    try {
      if (_isListening) {
        await _speech.stop();
        _isListening = false;
        
        // Stop recording
        if (_recorderController != null && _recorderController!.isRecording) {
          await _recorderController!.stop();
        }
        
        _logger.i('Stopped listening');
      }
    } catch (e) {
      _logger.e('Failed to stop listening: $e');
    }
  }
  
  /// Handle speech recognition results
  void _onSpeechResult(
    stt.SpeechRecognitionResult result, 
    String? targetLanguage,
    bool enableRealTimeTranslation,
  ) async {
    try {
      _lastWords = result.recognizedWords;
      _confidence = result.confidence;
      
      final recognitionResult = VoiceRecognitionResult(
        text: _lastWords,
        confidence: _confidence,
        isFinal: result.finalResult,
        language: _settings.inputLanguage,
        alternatives: result.alternates?.map((alt) => alt.recognizedWords).toList(),
      );
      
      // Emit recognition result
      _recognitionController.add(recognitionResult);
      
      // Perform real-time translation if enabled and result is confident enough
      if (enableRealTimeTranslation && 
          _confidence > _settings.minConfidenceThreshold &&
          _lastWords.trim().isNotEmpty) {
        
        await _performVoiceTranslation(_lastWords, targetLanguage ?? 'en');
      }
      
    } catch (e) {
      _logger.e('Error processing speech result: $e');
    }
  }
  
  /// Perform voice translation
  Future<void> _performVoiceTranslation(String text, String targetLanguage) async {
    try {
      final stopwatch = Stopwatch()..start();
      
      // Translate the text
      final translationResult = await _translationService.translate(
        text: text,
        targetLanguage: targetLanguage,
        sourceLanguage: _settings.inputLanguage,
        context: {
          'source': 'voice',
          'confidence': _confidence,
          'real_time': true,
        },
      );
      
      stopwatch.stop();
      
      // Create voice translation result
      final voiceTranslationResult = VoiceTranslationResult(
        originalText: text,
        translatedText: translationResult.translatedText,
        sourceLanguage: translationResult.sourceLanguage,
        targetLanguage: translationResult.targetLanguage,
        speechConfidence: _confidence,
        translationConfidence: translationResult.confidencePercentage / 100,
        totalProcessingTime: stopwatch.elapsed,
        provider: translationResult.provider,
        sentiment: translationResult.sentiment,
      );
      
      // Emit translation result
      _translationController.add(voiceTranslationResult);
      
      // Speak translation if TTS is enabled
      if (_settings.enableTTS && !_isSpeaking) {
        await _speakTranslation(translationResult.translatedText);
      }
      
    } catch (e) {
      _logger.e('Voice translation failed: $e');
      _translationController.addError(
        VoiceTranslationException('Translation failed: ${e.toString()}')
      );
    }
  }
  
  /// Speak translated text
  Future<void> _speakTranslation(String text) async {
    try {
      if (_isSpeaking) {
        await _flutterTts.stop();
      }
      
      await _flutterTts.setLanguage(_settings.outputLanguage);
      await _flutterTts.speak(text);
      
    } catch (e) {
      _logger.e('Failed to speak translation: $e');
    }
  }
  
  /// Handle speech recognition status changes
  void _onSpeechStatus(String status) {
    _logger.d('Speech status: $status');
    
    if (status == 'notListening') {
      _isListening = false;
    }
  }
  
  /// Handle speech recognition errors
  void _onSpeechError(stt.SpeechRecognitionError error) {
    _logger.e('Speech recognition error: ${error.errorMsg}');
    _isListening = false;
    
    _recognitionController.addError(
      SpeechRecognitionException(error.errorMsg),
    );
  }
  
  /// Handle sound level changes for volume visualization
  void _onSoundLevelChange(double level) {
    _volumeController.add(level);
  }
  
  /// Get locale string for language code
  String _getLocaleForLanguage(String languageCode) {
    final localeMap = {
      'en': 'en_US',
      'es': 'es_ES',
      'fr': 'fr_FR',
      'de': 'de_DE',
      'it': 'it_IT',
      'pt': 'pt_PT',
      'ru': 'ru_RU',
      'ja': 'ja_JP',
      'ko': 'ko_KR',
      'zh': 'zh_CN',
    };
    
    return localeMap[languageCode] ?? AppConstants.defaultVoiceLocale;
  }
  
  /// Update voice settings
  void updateSettings(VoiceSettings settings) {
    _settings = settings;
    
    // Apply TTS settings
    _flutterTts.setLanguage(settings.outputLanguage);
    _flutterTts.setSpeechRate(settings.speechRate);
    _flutterTts.setVolume(settings.volume);
    _flutterTts.setPitch(settings.pitch);
    
    _logger.i('Voice settings updated');
  }
  
  /// Get current voice settings
  VoiceSettings get settings => _settings;
  
  /// Check if currently listening
  bool get isListening => _isListening;
  
  /// Check if currently speaking
  bool get isSpeaking => _isSpeaking;
  
  /// Get last recognized words
  String get lastWords => _lastWords;
  
  /// Get recognition confidence
  double get confidence => _confidence;
  
  /// Stop TTS
  Future<void> stopSpeaking() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      _isSpeaking = false;
    }
  }
  
  /// Dispose resources
  void dispose() {
    _speech.cancel();
    _flutterTts.stop();
    _recorderController?.dispose();
    _playerController?.dispose();
    _recognitionController.close();
    _translationController.close();
    _volumeController.close();
    
    _logger.i('Voice service disposed');
  }
}

/// Voice recognition result
class VoiceRecognitionResult {
  final String text;
  final double confidence;
  final bool isFinal;
  final String language;
  final List<String>? alternatives;
  final DateTime timestamp;
  
  VoiceRecognitionResult({
    required this.text,
    required this.confidence,
    required this.isFinal,
    required this.language,
    this.alternatives,
  }) : timestamp = DateTime.now();
}

/// Voice translation result
class VoiceTranslationResult {
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final double speechConfidence;
  final double translationConfidence;
  final Duration totalProcessingTime;
  final String provider;
  final SentimentAnalysis sentiment;
  final DateTime timestamp;
  
  VoiceTranslationResult({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.speechConfidence,
    required this.translationConfidence,
    required this.totalProcessingTime,
    required this.provider,
    required this.sentiment,
  }) : timestamp = DateTime.now();
  
  double get overallConfidence => (speechConfidence + translationConfidence) / 2;
}

/// Voice service settings
class VoiceSettings {
  String inputLanguage;
  String outputLanguage;
  double speechRate;
  double volume;
  double pitch;
  bool enableTTS;
  double minConfidenceThreshold;
  VoiceRecognitionMode recognitionMode;
  bool enableNoiseReduction;
  bool enableEchoCancellation;
  
  VoiceSettings({
    this.inputLanguage = 'en',
    this.outputLanguage = 'en',
    this.speechRate = 0.5,
    this.volume = 1.0,
    this.pitch = 1.0,
    this.enableTTS = true,
    this.minConfidenceThreshold = 0.7,
    this.recognitionMode = VoiceRecognitionMode.continuous,
    this.enableNoiseReduction = true,
    this.enableEchoCancellation = true,
  });
}

/// Voice recognition modes
enum VoiceRecognitionMode {
  continuous,
  pushToTalk,
  singlePhrase,
}
