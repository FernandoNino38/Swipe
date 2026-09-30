import 'package:flutter/material.dart';

/// Define o tema visual do aplicativo Swipe com base nas diretrizes Material 3 Expressive,
/// geometria orgânica squircle, cores de alta legibilidade
/// (Blue, Emerald Mint, Coral Red, Rose Pink) e superfícies AMOLED translúcidas.
class M3ExpressiveTheme {
  // Paleta de Cores Signature do Swipe
  static const Color oneUiBlue = Color(0xFF0072DE); // Electric Blue
  static const Color oneUiMint = Color(0xFF2AC06D); // Emerald Mint (Manter)
  static const Color oneUiCoral = Color(0xFFFA5252); // Coral Red (Excluir)
  static const Color oneUiRose = Color(0xFFFF3366); // Rose Pink (Favorito)
  static const Color oneUiAmber = Color(0xFFFF922B); // Amber
  static const Color oneUiPurple = Color(0xFF7952B3); // Warm Violet

  // Fallbacks e compatibilidade de constantes existentes
  static const Color defaultSeedColor = oneUiBlue;
  static const Color positiveActionColor = oneUiMint;
  static const Color negativeActionColor = oneUiCoral;
  static const Color accentWarningColor = oneUiAmber;

  // Raios de Formas M3 Expressive (Pill, Squircle e Rounded Containers)
  static const double cardBorderRadius = 28.0;
  static const double capsuleRadius = 32.0;
  static const double pillBorderRadius = 24.0;
  static const double chipBorderRadius = 16.0;
  static const double sheetBorderRadius = 28.0;

  // Curvas de Movimento Oficiais do Material 3 Expressive
  // Emphasized (padrão expressivo com overshoot/deceleração orgânica)
  static const Curve motionEmphasized = Curves.easeInOutCubicEmphasized;
  // Emphasized Decelerate (entradas, expansões e desfechos)
  static const Curve motionEmphasizedDecelerate = Curves.easeOutCubic;
  // Emphasized Accelerate (saídas rápidas de tela e dispensas)
  static const Curve motionEmphasizedAccelerate = Curves.easeInCubic;
  // Expressive Spring Bounce (toques, press e feedbacks táteis)
  static const Curve motionSpring = Curves.easeOutBack;

  // Durações de Movimento M3 Expressive
  static const Duration motionDurationShort = Duration(milliseconds: 150);
  static const Duration motionDurationMedium = Duration(milliseconds: 300);
  static const Duration motionDurationLong = Duration(milliseconds: 450);

  // Superfícies do Swipe M3 Expressive
  static const Color lightScaffold = Color(0xFFF6F8FC);
  static const Color lightCardSurface = Color(0xFFFFFFFF);
  static const Color darkScaffold = Color(0xFF0F1218);
  static const Color darkCardSurface = Color(0xFF181C26);

  /// Constrói o ThemeData Expressive
  static ThemeData buildTheme({
    ColorScheme? dynamicColorScheme,
    Brightness brightness = Brightness.light,
  }) {
    final isDark = brightness == Brightness.dark;

    final baseColorScheme = dynamicColorScheme ??
        ColorScheme.fromSeed(
          seedColor: oneUiBlue,
          brightness: brightness,
        );

    final colorScheme = baseColorScheme.copyWith(
      primary: isDark ? const Color(0xFF388BFD) : oneUiBlue,
      onPrimary: Colors.white,
      primaryContainer: isDark ? const Color(0xFF0D3868) : const Color(0xFFE3F0FF),
      onPrimaryContainer: isDark ? const Color(0xFFD0E6FF) : const Color(0xFF004085),

      secondary: isDark ? const Color(0xFF4DD0E1) : const Color(0xFF0288D1),
      onSecondary: Colors.white,
      secondaryContainer: isDark ? const Color(0xFF133842) : const Color(0xFFE1F5FE),
      onSecondaryContainer: isDark ? const Color(0xFFB2EBF2) : const Color(0xFF01579B),

      surface: isDark ? darkScaffold : lightScaffold,
      onSurface: isDark ? const Color(0xFFF0F3F8) : const Color(0xFF1C1E23),
      onSurfaceVariant: isDark ? const Color(0xFFA0A6B5) : const Color(0xFF5F6575),

      surfaceContainerLowest: isDark ? const Color(0xFF060709) : const Color(0xFFFFFFFF),
      surfaceContainerLow: isDark ? const Color(0xFF10131A) : const Color(0xFFF7F8FC),
      surfaceContainer: isDark ? darkCardSurface : lightCardSurface,
      surfaceContainerHigh: isDark ? const Color(0xFF202430) : const Color(0xFFECEEF5),
      surfaceContainerHighest: isDark ? const Color(0xFF2B3040) : const Color(0xFFE2E5F0),

      outline: isDark ? const Color(0xFF3D4455) : const Color(0xFFCFD5E2),
      outlineVariant: isDark ? const Color(0xFF252B37) : const Color(0xFFE4E7F0),

      error: isDark ? const Color(0xFFFF6B6B) : oneUiCoral,
      errorContainer: isDark ? const Color(0xFF4A1515) : const Color(0xFFFFE8E8),
      onErrorContainer: isDark ? const Color(0xFFFFD2D2) : const Color(0xFF8B1212),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? darkScaffold : lightScaffold,

      // Tipografia expressiva com legibilidade em grandes cabeçalhos
      textTheme: _buildOneUiTextTheme(colorScheme),

      // AppBar limpa e transparente com título expressivo
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? darkScaffold : lightScaffold,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),

      // Cartões M3 Expressive (Superfícies tonais sem bordas duras artificiais)
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? colorScheme.surfaceContainerHigh : colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardBorderRadius),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
      ),

      // Botões arredondados confortáveis
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(pillBorderRadius),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        ),
      ),

      // Chips com alto contraste, contornos nítidos e feedback tátil
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(chipBorderRadius),
          side: BorderSide(
            color: isDark ? const Color(0xFF38435C) : const Color(0xFFCCD4E3),
            width: 1.0,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF222838) : const Color(0xFFEFF2F8),
        selectedColor: colorScheme.primary,
        secondarySelectedColor: colorScheme.primary,
        checkmarkColor: Colors.white,
        iconTheme: IconThemeData(
          size: 16,
          color: isDark ? const Color(0xFFE2E7F5) : const Color(0xFF1E2533),
        ),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: isDark ? const Color(0xFFE2E7F5) : const Color(0xFF1E2533),
        ),
        secondaryLabelStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 13,
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // Diálogos e Bottom Sheets
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? const Color(0xFF1B1E28) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sheetBorderRadius),
        ),
        elevation: 8,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? const Color(0xFF161922) : Colors.white,
        modalBackgroundColor: isDark ? const Color(0xFF161922) : Colors.white,
        elevation: 12,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(sheetBorderRadius),
          ),
        ),
        dragHandleColor: isDark ? const Color(0xFF4E5568) : const Color(0xFFCFD5E2),
      ),

      // Efeito de ondulação (Ripple) elástico e fluido
      splashFactory: InkSparkle.splashFactory,
    );
  }

  static TextTheme _buildOneUiTextTheme(ColorScheme colorScheme) {
    return const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
      ),
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleLarge: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
      ),
      bodyMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
