// 🌐 LingoSphere - Native Sharing Service
// Comprehensive cross-platform sharing with rich content support

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import '../models/translation_entry.dart';
import '../constants/app_constants.dart';
import '../../main.dart';

/// Sharing content types
enum ShareContentType {
  text,
  image,
  audio,
  file,
  translation,
  conversation,
  mixed,
}

/// Sharing platforms
enum SharingPlatform {
  generic,
  whatsapp,
  telegram,
  twitter,
  facebook,
  instagram,
  linkedin,
  email,
  sms,
  clipboard,
  airdrop,
}

/// Share content data model
class ShareContent {
  final ShareContentType type;
  final String? text;
  final String? subject;
  final List<String>? filePaths;
  final List<XFile>? files;
  final Map<String, dynamic>? metadata;
  final SharingPlatform? preferredPlatform;

  const ShareContent({
    required this.type,
    this.text,
    this.subject,
    this.filePaths,
    this.files,
    this.metadata,
    this.preferredPlatform,
  });

  ShareContent copyWith({
    ShareContentType? type,
    String? text,
    String? subject,
    List<String>? filePaths,
    List<XFile>? files,
    Map<String, dynamic>? metadata,
    SharingPlatform? preferredPlatform,
  }) {
    return ShareContent(
      type: type ?? this.type,
      text: text ?? this.text,
      subject: subject ?? this.subject,
      filePaths: filePaths ?? this.filePaths,
      files: files ?? this.files,
      metadata: metadata ?? this.metadata,
      preferredPlatform: preferredPlatform ?? this.preferredPlatform,
    );
  }
}

/// Share result information
class ShareResult {
  final bool success;
  final String? errorMessage;
  final SharingPlatform? platform;
  final DateTime sharedAt;
  final Map<String, dynamic>? analytics;

  const ShareResult({
    required this.success,
    this.errorMessage,
    this.platform,
    required this.sharedAt,
    this.analytics,
  });

  static ShareResult createSuccess({
    SharingPlatform? platform,
    Map<String, dynamic>? analytics,
  }) {
    return ShareResult(
      success: true,
      platform: platform,
      sharedAt: DateTime.now(),
      analytics: analytics,
    );
  }

  static ShareResult createError(String message) {
    return ShareResult(
      success: false,
      errorMessage: message,
      sharedAt: DateTime.now(),
    );
  }
}

/// Native sharing service for cross-platform content sharing
class NativeSharingService {
  static final NativeSharingService _instance =
      NativeSharingService._internal();
  factory NativeSharingService() => _instance;
  NativeSharingService._internal();

  /// Share content using the native sharing system
  Future<ShareResult> shareContent(ShareContent content) async {
    try {
      logger.d(
          'Sharing content: ${content.type} to ${content.preferredPlatform}');

      // Platform-specific sharing
      if (content.preferredPlatform != null &&
          content.preferredPlatform != SharingPlatform.generic) {
        return await _shareToPlatform(content);
      }

      // Generic sharing
      return await _shareGeneric(content);
    } catch (e) {
      logger.e('Failed to share content: $e');
      return ShareResult.createError('Failed to share content: $e');
    }
  }

  /// Share translation with rich formatting
  Future<ShareResult> shareTranslation({
    required TranslationEntry translation,
    bool includeMetadata = true,
    bool includeFormatting = true,
    SharingPlatform? preferredPlatform,
  }) async {
    try {
      final formattedText = _formatTranslationText(
        translation,
        includeMetadata: includeMetadata,
        includeFormatting: includeFormatting,
        platform: preferredPlatform,
      );

      final shareContent = ShareContent(
        type: ShareContentType.translation,
        text: formattedText,
        subject: 'Translation from LingoSphere',
        preferredPlatform: preferredPlatform,
        metadata: {
          'translation_id': translation.id,
          'source_language': translation.sourceLanguage,
          'target_language': translation.targetLanguage,
          'type': translation.type.name,
        },
      );

      return await this.shareContent(shareContent);
    } catch (e) {
      logger.e('Failed to share translation: $e');
      return ShareResult.createError('Failed to share translation: $e');
    }
  }

  /// Share conversation history
  Future<ShareResult> shareConversation({
    required List<TranslationEntry> conversation,
    String? title,
    bool includeTimestamps = true,
    SharingPlatform? preferredPlatform,
  }) async {
    try {
      final formattedText = _formatConversationText(
        conversation,
        title: title,
        includeTimestamps: includeTimestamps,
        platform: preferredPlatform,
      );

      final shareContent = ShareContent(
        type: ShareContentType.conversation,
        text: formattedText,
        subject: title ?? 'Conversation from LingoSphere',
        preferredPlatform: preferredPlatform,
        metadata: {
          'conversation_length': conversation.length,
          'languages': _getConversationLanguages(conversation),
        },
      );

      return await this.shareContent(shareContent);
    } catch (e) {
      logger.e('Failed to share conversation: $e');
      return ShareResult.createError('Failed to share conversation: $e');
    }
  }

  /// Share image with translation overlay
  Future<ShareResult> shareImageWithTranslation({
    required String imagePath,
    required TranslationEntry translation,
    SharingPlatform? preferredPlatform,
  }) async {
    try {
      final captionText = _formatTranslationText(
        translation,
        includeMetadata: false,
        includeFormatting: true,
        platform: preferredPlatform,
      );

      final shareContent = ShareContent(
        type: ShareContentType.image,
        text: captionText,
        files: [XFile(imagePath)],
        subject: 'Image Translation from LingoSphere',
        preferredPlatform: preferredPlatform,
        metadata: {
          'image_path': imagePath,
          'translation_id': translation.id,
        },
      );

      return await this.shareContent(shareContent);
    } catch (e) {
      logger.e('Failed to share image with translation: $e');
      return ShareResult.createError(
          'Failed to share image with translation: $e');
    }
  }

  /// Share audio file with transcription
  Future<ShareResult> shareAudioWithTranscription({
    required String audioPath,
    required TranslationEntry translation,
    SharingPlatform? preferredPlatform,
  }) async {
    try {
      final captionText = '''
🎙️ Voice Translation from LingoSphere

📝 Original (${translation.sourceLanguage.toUpperCase()}):
${translation.sourceText}

🔄 Translation (${translation.targetLanguage.toUpperCase()}):
${translation.translatedText}

⏰ ${_formatTimestamp(translation.timestamp)}
🌐 LingoSphere - AI-Powered Translation
''';

      final shareContent = ShareContent(
        type: ShareContentType.audio,
        text: captionText,
        files: [XFile(audioPath)],
        subject: 'Voice Translation from LingoSphere',
        preferredPlatform: preferredPlatform,
        metadata: {
          'audio_path': audioPath,
          'translation_id': translation.id,
          'type': 'voice',
        },
      );

      return await this.shareContent(shareContent);
    } catch (e) {
      logger.e('Failed to share audio with transcription: $e');
      return ShareResult.createError(
          'Failed to share audio with transcription: $e');
    }
  }

  /// Copy content to clipboard
  Future<ShareResult> copyToClipboard(String text) async {
    try {
      // We'll implement clipboard functionality here
      // For now, use the sharing system
      final shareContent = ShareContent(
        type: ShareContentType.text,
        text: text,
        preferredPlatform: SharingPlatform.clipboard,
      );

      return await this.shareContent(shareContent);
    } catch (e) {
      logger.e('Failed to copy to clipboard: $e');
      return ShareResult.createError('Failed to copy to clipboard: $e');
    }
  }

  /// Get available sharing platforms for current device
  List<SharingPlatform> getAvailablePlatforms() {
    final platforms = <SharingPlatform>[
      SharingPlatform.generic,
      SharingPlatform.clipboard,
      SharingPlatform.email,
    ];

    // Add platform-specific options
    if (Platform.isIOS) {
      platforms.addAll([
        SharingPlatform.airdrop,
        SharingPlatform.whatsapp,
        SharingPlatform.telegram,
        SharingPlatform.twitter,
        SharingPlatform.instagram,
      ]);
    }

    if (Platform.isAndroid) {
      platforms.addAll([
        SharingPlatform.whatsapp,
        SharingPlatform.telegram,
        SharingPlatform.twitter,
        SharingPlatform.facebook,
        SharingPlatform.linkedin,
        SharingPlatform.sms,
      ]);
    }

    return platforms;
  }

  /// Get platform display name
  String getPlatformDisplayName(SharingPlatform platform) {
    switch (platform) {
      case SharingPlatform.generic:
        return 'Share';
      case SharingPlatform.whatsapp:
        return 'WhatsApp';
      case SharingPlatform.telegram:
        return 'Telegram';
      case SharingPlatform.twitter:
        return 'Twitter';
      case SharingPlatform.facebook:
        return 'Facebook';
      case SharingPlatform.instagram:
        return 'Instagram';
      case SharingPlatform.linkedin:
        return 'LinkedIn';
      case SharingPlatform.email:
        return 'Email';
      case SharingPlatform.sms:
        return 'Messages';
      case SharingPlatform.clipboard:
        return 'Copy';
      case SharingPlatform.airdrop:
        return 'AirDrop';
    }
  }

  /// Get platform icon
  IconData getPlatformIcon(SharingPlatform platform) {
    switch (platform) {
      case SharingPlatform.generic:
        return Icons.share;
      case SharingPlatform.whatsapp:
        return Icons.chat_bubble;
      case SharingPlatform.telegram:
        return Icons.send;
      case SharingPlatform.twitter:
        return Icons.alternate_email;
      case SharingPlatform.facebook:
        return Icons.facebook;
      case SharingPlatform.instagram:
        return Icons.camera_alt;
      case SharingPlatform.linkedin:
        return Icons.business;
      case SharingPlatform.email:
        return Icons.email;
      case SharingPlatform.sms:
        return Icons.message;
      case SharingPlatform.clipboard:
        return Icons.copy;
      case SharingPlatform.airdrop:
        return Icons.wifi_tethering;
    }
  }

  // Private methods

  /// Share to specific platform
  Future<ShareResult> _shareToPlatform(ShareContent content) async {
    switch (content.preferredPlatform!) {
      case SharingPlatform.whatsapp:
        return await _shareToWhatsApp(content);
      case SharingPlatform.telegram:
        return await _shareToTelegram(content);
      case SharingPlatform.twitter:
        return await _shareToTwitter(content);
      case SharingPlatform.email:
        return await _shareToEmail(content);
      case SharingPlatform.sms:
        return await _shareToSMS(content);
      case SharingPlatform.clipboard:
        return await _shareToClipboard(content);
      default:
        return await _shareGeneric(content);
    }
  }

  /// Generic sharing using native share dialog
  Future<ShareResult> _shareGeneric(ShareContent content) async {
    try {
      if (content.files != null && content.files!.isNotEmpty) {
        final result = await Share.shareXFiles(
          content.files!,
          text: content.text,
          subject: content.subject,
        );

        return result.status == ShareResultStatus.success
            ? ShareResult.createSuccess(platform: SharingPlatform.generic)
            : ShareResult.createError('Share failed: ${result.status}');
      } else if (content.text != null) {
        await Share.share(
          content.text!,
          subject: content.subject,
        );

        // Share.share() returns void, so we assume success if no exception is thrown
        return ShareResult.createSuccess(platform: SharingPlatform.generic);
      } else {
        return ShareResult.createError('No content to share');
      }
    } catch (e) {
      return ShareResult.createError('Generic sharing failed: $e');
    }
  }

  /// Share to WhatsApp
  Future<ShareResult> _shareToWhatsApp(ShareContent content) async {
    try {
      final whatsappUrl = Uri.parse(
          'whatsapp://send?text=${Uri.encodeComponent(content.text ?? '')}');

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
        return ShareResult.createSuccess(platform: SharingPlatform.whatsapp);
      } else {
        // Fallback to generic sharing
        return await _shareGeneric(content);
      }
    } catch (e) {
      return ShareResult.createError('WhatsApp sharing failed: $e');
    }
  }

  /// Share to Telegram
  Future<ShareResult> _shareToTelegram(ShareContent content) async {
    try {
      final telegramUrl =
          Uri.parse('tg://msg?text=${Uri.encodeComponent(content.text ?? '')}');

      if (await canLaunchUrl(telegramUrl)) {
        await launchUrl(telegramUrl);
        return ShareResult.createSuccess(platform: SharingPlatform.telegram);
      } else {
        return await _shareGeneric(content);
      }
    } catch (e) {
      return ShareResult.createError('Telegram sharing failed: $e');
    }
  }

  /// Share to Twitter
  Future<ShareResult> _shareToTwitter(ShareContent content) async {
    try {
      // Limit text for Twitter
      String tweetText = content.text ?? '';
      if (tweetText.length > 280) {
        tweetText = '${tweetText.substring(0, 270)}... #LingoSphere';
      }

      final twitterUrl =
          Uri.parse('twitter://post?message=${Uri.encodeComponent(tweetText)}');
      final webUrl = Uri.parse(
          'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(tweetText)}');

      if (await canLaunchUrl(twitterUrl)) {
        await launchUrl(twitterUrl);
        return ShareResult.createSuccess(platform: SharingPlatform.twitter);
      } else if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl);
        return ShareResult.createSuccess(platform: SharingPlatform.twitter);
      } else {
        return await _shareGeneric(content);
      }
    } catch (e) {
      return ShareResult.createError('Twitter sharing failed: $e');
    }
  }

  /// Share to Email
  Future<ShareResult> _shareToEmail(ShareContent content) async {
    try {
      final emailUrl = Uri.parse(
          'mailto:?subject=${Uri.encodeComponent(content.subject ?? 'Shared from LingoSphere')}&body=${Uri.encodeComponent(content.text ?? '')}');

      if (await canLaunchUrl(emailUrl)) {
        await launchUrl(emailUrl);
        return ShareResult.createSuccess(platform: SharingPlatform.email);
      } else {
        return await _shareGeneric(content);
      }
    } catch (e) {
      return ShareResult.createError('Email sharing failed: $e');
    }
  }

  /// Share to SMS
  Future<ShareResult> _shareToSMS(ShareContent content) async {
    try {
      final smsUrl =
          Uri.parse('sms:?body=${Uri.encodeComponent(content.text ?? '')}');

      if (await canLaunchUrl(smsUrl)) {
        await launchUrl(smsUrl);
        return ShareResult.createSuccess(platform: SharingPlatform.sms);
      } else {
        return await _shareGeneric(content);
      }
    } catch (e) {
      return ShareResult.createError('SMS sharing failed: $e');
    }
  }

  /// Share to clipboard
  Future<ShareResult> _shareToClipboard(ShareContent content) async {
    try {
      // This would normally use Clipboard.setData, but we'll handle it through sharing
      return await _shareGeneric(content);
    } catch (e) {
      return ShareResult.createError('Clipboard sharing failed: $e');
    }
  }

  /// Handle share result from share_plus
  ShareResult _handleSharePlusResult(dynamic result, SharingPlatform platform) {
    // Log analytics
    logger.d('Share completed - Platform: $platform');

    // The result from share_plus is either ShareResult enum or String
    final success = result.toString() == 'ShareResultStatus.success';

    return ShareResult(
      success: success,
      platform: platform,
      sharedAt: DateTime.now(),
      analytics: {
        'platform': platform.toString(),
        'success': success,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Format translation text for sharing
  String _formatTranslationText(
    TranslationEntry translation, {
    required bool includeMetadata,
    required bool includeFormatting,
    SharingPlatform? platform,
  }) {
    final buffer = StringBuffer();

    if (includeFormatting) {
      if (platform == SharingPlatform.whatsapp ||
          platform == SharingPlatform.telegram) {
        // Rich formatting for messaging platforms
        buffer.writeln('🌐 *LingoSphere Translation*');
        buffer.writeln();
        buffer.writeln(
            '📝 *Original* (${translation.sourceLanguage.toUpperCase()}):');
        buffer.writeln(translation.sourceText);
        buffer.writeln();
        buffer.writeln(
            '🔄 *Translation* (${translation.targetLanguage.toUpperCase()}):');
        buffer.writeln(translation.translatedText);

        if (includeMetadata) {
          buffer.writeln();
          buffer.writeln('⏰ ${_formatTimestamp(translation.timestamp)}');
          if (translation.type != TranslationMethod.text) {
            buffer.writeln('📱 Type: ${translation.type.name}');
          }
        }
      } else {
        // Clean formatting for other platforms
        buffer.writeln('🌐 LingoSphere Translation');
        buffer.writeln();
        buffer.writeln(
            'Original (${translation.sourceLanguage}) → ${translation.targetLanguage}:');
        buffer.writeln(translation.sourceText);
        buffer.writeln();
        buffer.writeln('Translation:');
        buffer.writeln(translation.translatedText);

        if (includeMetadata) {
          buffer.writeln();
          buffer.writeln(
              'Translated on ${_formatTimestamp(translation.timestamp)}');
        }
      }
    } else {
      // Simple formatting
      buffer.writeln('${translation.sourceText}');
      buffer.writeln();
      buffer.writeln('${translation.translatedText}');
      buffer.writeln();
      buffer.writeln('- LingoSphere');
    }

    return buffer.toString();
  }

  /// Format conversation text for sharing
  String _formatConversationText(
    List<TranslationEntry> conversation, {
    String? title,
    required bool includeTimestamps,
    SharingPlatform? platform,
  }) {
    final buffer = StringBuffer();

    buffer.writeln(title ?? '🌐 LingoSphere Conversation');
    buffer.writeln('=' * 40);
    buffer.writeln();

    for (int i = 0; i < conversation.length; i++) {
      final entry = conversation[i];

      if (includeTimestamps) {
        buffer.writeln('[${_formatTimestamp(entry.timestamp)}]');
      }

      buffer.writeln('${entry.sourceLanguage} → ${entry.targetLanguage}:');
      buffer.writeln('📝 ${entry.sourceText}');
      buffer.writeln('🔄 ${entry.translatedText}');

      if (i < conversation.length - 1) {
        buffer.writeln();
        buffer.writeln('-' * 20);
        buffer.writeln();
      }
    }

    buffer.writeln();
    buffer.writeln('💬 ${conversation.length} translations');
    buffer.writeln('🌐 Shared from LingoSphere');

    return buffer.toString();
  }

  /// Get languages used in conversation
  Set<String> _getConversationLanguages(List<TranslationEntry> conversation) {
    final languages = <String>{};
    for (final entry in conversation) {
      languages.add(entry.sourceLanguage);
      languages.add(entry.targetLanguage);
    }
    return languages;
  }

  /// Format timestamp for display
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
