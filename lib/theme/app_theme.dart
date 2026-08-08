import 'package:flutter/material.dart';

/// Palette inspirée des couleurs des cartes d'atout du Tarot : vert et
/// bordeaux, déclinés sur l'ensemble de l'appli pour sortir du blanc pur.
const Color vertAtout = Color(0xFF1B4D3E);
const Color bordeaux = Color(0xFF7A1F2B);
const Color _ivoire = Color(0xFFF7F3EA);
const Color _bordeauxPale = Color(0xFFF0D9DC);

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: vertAtout,
    brightness: Brightness.light,
  ).copyWith(
    secondary: bordeaux,
    onSecondary: _ivoire,
    secondaryContainer: _bordeauxPale,
    onSecondaryContainer: bordeaux,
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
    chipTheme: ChipThemeData(
      selectedColor: colorScheme.secondaryContainer,
      labelStyle: TextStyle(color: colorScheme.onSurface),
      side: BorderSide(color: colorScheme.outlineVariant),
    ),
  );
}
