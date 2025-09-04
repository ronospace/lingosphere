// 🌐 LingoSphere - WhatsApp Business API Integration
// Real-time WhatsApp message translation and webhook handling

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';
import '../exceptions/translation_exceptions.dart';
import 'translation_service.dart';

class WhatsAppService {
  static final WhatsAppService _instance = WhatsAppService._internal();
  factory WhatsAppService() => _instance;
  WhatsAppService._internal();

  final Dio _dio = Dio();
  final Logger _logger = Logger();
  final TranslationService _translationService = TranslationService();

  String? _accessToken;
  String? _phoneNumberId;
  String? _webhookToken;

  // Active chat sessions with translation preferences
  final Map<String, ChatSession> _activeSessions = {};

  /// Initialize WhatsApp Business API
  Future<void> initialize({
    required String accessToken,
    required String phoneNumberId,
    required String webhookToken,
  }) async {
    try {
      _accessToken = accessToken;
      _phoneNumberId = phoneNumberId;
      _webhookToken = webhookToken;

      // Configure Dio
      _dio.options = BaseOptions(
        baseUrl: AppConstants.whatsappBusinessApiUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      _logger.i('WhatsApp Business API initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize WhatsApp service: $e');
      throw MessagingPlatformException(
        'WhatsApp initialization failed',
        platform: 'WhatsApp',
      );
    }
  }

  /// Handle incoming webhook from WhatsApp
  Future<void> handleWebhook(Map<String, dynamic> webhookData) async {
    try {
      _logger.d('Received WhatsApp webhook: $webhookData');

      // Verify webhook
      if (!_verifyWebhook(webhookData)) {
        throw MessagingPlatformException(
          'Invalid webhook signature',
          platform: 'WhatsApp',
        );
      }

      // Process incoming messages
      final entry = webhookData['entry']?[0];
      if (entry == null) return;

      final changes = entry['changes'];
      if (changes == null) return;

      for (final change in changes) {
        if (change['field'] == 'messages') {
          await _processMessageChange(change['value']);
        }
      }
    } catch (e) {
      _logger.e('Failed to handle WhatsApp webhook: $e');
    }
  }

  /// Process message changes from webhook
  Future<void> _processMessageChange(Map<String, dynamic> value) async {
    try {
      final messages = value['messages'] as List?;
      if (messages == null) return;

      for (final message in messages) {
        await _processIncomingMessage(message);
      }
    } catch (e) {
      _logger.e('Failed to process message change: $e');
    }
  }

  /// Process individual incoming message
  Future<void> _processIncomingMessage(Map<String, dynamic> message) async {
    try {
      final from = message['from'] as String;
      final messageId = message['id'] as String;
      final timestamp = message['timestamp'] as String;

      // Check if user has translation enabled
      final session = _getOrCreateSession(from);
      if (!session.translationEnabled) return;

      // Extract message text
      String? messageText;
      MessageType messageType = MessageType.text;

      if (message['type'] == 'text') {
        messageText = message['text']['body'];
      } else if (message['type'] == 'audio') {
        messageType = MessageType.voice;
        // Handle voice message transcription
        messageText = await _transcribeVoiceMessage(message['audio']);
      } else {
        // Skip non-text messages for now
        return;
      }

      if (messageText == null || messageText.trim().isEmpty) return;

      _logger.i('Processing message from $from: $messageText');

      // Translate message
      final translationResult = await _translationService.translate(
        text: messageText,
        targetLanguage: session.targetLanguage,
        context: {
          'platform': 'whatsapp',
          'user_id': from,
          'message_id': messageId,
          'formality': session.formalityLevel,
        },
      );

      // Send translated message to user's private feed
      if (session.usePrivateFeed) {
        await _sendPrivateTranslation(from, translationResult, messageType);
      }

      // Send translation overlay if enabled
      if (session.useOverlay) {
        await _sendTranslationOverlay(from, translationResult, messageType);
      }

      // Store translation for analytics
      await _storeTranslationAnalytics(from, messageText, translationResult);
    } catch (e) {
      _logger.e('Failed to process incoming message: $e');
    }
  }

  /// Send translated message as private feed
  Future<void> _sendPrivateTranslation(
    String userId,
    dynamic translationResult,
    MessageType messageType,
  ) async {
    try {
      final confidenceEmoji = _getConfidenceEmoji(translationResult.confidence);
      final sentimentEmoji = translationResult.sentiment.sentimentEmoji;

      final privateMessage = '''
🌐 *LingoSphere Translation* $confidenceEmoji

📝 *Original* (${translationResult.sourceLanguage.toUpperCase()}):
${translationResult.originalText}

🔄 *Translation* (${translationResult.targetLanguage.toUpperCase()}):
${translationResult.translatedText}

${sentimentEmoji} *Sentiment*: ${translationResult.sentiment.sentimentString}
🎯 *Confidence*: ${translationResult.confidencePercentage.toStringAsFixed(0)}%
⚡ *Provider*: ${translationResult.provider.toUpperCase()}
⏱️ *Speed*: ${translationResult.metadata.processingTimeMs}ms

${messageType == MessageType.voice ? '🎙️ Voice message transcribed' : ''}
''';

      await _sendMessage(
        to: userId,
        message: privateMessage,
        messageType: 'text',
      );
    } catch (e) {
      _logger.e('Failed to send private translation: $e');
    }
  }

  /// Send translation as overlay response
  Future<void> _sendTranslationOverlay(
    String userId,
    dynamic translationResult,
    MessageType messageType,
  ) async {
    try {
      // Send a more subtle overlay translation
      final overlayMessage = '''
💬 ${translationResult.translatedText}

_${translationResult.sourceLanguage} → ${translationResult.targetLanguage} via LingoSphere_
''';

      await _sendMessage(
        to: userId,
        message: overlayMessage,
        messageType: 'text',
      );
    } catch (e) {
      _logger.e('Failed to send translation overlay: $e');
    }
  }

  /// Send message via WhatsApp Business API
  Future<void> _sendMessage({
    required String to,
    required String message,
    required String messageType,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final payload = {
        'messaging_product': 'whatsapp',
        'to': to,
        'type': messageType,
        messageType: messageType == 'text'
            ? {'body': message}
            : additionalData ?? {'body': message},
      };

      final response = await _dio.post(
        '/$_phoneNumberId/messages',
        data: payload,
      );

      if (response.statusCode == 200) {
        _logger.d('Message sent successfully to $to');
      } else {
        throw MessagingPlatformException(
          'Failed to send message: ${response.statusMessage}',
          platform: 'WhatsApp',
        );
      }
    } catch (e) {
      _logger.e('Failed to send WhatsApp message: $e');
      rethrow;
    }
  }

  /// Transcribe voice message (placeholder for actual implementation)
  Future<String?> _transcribeVoiceMessage(
      Map<String, dynamic> audioData) async {
    try {
      // This would integrate with speech-to-text service
      // For now, return a placeholder
      return '[Voice message - transcription not available]';
    } catch (e) {
      _logger.e('Failed to transcribe voice message: $e');
      return null;
    }
  }

  /// Get or create chat session
  ChatSession _getOrCreateSession(String userId) {
    if (!_activeSessions.containsKey(userId)) {
      _activeSessions[userId] = ChatSession(
        userId: userId,
        platform: MessagingPlatform.whatsapp,
        translationEnabled: true,
        targetLanguage: 'en',
        usePrivateFeed: true,
        useOverlay: false,
        formalityLevel: 'default',
      );
    }
    return _activeSessions[userId]!;
  }

  /// Verify webhook signature
  bool _verifyWebhook(Map<String, dynamic> webhookData) {
    // Implement webhook verification logic here
    // For development, return true
    return true;
  }

  /// Get confidence emoji based on translation confidence
  String _getConfidenceEmoji(dynamic confidence) {
    if (confidence == 'high') return '🎯';
    if (confidence == 'medium') return '✅';
    if (confidence == 'low') return '⚠️';
    return '❓';
  }

  /// Store translation analytics
  Future<void> _storeTranslationAnalytics(
    String userId,
    String originalText,
    dynamic translationResult,
  ) async {
    try {
      // Store analytics data for insights
      final analyticsData = {
        'user_id': userId,
        'platform': 'whatsapp',
        'original_text': originalText,
        'translated_text': translationResult.translatedText,
        'source_language': translationResult.sourceLanguage,
        'target_language': translationResult.targetLanguage,
        'confidence': translationResult.confidence.toString(),
        'provider': translationResult.provider,
        'processing_time_ms': translationResult.metadata.processingTimeMs,
        'sentiment': translationResult.sentiment.sentiment.toString(),
        'sentiment_score': translationResult.sentiment.score,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // This would be stored in Firebase or another analytics service
      _logger.d('Translation analytics: $analyticsData');
    } catch (e) {
      _logger.e('Failed to store translation analytics: $e');
    }
  }

  /// Enable translation for a user
  Future<void> enableTranslation(
    String userId, {
    String targetLanguage = 'en',
    bool usePrivateFeed = true,
    bool useOverlay = false,
    String formalityLevel = 'default',
  }) async {
    final session = _getOrCreateSession(userId);
    session.translationEnabled = true;
    session.targetLanguage = targetLanguage;
    session.usePrivateFeed = usePrivateFeed;
    session.useOverlay = useOverlay;
    session.formalityLevel = formalityLevel;

    _logger.i('Translation enabled for user $userId');

    // Send welcome message
    await _sendMessage(
      to: userId,
      message: '''
🌐 *LingoSphere Activated!*

Your messages will now be translated to ${AppConstants.supportedLanguages[targetLanguage] ?? targetLanguage}.

✨ *Features enabled*:
${usePrivateFeed ? '✅ Private translation feed' : '❌ Private feed disabled'}
${useOverlay ? '✅ Translation overlay' : '❌ Overlay disabled'}

Type */lingosphere help* for more options.
''',
      messageType: 'text',
    );
  }

  /// Disable translation for a user
  Future<void> disableTranslation(String userId) async {
    if (_activeSessions.containsKey(userId)) {
      _activeSessions[userId]!.translationEnabled = false;
    }

    await _sendMessage(
      to: userId,
      message:
          '🌐 LingoSphere translation disabled. Type */lingosphere start* to re-enable.',
      messageType: 'text',
    );
  }
}

/// Chat session configuration
class ChatSession {
  final String userId;
  final MessagingPlatform platform;
  bool translationEnabled;
  String targetLanguage;
  bool usePrivateFeed;
  bool useOverlay;
  String formalityLevel;
  DateTime createdAt;
  DateTime lastActivity;

  ChatSession({
    required this.userId,
    required this.platform,
    required this.translationEnabled,
    required this.targetLanguage,
    required this.usePrivateFeed,
    required this.useOverlay,
    required this.formalityLevel,
  })  : createdAt = DateTime.now(),
        lastActivity = DateTime.now();

  void updateActivity() {
    lastActivity = DateTime.now();
  }
}

/// Message types for processing
enum MessageType {
  text,
  voice,
  image,
  video,
  document,
  location,
  contact,
}
