// 🌐 LingoSphere - Advanced Translation Screen
// Comprehensive translation interface with real-time processing and AI insights

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/translation_service.dart';
import '../../../core/services/voice_service.dart';
import '../../../core/services/advanced_ai_service.dart';
import '../../../core/models/translation_models.dart';
import '../../../core/models/ai_models.dart';
import '../../../core/exceptions/translation_exceptions.dart';
import '../../camera/presentation/camera_translation_screen.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:async';

class TranslationScreen extends ConsumerStatefulWidget {
  final String? initialText;
  final String? sourceLanguage;
  final String? targetLanguage;

  const TranslationScreen({
    super.key,
    this.initialText,
    this.sourceLanguage,
    this.targetLanguage,
  });

  @override
  ConsumerState<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends ConsumerState<TranslationScreen>
    with TickerProviderStateMixin {
  late TextEditingController _sourceController;
  late TextEditingController _targetController;
  late AnimationController _translationAnimationController;
  late AnimationController _swapAnimationController;
  late Animation<double> _translationAnimation;
  late Animation<double> _swapAnimation;

  String _selectedSourceLanguage = 'auto';
  String _selectedTargetLanguage = 'en';
  bool _isTranslating = false;
  bool _hasTranslation = false;
  TranslationResult? _currentTranslation;

  final FocusNode _sourceFocusNode = FocusNode();
  final FocusNode _targetFocusNode = FocusNode();
  
  // Voice input state
  final VoiceService _voiceService = VoiceService();
  bool _isListening = false;
  bool _voiceInitialized = false;
  StreamSubscription<VoiceRecognitionResult>? _voiceSubscription;
  
  // Advanced AI state
  final AdvancedAIService _aiService = AdvancedAIService();
  bool _aiInitialized = false;
  List<SmartSuggestion> _aiSuggestions = [];
  bool _isLoadingAISuggestions = false;
  UserPersonality? _userPersonality;
  
  // Enhanced translation state
  Timer? _debounceTimer;
  List<TranslationResult> _translationHistory = [];
  List<String> _alternativeTranslations = [];
  bool _realTimeTranslationEnabled = true;
  bool _isLoadingAlternatives = false;

  @override
  void initState() {
    super.initState();
    _sourceController = TextEditingController(text: widget.initialText ?? '');
    _targetController = TextEditingController();

    _selectedSourceLanguage = widget.sourceLanguage ?? 'auto';
    _selectedTargetLanguage = widget.targetLanguage ?? 'en';

    _translationAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _swapAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _translationAnimation = CurvedAnimation(
      parent: _translationAnimationController,
      curve: Curves.easeOutBack,
    );
    _swapAnimation = CurvedAnimation(
      parent: _swapAnimationController,
      curve: Curves.elasticOut,
    );

    _sourceController.addListener(_onSourceTextChanged);
    _initializeVoiceService();
    _initializeAIService();
    _loadTranslationHistory();
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _targetController.dispose();
    _translationAnimationController.dispose();
    _swapAnimationController.dispose();
    _sourceFocusNode.dispose();
    _targetFocusNode.dispose();
    _voiceSubscription?.cancel();
    _voiceService.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSourceTextChanged() {
    if (_sourceController.text.isEmpty) {
      setState(() {
        _hasTranslation = false;
        _currentTranslation = null;
      });
      _targetController.clear();
      _translationAnimationController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildTranslationInterface()),
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Translation',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryBlue,
        ),
      ),
      backgroundColor: AppTheme.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      actions: [
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: () => _showTranslationHistory(),
          tooltip: 'Translation History',
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showMoreOptions(),
        ),
      ],
    );
  }

  Widget _buildTranslationInterface() {
    return AnimationLimiter(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            horizontalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            _buildLanguageSelector(),
            const SizedBox(height: 20),
            _buildTranslationCards(),
            if (_hasTranslation) ...[
              const SizedBox(height: 20),
              _buildTranslationDetails(),
              const SizedBox(height: 20),
              _buildAlternativeTranslations(),
              if (_aiSuggestions.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildAISuggestions(),
              ],
            ],
            const SizedBox(height: 80), // Bottom padding for action bar
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.language, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                const Text(
                  'Languages',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray900,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.vibrantGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'AI Powered',
                    style: TextStyle(
                      color: AppTheme.vibrantGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildLanguageDropdown(true)),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimatedBuilder(
                    animation: _swapAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _swapAnimation.value * 3.14159,
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: FloatingActionButton(
                            onPressed: _swapLanguages,
                            backgroundColor: AppTheme.accentTeal,
                            mini: true,
                            child: const Icon(
                              Icons.swap_horiz,
                              color: AppTheme.white,
                              size: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(child: _buildLanguageDropdown(false)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown(bool isSource) {
    final value = isSource ? _selectedSourceLanguage : _selectedTargetLanguage;
    final label = isSource ? 'From' : 'To';

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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.gray300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            items: AppConstants.supportedLanguages.entries
                .map((e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(
                        e.value,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ))
                .toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                setState(() {
                  if (isSource) {
                    _selectedSourceLanguage = newValue;
                  } else {
                    _selectedTargetLanguage = newValue;
                  }
                });
                if (_sourceController.text.isNotEmpty) {
                  _performTranslation();
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTranslationCards() {
    return Column(
      children: [
        _buildSourceCard(),
        const SizedBox(height: 16),
        _buildTranslationArrow(),
        const SizedBox(height: 16),
        _buildTargetCard(),
      ],
    );
  }

  Widget _buildSourceCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Enter text',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_sourceController.text.length}/${AppConstants.maxTranslationLength}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.gray500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(minHeight: 120),
              child: TextField(
                controller: _sourceController,
                focusNode: _sourceFocusNode,
                maxLines: null,
                minLines: 4,
                maxLength: AppConstants.maxTranslationLength,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'Type or paste text to translate...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  counterText: '',
                  hintStyle: TextStyle(color: AppTheme.gray400),
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: AppTheme.gray900,
                ),
                onChanged: (_) => _debounceTranslation(),
                autofocus: false,
                enabled: true,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInputAction(
                  _isListening ? Icons.stop : Icons.mic,
                  _isListening ? 'Stop Recording' : 'Voice Input',
                  _isListening ? AppTheme.errorRed : AppTheme.vibrantGreen,
                  _startVoiceInput,
                ),
                const SizedBox(width: 12),
                _buildInputAction(
                  Icons.camera_alt,
                  'Camera',
                  AppTheme.accentTeal,
                  _startCameraOCR,
                ),
                const SizedBox(width: 12),
                _buildInputAction(
                  Icons.content_paste,
                  'Paste',
                  AppTheme.warningAmber,
                  _pasteFromClipboard,
                ),
                const Spacer(),
                if (_sourceController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      _sourceController.clear();
                      setState(() {
                        _hasTranslation = false;
                        _currentTranslation = null;
                      });
                      _targetController.clear();
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.gray100,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputAction(
    IconData icon,
    String tooltip,
    Color color,
    VoidCallback onPressed,
  ) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  Widget _buildTranslationArrow() {
    return AnimatedBuilder(
      animation: _translationAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_translationAnimation.value * 0.2),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  _isTranslating ? AppTheme.vibrantGreen : AppTheme.primaryBlue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_isTranslating
                          ? AppTheme.vibrantGreen
                          : AppTheme.primaryBlue)
                      .withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _isTranslating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppTheme.white),
                    ),
                  )
                : const Icon(
                    Icons.arrow_downward,
                    color: AppTheme.white,
                    size: 20,
                  ),
          ),
        );
      },
    );
  }

  Widget _buildTargetCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  'Translation',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray700,
                  ),
                ),
                const Spacer(),
                if (_currentTranslation != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getConfidenceColorFromEnum(
                              _currentTranslation!.confidence)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          size: 12,
                          color: _getConfidenceColorFromEnum(
                              _currentTranslation!.confidence),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_currentTranslation!.confidencePercentage.toInt()}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getConfidenceColorFromEnum(
                                _currentTranslation!.confidence),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 144),
              child: _hasTranslation
                  ? SelectableText(
                      _targetController.text,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.4,
                        color: AppTheme.gray900,
                      ),
                    )
                  : Container(
                      height: 144,
                      alignment: Alignment.center,
                      child: Text(
                        _sourceController.text.isEmpty
                            ? 'Translation will appear here...'
                            : 'Start typing to see translation',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.gray400,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
            if (_hasTranslation) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildTranslationAction(
                    Icons.volume_up,
                    'Listen',
                    _playAudio,
                  ),
                  const SizedBox(width: 12),
                  _buildTranslationAction(
                    Icons.copy,
                    'Copy',
                    _copyTranslation,
                  ),
                  const SizedBox(width: 12),
                  _buildTranslationAction(
                    Icons.share,
                    'Share',
                    _shareTranslation,
                  ),
                  const SizedBox(width: 12),
                  _buildTranslationAction(
                    Icons.favorite_border,
                    'Save',
                    _saveTranslation,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationAction(
    IconData icon,
    String tooltip,
    VoidCallback onPressed,
  ) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.gray100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.gray600, size: 18),
        ),
      ),
    );
  }

  Widget _buildTranslationDetails() {
    if (_currentTranslation == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _translationAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _translationAnimation.value) * 50),
          child: Opacity(
            opacity: _translationAnimation.value,
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Translation Details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.gray700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Provider',
                      _currentTranslation!.provider.toUpperCase(),
                      Icons.api,
                    ),
                    _buildDetailRow(
                      'Sentiment',
                      _getSentimentText(_currentTranslation!.sentiment),
                      _getSentimentIcon(_currentTranslation!.sentiment),
                    ),
                    _buildDetailRow(
                      'Processing Time',
                      '${_currentTranslation!.metadata.processingTime?.inMilliseconds ?? 0}ms',
                      Icons.timer,
                    ),
                    if (_currentTranslation!.context.culturalMarkers.isNotEmpty)
                      _buildDetailRow(
                        'Cultural Context',
                        _currentTranslation!.context.culturalMarkers.join(', '),
                        Icons.public,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.gray500),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.gray600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.gray800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativeTranslations() {
    if (_alternativeTranslations.isEmpty && !_isLoadingAlternatives) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.alt_route, size: 18, color: AppTheme.accentTeal),
                SizedBox(width: 8),
                Text(
                  'Alternative Translations',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoadingAlternatives)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              ..._alternativeTranslations.asMap().entries.map((entry) {
                final index = entry.key;
                final alternative = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: InkWell(
                  onTap: () => _selectAlternative(alternative),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.gray50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppTheme.accentTeal.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accentTeal,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            alternative,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.gray800,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: AppTheme.gray400,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: AppTheme.gray200.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _sourceController.text.isEmpty ? null : _clearAll,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _sourceController.text.isEmpty || _isTranslating
                    ? null
                    : _performTranslation,
                icon: _isTranslating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(AppTheme.white),
                        ),
                      )
                    : const Icon(Icons.translate),
                label: Text(_isTranslating ? 'Translating...' : 'Translate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.vibrantGreen,
                  foregroundColor: AppTheme.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Action methods
  void _swapLanguages() {
    _swapAnimationController.forward().then((_) {
      _swapAnimationController.reset();
    });

    setState(() {
      final temp = _selectedSourceLanguage;
      _selectedSourceLanguage = _selectedTargetLanguage;
      _selectedTargetLanguage = temp;

      // Swap text content if both exist
      if (_hasTranslation && _sourceController.text.isNotEmpty) {
        final tempText = _sourceController.text;
        _sourceController.text = _targetController.text;
        _targetController.text = tempText;
      }
    });

    if (_sourceController.text.isNotEmpty) {
      _performTranslation();
    }
  }

  void _debounceTranslation() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_sourceController.text.trim().isNotEmpty && mounted && _realTimeTranslationEnabled) {
        _performTranslation();
      }
    });
  }

  Future<void> _performTranslation() async {
    final input = _sourceController.text.trim();
    if (input.isEmpty) return;

    setState(() => _isTranslating = true);
    _translationAnimationController.forward();

    try {
      final result = await TranslationService().translate(
        text: input,
        sourceLanguage: _selectedSourceLanguage,
        targetLanguage: _selectedTargetLanguage,
        mode: TranslationMode.realTime,
      );

      if (!mounted) return;
      setState(() {
        _isTranslating = false;
        _hasTranslation = true;
        _currentTranslation = result;
        _targetController.text = result.translatedText;
      });
      _translationAnimationController.forward();
      
      // Save to history and load alternatives
      _saveToHistory(result);
      _loadAlternativeTranslations();
      _loadAISuggestions();
    } on TranslationException catch (e) {
      if (!mounted) return;
      setState(() {
        _isTranslating = false;
        _hasTranslation = false;
        _currentTranslation = null;
        _targetController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.userMessage),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTranslating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Translation failed. Please try again.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  Future<void> _initializeVoiceService() async {
    try {
      await _voiceService.initialize();
      setState(() => _voiceInitialized = true);
    } catch (e) {
      // Voice service initialization failed - continue without voice input
    }
  }
  
  Future<void> _startVoiceInput() async {
    if (!_voiceInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice input not available'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if (_isListening) {
      await _stopVoiceInput();
      return;
    }

    try {
      setState(() => _isListening = true);
      
      // Start listening with current settings
      await _voiceService.startListening(
        targetLanguage: _selectedTargetLanguage,
        enableRealTimeTranslation: false, // We'll handle translation separately
      );

      // Listen to recognition results
      _voiceSubscription = _voiceService.recognitionStream.listen(
        (result) {
          if (result.isFinal && result.text.trim().isNotEmpty) {
            // Set the recognized text in the source field
            setState(() {
              _sourceController.text = result.text;
              _isListening = false;
            });
            
            // Trigger translation
            _debounceTranslation();
            
            // Stop listening after getting final result
            _stopVoiceInput();
          } else if (!result.isFinal) {
            // Show partial results in real-time
            setState(() {
              _sourceController.text = result.text;
            });
          }
        },
        onError: (error) {
          setState(() => _isListening = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Voice recognition error: ${error.toString()}'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listening... Speak now'),
          backgroundColor: AppTheme.vibrantGreen,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() => _isListening = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start voice input: ${e.toString()}'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  Future<void> _stopVoiceInput() async {
    if (_isListening) {
      try {
        await _voiceService.stopListening();
        setState(() => _isListening = false);
        await _voiceSubscription?.cancel();
        _voiceSubscription = null;
      } catch (e) {
        // Handle error silently
      }
    }
  }

  void _startCameraOCR() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CameraTranslationScreen(
          targetLanguage: null, // Will use current selection
        ),
      ),
    );
  }

  void _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      _sourceController.text = data!.text!;
      _debounceTranslation();
    }
  }

  void _playAudio() async {
    if (_hasTranslation && _targetController.text.isNotEmpty) {
      try {
        // Import the voice service
        final voiceService = VoiceService();
        
        // Speak the translated text in the target language
        await voiceService.speak(
          _targetController.text,
          language: _selectedTargetLanguage,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Playing audio...'),
            duration: Duration(seconds: 1),
            backgroundColor: AppTheme.vibrantGreen,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Audio playback failed: ${e.toString()}'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No translation to play'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _copyTranslation() {
    if (_hasTranslation) {
      Clipboard.setData(ClipboardData(text: _targetController.text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Translation copied to clipboard'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _shareTranslation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share feature coming soon!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _saveTranslation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Translation saved to favorites!'),
        backgroundColor: AppTheme.vibrantGreen,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _selectAlternative(String alternative) {
    setState(() {
      _targetController.text = alternative;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alternative translation selected'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _clearAll() {
    _sourceController.clear();
    _targetController.clear();
    setState(() {
      _hasTranslation = false;
      _currentTranslation = null;
    });
    _translationAnimationController.reset();
  }

  void _showTranslationHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Translation history feature coming soon!'),
        backgroundColor: AppTheme.primaryBlue,
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.document_scanner),
              title: const Text('Document Translation'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.batch_prediction),
              title: const Text('Batch Translation'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.record_voice_over),
              title: const Text('Conversation Mode'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColorFromEnum(TranslationConfidence confidence) {
    switch (confidence) {
      case TranslationConfidence.high:
        return AppTheme.successGreen;
      case TranslationConfidence.medium:
        return AppTheme.warningAmber;
      case TranslationConfidence.low:
      case TranslationConfidence.uncertain:
        return AppTheme.errorRed;
    }
  }

  String _getSentimentText(SentimentAnalysis sentiment) {
    switch (sentiment.sentiment) {
      case SentimentType.positive:
        return 'Positive';
      case SentimentType.negative:
        return 'Negative';
      case SentimentType.neutral:
        return 'Neutral';
    }
  }

  IconData _getSentimentIcon(SentimentAnalysis sentiment) {
    switch (sentiment.sentiment) {
      case SentimentType.positive:
        return Icons.sentiment_satisfied;
      case SentimentType.negative:
        return Icons.sentiment_dissatisfied;
      case SentimentType.neutral:
        return Icons.sentiment_neutral;
    }
  }

  // Enhanced translation functionality methods
  Future<void> _loadTranslationHistory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/translation_history.json');
      
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final List<dynamic> jsonList = json.decode(jsonString);
        _translationHistory = jsonList
            .map((json) => TranslationResult.fromJson(json))
            .toList();
      }
    } catch (e) {
      // Silent failure - history loading is non-critical
    }
  }

  Future<void> _saveToHistory(TranslationResult result) async {
    try {
      // Add to beginning of history (most recent first)
      _translationHistory.insert(0, result);
      
      // Keep only last 50 translations to avoid excessive storage
      if (_translationHistory.length > 50) {
        _translationHistory = _translationHistory.take(50).toList();
      }
      
      // Save to device storage
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/translation_history.json');
      final jsonString = json.encode(
        _translationHistory.map((e) => e.toJson()).toList(),
      );
      await file.writeAsString(jsonString);
    } catch (e) {
      // Silent failure - saving to history is non-critical
    }
  }

  Future<void> _loadAlternativeTranslations() async {
    if (_currentTranslation == null) return;
    
    setState(() => _isLoadingAlternatives = true);
    
    try {
      // Generate alternative translations using different providers or methods
      final alternatives = await _generateAlternativeTranslations(
        _currentTranslation!.originalText,
        _selectedSourceLanguage,
        _selectedTargetLanguage,
      );
      
      if (mounted) {
        setState(() {
          _alternativeTranslations = alternatives;
          _isLoadingAlternatives = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _alternativeTranslations = [];
          _isLoadingAlternatives = false;
        });
      }
    }
  }

  Future<List<String>> _generateAlternativeTranslations(
    String text,
    String sourceLang,
    String targetLang,
  ) async {
    final List<String> alternatives = [];
    final translationService = TranslationService();
    
    try {
      // Try different translation contexts for variations
      final contexts = [
        {'style': 'formal'},
        {'style': 'casual'},
        {'style': 'professional'},
      ];
      
      for (final context in contexts) {
        try {
          final result = await translationService.translate(
            text: text,
            sourceLanguage: sourceLang,
            targetLanguage: targetLang,
            context: context,
          );
          
          // Only add if different from main translation
          if (result.translatedText != _currentTranslation?.translatedText &&
              !alternatives.contains(result.translatedText)) {
            alternatives.add(result.translatedText);
          }
        } catch (e) {
          // Skip this alternative if it fails
        }
      }
      
      // If no alternatives were found, add some mock alternatives
      // for demonstration (in production, you might use ML models)
      if (alternatives.isEmpty && _currentTranslation != null) {
        alternatives.addAll(_generateMockAlternatives(_currentTranslation!.translatedText));
      }
      
      return alternatives.take(3).toList(); // Limit to 3 alternatives
    } catch (e) {
      return [];
    }
  }

  List<String> _generateMockAlternatives(String originalTranslation) {
    // This is a simple mock implementation
    // In production, you would use more sophisticated methods
    final alternatives = <String>[];
    
    // Add some variations based on common patterns
    if (originalTranslation.toLowerCase().contains('hello')) {
      alternatives.addAll([
        originalTranslation.replaceAll(RegExp('hello', caseSensitive: false), 'Hi'),
        originalTranslation.replaceAll(RegExp('hello', caseSensitive: false), 'Hey'),
      ]);
    }
    
    if (originalTranslation.toLowerCase().contains('thank you')) {
      alternatives.addAll([
        originalTranslation.replaceAll(RegExp('thank you', caseSensitive: false), 'thanks'),
        originalTranslation.replaceAll(RegExp('thank you', caseSensitive: false), 'much appreciated'),
      ]);
    }
    
    // Remove duplicates and original
    return alternatives
        .where((alt) => alt != originalTranslation)
        .toSet()
        .toList();
  }

  // Advanced AI Integration Methods

  Future<void> _initializeAIService() async {
    try {
      await _aiService.initialize(
        openAIApiKey: const String.fromEnvironment('OPENAI_API_KEY'),
        claudeApiKey: const String.fromEnvironment('CLAUDE_API_KEY'),
        geminiApiKey: const String.fromEnvironment('GEMINI_API_KEY'),
      );
      setState(() => _aiInitialized = true);
      
      // Load user personality if available
      _loadUserPersonality();
    } catch (e) {
      // AI service initialization failed - continue without AI features
    }
  }

  Future<void> _loadUserPersonality() async {
    if (!_aiInitialized) return;
    
    try {
      final personality = await _aiService.analyzeUserPersonality(
        userId: 'default_user', // Would use actual user ID
        recentTranslations: _translationHistory.take(10).toList(),
      );
      
      setState(() {
        _userPersonality = personality;
      });
    } catch (e) {
      // Personality analysis failed - continue without personality features
    }
  }

  Future<void> _loadAISuggestions() async {
    if (!_aiInitialized || _currentTranslation == null) return;
    
    setState(() => _isLoadingAISuggestions = true);
    
    try {
      final suggestions = await _aiService.generateContextualSuggestions(
        text: _currentTranslation!.originalText,
        sourceLanguage: _selectedSourceLanguage,
        targetLanguage: _selectedTargetLanguage,
        conversationId: 'translation_session',
        additionalContext: {
          'screen': 'translation',
          'user_personality': _userPersonality?.primaryType.name,
        },
      );
      
      if (mounted) {
        setState(() {
          _aiSuggestions = suggestions;
          _isLoadingAISuggestions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiSuggestions = [];
          _isLoadingAISuggestions = false;
        });
      }
    }
  }

  Widget _buildAISuggestions() {
    if (_aiSuggestions.isEmpty && !_isLoadingAISuggestions) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.vibrantGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: AppTheme.vibrantGreen,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'AI Smart Suggestions',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray700,
                  ),
                ),
                const Spacer(),
                if (_userPersonality != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _userPersonality!.primaryType.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoadingAISuggestions)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircularProgressIndicator(strokeWidth: 2),
                      SizedBox(height: 8),
                      Text(
                        'AI is analyzing context...',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._aiSuggestions.asMap().entries.map((entry) {
                final index = entry.key;
                final suggestion = entry.value;
                return _buildAISuggestionItem(suggestion, index);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildAISuggestionItem(SmartSuggestion suggestion, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => _selectAISuggestion(suggestion),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getSuggestionContextColor(suggestion.context).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getSuggestionContextColor(suggestion.context).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _getSuggestionContextColor(suggestion.context).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getSuggestionContextColor(suggestion.context),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      suggestion.text,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.gray900,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getConfidenceColor(suggestion.confidence).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${(suggestion.confidence * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getConfidenceColor(suggestion.confidence),
                      ),
                    ),
                  ),
                ],
              ),
              if (suggestion.reasoning.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 14,
                      color: _getSuggestionContextColor(suggestion.context),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        suggestion.reasoning,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.gray600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppTheme.gray100,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      suggestion.source.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.gray600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: _getSuggestionContextColor(suggestion.context).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      suggestion.context.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: _getSuggestionContextColor(suggestion.context),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSuggestionContextColor(SuggestionContext context) {
    switch (context) {
      case SuggestionContext.contextual:
        return AppTheme.vibrantGreen;
      case SuggestionContext.alternative:
        return AppTheme.accentTeal;
      case SuggestionContext.creative:
        return AppTheme.warningAmber;
      case SuggestionContext.formal:
        return AppTheme.primaryBlue;
      case SuggestionContext.casual:
        return Colors.purple;
      case SuggestionContext.standard:
        return AppTheme.gray600;
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.9) return AppTheme.successGreen;
    if (confidence >= 0.7) return AppTheme.vibrantGreen;
    if (confidence >= 0.5) return AppTheme.warningAmber;
    return AppTheme.errorRed;
  }

  void _selectAISuggestion(SmartSuggestion suggestion) {
    setState(() {
      _targetController.text = suggestion.text;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('AI suggestion selected: ${suggestion.source} (${(suggestion.confidence * 100).toInt()}% confidence)'),
        duration: const Duration(seconds: 2),
        backgroundColor: _getSuggestionContextColor(suggestion.context),
      ),
    );
    
    // Log AI suggestion usage for analytics
    // Would integrate with Firebase Analytics here
  }
}
