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
  Stream<VoiceRecognitionResult> get recognitionStream =>
      _recognitionController.stream;
  Stream<VoiceTranslationResult> get translationStream =>
      _translationController.stream;
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
    try {
      _recorderController = RecorderController();
      _playerController = PlayerController();

      // Note: RecorderController and PlayerController don't need explicit initialization
      // They are initialized automatically when first used

      _logger.i('Audio controllers initialized');
    } catch (e) {
      _logger.w('Audio controller initialization warning: $e');
      // Continue without audio controllers if they fail to initialize
    }
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
        localeId: localeId,
        onSoundLevelChange: _onSoundLevelChange,
        listenOptions: stt.SpeechListenOptions(
          partialResults: mode == VoiceRecognitionMode.continuous,
          cancelOnError: true,
          listenMode: mode == VoiceRecognitionMode.continuous
              ? stt.ListenMode.confirmation
              : stt.ListenMode.search,
        ),
      );

      _isListening = true;

      // Start recording for waveform visualization
      if (_recorderController != null) {
        await _recorderController!.record();
      }

      _logger.i('Started listening for voice input');
    } catch (e) {
      _logger.e('Failed to start listening: $e');
      throw VoiceTranslationException(
          'Failed to start voice recognition: ${e.toString()}');
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

  /// Handle speech recognition result
  void _onSpeechResult(
    dynamic result,
    String? targetLanguage,
    bool enableRealTimeTranslation,
  ) async {
    try {
      _lastWords = result.recognizedWords ?? '';
      _confidence = result.confidence ?? 0.0;

      final recognitionResult = VoiceRecognitionResult(
        text: _lastWords,
        confidence: _confidence,
        isFinal: result.finalResult ?? false,
        language: _settings.inputLanguage,
        alternatives: result.alternates
            ?.map<String>((alt) => alt.recognizedWords ?? '')
            .toList(),
        timestamp: DateTime.now(),
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
  Future<void> _performVoiceTranslation(
      String text, String targetLanguage) async {
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
        timestamp: DateTime.now(),
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
          VoiceTranslationException('Translation failed: ${e.toString()}'));
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

  /// Enhanced speak method with language detection and voice selection
  Future<void> speak(
    String text, {
    String? language,
    double? rate,
    double? pitch,
    double? volume,
    bool interrupt = true,
  }) async {
    try {
      if (interrupt && _isSpeaking) {
        await _flutterTts.stop();
      }

      // Apply temporary settings if provided
      if (language != null) {
        await _flutterTts.setLanguage(language);
      }
      if (rate != null) {
        await _flutterTts.setSpeechRate(rate);
      }
      if (pitch != null) {
        await _flutterTts.setPitch(pitch);
      }
      if (volume != null) {
        await _flutterTts.setVolume(volume);
      }

      await _flutterTts.speak(text);
      
      _logger.d('Speaking text: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
    } catch (e) {
      _logger.e('Failed to speak text: $e');
      throw VoiceTranslationException('Text-to-speech failed: ${e.toString()}');
    }
  }

  /// Get available TTS voices for a language
  Future<List<Map<String, String>>> getAvailableVoices(String? language) async {
    try {
      final voices = await _flutterTts.getVoices;
      if (language != null) {
        return voices
            .where((voice) => voice['locale']?.startsWith(language) == true)
            .toList();
      }
      return voices;
    } catch (e) {
      _logger.e('Failed to get available voices: $e');
      return [];
    }
  }

  /// Set specific voice by name
  Future<void> setVoice(String voiceName) async {
    try {
      await _flutterTts.setVoice({'name': voiceName});
      _logger.i('Voice set to: $voiceName');
    } catch (e) {
      _logger.e('Failed to set voice: $e');
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
  void _onSpeechError(dynamic error) {
    _logger.e('Speech recognition error: ${error.errorMsg}');
    _isListening = false;

    _recognitionController.addError(
      SpeechRecognitionException(error.errorMsg ?? 'Speech recognition error'),
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

  /// Get TTS locale for language code
  String _getLocaleForTts(String languageCode) {
    final localeMap = {
      'en': 'en-US',
      'es': 'es-ES',
      'fr': 'fr-FR',
      'de': 'de-DE',
      'it': 'it-IT',
      'pt': 'pt-PT',
      'ru': 'ru-RU',
      'ja': 'ja-JP',
      'ko': 'ko-KR',
      'zh': 'zh-CN',
    };

    return localeMap[languageCode] ?? 'en-US';
  }

  /// Dispose resources
  Future<void> dispose() async {
    try {
      await stopListening();
      await stopSpeaking();
      
      await _recognitionController.close();
      await _translationController.close();
      await _volumeController.close();
      
      _recorderController?.dispose();
      _playerController?.dispose();
      
      _logger.i('Voice service disposed');
    } catch (e) {
      _logger.e('Error disposing voice service: $e');
    }
  }
}
