// 🔊 LingoSphere TTS Control Widget
// Advanced audio control with visual feedback and customization options

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../shared/theme/app_theme.dart';
import '../../core/services/tts_service.dart';
import '../../core/models/translation_entry.dart';

enum TTSControlSize {
  small,
  medium,
  large,
}

class TTSControlWidget extends ConsumerStatefulWidget {
  final String text;
  final String? language;
  final TTSVoice? voice;
  final TranslationEntry? translationEntry;
  final bool speakOriginal;
  final TTSControlSize size;
  final Color? primaryColor;
  final Color? backgroundColor;
  final bool showProgress;
  final bool showSettings;
  final VoidCallback? onPlayStart;
  final VoidCallback? onPlayComplete;
  final VoidCallback? onError;

  const TTSControlWidget({
    Key? key,
    required this.text,
    this.language,
    this.voice,
    this.translationEntry,
    this.speakOriginal = false,
    this.size = TTSControlSize.medium,
    this.primaryColor,
    this.backgroundColor,
    this.showProgress = true,
    this.showSettings = false,
    this.onPlayStart,
    this.onPlayComplete,
    this.onError,
  }) : super(key: key);

  @override
  ConsumerState<TTSControlWidget> createState() => _TTSControlWidgetState();
}

class _TTSControlWidgetState extends ConsumerState<TTSControlWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  bool _isCurrentlyPlaying = false;
  String _highlightedWord = '';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupTTSListeners();
  }

  void _setupAnimations() {
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupTTSListeners() {
    final ttsService = ref.read(ttsServiceProvider);

    // Listen to TTS state changes
    ttsService.stateStream.listen((state) {
      if (mounted) {
        setState(() {
          final wasPlaying = _isCurrentlyPlaying;
          _isCurrentlyPlaying = state == TTSState.playing;

          if (_isCurrentlyPlaying && !wasPlaying) {
            _startPlayingAnimation();
            widget.onPlayStart?.call();
          } else if (!_isCurrentlyPlaying && wasPlaying) {
            _stopPlayingAnimation();
            if (state == TTSState.stopped) {
              widget.onPlayComplete?.call();
            }
          }
        });
      }
    });

    // Listen to word progress for highlighting
    if (widget.showProgress) {
      ttsService.progressStream.listen((word) {
        if (mounted && _isCurrentlyPlaying) {
          setState(() {
            _highlightedWord = word;
          });
        }
      });
    }
  }

  void _startPlayingAnimation() {
    _pulseAnimationController.repeat(reverse: true);
    _progressAnimationController.forward();
  }

  void _stopPlayingAnimation() {
    _pulseAnimationController.stop();
    _progressAnimationController.reverse();
    setState(() {
      _highlightedWord = '';
    });
  }

  @override
  void dispose() {
    _pulseAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: SlideAnimation(
        duration: const Duration(milliseconds: 200),
        verticalOffset: 20.0,
        child: FadeInAnimation(
          child: _buildControlWidget(),
        ),
      ),
    );
  }

  Widget _buildControlWidget() {
    switch (widget.size) {
      case TTSControlSize.small:
        return _buildSmallControl();
      case TTSControlSize.medium:
        return _buildMediumControl();
      case TTSControlSize.large:
        return _buildLargeControl();
    }
  }

  Widget _buildSmallControl() {
    final ttsState = ref.watch(ttsStateProvider);

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppTheme.gray700.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isCurrentlyPlaying ? _pulseAnimation.value : 1.0,
            child: IconButton(
              icon: Icon(
                _getPlayIcon(ttsState.value ?? TTSState.stopped),
                color: widget.primaryColor ?? AppTheme.vibrantGreen,
                size: 16,
              ),
              onPressed: _handlePlayPause,
              padding: EdgeInsets.zero,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMediumControl() {
    final ttsState = ref.watch(ttsStateProvider);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppTheme.gray700.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isCurrentlyPlaying ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.primaryColor ?? AppTheme.vibrantGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: Icon(
                      _getPlayIcon(ttsState.value ?? TTSState.stopped),
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _handlePlayPause,
                    padding: EdgeInsets.zero,
                  ),
                ),
              );
            },
          ),
          if (widget.showProgress && _isCurrentlyPlaying) ...[
            const SizedBox(width: 8),
            _buildProgressIndicator(),
          ],
          if (widget.showSettings) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(
                Icons.settings,
                color: AppTheme.gray400,
                size: 18,
              ),
              onPressed: _showTTSSettings,
              padding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLargeControl() {
    final ttsState = ref.watch(ttsStateProvider);
    final ttsSettings = ref.watch(ttsSettingsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppTheme.gray800,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.gray600,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main control row
          Row(
            children: [
              // Play/Pause button
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isCurrentlyPlaying ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: widget.primaryColor ?? AppTheme.vibrantGreen,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (widget.primaryColor ?? AppTheme.vibrantGreen)
                                    .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          _getPlayIcon(ttsState.value ?? TTSState.stopped),
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: _handlePlayPause,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              // Text preview and info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.showProgress && _highlightedWord.isNotEmpty) ...[
                      Text(
                        'Playing: $_highlightedWord',
                        style: TextStyle(
                          color: widget.primaryColor ?? AppTheme.vibrantGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      widget.text.length > 60
                          ? '${widget.text.substring(0, 60)}...'
                          : widget.text,
                      style: const TextStyle(
                        color: AppTheme.white,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.language != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Language: ${widget.language}',
                        style: const TextStyle(
                          color: AppTheme.gray400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Settings button
              if (widget.showSettings)
                IconButton(
                  icon: const Icon(
                    Icons.tune,
                    color: AppTheme.gray400,
                    size: 20,
                  ),
                  onPressed: _showTTSSettings,
                ),
            ],
          ),
          // Progress indicator
          if (widget.showProgress && _isCurrentlyPlaying) ...[
            const SizedBox(height: 12),
            _buildProgressIndicator(),
          ],
          // Quick settings
          if (widget.showSettings) ...[
            const SizedBox(height: 12),
            _buildQuickSettings(ttsSettings),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1.5),
            color: AppTheme.gray600,
          ),
          child: FractionallySizedBox(
            widthFactor: _progressAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1.5),
                color: widget.primaryColor ?? AppTheme.vibrantGreen,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickSettings(TTSSettings settings) {
    return Row(
      children: [
        // Speed control
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Speed',
                style: TextStyle(
                  color: AppTheme.gray400,
                  fontSize: 12,
                ),
              ),
              Slider(
                value: settings.speechRate,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                activeColor: widget.primaryColor ?? AppTheme.vibrantGreen,
                inactiveColor: AppTheme.gray600,
                onChanged: (value) {
                  ref
                      .read(ttsSettingsProvider.notifier)
                      .updateSpeechRate(value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Volume control
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Volume',
                style: TextStyle(
                  color: AppTheme.gray400,
                  fontSize: 12,
                ),
              ),
              Slider(
                value: settings.volume,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                activeColor: widget.primaryColor ?? AppTheme.vibrantGreen,
                inactiveColor: AppTheme.gray600,
                onChanged: (value) {
                  ref.read(ttsSettingsProvider.notifier).updateVolume(value);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getPlayIcon(TTSState state) {
    switch (state) {
      case TTSState.playing:
        return Icons.pause;
      case TTSState.paused:
        return Icons.play_arrow;
      case TTSState.stopped:
      default:
        return Icons.play_arrow;
    }
  }

  Future<void> _handlePlayPause() async {
    final ttsService = ref.read(ttsServiceProvider);
    final currentState = ttsService.currentState;

    try {
      if (currentState == TTSState.playing) {
        await ttsService.pause();
      } else if (currentState == TTSState.paused) {
        await ttsService.resume();
      } else {
        // Start playing
        bool success;
        if (widget.translationEntry != null) {
          success = await ttsService.speakTranslation(
            widget.translationEntry!,
            speakOriginal: widget.speakOriginal,
          );
        } else {
          success = await ttsService.speak(
            widget.text,
            language: widget.language,
            voice: widget.voice,
          );
        }

        if (!success) {
          widget.onError?.call();
        }
      }
    } catch (e) {
      print('Error controlling TTS playback: $e');
      widget.onError?.call();
    }
  }

  void _showTTSSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.gray900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _TTSSettingsSheet(
        primaryColor: widget.primaryColor ?? AppTheme.vibrantGreen,
        language: widget.language,
      ),
    );
  }
}

class _TTSSettingsSheet extends ConsumerWidget {
  final Color primaryColor;
  final String? language;

  const _TTSSettingsSheet({
    required this.primaryColor,
    this.language,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ttsService = ref.watch(ttsServiceProvider);
    final settings = ref.watch(ttsSettingsProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'TTS Settings',
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: AppTheme.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Speech Rate
          _buildSettingSlider(
            'Speech Rate',
            settings.speechRate,
            0.1,
            1.0,
            9,
            (value) =>
                ref.read(ttsSettingsProvider.notifier).updateSpeechRate(value),
          ),

          // Volume
          _buildSettingSlider(
            'Volume',
            settings.volume,
            0.0,
            1.0,
            10,
            (value) =>
                ref.read(ttsSettingsProvider.notifier).updateVolume(value),
          ),

          // Pitch
          _buildSettingSlider(
            'Pitch',
            settings.pitch,
            0.5,
            2.0,
            15,
            (value) =>
                ref.read(ttsSettingsProvider.notifier).updatePitch(value),
          ),

          // Voice Selection
          if (language != null &&
              ttsService.isLanguageSupported(language!)) ...[
            const SizedBox(height: 16),
            _buildVoiceSelector(ref, ttsService, language!),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSettingSlider(
    String label,
    double value,
    double min,
    double max,
    int divisions,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                color: primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: primaryColor,
          inactiveColor: AppTheme.gray600,
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildVoiceSelector(
      WidgetRef ref, TTSService ttsService, String language) {
    final voices = ttsService.getVoicesForLanguage(language);
    final settings = ref.watch(ttsSettingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Voice',
          style: TextStyle(
            color: AppTheme.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.gray800,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.gray600),
          ),
          child: DropdownButton<TTSVoice>(
            value: settings.preferredVoice,
            hint: const Text(
              'Select Voice',
              style: TextStyle(color: AppTheme.gray400),
            ),
            isExpanded: true,
            underline: const SizedBox.shrink(),
            dropdownColor: AppTheme.gray800,
            style: const TextStyle(color: AppTheme.white),
            items: voices
                .map((voice) => DropdownMenuItem(
                      value: voice,
                      child: Row(
                        children: [
                          Icon(
                            voice.gender == VoiceGender.male
                                ? Icons.face
                                : voice.gender == VoiceGender.female
                                    ? Icons.face_3
                                    : Icons.person,
                            color: AppTheme.gray400,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(voice.name)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${(voice.quality * 100).toInt()}%',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: (voice) {
              ref
                  .read(ttsSettingsProvider.notifier)
                  .updatePreferredVoice(voice);
            },
          ),
        ),
      ],
    );
  }
}
