// 🌐 LingoSphere - Camera Translation Screen
// Real-time OCR and translation with advanced overlay features

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart' as camera;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/camera_ocr_service.dart';
import '../../history/services/translation_history_integration_service.dart';
import '../../../core/services/offline_sync_service.dart';
import '../../../core/models/translation_entry.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/widgets/tts_control_widget.dart';

class CameraTranslationScreen extends ConsumerStatefulWidget {
  final String? targetLanguage;
  final String? sourceLanguage;
  final bool enableOverlay;

  const CameraTranslationScreen({
    super.key,
    this.targetLanguage,
    this.sourceLanguage,
    this.enableOverlay = true,
  });

  @override
  ConsumerState<CameraTranslationScreen> createState() =>
      _CameraTranslationScreenState();
}

class _CameraTranslationScreenState
    extends ConsumerState<CameraTranslationScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final CameraOCRService _ocrService = CameraOCRService();
  camera.CameraController? _cameraController;
  StreamSubscription<OCRResult>? _ocrSubscription;

  late TranslationHistoryIntegration _historyIntegration;
  late OfflineSyncService _offlineSyncService;

  late AnimationController _overlayAnimationController;
  late AnimationController _buttonsAnimationController;
  late AnimationController _scanAnimationController;

  late Animation<double> _overlayAnimation;
  late Animation<double> _buttonsAnimation;
  late Animation<double> _scanAnimation;

  String _selectedTargetLanguage = 'en';
  String _selectedSourceLanguage = 'auto';
  bool _isInitializing = true;
  bool _isScanning = false;
  bool _showOverlay = true;
  bool _flashEnabled = false;
  bool _isProcessing = false;

  OCRResult? _lastResult;
  List<OCRResult> _translationHistory = [];

  // UI State
  bool _showSettings = false;
  bool _showHistory = false;
  double _confidence = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _selectedTargetLanguage = widget.targetLanguage ?? 'en';
    _selectedSourceLanguage = widget.sourceLanguage ?? 'auto';
    _showOverlay = widget.enableOverlay;

    _initializeServices();
    _initializeAnimations();
    _initializeCamera();
  }

  void _initializeServices() {
    _historyIntegration = ref.read(translationHistoryIntegrationProvider);
    _offlineSyncService = ref.read(offlineSyncServiceProvider.notifier);
  }

  void _initializeAnimations() {
    _overlayAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _buttonsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scanAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _overlayAnimation = CurvedAnimation(
      parent: _overlayAnimationController,
      curve: Curves.easeInOut,
    );
    _buttonsAnimation = CurvedAnimation(
      parent: _buttonsAnimationController,
      curve: Curves.easeOutBack,
    );
    _scanAnimation = CurvedAnimation(
      parent: _scanAnimationController,
      curve: Curves.linear,
    );

    _buttonsAnimationController.forward();
  }

  Future<void> _initializeCamera() async {
    try {
      await _ocrService.initialize();
      _cameraController = await _ocrService.startCamera();

      if (mounted) {
        setState(() => _isInitializing = false);
        _overlayAnimationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isInitializing = false);
        _showError('Failed to initialize camera: ${e.toString()}');
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopScanning();
    } else if (state == AppLifecycleState.resumed) {
      if (_isScanning) {
        _startScanning();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ocrSubscription?.cancel();
    _overlayAnimationController.dispose();
    _buttonsAnimationController.dispose();
    _scanAnimationController.dispose();
    _ocrService.dispose();
    super.dispose();
  }

  void _startScanning() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      setState(() {
        _isScanning = true;
        _isProcessing = true;
      });

      // Start enhanced real-time OCR recognition with translation overlay
      await _ocrService.startRecognition(
        targetLanguage: _selectedTargetLanguage,
        translateText: true,
      );
      
      // Listen to OCR results with real-time processing
      _ocrSubscription = _ocrService.ocrResultStream.listen(
        (result) {
          if (mounted && result.confidence > 0.5) {
            setState(() {
              _lastResult = result;
              _confidence = result.confidence;
            });
            
            // Add to history only if confidence is high
            if (result.confidence > 0.7) {
              _translationHistory.add(result);
              _saveCameraTranslationToHistory(result);
            }
            
            // Trigger haptic feedback for successful recognition
            if (result.confidence > 0.8) {
              HapticFeedback.lightImpact();
            }
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() => _isProcessing = false);
            _showError('OCR recognition failed: ${error.toString()}');
          }
        },
      );
      
      setState(() => _isProcessing = false);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Real-time translation started! Point camera at text'),
          backgroundColor: AppTheme.vibrantGreen,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() {
        _isScanning = false;
        _isProcessing = false;
      });
      _showError('Failed to start scanning: ${e.toString()}');
    }
  }
  

  Future<void> _stopScanning() async {
    setState(() {
      _isScanning = false;
      _isProcessing = false;
    });

    await _ocrSubscription?.cancel();
    _ocrSubscription = null;
    // Stop recognition but keep camera running
    try {
      // The service will handle stopping recognition internally
      await _ocrService.stopCamera();
      // Restart camera for preview
      _cameraController = await _ocrService.startCamera();
    } catch (e) {
      _showError('Error stopping scanning: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          _buildCameraPreview(),

          // Translation Overlay
          if (_showOverlay && _lastResult != null) _buildTranslationOverlay(),

          // Scanning Animation
          if (_isScanning) _buildScanningAnimation(),

          // Top Controls
          _buildTopControls(),

          // Bottom Controls
          _buildBottomControls(),

          // Settings Panel
          if (_showSettings) _buildSettingsPanel(),

          // History Panel
          if (_showHistory) _buildHistoryPanel(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_isInitializing) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.vibrantGreen),
              SizedBox(height: 16),
              Text(
                'Initializing Camera...',
                style: TextStyle(color: AppTheme.white),
              ),
            ],
          ),
        ),
      );
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Text(
            'Camera not available',
            style: TextStyle(color: AppTheme.white),
          ),
        ),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _cameraController!.value.previewSize!.height,
          height: _cameraController!.value.previewSize!.width,
          child: camera.CameraPreview(_cameraController!),
        ),
      ),
    );
  }

  Widget _buildTranslationOverlay() {
    return AnimatedBuilder(
      animation: _overlayAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _overlayAnimation.value,
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.vibrantGreen.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
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
                              color: AppTheme.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getConfidenceColor().withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_confidence.toInt()}%',
                              style: TextStyle(
                                color: _getConfidenceColor(),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_lastResult!.originalText.isNotEmpty) ...[
                        Text(
                          'Original:',
                          style: TextStyle(
                            color: AppTheme.gray400,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _lastResult!.originalText,
                          style: const TextStyle(
                            color: AppTheme.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (_lastResult!.hasTranslation) ...[
                        Text(
                          'Translation:',
                          style: TextStyle(
                            color: AppTheme.gray400,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _lastResult!.translatedText,
                          style: const TextStyle(
                            color: AppTheme.vibrantGreen,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Advanced TTS Control
                          TTSControlWidget(
                            text: _lastResult!.translatedText,
                            language: _selectedTargetLanguage,
                            size: TTSControlSize.small,
                            primaryColor: AppTheme.vibrantGreen,
                            backgroundColor: AppTheme.gray700.withValues(alpha: 0.3),
                          ),
                          const SizedBox(width: 8),
                          _buildOverlayAction(
                            Icons.copy,
                            'Copy',
                            _copyTranslation,
                          ),
                          const SizedBox(width: 8),
                          _buildOverlayAction(
                            Icons.share,
                            'Share',
                            _shareTranslation,
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close,
                                color: AppTheme.gray400),
                            onPressed: () {
                              setState(() => _lastResult = null);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 120), // Space for bottom controls
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverlayAction(
      IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.gray700.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.white, size: 18),
        ),
      ),
    );
  }

  Widget _buildScanningAnimation() {
    return AnimatedBuilder(
      animation: _scanAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ScanningOverlayPainter(
            progress: _scanAnimation.value,
            isProcessing: _isProcessing,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildTopControls() {
    return SafeArea(
      child: AnimatedBuilder(
        animation: _buttonsAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -50 * (1 - _buttonsAnimation.value)),
            child: Opacity(
              opacity: _buttonsAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildTopButton(
                      Icons.arrow_back,
                      () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    _buildTopButton(
                      _flashEnabled ? Icons.flash_on : Icons.flash_off,
                      _toggleFlash,
                    ),
                    const SizedBox(width: 12),
                    _buildTopButton(
                      Icons.flip_camera_ios,
                      _switchCamera,
                    ),
                    const SizedBox(width: 12),
                    _buildTopButton(
                      Icons.settings,
                      _toggleSettings,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppTheme.white, size: 20),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _buttonsAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - _buttonsAnimation.value)),
              child: Opacity(
                opacity: _buttonsAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Language Selection
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppTheme.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppConstants.supportedLanguages[
                                      _selectedSourceLanguage] ??
                                  'Auto',
                              style: const TextStyle(
                                color: AppTheme.white,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward,
                              color: AppTheme.vibrantGreen,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppConstants.supportedLanguages[
                                      _selectedTargetLanguage] ??
                                  'English',
                              style: const TextStyle(
                                color: AppTheme.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Main Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildBottomButton(
                            Icons.history,
                            'History',
                            _toggleHistory,
                            isSecondary: true,
                          ),
                          _buildMainScanButton(),
                          _buildBottomButton(
                            _showOverlay
                                ? Icons.visibility
                                : Icons.visibility_off,
                            'Overlay',
                            _toggleOverlay,
                            isSecondary: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainScanButton() {
    return GestureDetector(
      onTap: _isScanning ? _stopScanning : _startScanning,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: _isScanning
              ? const LinearGradient(
                  colors: [AppTheme.errorRed, AppTheme.warningAmber],
                )
              : const LinearGradient(
                  colors: [AppTheme.vibrantGreen, AppTheme.accentTeal],
                ),
          boxShadow: [
            BoxShadow(
              color: (_isScanning ? AppTheme.errorRed : AppTheme.vibrantGreen)
                  .withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          _isScanning ? Icons.stop : Icons.camera_alt,
          color: AppTheme.white,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildBottomButton(
    IconData icon,
    String label,
    VoidCallback onPressed, {
    bool isSecondary = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSecondary
                  ? AppTheme.black.withValues(alpha: 0.6)
                  : AppTheme.vibrantGreen.withValues(alpha: 0.8),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: AppTheme.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPanel() {
    return _buildSlidePanel(
      title: 'Camera Settings',
      onClose: _toggleSettings,
      child: Column(
        children: [
          _buildLanguageSelector(),
          const SizedBox(height: 20),
          _buildSettingsOption(
            'Translation Overlay',
            'Show translations over camera feed',
            _showOverlay,
            (value) => setState(() => _showOverlay = value),
          ),
          _buildSettingsOption(
            'Auto Translate',
            'Automatically translate detected text',
            true,
            (value) {},
          ),
          _buildSettingsOption(
            'Save to History',
            'Keep translation history',
            true,
            (value) {},
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryPanel() {
    return _buildSlidePanel(
      title: 'Translation History',
      onClose: _toggleHistory,
      child: _translationHistory.isEmpty
          ? const Center(
              child: Text(
                'No translations yet.\nStart scanning to build your history.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.gray400,
                  fontSize: 14,
                ),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              itemCount: _translationHistory.length,
              itemBuilder: (context, index) {
                final result =
                    _translationHistory[_translationHistory.length - 1 - index];
                return _buildHistoryItem(result);
              },
            ),
    );
  }

  Widget _buildSlidePanel({
    required String title,
    required VoidCallback onClose,
    required Widget child,
  }) {
    return AnimationLimiter(
      child: SlideAnimation(
        duration: const Duration(milliseconds: 300),
        verticalOffset: 100.0,
        child: FadeInAnimation(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppTheme.gray900,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.gray700,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppTheme.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppTheme.white),
                        onPressed: onClose,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Translation Language',
          style: TextStyle(
            color: AppTheme.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.gray800,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.gray700),
          ),
          child: DropdownButton<String>(
            value: _selectedTargetLanguage,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            dropdownColor: AppTheme.gray800,
            style: const TextStyle(color: AppTheme.white),
            items: AppConstants.supportedLanguages.entries
                .where((entry) => entry.key != 'auto')
                .map((entry) => DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ))
                .toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                setState(() => _selectedTargetLanguage = newValue);
                if (_isScanning) {
                  _stopScanning();
                  _startScanning();
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsOption(
    String title,
    String description,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppTheme.gray400,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppTheme.vibrantGreen,
            activeThumbColor: AppTheme.white,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(OCRResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.gray800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.translate,
                color: AppTheme.vibrantGreen,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Translation',
                style: const TextStyle(
                  color: AppTheme.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${result.confidencePercentage.toInt()}%',
                style: TextStyle(
                  color: _getConfidenceColor(result.confidence),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            result.originalText,
            style: const TextStyle(
              color: AppTheme.gray300,
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (result.hasTranslation) ...[
            const SizedBox(height: 4),
            Text(
              result.translatedText,
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Color _getConfidenceColor([double? confidence]) {
    final conf = confidence ?? _confidence;
    if (conf >= 0.8) return AppTheme.successGreen;
    if (conf >= 0.6) return AppTheme.warningAmber;
    return AppTheme.errorRed;
  }

  /// Saves camera OCR translation to history with smart duplicate detection
  Future<void> _saveCameraTranslationToHistory(OCRResult result) async {
    try {
      // Create translation entry from OCR result
      final entry = TranslationEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sourceText: result.originalText,
        translatedText: result.translatedText,
        sourceLanguage: _selectedSourceLanguage,
        targetLanguage: _selectedTargetLanguage,
        timestamp: DateTime.now(),
        type: TranslationMethod.camera,
        confidence: result.confidence,
        metadata: {
          'confidence': result.confidence,
          'ocrConfidence': result.confidence,
          'detectedLanguage':
              result.translation?.sourceLanguage ?? _selectedSourceLanguage,
          'processingTime': DateTime.now().millisecondsSinceEpoch,
          'cameraSettings': {
            'flashEnabled': _flashEnabled,
            'targetLanguage': _selectedTargetLanguage,
            'sourceLanguage': _selectedSourceLanguage,
          },
        },
      );

      // Save to history using the history integration service with smart detection
      await _historyIntegration.saveTranslationWithDuplicateCheck(entry);

      // Try to sync if online
      try {
        await _offlineSyncService.syncPendingChanges();
      } catch (syncError) {
        // Sync error is not critical, translation is saved locally
        debugPrint('Sync warning: ${syncError.toString()}');
      }

      debugPrint('Camera translation saved to history: ${result.originalText}');
    } catch (e) {
      debugPrint('Error saving camera translation to history: ${e.toString()}');
      // Don't show error to user as this is a background operation
    }
  }

  // Action methods
  void _toggleFlash() async {
    try {
      await _ocrService.toggleFlash();
      setState(() => _flashEnabled = !_flashEnabled);
    } catch (e) {
      _showError('Failed to toggle flash');
    }
  }

  void _switchCamera() async {
    try {
      final wasScanning = _isScanning;
      if (wasScanning) {
        await _stopScanning();
      }

      await _ocrService.switchCamera();

      if (wasScanning) {
        _startScanning();
      }
    } catch (e) {
      _showError('Failed to switch camera');
    }
  }

  void _toggleSettings() {
    setState(() => _showSettings = !_showSettings);
  }

  void _toggleHistory() {
    setState(() => _showHistory = !_showHistory);
  }

  void _toggleOverlay() {
    setState(() => _showOverlay = !_showOverlay);
  }

  void _copyTranslation() {
    if (_lastResult?.hasTranslation == true) {
      Clipboard.setData(ClipboardData(text: _lastResult!.translatedText));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Translation copied to clipboard'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }

  void _shareTranslation() {
    // TODO: Implement sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing coming soon!'),
        backgroundColor: AppTheme.vibrantGreen,
      ),
    );
  }
}

/// Custom painter for scanning overlay animation
class ScanningOverlayPainter extends CustomPainter {
  final double progress;
  final bool isProcessing;

  ScanningOverlayPainter({
    required this.progress,
    required this.isProcessing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isProcessing) return;

    final paint = Paint()
      ..color = AppTheme.vibrantGreen.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw scanning line
    final lineY = size.height * progress;
    canvas.drawLine(
      Offset(0, lineY),
      Offset(size.width, lineY),
      paint..strokeWidth = 4,
    );

    // Draw corner brackets
    final cornerSize = 40.0;
    final margin = 60.0;

    paint
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(margin, margin + cornerSize)
        ..lineTo(margin, margin)
        ..lineTo(margin + cornerSize, margin),
      paint,
    );

    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(size.width - margin - cornerSize, margin)
        ..lineTo(size.width - margin, margin)
        ..lineTo(size.width - margin, margin + cornerSize),
      paint,
    );

    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(margin, size.height - margin - cornerSize)
        ..lineTo(margin, size.height - margin)
        ..lineTo(margin + cornerSize, size.height - margin),
      paint,
    );

    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(size.width - margin - cornerSize, size.height - margin)
        ..lineTo(size.width - margin, size.height - margin)
        ..lineTo(size.width - margin, size.height - margin - cornerSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant ScanningOverlayPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isProcessing != isProcessing;
  }
}
