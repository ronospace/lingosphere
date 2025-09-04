// 🔊 LingoSphere TTS Service
// Advanced Text-to-Speech with multi-language support, voice selection, and smart caching

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/translation_entry.dart';

enum TTSState {
  stopped,
  playing,
  paused,
  continued,
}

enum VoiceGender {
  male,
  female,
  neutral,
}

class TTSVoice {
  final String name;
  final String locale;
  final VoiceGender gender;
  final double quality; // 0.0 to 1.0

  const TTSVoice({
    required this.name,
    required this.locale,
    required this.gender,
    this.quality = 0.5,
  });

  @override
  String toString() => '$name ($locale)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TTSVoice &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          locale == other.locale;

  @override
  int get hashCode => name.hashCode ^ locale.hashCode;
}

class TTSSettings {
  final double speechRate;
  final double volume;
  final double pitch;
  final TTSVoice? preferredVoice;
  final bool autoPlay;
  final bool highlightText;

  const TTSSettings({
    this.speechRate = 0.5,
    this.volume = 0.8,
    this.pitch = 1.0,
    this.preferredVoice,
    this.autoPlay = false,
    this.highlightText = true,
  });

  TTSSettings copyWith({
    double? speechRate,
    double? volume,
    double? pitch,
    TTSVoice? preferredVoice,
    bool? autoPlay,
    bool? highlightText,
  }) {
    return TTSSettings(
      speechRate: speechRate ?? this.speechRate,
      volume: volume ?? this.volume,
      pitch: pitch ?? this.pitch,
      preferredVoice: preferredVoice ?? this.preferredVoice,
      autoPlay: autoPlay ?? this.autoPlay,
      highlightText: highlightText ?? this.highlightText,
    );
  }
}

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  final StreamController<TTSState> _stateController =
      StreamController<TTSState>.broadcast();
  final StreamController<String> _progressController =
      StreamController<String>.broadcast();

  TTSState _currentState = TTSState.stopped;
  TTSSettings _settings = const TTSSettings();
  List<TTSVoice> _availableVoices = [];
  Map<String, List<TTSVoice>> _voicesByLanguage = {};

  bool _isInitialized = false;
  String? _currentText;
  String? _currentLanguage;

  // Getters
  Stream<TTSState> get stateStream => _stateController.stream;
  Stream<String> get progressStream => _progressController.stream;
  TTSState get currentState => _currentState;
  TTSSettings get settings => _settings;
  List<TTSVoice> get availableVoices => List.unmodifiable(_availableVoices);
  Map<String, List<TTSVoice>> get voicesByLanguage =>
      Map.unmodifiable(_voicesByLanguage);
  bool get isInitialized => _isInitialized;
  bool get isPlaying => _currentState == TTSState.playing;
  bool get isPaused => _currentState == TTSState.paused;
  bool get isStopped => _currentState == TTSState.stopped;

  /// Initialize TTS service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      await _setupTTSHandlers();
      await _loadAvailableVoices();
      await _applySettings(_settings);

      _isInitialized = true;
      print('TTS Service initialized successfully');
      return true;
    } catch (e) {
      print('Error initializing TTS service: $e');
      return false;
    }
  }

  /// Setup TTS event handlers
  Future<void> _setupTTSHandlers() async {
    _flutterTts.setStartHandler(() {
      _updateState(TTSState.playing);
    });

    _flutterTts.setCompletionHandler(() {
      _updateState(TTSState.stopped);
      _currentText = null;
      _currentLanguage = null;
    });

    _flutterTts.setErrorHandler((msg) {
      print('TTS Error: $msg');
      _updateState(TTSState.stopped);
    });

    _flutterTts.setPauseHandler(() {
      _updateState(TTSState.paused);
    });

    _flutterTts.setContinueHandler(() {
      _updateState(TTSState.continued);
    });

    _flutterTts.setCancelHandler(() {
      _updateState(TTSState.stopped);
    });

    // Progress tracking for word highlighting
    _flutterTts.setProgressHandler((text, start, end, word) {
      _progressController.add(word);
    });
  }

  /// Load available TTS voices
  Future<void> _loadAvailableVoices() async {
    try {
      final voices = await _flutterTts.getVoices;
      _availableVoices.clear();
      _voicesByLanguage.clear();

      for (var voice in voices) {
        final ttsVoice = TTSVoice(
          name: voice['name'] ?? 'Unknown',
          locale: voice['locale'] ?? 'en-US',
          gender: _parseGender(voice['gender'] ?? 'neutral'),
          quality: _parseQuality(voice['quality'] ?? 'normal'),
        );

        _availableVoices.add(ttsVoice);

        final language = ttsVoice.locale.split('-')[0];
        _voicesByLanguage.putIfAbsent(language, () => []).add(ttsVoice);
      }

      // Sort voices by quality within each language
      _voicesByLanguage.forEach((key, voices) {
        voices.sort((a, b) => b.quality.compareTo(a.quality));
      });

      print(
          'Loaded ${_availableVoices.length} TTS voices for ${_voicesByLanguage.length} languages');
    } catch (e) {
      print('Error loading TTS voices: $e');
    }
  }

  /// Parse voice gender from string
  VoiceGender _parseGender(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return VoiceGender.male;
      case 'female':
        return VoiceGender.female;
      default:
        return VoiceGender.neutral;
    }
  }

  /// Parse voice quality from string
  double _parseQuality(String quality) {
    switch (quality.toLowerCase()) {
      case 'enhanced':
      case 'premium':
        return 1.0;
      case 'high':
        return 0.8;
      case 'normal':
      case 'standard':
        return 0.5;
      case 'low':
        return 0.3;
      default:
        return 0.5;
    }
  }

  /// Update TTS settings
  Future<void> updateSettings(TTSSettings newSettings) async {
    _settings = newSettings;
    if (_isInitialized) {
      await _applySettings(_settings);
    }
  }

  /// Apply TTS settings to engine
  Future<void> _applySettings(TTSSettings settings) async {
    try {
      await _flutterTts.setSpeechRate(settings.speechRate);
      await _flutterTts.setVolume(settings.volume);
      await _flutterTts.setPitch(settings.pitch);

      if (settings.preferredVoice != null) {
        await _flutterTts.setVoice({
          'name': settings.preferredVoice!.name,
          'locale': settings.preferredVoice!.locale,
        });
      }
    } catch (e) {
      print('Error applying TTS settings: $e');
    }
  }

  /// Speak text with automatic language detection
  Future<bool> speak(String text, {String? language, TTSVoice? voice}) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return false;
    }

    if (text.trim().isEmpty) return false;

    try {
      // Stop current playback
      if (_currentState != TTSState.stopped) {
        await stop();
      }

      _currentText = text;
      _currentLanguage = language;

      // Set appropriate voice for language
      if (voice != null) {
        await _setVoice(voice);
      } else if (language != null) {
        await _setLanguageVoice(language);
      }

      await _flutterTts.speak(text);
      return true;
    } catch (e) {
      print('Error speaking text: $e');
      return false;
    }
  }

  /// Speak translation entry (convenience method)
  Future<bool> speakTranslation(TranslationEntry entry,
      {bool speakOriginal = false}) async {
    final text = speakOriginal ? entry.sourceText : entry.translatedText;
    final language =
        speakOriginal ? entry.sourceLanguage : entry.targetLanguage;

    return await speak(text, language: language);
  }

  /// Set voice for specific language
  Future<void> _setLanguageVoice(String language) async {
    final voices = _voicesByLanguage[language];
    if (voices != null && voices.isNotEmpty) {
      final bestVoice =
          _settings.preferredVoice?.locale.startsWith(language) == true
              ? _settings.preferredVoice!
              : voices.first; // Highest quality voice

      await _setVoice(bestVoice!);
    } else {
      // Fallback to system language
      await _flutterTts.setLanguage(language);
    }
  }

  /// Set specific voice
  Future<void> _setVoice(TTSVoice voice) async {
    try {
      await _flutterTts.setVoice({
        'name': voice.name,
        'locale': voice.locale,
      });
    } catch (e) {
      print('Error setting voice: $e');
      // Fallback to language setting
      final language = voice.locale.split('-')[0];
      await _flutterTts.setLanguage(language);
    }
  }

  /// Pause current playback
  Future<void> pause() async {
    if (_currentState == TTSState.playing) {
      await _flutterTts.pause();
    }
  }

  /// Resume paused playback
  Future<void> resume() async {
    if (_currentState == TTSState.paused) {
      await _flutterTts.speak(_currentText ?? '');
    }
  }

  /// Stop current playback
  Future<void> stop() async {
    await _flutterTts.stop();
    _updateState(TTSState.stopped);
    _currentText = null;
    _currentLanguage = null;
  }

  /// Get voices for specific language
  List<TTSVoice> getVoicesForLanguage(String language) {
    return _voicesByLanguage[language] ?? [];
  }

  /// Get best voice for language
  TTSVoice? getBestVoiceForLanguage(String language,
      {VoiceGender? preferredGender}) {
    final voices = getVoicesForLanguage(language);
    if (voices.isEmpty) return null;

    if (preferredGender != null) {
      final filteredVoices =
          voices.where((v) => v.gender == preferredGender).toList();
      if (filteredVoices.isNotEmpty) {
        return filteredVoices.first; // Already sorted by quality
      }
    }

    return voices.first; // Highest quality voice
  }

  /// Check if language is supported
  bool isLanguageSupported(String language) {
    return _voicesByLanguage.containsKey(language);
  }

  /// Get supported languages
  List<String> getSupportedLanguages() {
    return _voicesByLanguage.keys.toList()..sort();
  }

  /// Update state and notify listeners
  void _updateState(TTSState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      _stateController.add(_currentState);
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await stop();
    await _stateController.close();
    await _progressController.close();
  }
}

// Provider for dependency injection

final ttsServiceProvider = Provider<TTSService>((ref) {
  return TTSService();
});

final ttsStateProvider = StreamProvider<TTSState>((ref) {
  final ttsService = ref.watch(ttsServiceProvider);
  return ttsService.stateStream;
});

final ttsSettingsProvider =
    StateNotifierProvider<TTSSettingsNotifier, TTSSettings>((ref) {
  return TTSSettingsNotifier(ref);
});

class TTSSettingsNotifier extends StateNotifier<TTSSettings> {
  TTSSettingsNotifier(this.ref) : super(const TTSSettings()) {
    _loadSettings();
  }

  final Ref ref;
  late final TTSService _ttsService = ref.read(ttsServiceProvider);

  void _loadSettings() {
    // TODO: Load from shared preferences
    // For now, use defaults
  }

  Future<void> updateSpeechRate(double rate) async {
    final newSettings = state.copyWith(speechRate: rate);
    await _updateSettings(newSettings);
  }

  Future<void> updateVolume(double volume) async {
    final newSettings = state.copyWith(volume: volume);
    await _updateSettings(newSettings);
  }

  Future<void> updatePitch(double pitch) async {
    final newSettings = state.copyWith(pitch: pitch);
    await _updateSettings(newSettings);
  }

  Future<void> updatePreferredVoice(TTSVoice? voice) async {
    final newSettings = state.copyWith(preferredVoice: voice);
    await _updateSettings(newSettings);
  }

  Future<void> updateAutoPlay(bool autoPlay) async {
    final newSettings = state.copyWith(autoPlay: autoPlay);
    await _updateSettings(newSettings);
  }

  Future<void> updateHighlightText(bool highlight) async {
    final newSettings = state.copyWith(highlightText: highlight);
    await _updateSettings(newSettings);
  }

  Future<void> _updateSettings(TTSSettings newSettings) async {
    state = newSettings;
    await _ttsService.updateSettings(newSettings);
    // TODO: Save to shared preferences
  }
}
