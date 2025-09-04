// 🌐 LingoSphere - Enhanced Email Sharing Service
// Professional email templates for translation sharing

import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import '../models/translation_entry.dart';
import '../constants/app_constants.dart';
import '../../main.dart';

/// Email template types
enum EmailTemplate {
  businessFormal,
  casual,
  educational,
  technical,
  presentation,
  summary,
}

/// Email sharing configuration
class EmailShareConfig {
  final EmailTemplate template;
  final String? recipientEmail;
  final String? senderName;
  final String? companyName;
  final bool includeAppPromo;
  final bool includeStatistics;
  final bool includeTimestamps;
  final Map<String, dynamic>? customData;

  const EmailShareConfig({
    this.template = EmailTemplate.casual,
    this.recipientEmail,
    this.senderName,
    this.companyName,
    this.includeAppPromo = true,
    this.includeStatistics = true,
    this.includeTimestamps = true,
    this.customData,
  });
}

/// Enhanced email sharing service
class EnhancedEmailSharingService {
  static final EnhancedEmailSharingService _instance =
      EnhancedEmailSharingService._internal();
  factory EnhancedEmailSharingService() => _instance;
  EnhancedEmailSharingService._internal();

  /// Share single translation via email
  Future<bool> shareTranslation({
    required TranslationEntry translation,
    required EmailShareConfig config,
  }) async {
    try {
      final subject = _generateSubject(
        template: config.template,
        contentType: 'Translation',
        sourceLanguage: translation.sourceLanguage,
        targetLanguage: translation.targetLanguage,
      );

      final body = _generateTranslationEmailBody(translation, config);

      return await _sendEmail(
        to: config.recipientEmail,
        subject: subject,
        body: body,
      );
    } catch (e) {
      logger.e('Failed to share translation via email: $e');
      return false;
    }
  }

  /// Share conversation via email
  Future<bool> shareConversation({
    required List<TranslationEntry> conversation,
    required EmailShareConfig config,
    String? conversationTitle,
  }) async {
    try {
      final languages = _getConversationLanguages(conversation);
      final subject = _generateSubject(
        template: config.template,
        contentType: 'Conversation',
        customTitle: conversationTitle,
        languages: languages,
      );

      final body = _generateConversationEmailBody(
        conversation,
        config,
        conversationTitle,
      );

      return await _sendEmail(
        to: config.recipientEmail,
        subject: subject,
        body: body,
      );
    } catch (e) {
      logger.e('Failed to share conversation via email: $e');
      return false;
    }
  }

  /// Share translation with image attachment
  Future<bool> shareTranslationWithImage({
    required TranslationEntry translation,
    required String imagePath,
    required EmailShareConfig config,
  }) async {
    try {
      final subject = _generateSubject(
        template: config.template,
        contentType: 'Image Translation',
        sourceLanguage: translation.sourceLanguage,
        targetLanguage: translation.targetLanguage,
      );

      final body = _generateImageTranslationEmailBody(
        translation,
        config,
        imagePath,
      );

      return await _sendEmail(
        to: config.recipientEmail,
        subject: subject,
        body: body,
      );
    } catch (e) {
      logger.e('Failed to share image translation via email: $e');
      return false;
    }
  }

  /// Share translation summary/report
  Future<bool> shareTranslationReport({
    required List<TranslationEntry> translations,
    required EmailShareConfig config,
    String? reportTitle,
    Map<String, dynamic>? analytics,
  }) async {
    try {
      final subject = reportTitle ?? 'Translation Report from LingoSphere';

      final body = _generateReportEmailBody(
        translations,
        config,
        reportTitle,
        analytics,
      );

      return await _sendEmail(
        to: config.recipientEmail,
        subject: subject,
        body: body,
      );
    } catch (e) {
      logger.e('Failed to share translation report via email: $e');
      return false;
    }
  }

  /// Get available email templates
  List<EmailTemplate> getAvailableTemplates() {
    return EmailTemplate.values;
  }

  /// Get template display name
  String getTemplateDisplayName(EmailTemplate template) {
    switch (template) {
      case EmailTemplate.businessFormal:
        return 'Business Formal';
      case EmailTemplate.casual:
        return 'Casual';
      case EmailTemplate.educational:
        return 'Educational';
      case EmailTemplate.technical:
        return 'Technical';
      case EmailTemplate.presentation:
        return 'Presentation';
      case EmailTemplate.summary:
        return 'Summary';
    }
  }

  /// Get template description
  String getTemplateDescription(EmailTemplate template) {
    switch (template) {
      case EmailTemplate.businessFormal:
        return 'Professional format for business communications';
      case EmailTemplate.casual:
        return 'Friendly and informal tone for personal sharing';
      case EmailTemplate.educational:
        return 'Structured format for learning and teaching';
      case EmailTemplate.technical:
        return 'Detailed format with technical information';
      case EmailTemplate.presentation:
        return 'Clean format suitable for presentations';
      case EmailTemplate.summary:
        return 'Condensed format highlighting key points';
    }
  }

  // Private methods

  /// Generate email subject based on template and content
  String _generateSubject({
    required EmailTemplate template,
    required String contentType,
    String? sourceLanguage,
    String? targetLanguage,
    String? customTitle,
    Set<String>? languages,
  }) {
    switch (template) {
      case EmailTemplate.businessFormal:
        if (customTitle != null) return 'RE: $customTitle';
        if (sourceLanguage != null && targetLanguage != null) {
          return '$contentType: ${_getLanguageName(sourceLanguage)} to ${_getLanguageName(targetLanguage)}';
        }
        return 'Translation $contentType from LingoSphere';

      case EmailTemplate.casual:
        if (customTitle != null) return '📱 $customTitle';
        return '🌐 Check out this translation!';

      case EmailTemplate.educational:
        if (languages != null && languages.length > 1) {
          return 'Language Learning: ${languages.map(_getLanguageName).join(', ')}';
        }
        return 'Translation Learning Material';

      case EmailTemplate.technical:
        return 'Translation Data Export - ${DateTime.now().toString().split(' ')[0]}';

      case EmailTemplate.presentation:
        return customTitle ?? 'Translation Content for Presentation';

      case EmailTemplate.summary:
        return 'Translation Summary Report';
    }
  }

  /// Generate email body for single translation
  String _generateTranslationEmailBody(
    TranslationEntry translation,
    EmailShareConfig config,
  ) {
    final buffer = StringBuffer();

    switch (config.template) {
      case EmailTemplate.businessFormal:
        _addBusinessFormalTranslationContent(buffer, translation, config);
        break;
      case EmailTemplate.casual:
        _addCasualTranslationContent(buffer, translation, config);
        break;
      case EmailTemplate.educational:
        _addEducationalTranslationContent(buffer, translation, config);
        break;
      case EmailTemplate.technical:
        _addTechnicalTranslationContent(buffer, translation, config);
        break;
      case EmailTemplate.presentation:
        _addPresentationTranslationContent(buffer, translation, config);
        break;
      case EmailTemplate.summary:
        _addSummaryTranslationContent(buffer, translation, config);
        break;
    }

    if (config.includeAppPromo) {
      _addAppPromotion(buffer, config.template);
    }

    _addEmailFooter(buffer, config);

    return buffer.toString();
  }

  /// Generate email body for conversation
  String _generateConversationEmailBody(
    List<TranslationEntry> conversation,
    EmailShareConfig config,
    String? title,
  ) {
    final buffer = StringBuffer();

    _addEmailHeader(buffer, config);

    switch (config.template) {
      case EmailTemplate.businessFormal:
        _addBusinessFormalConversationContent(
            buffer, conversation, config, title);
        break;
      case EmailTemplate.casual:
        _addCasualConversationContent(buffer, conversation, config, title);
        break;
      case EmailTemplate.educational:
        _addEducationalConversationContent(buffer, conversation, config, title);
        break;
      case EmailTemplate.technical:
        _addTechnicalConversationContent(buffer, conversation, config, title);
        break;
      case EmailTemplate.presentation:
        _addPresentationConversationContent(
            buffer, conversation, config, title);
        break;
      case EmailTemplate.summary:
        _addSummaryConversationContent(buffer, conversation, config, title);
        break;
    }

    if (config.includeStatistics) {
      _addConversationStatistics(buffer, conversation, config.template);
    }

    if (config.includeAppPromo) {
      _addAppPromotion(buffer, config.template);
    }

    _addEmailFooter(buffer, config);

    return buffer.toString();
  }

  /// Generate email body for image translation
  String _generateImageTranslationEmailBody(
    TranslationEntry translation,
    EmailShareConfig config,
    String imagePath,
  ) {
    final buffer = StringBuffer();

    _addEmailHeader(buffer, config);

    buffer.writeln('📸 Image Translation Results');
    buffer.writeln();
    buffer.writeln(
        'Original Text (${_getLanguageName(translation.sourceLanguage)}):');
    buffer.writeln(translation.sourceText);
    buffer.writeln();
    buffer.writeln(
        'Translation (${_getLanguageName(translation.targetLanguage)}):');
    buffer.writeln(translation.translatedText);
    buffer.writeln();

    if (config.includeTimestamps) {
      buffer.writeln('Processed: ${_formatDateTime(translation.timestamp)}');
      buffer.writeln();
    }

    buffer.writeln('📎 Image attachment included');
    buffer.writeln();

    if (config.includeAppPromo) {
      _addAppPromotion(buffer, config.template);
    }

    _addEmailFooter(buffer, config);

    return buffer.toString();
  }

  /// Generate email body for translation report
  String _generateReportEmailBody(
    List<TranslationEntry> translations,
    EmailShareConfig config,
    String? reportTitle,
    Map<String, dynamic>? analytics,
  ) {
    final buffer = StringBuffer();

    _addEmailHeader(buffer, config);

    buffer.writeln(reportTitle ?? 'Translation Report');
    buffer.writeln('=' * 50);
    buffer.writeln();

    if (analytics != null) {
      buffer.writeln('📊 SUMMARY');
      buffer.writeln('• Total Translations: ${translations.length}');
      buffer
          .writeln('• Languages: ${_getUniqueLanguages(translations).length}');
      buffer.writeln('• Date Range: ${_getDateRange(translations)}');
      buffer.writeln(
          '• Translation Types: ${_getTranslationTypes(translations).join(', ')}');
      buffer.writeln();
    }

    buffer.writeln('📋 TRANSLATIONS');
    buffer.writeln();

    for (int i = 0; i < translations.length; i++) {
      final translation = translations[i];

      buffer.writeln(
          '${i + 1}. ${_getLanguageName(translation.sourceLanguage)} → ${_getLanguageName(translation.targetLanguage)}');
      buffer.writeln('   Original: ${translation.sourceText}');
      buffer.writeln('   Translation: ${translation.translatedText}');

      if (config.includeTimestamps) {
        buffer.writeln('   Date: ${_formatDateTime(translation.timestamp)}');
      }

      buffer.writeln();
    }

    if (config.includeAppPromo) {
      _addAppPromotion(buffer, config.template);
    }

    _addEmailFooter(buffer, config);

    return buffer.toString();
  }

  /// Send email using platform's default email client
  Future<bool> _sendEmail({
    String? to,
    required String subject,
    required String body,
  }) async {
    try {
      final emailUri = Uri(
        scheme: 'mailto',
        path: to ?? '',
        query: _encodeQueryParameters({
          'subject': subject,
          'body': body,
        }),
      );

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        return true;
      } else {
        logger.w('Cannot launch email client');
        return false;
      }
    } catch (e) {
      logger.e('Failed to send email: $e');
      return false;
    }
  }

  // Template-specific content generators

  void _addBusinessFormalTranslationContent(
    StringBuffer buffer,
    TranslationEntry translation,
    EmailShareConfig config,
  ) {
    _addEmailHeader(buffer, config);

    buffer.writeln('Dear Recipient,');
    buffer.writeln();
    buffer
        .writeln('Please find below the translation results from LingoSphere:');
    buffer.writeln();
    buffer.writeln(
        'Source Language: ${_getLanguageName(translation.sourceLanguage)}');
    buffer.writeln(
        'Target Language: ${_getLanguageName(translation.targetLanguage)}');
    buffer.writeln();
    buffer.writeln('Original Text:');
    buffer.writeln('"${translation.sourceText}"');
    buffer.writeln();
    buffer.writeln('Translation:');
    buffer.writeln('"${translation.translatedText}"');
    buffer.writeln();

    if (config.includeTimestamps) {
      buffer.writeln(
          'Translation Date: ${_formatDateTime(translation.timestamp)}');
      buffer.writeln();
    }

    buffer.writeln('Best regards,');
    buffer.writeln(config.senderName ?? 'LingoSphere User');
    if (config.companyName != null) {
      buffer.writeln(config.companyName!);
    }
    buffer.writeln();
  }

  void _addCasualTranslationContent(
    StringBuffer buffer,
    TranslationEntry translation,
    EmailShareConfig config,
  ) {
    buffer.writeln('Hey! 👋');
    buffer.writeln();
    buffer.writeln('Check out this translation I got from LingoSphere:');
    buffer.writeln();
    buffer.writeln(
        '🗣️ ${_getLanguageName(translation.sourceLanguage)}: ${translation.sourceText}');
    buffer.writeln(
        '🔄 ${_getLanguageName(translation.targetLanguage)}: ${translation.translatedText}');
    buffer.writeln();

    if (config.includeTimestamps) {
      buffer.writeln('📅 ${_formatDateTime(translation.timestamp)}');
      buffer.writeln();
    }

    buffer.writeln('Pretty cool, right? 😊');
    buffer.writeln();
  }

  void _addEducationalTranslationContent(
    StringBuffer buffer,
    TranslationEntry translation,
    EmailShareConfig config,
  ) {
    _addEmailHeader(buffer, config);

    buffer.writeln('📚 Language Learning Material');
    buffer.writeln();
    buffer.writeln(
        'Language Pair: ${_getLanguageName(translation.sourceLanguage)} ↔ ${_getLanguageName(translation.targetLanguage)}');
    buffer.writeln();
    buffer.writeln('Example Sentence:');
    buffer.writeln('• Source: ${translation.sourceText}');
    buffer.writeln('• Translation: ${translation.translatedText}');
    buffer.writeln();

    // Add learning notes if available
    if (translation.type == TranslationMethod.voice) {
      buffer.writeln(
          '💡 Note: This was a voice translation, great for pronunciation practice!');
      buffer.writeln();
    }

    buffer.writeln('Keep practicing! 🌟');
    buffer.writeln();
  }

  void _addTechnicalTranslationContent(
    StringBuffer buffer,
    TranslationEntry translation,
    EmailShareConfig config,
  ) {
    _addEmailHeader(buffer, config);

    buffer.writeln('TRANSLATION DATA EXPORT');
    buffer.writeln('========================');
    buffer.writeln();
    buffer.writeln('Translation ID: ${translation.id}');
    buffer.writeln('Source Language: ${translation.sourceLanguage}');
    buffer.writeln('Target Language: ${translation.targetLanguage}');
    buffer.writeln('Translation Type: ${translation.type.name}');
    buffer.writeln('Timestamp: ${translation.timestamp.toIso8601String()}');
    buffer.writeln('Favorite Status: ${translation.isFavorite}');
    buffer.writeln();
    buffer.writeln('Source Text:');
    buffer.writeln('${translation.sourceText}');
    buffer.writeln();
    buffer.writeln('Translated Text:');
    buffer.writeln('${translation.translatedText}');
    buffer.writeln();
    buffer
        .writeln('Character Count (Source): ${translation.sourceText.length}');
    buffer.writeln(
        'Character Count (Target): ${translation.translatedText.length}');
    buffer.writeln();
  }

  void _addPresentationTranslationContent(
    StringBuffer buffer,
    TranslationEntry translation,
    EmailShareConfig config,
  ) {
    buffer.writeln(
        '${_getLanguageName(translation.sourceLanguage)} → ${_getLanguageName(translation.targetLanguage)}');
    buffer.writeln();
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln();
    buffer.writeln('Original:');
    buffer.writeln(translation.sourceText);
    buffer.writeln();
    buffer.writeln('Translation:');
    buffer.writeln(translation.translatedText);
    buffer.writeln();
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln();
  }

  void _addSummaryTranslationContent(
    StringBuffer buffer,
    TranslationEntry translation,
    EmailShareConfig config,
  ) {
    buffer.writeln('Translation Summary');
    buffer.writeln('─────────────────');
    buffer.writeln(
        '${_getLanguageName(translation.sourceLanguage)} → ${_getLanguageName(translation.targetLanguage)}');
    buffer.writeln();
    buffer.writeln('• ${translation.sourceText}');
    buffer.writeln('• ${translation.translatedText}');
    buffer.writeln();
  }

  // Conversation content generators (simplified for space)
  void _addBusinessFormalConversationContent(
    StringBuffer buffer,
    List<TranslationEntry> conversation,
    EmailShareConfig config,
    String? title,
  ) {
    buffer.writeln('Dear Recipient,');
    buffer.writeln();
    buffer.writeln('Please find below the conversation transcript:');
    buffer.writeln();

    for (int i = 0; i < conversation.length; i++) {
      final entry = conversation[i];
      buffer.writeln(
          '${i + 1}. ${_getLanguageName(entry.sourceLanguage)} → ${_getLanguageName(entry.targetLanguage)}');
      buffer.writeln('   "${entry.sourceText}" → "${entry.translatedText}"');
      buffer.writeln();
    }
  }

  void _addCasualConversationContent(
    StringBuffer buffer,
    List<TranslationEntry> conversation,
    EmailShareConfig config,
    String? title,
  ) {
    buffer.writeln('Hey! 👋');
    buffer.writeln();
    buffer.writeln('Here\'s our conversation from LingoSphere:');
    buffer.writeln();

    for (final entry in conversation) {
      buffer.writeln('🗣️ ${entry.sourceText}');
      buffer.writeln('🔄 ${entry.translatedText}');
      buffer.writeln();
    }
  }

  void _addEducationalConversationContent(
    StringBuffer buffer,
    List<TranslationEntry> conversation,
    EmailShareConfig config,
    String? title,
  ) {
    buffer.writeln('📚 Conversation Practice Material');
    buffer.writeln();

    final languages = _getConversationLanguages(conversation);
    buffer.writeln('Languages: ${languages.map(_getLanguageName).join(' ↔ ')}');
    buffer.writeln();

    for (int i = 0; i < conversation.length; i++) {
      final entry = conversation[i];
      buffer.writeln('Example ${i + 1}:');
      buffer.writeln('• ${entry.sourceText}');
      buffer.writeln('• ${entry.translatedText}');
      buffer.writeln();
    }
  }

  void _addTechnicalConversationContent(
    StringBuffer buffer,
    List<TranslationEntry> conversation,
    EmailShareConfig config,
    String? title,
  ) {
    buffer.writeln('CONVERSATION DATA EXPORT');
    buffer.writeln('========================');
    buffer.writeln();
    buffer.writeln('Total Entries: ${conversation.length}');
    buffer.writeln('Export Date: ${DateTime.now().toIso8601String()}');
    buffer.writeln();

    for (int i = 0; i < conversation.length; i++) {
      final entry = conversation[i];
      buffer.writeln('Entry ${i + 1}:');
      buffer.writeln('ID: ${entry.id}');
      buffer.writeln('Timestamp: ${entry.timestamp.toIso8601String()}');
      buffer.writeln('Source (${entry.sourceLanguage}): ${entry.sourceText}');
      buffer
          .writeln('Target (${entry.targetLanguage}): ${entry.translatedText}');
      buffer.writeln('─────────────────');
    }
  }

  void _addPresentationConversationContent(
    StringBuffer buffer,
    List<TranslationEntry> conversation,
    EmailShareConfig config,
    String? title,
  ) {
    buffer.writeln('${title ?? 'Multilingual Conversation'}');
    buffer.writeln();
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln();

    for (final entry in conversation) {
      buffer.writeln(
          '${_getLanguageName(entry.sourceLanguage)}: ${entry.sourceText}');
      buffer.writeln(
          '${_getLanguageName(entry.targetLanguage)}: ${entry.translatedText}');
      buffer.writeln();
    }

    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  void _addSummaryConversationContent(
    StringBuffer buffer,
    List<TranslationEntry> conversation,
    EmailShareConfig config,
    String? title,
  ) {
    buffer.writeln('Conversation Summary');
    buffer.writeln('───────────────────');
    buffer.writeln('Entries: ${conversation.length}');
    buffer.writeln(
        'Languages: ${_getConversationLanguages(conversation).map(_getLanguageName).join(', ')}');
    buffer.writeln();

    // Show only first few entries for summary
    final entriesToShow =
        conversation.length > 5 ? conversation.take(5).toList() : conversation;

    for (final entry in entriesToShow) {
      buffer.writeln('• ${entry.sourceText} → ${entry.translatedText}');
    }

    if (conversation.length > 5) {
      buffer.writeln('... and ${conversation.length - 5} more entries');
    }
    buffer.writeln();
  }

  // Helper methods

  void _addEmailHeader(StringBuffer buffer, EmailShareConfig config) {
    if (config.template == EmailTemplate.businessFormal &&
        config.companyName != null) {
      buffer.writeln(config.companyName!);
      buffer.writeln('─' * config.companyName!.length);
      buffer.writeln();
    }
  }

  void _addConversationStatistics(
    StringBuffer buffer,
    List<TranslationEntry> conversation,
    EmailTemplate template,
  ) {
    final languages = _getConversationLanguages(conversation);
    final types = _getTranslationTypes(conversation);

    if (template == EmailTemplate.casual) {
      buffer.writeln('📊 Quick Stats:');
      buffer.writeln('• ${conversation.length} translations');
      buffer.writeln('• ${languages.length} languages');
      buffer.writeln('• Types: ${types.join(', ')}');
    } else {
      buffer.writeln('Statistics:');
      buffer.writeln('Total Translations: ${conversation.length}');
      buffer
          .writeln('Languages: ${languages.map(_getLanguageName).join(', ')}');
      buffer.writeln('Translation Types: ${types.join(', ')}');
      buffer.writeln('Date Range: ${_getDateRange(conversation)}');
    }
    buffer.writeln();
  }

  void _addAppPromotion(StringBuffer buffer, EmailTemplate template) {
    if (template == EmailTemplate.casual) {
      buffer.writeln('📱 Get LingoSphere for seamless translation:');
      buffer.writeln('🌐 AI-powered • 🎙️ Voice support • 📱 Cross-platform');
    } else if (template == EmailTemplate.businessFormal) {
      buffer.writeln('This translation was generated using LingoSphere,');
      buffer.writeln('a professional AI-powered translation platform.');
    } else {
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln('🌐 LingoSphere - AI-Powered Translation');
      buffer.writeln('Experience seamless multilingual communication');
    }
    buffer.writeln();
  }

  void _addEmailFooter(StringBuffer buffer, EmailShareConfig config) {
    if (config.template != EmailTemplate.businessFormal) {
      buffer.writeln('--');
      buffer.writeln('Sent from LingoSphere');
      buffer.writeln('🌐 Breaking language barriers with AI');
    }
  }

  Set<String> _getConversationLanguages(List<TranslationEntry> conversation) {
    final languages = <String>{};
    for (final entry in conversation) {
      languages.add(entry.sourceLanguage);
      languages.add(entry.targetLanguage);
    }
    return languages;
  }

  Set<String> _getUniqueLanguages(List<TranslationEntry> translations) {
    final languages = <String>{};
    for (final entry in translations) {
      languages.add(entry.sourceLanguage);
      languages.add(entry.targetLanguage);
    }
    return languages;
  }

  Set<String> _getTranslationTypes(List<TranslationEntry> translations) {
    return translations.map((e) => e.type.name).toSet();
  }

  String _getDateRange(List<TranslationEntry> translations) {
    if (translations.isEmpty) return 'N/A';

    final sortedDates = translations.map((e) => e.timestamp).toList()..sort();
    final earliest = sortedDates.first;
    final latest = sortedDates.last;

    if (earliest.day == latest.day &&
        earliest.month == latest.month &&
        earliest.year == latest.year) {
      return _formatDate(earliest);
    }

    return '${_formatDate(earliest)} - ${_formatDate(latest)}';
  }

  String _getLanguageName(String languageCode) {
    return AppConstants.supportedLanguages[languageCode] ??
        languageCode.toUpperCase();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} at ${_formatTime(dateTime)}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((entry) =>
            '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}')
        .join('&');
  }
}
