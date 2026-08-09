import 'package:flutter/material.dart';

/// Palette inspirée des couleurs des cartes d'atout du Tarot : vert et
/// bordeaux, déclinés sur l'ensemble de l'appli. Aucune autre teinte
/// n'apparaît nulle part (y compris `tertiary`, neutralisé ci-dessous).
const Color vertAtout = Color(0xFF1B4D3E);
const Color bordeaux = Color(0xFF7A1F2B);
const Color _ivoire = Color(0xFFF7F3EA);
const Color _bordeauxPale = Color(0xFFF0D9DC);

// Couleur de sélection unique, en dur (pas recalculée depuis la seed à
// chaque build, pour ne jamais changer par accident) : c'est le
// primaryContainer que Material3 générait déjà pour la seed vert foncé —
// un mint/turquoise clair — désormais utilisé pour TOUT composant
// sélectionné (chips, boutons segmentés, tuiles de contrat), systématiquement
// accompagné d'un liseré noir.
const Color selectionFill = Color(0xFFA4F2D6);
const Color onSelectionFill = Color(0xFF002117);
const BorderSide selectionBorder = BorderSide(color: Colors.black, width: 2);

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
    // primary/primaryContainer restent dérivés de la seed pour les usages
    // "identité" (AppBar, avatars) — la sélection utilise `selectionFill`
    // ci-dessus, fixé en dur, pas ces tons auto-générés.
    surface: _surface,
    onSurface: _onSurface,
    surfaceContainerLowest: _surfaceContainerLowest,
    surfaceContainerLow: _surfaceContainerLow,
    surfaceContainer: _surfaceContainer,
    surfaceContainerHigh: _surfaceContainerHigh,
    surfaceContainerHighest: _surfaceContainerHighest,
  );

  // Style de sélection unique, appliqué à tous les `SegmentedButton` de
  // l'appli (bouts, petit au bout, poignée, camps de poignée...) : fond vert
  // fixe + liseré noir à l'état sélectionné, identique aux chips et aux
  // tuiles de contrat.
  final selectionStyle = ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected) ? selectionFill : colorScheme.surfaceContainerHigh),
    foregroundColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected) ? onSelectionFill : colorScheme.onSurface),
    side: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected)
        ? selectionBorder
        : BorderSide(color: colorScheme.outlineVariant)),
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
      selectedColor: selectionFill,
      labelStyle: TextStyle(color: colorScheme.onSurface),
      side: BorderSide(color: colorScheme.outlineVariant),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(style: selectionStyle),
  );
}
