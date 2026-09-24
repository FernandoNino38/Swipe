import 'package:flutter/material.dart';

/// Define o tema visual estritamente alinhado com o Material Design 3 (M3) Expressive.
/// Incorpora Dynamic Color (Material You), tipografia de alto contraste para sobreposição
/// de fotos e formas orgânicas com raios pronunciados (28dp a 32dp).
class M3ExpressiveTheme {
  // Cores de fallback caso o dispositivo não suporte Dynamic Color (Android < 12 ou Desktop)
  static const Color defaultSeedColor = Color(0xFF6750A4);
  static const Color positiveActionColor = Color(0xFF2E7D32); // Manter (Verde M3)
  static const Color negativeActionColor = Color(0xFFB3261E); // Excluir (Vermelho M3)
  static const Color accentWarningColor = Color(0xFFF57C00); // Mover/Atenção (Laranja M3)

  // Raios expressivos M3
  static const double cardBorderRadius = 32.0;
  static const double pillBorderRadius = 24.0;
  static const double chipBorderRadius = 16.0;
  static const double sheetBorderRadius = 28.0;

  /// Constrói o ThemeData com suporte a Dynamic Color
  static ThemeData buildTheme({
    ColorScheme? dynamicColorScheme,
    Brightness brightness = Brightness.light,
  }) {
    final baseColorScheme = dynamicColorScheme ??
        ColorScheme.fromSeed(
          seedColor: defaultSeedColor,
          brightness: brightness,
        );

    // Ajusta o ColorScheme para expressividade e contraste
    final colorScheme = baseColorScheme.copyWith(
      surfaceContainerLowest: brightness == Brightness.dark
          ? const Color(0xFF0F0F13)
          : const Color(0xFFFFFFFF),
      surfaceContainerLow: brightness == Brightness.dark
          ? const Color(0xFF1B1B20)
          : const Color(0xFFF7F2FA),
      surfaceContainer: brightness == Brightness.dark
          ? const Color(0xFF212026)
          : const Color(0xFFF3EDF7),
      surfaceContainerHigh: brightness == Brightness.dark
          ? const Color(0xFF2C2A31)
          : const Color(0xFFECE6F0),
      surfaceContainerHighest: brightness == Brightness.dark
          ? const Color(0xFF37343C)
          : const Color(0xFFE6E0E9),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,

      // Tipografia M3 Expressiva com legibilidade aprimorada
      textTheme: _buildExpressiveTextTheme(colorScheme),

      // Cartões com raios orgânicos expressivos
      cardTheme: CardThemeData(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardBorderRadius),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
      ),

      // Botões de ação flutuante (FAB) M3 Expressive
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(pillBorderRadius),
        ),
        elevation: 3.0,
        highlightElevation: 6.0,
      ),

      // Chips de Ação Rápida
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(chipBorderRadius),
        ),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // Diálogos e Bottom Sheets Expressivos
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sheetBorderRadius),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(sheetBorderRadius),
          ),
        ),
      ),

      // Efeito de ondulação (Ripple) elástico e fluido
      splashFactory: InkSparkle.splashFactory,
    );
  }

  static TextTheme _buildExpressiveTextTheme(ColorScheme colorScheme) {
    return const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
    );
  }
}
