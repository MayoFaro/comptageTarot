import 'package:flutter/material.dart';

/// Palette inspirée des couleurs des cartes d'atout du Tarot : vert et
/// bordeaux, déclinés sur l'ensemble de l'appli pour sortir du blanc pur.
const Color vertAtout = Color(0xFF1B4D3E);
const Color bordeaux = Color(0xFF7A1F2B);
const Color _ivoire = Color(0xFFF7F3EA);
const Color _bordeauxPale = Color(0xFFF0D9DC);

// Famille de surfaces teintées vert sauge — remplace les tons quasi-blancs
// que `ColorScheme.fromSeed` génère par défaut pour un thème clair.
const Color _surface = Color(0xFFE9F0E7);
const Color _surfaceContainerLowest = Color(0xFFF2F6F1);
const Color _surfaceContainerLow = Color(0xFFE3EBE1);
const Color _surfaceContainer = Color(0xFFDCE6DA);
const Color _surfaceContainerHigh = Color(0xFFD3E0D1);
const Color _surfaceContainerHighest = Color(0xFFC9DAC6);
const Color _onSurface = Color(0xFF1B2B20);

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: vertAtout,
    brightness: Brightness.light,
  ).copyWith(
    secondary: bordeaux,
    onSecondary: _ivoire,
    secondaryContainer: _bordeauxPale,
    onSecondaryContainer: bordeaux,
    surface: _surface,
    onSurface: _onSurface,
    surfaceContainerLowest: _surfaceContainerLowest,
    surfaceContainerLow: _surfaceContainerLow,
    surfaceContainer: _surfaceContainer,
    surfaceContainerHigh: _surfaceContainerHigh,
    surfaceContainerHighest: _surfaceContainerHighest,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.secondary,
      foregroundColor: colorScheme.onSecondary,
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: colorScheme.surfaceContainerHigh,
      selectedColor: colorScheme.secondaryContainer,
      labelStyle: TextStyle(color: colorScheme.onSurface),
      side: BorderSide(color: colorScheme.outlineVariant),
    ),
  );
}
