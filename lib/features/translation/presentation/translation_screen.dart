// 🌐 LingoSphere - Advanced Translation Screen
// Comprehensive translation interface with real-time processing and AI insights

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

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
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _targetController.dispose();
    _translationAnimationController.dispose();
    _swapAnimationController.dispose();
    _sourceFocusNode.dispose();
    _targetFocusNode.dispose();
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.vibrantGreen.withOpacity(0.1),
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
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: AnimatedBuilder(
                    animation: _swapAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _swapAnimation.value * 3.14159,
                        child: FloatingActionButton.small(
                          onPressed: _swapLanguages,
                          backgroundColor: AppTheme.accentTeal,
                          child: const Icon(
                            Icons.swap_horiz,
                            color: AppTheme.white,
                            size: 20,
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
            TextField(
              controller: _sourceController,
              focusNode: _sourceFocusNode,
              maxLines: 6,
              maxLength: AppConstants.maxTranslationLength,
              decoration: const InputDecoration(
                hintText: 'Type or paste text to translate...',
                border: InputBorder.none,
                counterText: '',
                hintStyle: TextStyle(color: AppTheme.gray400),
              ),
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
                color: AppTheme.gray900,
              ),
              onChanged: (_) => _debounceTranslation(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInputAction(
                  Icons.mic,
                  'Voice Input',
                  AppTheme.vibrantGreen,
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
            color: color.withOpacity(0.1),
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
              color: _isTranslating ? AppTheme.vibrantGreen : AppTheme.primaryBlue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_isTranslating ? AppTheme.vibrantGreen : AppTheme.primaryBlue)
                      .withOpacity(0.3),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getConfidenceColor(_currentTranslation!.confidence).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          size: 12,
                          color: _getConfidenceColor(_currentTranslation!.confidence),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(_currentTranslation!.confidence * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getConfidenceColor(_currentTranslation!.confidence),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    // Mock alternative translations for demonstration
    final alternatives = [
      'Hi, how are you doing?',
      'Hey, how are you?',
      'Hello, how do you do?',
    ];

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
            ...alternatives.asMap().entries.map((entry) {
              final index = entry.key;
              final alternative = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: InkWell(
                  onTap: () => _selectAlternative(alternative),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                            color: AppTheme.accentTeal.withOpacity(0.1),
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
            color: AppTheme.gray200.withOpacity(0.5),
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
    // Implement debounced translation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_sourceController.text.isNotEmpty && mounted) {
        _performTranslation();
      }
    });
  }

  void _performTranslation() {
    if (_sourceController.text.trim().isEmpty) return;

    setState(() => _isTranslating = true);
    _translationAnimationController.forward();

    // Simulate translation with delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTranslating = false;
          _hasTranslation = true;
          _targetController.text = _mockTranslate(_sourceController.text);
          _currentTranslation = TranslationResult(
            originalText: _sourceController.text,
            translatedText: _targetController.text,
            sourceLanguage: _selectedSourceLanguage,
            targetLanguage: _selectedTargetLanguage,
            confidence: 0.95,
            provider: 'google_api',
            sentiment: SentimentAnalysis(
              sentiment: SentimentType.neutral,
              score: 0.1,
              confidence: 85.0,
            ),
            context: ContextAnalysis(
              formality: FormalityLevel.neutral,
              domain: TextDomain.general,
              culturalMarkers: ['casual_greeting'],
              slangLevel: 0.2,
              additionalContext: {},
            ),
            metadata: TranslationMetadata(
              timestamp: DateTime.now(),
              processingTime: const Duration(milliseconds: 1500),
            ),
          );
        });
        _translationAnimationController.forward();
      }
    });
  }

  String _mockTranslate(String text) {
    // Mock translation logic
    final translations = {
      'hello': 'hola',
      'how are you': 'como estas',
      'good morning': 'buenos dias',
      'thank you': 'gracias',
      'goodbye': 'adios',
    };
    
    final lowerText = text.toLowerCase();
    for (final entry in translations.entries) {
      if (lowerText.contains(entry.key)) {
        return text.toLowerCase().replaceAll(entry.key, entry.value);
      }
    }
    
    return 'Mock translation of: $text';
  }

  void _startVoiceInput() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice input feature coming soon!'),
        backgroundColor: AppTheme.vibrantGreen,
      ),
    );
  }

  void _startCameraOCR() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Camera OCR feature coming soon!'),
        backgroundColor: AppTheme.accentTeal,
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

  void _playAudio() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Audio playback feature coming soon!'),
        duration: Duration(seconds: 1),
      ),
    );
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

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.9) return AppTheme.successGreen;
    if (confidence >= 0.7) return AppTheme.warningAmber;
    return AppTheme.errorRed;
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
}

// Import these from the existing models
class TranslationResult {
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final double confidence;
  final String provider;
  final SentimentAnalysis sentiment;
  final ContextAnalysis context;
  final TranslationMetadata metadata;

  TranslationResult({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.confidence,
    required this.provider,
    required this.sentiment,
    required this.context,
    required this.metadata,
  });
}

class SentimentAnalysis {
  final SentimentType sentiment;
  final double score;
  final double confidence;

  SentimentAnalysis({
    required this.sentiment,
    required this.score,
    required this.confidence,
  });
}

class ContextAnalysis {
  final FormalityLevel formality;
  final TextDomain domain;
  final List<String> culturalMarkers;
  final double slangLevel;
  final Map<String, dynamic> additionalContext;

  ContextAnalysis({
    required this.formality,
    required this.domain,
    required this.culturalMarkers,
    required this.slangLevel,
    required this.additionalContext,
  });
}

class TranslationMetadata {
  final DateTime timestamp;
  final Duration? processingTime;

  TranslationMetadata({
    required this.timestamp,
    this.processingTime,
  });
}

enum SentimentType { positive, negative, neutral }
enum FormalityLevel { formal, informal, neutral }
enum TextDomain { general, business, technical, casual }
