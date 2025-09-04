// 🎤 LingoSphere - Voice Translation Screen
// Real-time voice translation with conversation mode

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/voice_service.dart';
import '../../../core/services/translation_service.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/services/history_service.dart';
import '../../history/services/translation_history_integration_service.dart';
import '../../../core/services/offline_sync_service.dart';
import '../../../core/models/translation_entry.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/widgets/tts_control_widget.dart';
import '../../../main.dart';

class VoiceTranslationScreen extends ConsumerStatefulWidget {
  final String? sourceLanguage;
  final String? targetLanguage;
  final bool conversationMode;

  const VoiceTranslationScreen({
    super.key,
    this.sourceLanguage,
    this.targetLanguage,
    this.conversationMode = false,
  });

  @override
  ConsumerState<VoiceTranslationScreen> createState() =>
      _VoiceTranslationScreenState();
}

class _VoiceTranslationScreenState extends ConsumerState<VoiceTranslationScreen>
    with TickerProviderStateMixin {
  final VoiceService _voiceService = VoiceService();
  final TranslationService _translationService = TranslationService();

  // History integration services - will be initialized in build method
  HistoryService? _historyService;
  TranslationHistoryIntegration? _historyIntegration;
  OfflineSyncService? _offlineSyncService;

  // Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  // State
  String _sourceLanguage = 'auto';
  String _targetLanguage = 'en';
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _conversationMode = false;
  String _currentInput = '';
  String _currentTranslation = '';
  double _confidence = 0.0;
  List<VoiceConversationItem> _conversationHistory = [];

  // Audio Controllers
  RecorderController? _recorderController;
  PlayerController? _playerController;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
    _initializeAnimations();
    _initializeVoiceService();
  }

  void _initializeServices() {
    // Services are now initialized in build method using ref.watch
    _historyService = ref.watch(historyServiceProvider);
    _historyIntegration = ref.watch(translationHistoryIntegrationProvider);
    _offlineSyncService = ref.watch(offlineSyncServiceProvider);
  }

  void _initializeScreen() {
    _sourceLanguage = widget.sourceLanguage ?? 'auto';
    _targetLanguage = widget.targetLanguage ?? 'en';
    _conversationMode = widget.conversationMode;
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.linear,
    ));
  }

  Future<void> _initializeVoiceService() async {
    try {
      await _voiceService.initialize();
      _recorderController = RecorderController();
      _playerController = PlayerController();

      // Listen to voice service streams
      _voiceService.recognitionStream.listen(_onRecognitionResult);
      _voiceService.translationStream.listen(_onTranslationResult);
      _voiceService.volumeStream.listen(_onVolumeChanged);
    } catch (e) {
      logger.e('Failed to initialize voice service: $e');
      _showErrorSnackBar('Failed to initialize voice service');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _recorderController?.dispose();
    _playerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize services using ref.watch in build method
    _initializeServices();

    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: AnimationLimiter(
          child: Column(
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                _buildLanguageSelector(),
                Expanded(child: _buildMainContent()),
                _buildVoiceControls(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        _conversationMode ? 'Voice Conversation' : 'Voice Translation',
        style: const TextStyle(
          fontFamily: AppTheme.headingFontFamily,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppTheme.white,
      elevation: 2,
      actions: [
        IconButton(
          icon: Icon(
              _conversationMode ? Icons.translate : Icons.record_voice_over),
          onPressed: () {
            setState(() {
              _conversationMode = !_conversationMode;
            });
          },
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, size: 20),
                  SizedBox(width: 8),
                  Text('Voice Settings'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.clear_all, size: 20),
                  SizedBox(width: 8),
                  Text('Clear History'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.download, size: 20),
                  SizedBox(width: 8),
                  Text('Export Conversation'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildLanguageDropdown(
                'From',
                _sourceLanguage,
                (value) => setState(() => _sourceLanguage = value!),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: FloatingActionButton.small(
                onPressed: _swapLanguages,
                backgroundColor: AppTheme.vibrantGreen,
                child: const Icon(Icons.swap_horiz, color: AppTheme.white),
              ),
            ),
            Expanded(
              child: _buildLanguageDropdown(
                'To',
                _targetLanguage,
                (value) => setState(() => _targetLanguage = value!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown(
    String label,
    String value,
    void Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.gray600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.gray300),
            ),
          ),
          items: AppConstants.supportedLanguages.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    if (_conversationMode) {
      return _buildConversationView();
    } else {
      return _buildTranslationView();
    }
  }

  Widget _buildTranslationView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Voice Visualization
          Expanded(
            flex: 2,
            child: _buildVoiceVisualization(),
          ),

          // Current Input/Translation
          Expanded(
            flex: 3,
            child: _buildTranslationCards(),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationView() {
    return Column(
      children: [
        // Conversation History
        Expanded(
          child: _conversationHistory.isEmpty
              ? _buildEmptyConversation()
              : _buildConversationList(),
        ),

        // Current Input Area
        if (_currentInput.isNotEmpty || _isListening) _buildCurrentInputCard(),
      ],
    );
  }

  Widget _buildVoiceVisualization() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isListening ? _pulseAnimation.value : 1.0,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _isListening
                      ? RadialGradient(
                          colors: [
                            AppTheme.vibrantGreen.withValues(alpha: 0.3),
                            AppTheme.vibrantGreen.withValues(alpha: 0.1),
                            Colors.transparent,
                          ],
                        )
                      : null,
                  border: Border.all(
                    color:
                        _isListening ? AppTheme.vibrantGreen : AppTheme.gray300,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    size: 80,
                    color:
                        _isListening ? AppTheme.vibrantGreen : AppTheme.gray400,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTranslationCards() {
    return Column(
      children: [
        // Input Card
        Expanded(
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.mic,
                        color: AppTheme.primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppConstants.supportedLanguages[_sourceLanguage] ??
                            'Auto-detect',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const Spacer(),
                      if (_confidence > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getConfidenceColor(_confidence)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(_confidence * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getConfidenceColor(_confidence),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _currentInput.isEmpty
                            ? (_isListening
                                ? 'Listening...'
                                : 'Tap microphone to start')
                            : _currentInput,
                        style: TextStyle(
                          fontSize: 16,
                          color: _currentInput.isEmpty
                              ? AppTheme.gray500
                              : AppTheme.gray900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Translation Card
        Expanded(
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.translate,
                        color: AppTheme.vibrantGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppConstants.supportedLanguages[_targetLanguage] ??
                            'English',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.vibrantGreen,
                        ),
                      ),
                      const Spacer(),
                      if (_currentTranslation.isNotEmpty)
                        TTSControlWidget(
                          text: _currentTranslation,
                          language: _targetLanguage,
                          size: TTSControlSize.small,
                          primaryColor: AppTheme.vibrantGreen,
                          backgroundColor: AppTheme.white,
                          showProgress: false,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _currentTranslation.isEmpty
                            ? 'Translation will appear here'
                            : _currentTranslation,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: _currentTranslation.isEmpty
                              ? FontWeight.normal
                              : FontWeight.w500,
                          color: _currentTranslation.isEmpty
                              ? AppTheme.gray500
                              : AppTheme.gray900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyConversation() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.record_voice_over,
            size: 64,
            color: AppTheme.gray400,
          ),
          SizedBox(height: 16),
          Text(
            'Start a conversation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the microphone to begin\nreal-time voice translation',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.gray500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _conversationHistory.length,
      itemBuilder: (context, index) {
        final item = _conversationHistory[index];
        return _buildConversationItem(item);
      },
    );
  }

  Widget _buildConversationItem(VoiceConversationItem item) {
    final isSource = item.isSourceLanguage;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isSource ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (!isSource) const Spacer(),
          Flexible(
            flex: 3,
            child: Card(
              elevation: 1,
              color: isSource
                  ? AppTheme.white
                  : AppTheme.primaryBlue.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isSource ? Icons.mic : Icons.translate,
                          size: 16,
                          color: isSource
                              ? AppTheme.primaryBlue
                              : AppTheme.vibrantGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isSource ? 'Original' : 'Translation',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSource
                                ? AppTheme.primaryBlue
                                : AppTheme.vibrantGreen,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatTimestamp(item.timestamp),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.gray500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.text,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.gray900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isSource) const Spacer(),
        ],
      ),
    );
  }

  Widget _buildCurrentInputCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    size: 16,
                    color:
                        _isListening ? AppTheme.vibrantGreen : AppTheme.gray500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isListening ? 'Listening...' : 'Processing...',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _isListening
                          ? AppTheme.vibrantGreen
                          : AppTheme.gray500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _currentInput,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.gray900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.gray200,
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Stop/Clear Button
          FloatingActionButton(
            onPressed: _clearInput,
            backgroundColor: AppTheme.gray200,
            foregroundColor: AppTheme.gray700,
            heroTag: 'clear',
            child: const Icon(Icons.clear),
          ),

          // Main Microphone Button
          GestureDetector(
            onTap: _toggleListening,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isListening ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _isListening
                          ? AppTheme.primaryGradient
                          : LinearGradient(
                              colors: [
                                AppTheme.vibrantGreen,
                                AppTheme.vibrantGreen.withValues(alpha: 0.8)
                              ],
                            ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening
                                  ? AppTheme.primaryBlue
                                  : AppTheme.vibrantGreen)
                              .withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.stop : Icons.mic,
                      size: 36,
                      color: AppTheme.white,
                    ),
                  ),
                );
              },
            ),
          ),

          // Play Translation Button
          FloatingActionButton(
            onPressed: _currentTranslation.isNotEmpty ? _toggleSpeech : null,
            backgroundColor: _currentTranslation.isNotEmpty
                ? AppTheme.accentTeal
                : AppTheme.gray200,
            foregroundColor: _currentTranslation.isNotEmpty
                ? AppTheme.white
                : AppTheme.gray500,
            heroTag: 'play',
            child: Icon(_isSpeaking ? Icons.stop : Icons.volume_up),
          ),
        ],
      ),
    );
  }

  // Event Handlers
  void _toggleListening() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    try {
      setState(() {
        _isListening = true;
        _currentInput = '';
        _currentTranslation = '';
      });

      _pulseController.repeat(reverse: true);

      await _voiceService.startListening(
        targetLanguage: _targetLanguage,
        enableRealTimeTranslation: true,
      );
    } catch (e) {
      logger.e('Failed to start listening: $e');
      _showErrorSnackBar('Failed to start voice recognition');
      setState(() {
        _isListening = false;
      });
      _pulseController.stop();
    }
  }

  Future<void> _stopListening() async {
    try {
      await _voiceService.stopListening();
      setState(() {
        _isListening = false;
      });
      _pulseController.stop();
    } catch (e) {
      logger.e('Failed to stop listening: $e');
    }
  }

  void _toggleSpeech() async {
    if (_isSpeaking) {
      await _voiceService.stopSpeaking();
    } else if (_currentTranslation.isNotEmpty) {
      await _voiceService.speak(_currentTranslation, language: _targetLanguage);
    }
  }

  void _clearInput() {
    setState(() {
      _currentInput = '';
      _currentTranslation = '';
      _confidence = 0.0;
    });
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'settings':
        _showVoiceSettings();
        break;
      case 'clear':
        _clearConversation();
        break;
      case 'export':
        _exportConversation();
        break;
    }
  }

  void _showVoiceSettings() {
    // Show voice settings dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Voice Settings'),
        content: const Text(
            'Voice settings configuration will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _clearConversation() {
    setState(() {
      _conversationHistory.clear();
    });
  }

  void _exportConversation() {
    // Export conversation functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export conversation feature coming soon!'),
        backgroundColor: AppTheme.accentTeal,
      ),
    );
  }

  // Voice Service Event Handlers
  void _onRecognitionResult(dynamic result) {
    setState(() {
      _currentInput = result.recognizedWords ?? '';
      _confidence = result.confidence ?? 0.0;
    });
  }

  void _onTranslationResult(dynamic result) {
    setState(() {
      _currentTranslation = result.translatedText ?? '';
    });

    // Save voice translation to history
    if (_currentInput.isNotEmpty && _currentTranslation.isNotEmpty) {
      _saveVoiceTranslationToHistory();
    }

    // Add to conversation history if in conversation mode
    if (_conversationMode &&
        _currentInput.isNotEmpty &&
        _currentTranslation.isNotEmpty) {
      _addToConversation();
    }
  }

  void _onVolumeChanged(double volume) {
    // Handle volume changes for visualization
  }

  void _addToConversation() {
    final now = DateTime.now();

    // Add original text
    _conversationHistory.add(
      VoiceConversationItem(
        text: _currentInput,
        isSourceLanguage: true,
        timestamp: now,
        language: _sourceLanguage,
      ),
    );

    // Add translation
    _conversationHistory.add(
      VoiceConversationItem(
        text: _currentTranslation,
        isSourceLanguage: false,
        timestamp: now.add(const Duration(milliseconds: 100)),
        language: _targetLanguage,
      ),
    );

    setState(() {});

    // Clear current input for next conversation
    Future.delayed(const Duration(milliseconds: 500), () {
      _clearInput();
    });
  }

  // Save translation to history
  void _saveVoiceTranslationToHistory() {
    try {
      // Ensure services are initialized
      if (_historyIntegration == null || _offlineSyncService == null) {
        logger.w('History services not initialized, skipping save');
        return;
      }

      // Create a new translation entry
      final entry = TranslationEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sourceText: _currentInput,
        translatedText: _currentTranslation,
        sourceLanguage: _sourceLanguage,
        targetLanguage: _targetLanguage,
        timestamp: DateTime.now(),
        type: TranslationMethod.voice, // Mark as voice translation
        isFavorite: false,
      );

      // Save to history using history integration service
      _historyIntegration!.saveTranslation(entry);

      // Trigger offline sync to ensure persistence
      _offlineSyncService!.scheduleSync();

      logger.d('Voice translation saved to history');
    } catch (e) {
      logger.e('Failed to save voice translation to history: $e');
    }
  }

  // Utility Methods
  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.9) return AppTheme.successGreen;
    if (confidence >= 0.7) return AppTheme.warningAmber;
    return AppTheme.errorRed;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
      ),
    );
  }
}

// Data Models
class VoiceConversationItem {
  final String text;
  final bool isSourceLanguage;
  final DateTime timestamp;
  final String language;

  VoiceConversationItem({
    required this.text,
    required this.isSourceLanguage,
    required this.timestamp,
    required this.language,
  });
}
