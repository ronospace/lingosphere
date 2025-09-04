// 🌐 LingoSphere - App Constants
// Core application constants and configuration values

class AppConstants {
  // App Information
  static const String appName = 'LingoSphere';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Seamless multilingual group chat translation with AI-powered insights';

  // API Configuration
  static const String baseUrl = 'https://api.lingosphere.com';
  static const String googleTranslateApiUrl =
      'https://translation.googleapis.com/language/translate/v2';
  static const String deepLApiUrl = 'https://api-free.deepl.com/v2/translate';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  static const String translationsCollection = 'translations';
  static const String groupsCollection = 'groups';
  static const String settingsCollection = 'settings';
  static const String analyticsCollection = 'analytics';

  // Translation Services
  static const String defaultSourceLanguage = 'auto';
  static const String defaultTargetLanguage = 'en';
  static const int maxTranslationLength = 5000;
  static const int translationCacheExpiration = 7; // days

  // Voice Recognition
  static const int maxVoiceRecordingDuration = 300; // seconds
  static const String defaultVoiceLocale = 'en_US';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double iconSize = 24.0;
  static const double smallIconSize = 16.0;
  static const double largeIconSize = 32.0;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Supported Languages with AI Context Awareness
  static const Map<String, String> supportedLanguages = {
    'auto': 'Auto-detect',
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'it': 'Italian',
    'pt': 'Portuguese',
    'ru': 'Russian',
    'ja': 'Japanese',
    'ko': 'Korean',
    'zh': 'Chinese',
    'ar': 'Arabic',
    'hi': 'Hindi',
    'tr': 'Turkish',
    'pl': 'Polish',
    'nl': 'Dutch',
    'sv': 'Swedish',
    'da': 'Danish',
    'no': 'Norwegian',
    'fi': 'Finnish',
    'el': 'Greek',
    'he': 'Hebrew',
    'th': 'Thai',
    'vi': 'Vietnamese',
    'id': 'Indonesian',
    'ms': 'Malay',
    'tl': 'Filipino',
    'uk': 'Ukrainian',
    'cs': 'Czech',
    'sk': 'Slovak',
    'hu': 'Hungarian',
    'ro': 'Romanian',
    'bg': 'Bulgarian',
    'hr': 'Croatian',
    'sr': 'Serbian',
    'sl': 'Slovenian',
    'et': 'Estonian',
    'lv': 'Latvian',
    'lt': 'Lithuanian',
    'fa': 'Persian',
    'ur': 'Urdu',
    'bn': 'Bengali',
    'ta': 'Tamil',
    'te': 'Telugu',
    'ml': 'Malayalam',
    'kn': 'Kannada',
    'gu': 'Gujarati',
    'pa': 'Punjabi',
    'mr': 'Marathi',
    'ne': 'Nepali',
    'si': 'Sinhala',
    'my': 'Myanmar',
    'km': 'Khmer',
    'lo': 'Lao',
    'ka': 'Georgian',
    'am': 'Amharic',
    'sw': 'Swahili',
    'zu': 'Zulu',
    'af': 'Afrikaans',
    'sq': 'Albanian',
    'az': 'Azerbaijani',
    'be': 'Belarusian',
    'bs': 'Bosnian',
    'eu': 'Basque',
    'ca': 'Catalan',
    'cy': 'Welsh',
    'eo': 'Esperanto',
    'gl': 'Galician',
    'is': 'Icelandic',
    'ga': 'Irish',
    'la': 'Latin',
    'mt': 'Maltese',
    'mk': 'Macedonian',
    'mn': 'Mongolian',
    'tg': 'Tajik',
    'uz': 'Uzbek',
    'ky': 'Kyrgyz',
    'kk': 'Kazakh',
  };

  // Messaging Platform APIs
  static const String whatsappBusinessApiUrl =
      'https://graph.facebook.com/v18.0';
  static const String telegramBotApiUrl = 'https://api.telegram.org/bot';

  // Premium Features
  static const int freeTranslationsPerDay = 100;
  static const int proTranslationsPerDay = 5000;
  static const int enterpriseTranslationsPerDay = -1; // unlimited

  // Error Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Please check your internet connection.';
  static const String translationError =
      'Translation failed. Please try again.';
  static const String authenticationError =
      'Authentication failed. Please sign in again.';
  static const String permissionError =
      'Permission denied. Please grant required permissions.';

  // Storage Keys
  static const String userPreferencesKey = 'user_preferences';
  static const String translationCacheKey = 'translation_cache';
  static const String languageSettingsKey = 'language_settings';
  static const String themeSettingsKey = 'theme_settings';

  // Notification Channels
  static const String translationNotificationChannel =
      'translation_notifications';
  static const String messageNotificationChannel = 'message_notifications';
  static const String summaryNotificationChannel = 'summary_notifications';
}

// Language Detection Patterns and Cultural Context
class LanguagePatterns {
  static const Map<String, List<String>> slangPatterns = {
    'en': ['gonna', 'wanna', 'gotta', 'ain\'t', 'y\'all', 'sup', 'bro', 'dude'],
    'es': ['tío', 'guay', 'flipar', 'currar', 'mogollón', 'chaval', 'pijo'],
    'fr': ['mec', 'nana', 'bouquin', 'fringues', 'bosser', 'kiffer'],
    'de': ['krass', 'geil', 'chillen', 'checken', 'abfeiern', 'bock'],
    'it': ['figo', 'ganzo', 'figata', 'sbronza', 'casino', 'roba'],
  };

  static const Map<String, List<String>> formalPatterns = {
    'en': ['furthermore', 'nevertheless', 'consequently', 'therefore'],
    'es': ['sin embargo', 'no obstante', 'por consiguiente', 'por tanto'],
    'fr': ['néanmoins', 'cependant', 'par conséquent', 'toutefois'],
    'de': ['dennoch', 'allerdings', 'folglich', 'demzufolge'],
    'it': ['tuttavia', 'nondimeno', 'pertanto', 'quindi'],
  };

  // Emoji to sentiment mapping for cultural context
  static const Map<String, double> emojiSentiment = {
    '😀': 0.8,
    '😃': 0.9,
    '😄': 0.9,
    '😁': 0.8,
    '😆': 0.7,
    '😅': 0.6,
    '😂': 0.9,
    '🤣': 0.9,
    '😊': 0.8,
    '😇': 0.7,
    '😍': 0.9,
    '🥰': 0.9,
    '😘': 0.8,
    '😗': 0.6,
    '😙': 0.6,
    '😚': 0.6,
    '😋': 0.7,
    '😛': 0.6,
    '😝': 0.6,
    '😜': 0.6,
    '🤪': 0.6,
    '🤨': 0.0,
    '🧐': 0.0,
    '🤓': 0.5,
    '😎': 0.7,
    '🤩': 0.9,
    '🥳': 0.9,
    '😏': 0.3,
    '😒': -0.3,
    '😞': -0.5,
    '😔': -0.5,
    '😟': -0.4,
    '😕': -0.3,
    '🙁': -0.4,
    '☹️': -0.5,
    '😣': -0.4,
    '😖': -0.4,
    '😫': -0.5,
    '😩': -0.4,
    '🥺': -0.2,
    '😢': -0.6,
    '😭': -0.7,
    '😤': -0.3,
    '😠': -0.6,
    '😡': -0.8,
    '🤬': -0.9,
    '🤯': -0.2,
    '😳': 0.0,
    '🥵': -0.2,
    '🥶': -0.2,
    '😱': -0.4,
    '😨': -0.5,
    '😰': -0.4,
    '😥': -0.3,
    '😓': -0.2,
    '🤗': 0.8,
    '🤔': 0.0,
    '🤭': 0.3,
    '🤫': 0.0,
    '🤥': -0.2,
    '😶': 0.0,
    '😐': 0.0,
    '😑': -0.1,
    '😬': -0.2,
    '🙄': -0.3,
    '😯': 0.0,
    '😦': -0.2,
    '😧': -0.3,
    '😮': 0.1,
    '😲': 0.2,
    '🥱': -0.1,
    '😴': 0.0,
    '🤤': 0.0,
    '😪': -0.1,
    '😵': -0.3,
    '🤐': 0.0,
    '🥴': -0.2,
    '🤢': -0.4,
    '🤮': -0.6,
    '🤧': -0.2,
    '😷': -0.1,
    '🤒': -0.3,
    '🤕': -0.3,
    '🤑': 0.3,
    '🤠': 0.6,
  };
}

// Premium Subscription Tiers
enum SubscriptionTier {
  free,
  personal,
  team,
  enterprise,
}

// Translation Confidence Levels
enum TranslationConfidence {
  high, // > 90%
  medium, // 70-90%
  low, // 50-70%
  uncertain, // < 50%
}

// Supported Messaging Platforms
enum MessagingPlatform {
  whatsapp,
  telegram,
  slack,
  discord,
  teams,
  signal,
}

// Translation Modes
enum TranslationMode {
  realTime,
  privateFeed,
  overlay,
  summary,
}
