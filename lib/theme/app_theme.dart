import 'package:flutter/material.dart';

/// Palette inspirée des couleurs des cartes d'atout du Tarot : vert et
/// bordeaux, déclinés sur l'ensemble de l'appli. Aucune autre teinte
/// n'apparaît nulle part (y compris `tertiary`, neutralisé ci-dessous) —
/// une seule couleur de sélection (vert) est utilisée partout.
const Color vertAtout = Color(0xFF1B4D3E);
const Color bordeaux = Color(0xFF7A1F2B);
const Color _ivoire = Color(0xFFF7F3EA);
const Color _bordeauxPale = Color(0xFFF0D9DC);

// Famille de surfaces teintées vert sauge, nettement visible (pas un blanc
// cassé à quelques % près) — remplace les tons quasi-blancs que
// `ColorScheme.fromSeed` génère par défaut pour un thème clair.
const Color _surface = Color(0xFFD7E6D2);
const Color _surfaceContainerLowest = Color(0xFFE3EEDF);
const Color _surfaceContainerLow = Color(0xFFCFE0C9);
const Color _surfaceContainer = Color(0xFFC4D8BE);
const Color _surfaceContainerHigh = Color(0xFFB8CEB1);
const Color _surfaceContainerHighest = Color(0xFFACC5A4);
const Color _onSurface = Color(0xFF16241B);

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: vertAtout,
    brightness: Brightness.light,
  ).copyWith(
    secondary: bordeaux,
    onSecondary: _ivoire,
    secondaryContainer: _bordeauxPale,
    onSecondaryContainer: bordeaux,
    // Le tertiary auto-généré par Material3 tourne la teinte de la seed de
    // +60°, ce qui tombe dans le bleu pour une seed verte — on l'aligne sur
    // le bordeaux pour qu'aucune couleur hors palette n'apparaisse jamais.
    tertiary: bordeaux,
    onTertiary: _ivoire,
    tertiaryContainer: _bordeauxPale,
    onTertiaryContainer: bordeaux,
    surface: _surface,
    onSurface: _onSurface,
    surfaceContainerLowest: _surfaceContainerLowest,
    surfaceContainerLow: _surfaceContainerLow,
    surfaceContainer: _surfaceContainer,
    surfaceContainerHigh: _surfaceContainerHigh,
    surfaceContainerHighest: _surfaceContainerHighest,
  );

  // Couleur de sélection unique (vert), utilisée pour tout composant à état
  // sélectionné/coché : chips, boutons segmentés, tuiles de contrat.
  final selectionStyle = ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected)
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHigh),
    foregroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected)
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface),
    side: WidgetStatePropertyAll(BorderSide(color: colorScheme.outlineVariant)),
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
    dialogTheme: DialogThemeData(
      backgroundColor: colorScheme.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: colorScheme.surfaceContainerHigh,
      selectedColor: colorScheme.primaryContainer,
      labelStyle: TextStyle(color: colorScheme.onSurface),
      side: BorderSide(color: colorScheme.outlineVariant),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(style: selectionStyle),
  );
}
