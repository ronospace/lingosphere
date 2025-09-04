// 🌐 LingoSphere - Camera OCR Service
// Advanced camera-based text recognition with real-time translation capabilities

import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart' as camera;
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/translation_models.dart';
import 'translation_service.dart';

/// Comprehensive camera OCR service for real-time text recognition and translation
class CameraOCRService {
  static final CameraOCRService _instance = CameraOCRService._internal();
  factory CameraOCRService() => _instance;
  CameraOCRService._internal();

  final Logger _logger = Logger();
  final TextRecognizer _textRecognizer = TextRecognizer();

  camera.CameraController? _cameraController;
  List<camera.CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isProcessing = false;
  StreamController<OCRResult>? _ocrResultController;
  Timer? _recognitionTimer;

  // Configuration
  static const Duration _recognitionInterval = Duration(milliseconds: 500);
  // TODO: Implement retry logic
  // static const int _maxRecognitionRetries = 3;

  /// Initialize camera OCR service
  Future<void> initialize() async {
    try {
      await _requestPermissions();
      await _initializeCameras();
      _ocrResultController = StreamController<OCRResult>.broadcast();
      _isInitialized = true;
      _logger.i('Camera OCR service initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize Camera OCR service: $e');
      throw CameraOCRException('Failed to initialize camera service: $e');
    }
  }

  /// Request camera permissions
  Future<void> _requestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    if (!cameraStatus.isGranted) {
      throw CameraOCRException('Camera permission denied');
    }
  }

  /// Initialize available cameras
  Future<void> _initializeCameras() async {
    try {
      _cameras = await camera.availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        throw CameraOCRException('No cameras available on device');
      }
      _logger.i('Found ${_cameras!.length} available cameras');
    } catch (e) {
      throw CameraOCRException('Failed to initialize cameras: $e');
    }
  }

  /// Start camera with specified configuration
  Future<camera.CameraController> startCamera({
    camera.CameraLensDirection direction = camera.CameraLensDirection.back,
    camera.ResolutionPreset resolution = camera.ResolutionPreset.high,
  }) async {
    if (!_isInitialized) {
      throw CameraOCRException(
          'Service not initialized. Call initialize() first.');
    }

    try {
      // Find camera with specified direction
      final selectedCamera = _cameras!.firstWhere(
        (cam) => cam.lensDirection == direction,
        orElse: () => _cameras!.first,
      );

      // Initialize camera controller
      _cameraController = camera.CameraController(
        selectedCamera,
        resolution,
        enableAudio: false,
        imageFormatGroup: camera.ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();

      _logger.i('Camera started with resolution: $resolution');
      return _cameraController!;
    } catch (e) {
      throw CameraOCRException('Failed to start camera: $e');
    }
  }

  /// Stop camera and cleanup resources
  Future<void> stopCamera() async {
    try {
      await _stopRecognition();
      await _cameraController?.dispose();
      _cameraController = null;
      _logger.i('Camera stopped successfully');
    } catch (e) {
      _logger.w('Error stopping camera: $e');
    }
  }

  /// Start real-time text recognition
  Future<void> startRecognition({
    String? targetLanguage,
    bool translateText = true,
  }) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      throw CameraOCRException('Camera not initialized');
    }

    if (_isProcessing) {
      _logger.w('Recognition already in progress');
      return;
    }

    _isProcessing = true;

    // Start periodic image capture and recognition
    _recognitionTimer = Timer.periodic(_recognitionInterval, (_) async {
      await _captureAndRecognize(
        targetLanguage: targetLanguage,
        translateText: translateText,
      );
    });

    _logger.i('Real-time recognition started');
  }

  /// Stop real-time text recognition
  Future<void> _stopRecognition() async {
    _recognitionTimer?.cancel();
    _recognitionTimer = null;
    _isProcessing = false;
    _logger.i('Real-time recognition stopped');
  }

  /// Capture image and perform OCR
  Future<void> _captureAndRecognize({
    String? targetLanguage,
    bool translateText = true,
  }) async {
    if (!_isProcessing || _cameraController == null) return;

    try {
      final camera.XFile imageFile = await _cameraController!.takePicture();
      final InputImage inputImage = InputImage.fromFilePath(imageFile.path);

      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      if (recognizedText.text.isNotEmpty) {
        final result = await _processRecognizedText(
          recognizedText,
          targetLanguage: targetLanguage,
          translateText: translateText,
          imagePath: imageFile.path,
        );

        _ocrResultController?.add(result);
      }

      // Cleanup temporary file
      await File(imageFile.path).delete();
    } catch (e) {
      _logger.w('Recognition error: $e');
      // Don't throw to avoid interrupting continuous recognition
    }
  }

  /// Process single image for OCR
  Future<OCRResult> processImage(
    String imagePath, {
    String? targetLanguage,
    bool translateText = true,
  }) async {
    if (!_isInitialized) {
      throw CameraOCRException('Service not initialized');
    }

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      return await _processRecognizedText(
        recognizedText,
        targetLanguage: targetLanguage,
        translateText: translateText,
        imagePath: imagePath,
      );
    } catch (e) {
      throw CameraOCRException('Failed to process image: $e');
    }
  }

  /// Process recognized text and optionally translate
  Future<OCRResult> _processRecognizedText(
    RecognizedText recognizedText, {
    String? targetLanguage,
    bool translateText = true,
    String? imagePath,
  }) async {
    final textBlocks = recognizedText.blocks.map((block) {
      return TextBlock(
        text: block.text,
        boundingBox: block.boundingBox,
        confidence: _calculateConfidence(block),
        lines: block.lines
            .map((line) => TextLine(
                  text: line.text,
                  boundingBox: line.boundingBox,
                  confidence: _calculateConfidence(line),
                ))
            .toList(),
      );
    }).toList();

    TranslationResult? translation;
    if (translateText &&
        targetLanguage != null &&
        recognizedText.text.isNotEmpty) {
      try {
        translation = await TranslationService().translate(
          text: recognizedText.text,
          targetLanguage: targetLanguage,
          sourceLanguage: 'auto',
        );
      } catch (e) {
        _logger.w('Translation failed: $e');
      }
    }

    return OCRResult(
      originalText: recognizedText.text,
      textBlocks: textBlocks,
      translation: translation,
      confidence: _calculateOverallConfidence(textBlocks),
      imagePath: imagePath,
      timestamp: DateTime.now(),
    );
  }

  /// Calculate confidence for a text element
  double _calculateConfidence(dynamic element) {
    // ML Kit doesn't provide confidence directly, so we estimate based on text characteristics
    final text = element.text as String;
    if (text.isEmpty) return 0.0;

    double confidence = 0.8; // Base confidence

    // Higher confidence for longer text
    if (text.length > 10) confidence += 0.1;
    if (text.length > 20) confidence += 0.1;

    // Lower confidence for very short text
    if (text.length < 3) confidence -= 0.2;

    // Higher confidence for text with proper word structure
    final words = text.split(' ');
    if (words.length > 1) confidence += 0.1;

    return confidence.clamp(0.0, 1.0);
  }

  /// Calculate overall confidence from text blocks
  double _calculateOverallConfidence(List<TextBlock> blocks) {
    if (blocks.isEmpty) return 0.0;

    final totalConfidence = blocks.fold<double>(
      0.0,
      (sum, block) => sum + block.confidence,
    );

    return totalConfidence / blocks.length;
  }

  /// Get OCR results stream
  Stream<OCRResult> get ocrResultStream {
    if (_ocrResultController == null) {
      throw CameraOCRException('Service not initialized');
    }
    return _ocrResultController!.stream;
  }

  /// Switch camera (front/back)
  Future<void> switchCamera() async {
    if (_cameraController == null || _cameras == null || _cameras!.length < 2) {
      return;
    }

    try {
      final currentDirection = _cameraController!.description.lensDirection;
      final newDirection = currentDirection == camera.CameraLensDirection.back
          ? camera.CameraLensDirection.front
          : camera.CameraLensDirection.back;

      await stopCamera();
      await startCamera(direction: newDirection);

      if (_isProcessing) {
        await startRecognition();
      }

      _logger.i('Camera switched to: $newDirection');
    } catch (e) {
      throw CameraOCRException('Failed to switch camera: $e');
    }
  }

  /// Toggle flash if available
  Future<void> toggleFlash() async {
    if (_cameraController == null) return;

    try {
      final currentFlashMode = _cameraController!.value.flashMode;
      final newFlashMode = currentFlashMode == camera.FlashMode.off
          ? camera.FlashMode.torch
          : camera.FlashMode.off;

      await _cameraController!.setFlashMode(newFlashMode);
      _logger.i('Flash toggled to: $newFlashMode');
    } catch (e) {
      _logger.w('Failed to toggle flash: $e');
    }
  }

  /// Get camera controller
  camera.CameraController? get cameraController => _cameraController;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Check if recognition is active
  bool get isProcessing => _isProcessing;

  /// Get available cameras
  List<camera.CameraDescription>? get availableCameras => _cameras;

  /// Dispose service and cleanup resources
  Future<void> dispose() async {
    try {
      await _stopRecognition();
      await stopCamera();
      await _textRecognizer.close();
      await _ocrResultController?.close();
      _ocrResultController = null;
      _isInitialized = false;
      _logger.i('Camera OCR service disposed');
    } catch (e) {
      _logger.w('Error disposing Camera OCR service: $e');
    }
  }
}

/// OCR result containing recognized text and translation
class OCRResult {
  final String originalText;
  final List<TextBlock> textBlocks;
  final TranslationResult? translation;
  final double confidence;
  final String? imagePath;
  final DateTime timestamp;

  const OCRResult({
    required this.originalText,
    required this.textBlocks,
    this.translation,
    required this.confidence,
    this.imagePath,
    required this.timestamp,
  });

  /// Get translated text if available
  String get translatedText => translation?.translatedText ?? originalText;

  /// Check if translation is available
  bool get hasTranslation => translation != null;

  /// Get confidence as percentage
  double get confidencePercentage => confidence * 100;
}

/// Text block with position and confidence
class TextBlock {
  final String text;
  final Rect boundingBox;
  final double confidence;
  final List<TextLine> lines;

  const TextBlock({
    required this.text,
    required this.boundingBox,
    required this.confidence,
    required this.lines,
  });
}

/// Text line within a block
class TextLine {
  final String text;
  final Rect boundingBox;
  final double confidence;

  const TextLine({
    required this.text,
    required this.boundingBox,
    required this.confidence,
  });
}

/// Camera OCR specific exception
class CameraOCRException implements Exception {
  final String message;
  final String? code;
  final Exception? originalException;

  const CameraOCRException(
    this.message, {
    this.code,
    this.originalException,
  });

  @override
  String toString() => 'CameraOCRException: $message';
}
