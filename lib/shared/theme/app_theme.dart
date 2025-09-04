// 🌐 LingoSphere - Theme Configuration
// Modern design system with accessibility and multi-platform support

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Brand Colors - LingoSphere Design System
  static const Color primaryBlue = Color(0xFF1C3D5A);
  static const Color vibrantGreen = Color(0xFF31C48D);
  static const Color accentTeal = Color(0xFF0891B2);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF10B981);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // Additional Brand Colors (for UI components)
  static const Color backgroundDark = gray900;
  static const Color twitterBlue = Color(0xFF1DA1F2);
  static const Color vibrantOrange = Color(0xFFFF6B35);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, accentTeal],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [vibrantGreen, successGreen],
  );

  // Typography Scale - Using system fonts for now
  static const String? primaryFontFamily = null; // Uses system default
  static const String? headingFontFamily = null; // Uses system default

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: primaryFontFamily,

    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      primaryContainer: gray100,
      secondary: vibrantGreen,
      secondaryContainer: Color(0xFFECFDF5),
      tertiary: accentTeal,
      tertiaryContainer: Color(0xFFECFEFF),
      error: errorRed,
      errorContainer: Color(0xFFFEF2F2),
      surface: white,
      surfaceContainer: gray50,
      surfaceContainerHigh: gray100,
      onPrimary: white,
      onPrimaryContainer: primaryBlue,
      onSecondary: white,
      onSecondaryContainer: Color(0xFF064E3B),
      onTertiary: white,
      onTertiaryContainer: Color(0xFF0F172A),
      onError: white,
      onErrorContainer: Color(0xFF7F1D1D),
      onSurface: gray900,
      onSurfaceVariant: gray600,
      outline: gray300,
      outlineVariant: gray200,
      scrim: Colors.black54,
    ),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: white,
      foregroundColor: gray900,
      elevation: 0,
      scrolledUnderElevation: 1,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: gray900,
      ),
      iconTheme: IconThemeData(color: gray700),
      actionsIconTheme: IconThemeData(color: gray700),
    ),

    // Text Theme
    textTheme: const TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: gray900,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: gray900,
        height: 1.3,
      ),
      displaySmall: TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: gray900,
        height: 1.3,
      ),

      // Headline styles
      headlineLarge: TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: gray900,
        height: 1.4,
      ),
      headlineMedium: TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: gray900,
        height: 1.4,
      ),
      headlineSmall: TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: gray900,
        height: 1.4,
      ),

      // Title styles
      titleLarge: TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: gray900,
        height: 1.5,
      ),
      titleMedium: TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: gray900,
        height: 1.5,
      ),
      titleSmall: TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: gray700,
        height: 1.5,
      ),

      // Body styles
      bodyLarge: TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: gray700,
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: gray700,
        height: 1.6,
      ),
      bodySmall: TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: gray600,
        height: 1.6,
      ),

      // Label styles
      labelLarge: TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: gray800,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: gray700,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: gray600,
        height: 1.4,
      ),
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontFamily: primaryFontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: vibrantGreen,
        foregroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontFamily: primaryFontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryBlue,
        side: const BorderSide(color: gray300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontFamily: primaryFontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontFamily: primaryFontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: gray50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: gray300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: gray300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorRed, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: gray500),
      labelStyle: const TextStyle(color: gray700),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: gray200),
      ),
      margin: EdgeInsets.zero,
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: white,
      elevation: 8,
      selectedItemColor: primaryBlue,
      unselectedItemColor: gray500,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: primaryFontFamily,
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
    ),

    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
    ),

    // Snack Bar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: gray800,
      contentTextStyle: const TextStyle(
        color: white,
        fontFamily: primaryFontFamily,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: gray100,
      selectedColor: primaryBlue,
      secondarySelectedColor: vibrantGreen,
      disabledColor: gray200,
      labelStyle: const TextStyle(
        fontFamily: primaryFontFamily,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: const TextStyle(
        color: white,
        fontFamily: primaryFontFamily,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: vibrantGreen,
      foregroundColor: white,
      elevation: 4,
      shape: CircleBorder(),
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryBlue,
      linearTrackColor: gray200,
      circularTrackColor: gray200,
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return vibrantGreen;
        }
        return gray400;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return vibrantGreen.withValues(alpha: 0.5);
        }
        return gray300;
      }),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: primaryFontFamily,

    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: vibrantGreen,
      primaryContainer: gray800,
      secondary: accentTeal,
      secondaryContainer: Color(0xFF064E3B),
      tertiary: Color(0xFF60A5FA),
      tertiaryContainer: Color(0xFF1E3A8A),
      error: Color(0xFFF87171),
      errorContainer: Color(0xFF7F1D1D),
      surface: gray900,
      surfaceContainer: gray800,
      surfaceContainerHigh: gray700,
      onPrimary: gray900,
      onPrimaryContainer: vibrantGreen,
      onSecondary: gray900,
      onSecondaryContainer: accentTeal,
      onTertiary: gray900,
      onTertiaryContainer: Color(0xFF93C5FD),
      onError: gray900,
      onErrorContainer: Color(0xFFFCA5A5),
      onSurface: gray100,
      onSurfaceVariant: gray400,
      outline: gray600,
      outlineVariant: gray700,
      scrim: Colors.black87,
    ),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: gray900,
      foregroundColor: gray100,
      elevation: 0,
      scrolledUnderElevation: 1,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: gray100,
      ),
      iconTheme: IconThemeData(color: gray300),
      actionsIconTheme: IconThemeData(color: gray300),
    ),

    // Override other theme properties for dark mode...
    // (Similar structure as light theme but with dark colors)
  );

  // Custom Color Extensions
  static const Color translationHighlight = Color(0xFFECFEFF);
  static const Color voiceRecording = Color(0xFFFEF3C7);
  static const Color aiInsight = Color(0xFFF3E8FF);
  static const Color sentimentPositive = Color(0xFFECFDF5);
  static const Color sentimentNegative = Color(0xFFFEF2F2);
  static const Color sentimentNeutral = Color(0xFFF9FAFB);

  // Platform-specific adaptations
  static SystemUiOverlayStyle getSystemUIOverlayStyle(bool isDark) {
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: isDark ? gray900 : white,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    );
  }
}

// Custom Text Styles for specific use cases
class AppTextStyles {
  static const TextStyle messageText = TextStyle(
    fontSize: 16,
    height: 1.4,
    fontFamily: AppTheme.primaryFontFamily,
  );

  static const TextStyle translationText = TextStyle(
    fontSize: 14,
    height: 1.4,
    fontStyle: FontStyle.italic,
    fontFamily: AppTheme.primaryFontFamily,
    color: AppTheme.gray600,
  );

  static const TextStyle confidenceScore = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    fontFamily: AppTheme.primaryFontFamily,
  );

  static const TextStyle languageTag = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    fontFamily: AppTheme.primaryFontFamily,
    letterSpacing: 0.5,
  );

  static const TextStyle timestamp = TextStyle(
    fontSize: 11,
    color: AppTheme.gray500,
    fontFamily: AppTheme.primaryFontFamily,
  );
}
