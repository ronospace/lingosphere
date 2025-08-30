// 🌐 LingoSphere - Translation Service Tests
// Comprehensive unit testing for translation functionality

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import '../lib/core/services/translation_service.dart';
import '../lib/core/constants/app_constants.dart';
import '../lib/core/exceptions/translation_exceptions.dart';

@GenerateMocks([Dio])
import 'translation_service_test.mocks.dart';

void main() {
  group('TranslationService', () {
    late TranslationService translationService;
    late MockDio mockDio;

    setUp(() {
      translationService = TranslationService();
      mockDio = MockDio();
    });

    test('should initialize successfully', () async {
      // Act
      await translationService.initialize(
        googleApiKey: 'test_google_key',
        deepLApiKey: 'test_deepl_key',
        openAIApiKey: 'test_openai_key',
      );

      // Assert
      expect(translationService, isNotNull);
    });

    test('should throw exception for empty text', () async {
      // Act & Assert
      expect(
        () => translationService.translate(
          text: '',
          targetLanguage: 'es',
        ),
        throwsA(isA<TranslationException>()),
      );
    });

    test('should throw exception for text too long', () async {
      // Arrange
      final longText = 'a' * (AppConstants.maxTranslationLength + 1);

      // Act & Assert
      expect(
        () => translationService.translate(
          text: longText,
          targetLanguage: 'es',
        ),
        throwsA(isA<TranslationException>()),
      );
    });

    test('should detect language correctly', () async {
      // Arrange
      const text = "Hello, how are you?";

      // Act
      final detectedLanguage = await translationService.detectLanguage(text);

      // Assert
      expect(detectedLanguage, isNotNull);
      expect(detectedLanguage, isA<String>());
    });

    test('should return same text for same source and target language', () async {
      // Arrange
      const text = "Hello world";
      const language = "en";

      // Act
      final result = await translationService.translate(
        text: text,
        targetLanguage: language,
        sourceLanguage: language,
      );

      // Assert
      expect(result.originalText, equals(text));
      expect(result.translatedText, equals(text));
      expect(result.sourceLanguage, equals(language));
      expect(result.targetLanguage, equals(language));
    });

    test('should handle translation caching', () async {
      // Arrange
      const text = "Hello";
      const targetLanguage = "es";

      // Act - First translation
      final result1 = await translationService.translate(
        text: text,
        targetLanguage: targetLanguage,
      );

      // Act - Second translation (should use cache)
      final result2 = await translationService.translate(
        text: text,
        targetLanguage: targetLanguage,
      );

      // Assert
      expect(result1.originalText, equals(result2.originalText));
      expect(result1.translatedText, equals(result2.translatedText));
    });

    test('should clear cache correctly', () {
      // Act
      translationService.clearCache();

      // Assert
      final stats = translationService.getCacheStats();
      expect(stats['total_entries'], equals(0));
    });

    test('should analyze sentiment correctly', () async {
      // Arrange
      const positiveText = "I love this amazing app! 😍";
      const negativeText = "This is terrible and awful 😢";
      const neutralText = "This is a regular message.";

      // Act
      final result1 = await translationService.translate(
        text: positiveText,
        targetLanguage: 'es',
      );
      
      final result2 = await translationService.translate(
        text: negativeText,
        targetLanguage: 'es',
      );
      
      final result3 = await translationService.translate(
        text: neutralText,
        targetLanguage: 'es',
      );

      // Assert
      expect(result1.sentiment.sentiment.toString(), contains('positive'));
      expect(result2.sentiment.sentiment.toString(), contains('negative'));
      expect(result3.sentiment.sentiment.toString(), contains('neutral'));
    });

    test('should handle batch translation', () async {
      // Arrange
      final texts = ['Hello', 'World', 'Test'];
      const targetLanguage = 'es';

      // Act
      final results = await translationService.translateBatch(
        texts: texts,
        targetLanguage: targetLanguage,
      );

      // Assert
      expect(results.length, equals(texts.length));
      for (int i = 0; i < results.length; i++) {
        expect(results[i].originalText, equals(texts[i]));
        expect(results[i].targetLanguage, equals(targetLanguage));
      }
    });

    test('should provide cache statistics', () {
      // Act
      final stats = translationService.getCacheStats();

      // Assert
      expect(stats, isNotNull);
      expect(stats, containsPair('total_entries', isA<int>()));
      expect(stats, containsPair('valid_entries', isA<int>()));
      expect(stats, containsPair('expired_entries', isA<int>()));
      expect(stats, containsPair('cache_hit_ratio', isA<num>()));
    });

    tearDown(() {
      translationService.dispose();
    });
  });

  group('Language Detection', () {
    late TranslationService translationService;

    setUp(() {
      translationService = TranslationService();
    });

    test('should detect English correctly', () async {
      // Arrange
      const englishText = "Hello, how are you doing today?";

      // Act
      final result = await translationService.detectLanguage(englishText);

      // Assert
      expect(result, equals('en'));
    });

    test('should fallback to default language for unknown text', () async {
      // Arrange
      const unknownText = "xyz123!@#";

      // Act
      final result = await translationService.detectLanguage(unknownText);

      // Assert
      expect(result, equals(AppConstants.defaultSourceLanguage));
    });

    tearDown(() {
      translationService.dispose();
    });
  });

  group('Context Analysis', () {
    late TranslationService translationService;

    setUp(() {
      translationService = TranslationService();
    });

    test('should detect formal language patterns', () async {
      // Arrange
      const formalText = "Furthermore, I would like to discuss the consequences of this decision.";

      // Act
      final result = await translationService.translate(
        text: formalText,
        targetLanguage: 'es',
      );

      // Assert
      expect(result.context.formality.toString(), contains('formal'));
    });

    test('should detect informal language patterns', () async {
      // Arrange
      const informalText = "Hey dude, gonna hang out later? This is totally awesome!";

      // Act
      final result = await translationService.translate(
        text: informalText,
        targetLanguage: 'es',
      );

      // Assert
      expect(result.context.formality.toString(), contains('informal'));
    });

    test('should detect business domain', () async {
      // Arrange
      const businessText = "We need to discuss the project deadline with our client for revenue optimization.";

      // Act
      final result = await translationService.translate(
        text: businessText,
        targetLanguage: 'es',
      );

      // Assert
      expect(result.context.domain.toString(), contains('business'));
    });

    tearDown(() {
      translationService.dispose();
    });
  });
}
