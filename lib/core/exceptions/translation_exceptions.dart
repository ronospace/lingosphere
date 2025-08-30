// 🌐 LingoSphere - Translation Exceptions
// Comprehensive exception handling for translation services

import '../constants/app_constants.dart';

/// Base exception class for all translation-related errors
abstract class TranslationException implements Exception {
  final String message;
  final String? code;
  final Map<String, dynamic>? details;
  final Exception? originalException;
  
  const TranslationException(
    this.message, {
    this.code,
    this.details,
    this.originalException,
  });
  
  @override
  String toString() {
    if (code != null) {
      return 'TranslationException($code): $message';
    }
    return 'TranslationException: $message';
  }
  
  /// Get user-friendly error message
  String get userMessage => message;
  
  /// Check if error is recoverable
  bool get isRecoverable => false;
}

/// General translation service error
class TranslationServiceException extends TranslationException {
  const TranslationServiceException(
    super.message, {
    super.code,
    super.details,
    super.originalException,
  });
  
  @override
  bool get isRecoverable => true;
}

/// Network-related translation errors
class TranslationNetworkException extends TranslationException {
  const TranslationNetworkException(
    super.message, {
    super.code,
    super.details,
    super.originalException,
  });
  
  @override
  String get userMessage => AppConstants.networkError;
  
  @override
  bool get isRecoverable => true;
}

/// API key or authentication errors
class TranslationAuthException extends TranslationException {
  const TranslationAuthException(
    super.message, {
    super.code,
    super.details,
    super.originalException,
  });
  
  @override
  String get userMessage => AppConstants.authenticationError;
  
  @override
  bool get isRecoverable => false;
}

/// Translation API quota exceeded
class TranslationQuotaException extends TranslationException {
  final int currentUsage;
  final int maxAllowed;
  final DateTime? resetTime;
  
  const TranslationQuotaException(
    super.message, {
    required this.currentUsage,
    required this.maxAllowed,
    this.resetTime,
    super.code,
    super.details,
    super.originalException,
  });
  
  @override
  String get userMessage => 'Translation quota exceeded. Please try again later.';
  
  @override
  bool get isRecoverable => resetTime != null;
}

/// Language not supported by translation service
class UnsupportedLanguageException extends TranslationException {
  final String language;
  final List<String> supportedLanguages;
  
  const UnsupportedLanguageException(
    super.message, {
    required this.language,
    required this.supportedLanguages,
    super.code,
    super.details,
    super.originalException,
  });
  
  @override
  String get userMessage => 'Language "$language" is not supported for translation.';
  
  @override
  bool get isRecoverable => false;
}

/// Text too long for translation
class TextTooLongException extends TranslationException {
  final int textLength;
  final int maxLength;
  
  const TextTooLongException(
    super.message, {
    required this.textLength,
    required this.maxLength,
    super.code,
    super.details,
    super.originalException,
  });
  
  @override
  String get userMessage => 'Text is too long for translation. Maximum length is $maxLength characters.';
  
  @override
  bool get isRecoverable => false;
}

/// Invalid input text for translation
class InvalidTextException extends TranslationException {
  const InvalidTextException(
    super.message, {
    super.code,
    super.details,
    super.originalException,
  });
  
  @override
  String get userMessage => 'Invalid text provided for translation.';
  
  @override
  bool get isRecoverable => false;
}

/// Translation service timeout
class TranslationTimeoutException extends TranslationException {
  final Duration timeout;
  
  const TranslationTimeoutException(
    super.message, {
    required this.timeout,
    super.code,
    super.details,
    super.originalException,
  });
  
  @override
  String get userMessage => 'Translation service timed out. Please try again.';
  
  @override
  bool get isRecoverable => true;
}

/// Language detection failed
class LanguageDetectionException extends TranslationException {
  const LanguageDetectionException(
    super.message, {
    super.code,
    super.details,
    super.originalException,
  });
  
  @override
  String get userMessage => 'Unable to detect the language of the text.';
  
  @override
  bool get isRecoverable => true;
}

/// Translation provider specific errors
class ProviderException extends TranslationException {
  final String provider;
  
  const ProviderException(
    super.message, {
    required this.provider,
    super.code,
    super.details,
    super.originalException,
  });
  
  @override
  String get userMessage => 'Translation provider "$provider" encountered an error.';
  
  @override
  bool get isRecoverable => true;
}

/// Voice translation specific errors
class VoiceTranslationException extends TranslationException {
  const VoiceTranslationException(
    super.message, {
    super.code,
    super.details,
    super.originalException,
  });
  
  @override
  String get userMessage => 'Voice translation failed. Please try again.';
  
  @override
  bool get isRecoverable => true;
}

/// Speech recognition failed
class SpeechRecognitionException extends TranslationException {
  const SpeechRecognitionException(
    super.message, {
    super.code,
    super.details,
    super.originalException,
  });
  
  @override
  String get userMessage => 'Could not understand the speech. Please speak more clearly.';
  
  @override
  bool get isRecoverable => true;
}

/// Audio quality too poor for recognition
class PoorAudioQualityException extends TranslationException {
  final double quality;
  final double minRequiredQuality;
  
  const PoorAudioQualityException(
    super.message, {
    required this.quality,
    required this.minRequiredQuality,
    super.code,
    super.details,
    super.originalException,
  });
  
  @override
  String get userMessage => 'Audio quality is too poor for accurate translation. Please record in a quieter environment.';
  
  @override
  bool get isRecoverable => true;
}

/// Cache-related errors
class TranslationCacheException extends TranslationException {
  const TranslationCacheException(
    super.message, {
    super.code,
    super.details,
    super.originalException,
  });
  
  @override
  String get userMessage => 'Translation cache error occurred.';
  
  @override
  bool get isRecoverable => true;
}

/// Batch translation errors
class BatchTranslationException extends TranslationException {
  final List<int> failedIndices;
  final List<TranslationException> individualErrors;
  
  const BatchTranslationException(
    super.message, {
    required this.failedIndices,
    required this.individualErrors,
    super.code,
    super.details,
    super.originalException,
  });
  
  @override
  String get userMessage => 'Some translations in the batch failed.';
  
  @override
  bool get isRecoverable => true;
  
  /// Get successfully translated indices
  List<int> get successfulIndices {
    final successCount = (details?['successCount'] ?? 0) as int;
    final totalIndices = List.generate(failedIndices.length + successCount, (i) => i);
    return totalIndices.where((i) => !failedIndices.contains(i)).toList();
  }
}

/// Configuration or setup errors
class TranslationConfigException extends TranslationException {
  const TranslationConfigException(
    super.message, {
    super.code,
    super.details,
    super.originalException,
  });
  
  @override
  String get userMessage => 'Translation service configuration error.';
  
  @override
  bool get isRecoverable => false;
}

/// Rate limiting errors
class RateLimitException extends TranslationException {
  final Duration retryAfter;
  final int requestCount;
  final int maxRequests;
  
  const RateLimitException(
    super.message, {
    required this.retryAfter,
    required this.requestCount,
    required this.maxRequests,
    super.code,
    super.details,
    super.originalException,
  });
  
  @override
  String get userMessage => 'Too many requests. Please wait ${retryAfter.inSeconds} seconds before trying again.';
  
  @override
  bool get isRecoverable => true;
}

/// Content filtering or inappropriate content errors
class ContentFilterException extends TranslationException {
  final String reason;
  
  const ContentFilterException(
    super.message, {
    required this.reason,
    super.code,
    super.details,
    super.originalException,
  });
  
  @override
  String get userMessage => 'Content cannot be translated due to content policy restrictions.';
  
  @override
  bool get isRecoverable => false;
}

/// Translation quality too low
class LowQualityTranslationException extends TranslationException {
  final double qualityScore;
  final double minAcceptableScore;
  
  const LowQualityTranslationException(
    super.message, {
    required this.qualityScore,
    required this.minAcceptableScore,
    super.code,
    super.details,
    super.originalException,
  });
  
  @override
  String get userMessage => 'Translation quality is below acceptable standards. Please try a different approach.';
  
  @override
  bool get isRecoverable => true;
}

/// Messaging platform integration errors
class MessagingPlatformException extends TranslationException {
  final String platform;
  
  const MessagingPlatformException(
    super.message, {
    required this.platform,
    super.code,
    super.details,
    super.originalException,
  });
  
  @override
  String get userMessage => 'Error connecting to $platform. Please check your connection and try again.';
  
  @override
  bool get isRecoverable => true;
}

/// Permission denied for accessing messaging platforms
class MessagingPermissionException extends TranslationException {
  final String permission;
  final String platform;
  
  const MessagingPermissionException(
    super.message, {
    required this.permission,
    required this.platform,
    super.code,
    super.details,
    super.originalException,
  });
  
  @override
  String get userMessage => AppConstants.permissionError;
  
  @override
  bool get isRecoverable => false;
}

/// Utility class for creating common translation exceptions
class TranslationExceptionFactory {
  static TranslationException networkError([Exception? original]) {
    return TranslationNetworkException(
      'Network connection failed',
      code: 'NETWORK_ERROR',
      originalException: original,
    );
  }
  
  static TranslationException textTooLong(int length) {
    return TextTooLongException(
      'Text length $length exceeds maximum allowed',
      textLength: length,
      maxLength: AppConstants.maxTranslationLength,
      code: 'TEXT_TOO_LONG',
    );
  }
  
  static TranslationException emptyText() {
    return const InvalidTextException(
      'Text cannot be empty',
      code: 'EMPTY_TEXT',
    );
  }
  
  static TranslationException unsupportedLanguage(String language) {
    return UnsupportedLanguageException(
      'Language not supported: $language',
      language: language,
      supportedLanguages: AppConstants.supportedLanguages.keys.toList(),
      code: 'UNSUPPORTED_LANGUAGE',
    );
  }
  
  static TranslationException timeout(Duration duration) {
    return TranslationTimeoutException(
      'Translation timed out after ${duration.inSeconds}s',
      timeout: duration,
      code: 'TIMEOUT',
    );
  }
  
  static TranslationException quotaExceeded(int current, int max, [DateTime? resetTime]) {
    return TranslationQuotaException(
      'Translation quota exceeded: $current/$max',
      currentUsage: current,
      maxAllowed: max,
      resetTime: resetTime,
      code: 'QUOTA_EXCEEDED',
    );
  }
  
  static TranslationException authenticationFailed([Exception? original]) {
    return TranslationAuthException(
      'Authentication failed',
      code: 'AUTH_FAILED',
      originalException: original,
    );
  }
  
  static TranslationException providerError(String provider, [Exception? original]) {
    return ProviderException(
      'Provider error: $provider',
      provider: provider,
      code: 'PROVIDER_ERROR',
      originalException: original,
    );
  }
  
  static TranslationException rateLimit(Duration retryAfter, int count, int max) {
    return RateLimitException(
      'Rate limit exceeded: $count/$max requests',
      retryAfter: retryAfter,
      requestCount: count,
      maxRequests: max,
      code: 'RATE_LIMIT',
    );
  }
  
  static TranslationException contentFiltered(String reason) {
    return ContentFilterException(
      'Content filtered: $reason',
      reason: reason,
      code: 'CONTENT_FILTERED',
    );
  }
  
  static TranslationException lowQuality(double score, double minScore) {
    return LowQualityTranslationException(
      'Translation quality too low: $score < $minScore',
      qualityScore: score,
      minAcceptableScore: minScore,
      code: 'LOW_QUALITY',
    );
  }
}
