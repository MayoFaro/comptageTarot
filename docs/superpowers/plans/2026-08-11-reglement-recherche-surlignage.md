# Surlignage et navigation multi-occurrences — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Surligner toutes les occurrences du terme cherché dans l'écran Règlement, et permettre de naviguer (précédent/suivant, avec compteur) entre toutes les sections qui en contiennent au moins une.

**Architecture:** Une normalisation accents/casse "avec suivi de position" localise les occurrences dans le texte original de chaque section ; ces positions servent à encadrer chaque occurrence de marqueurs Unicode invisibles avant de passer le markdown à `MarkdownBody` ; une syntaxe inline + un builder `flutter_markdown_plus` personnalisés transforment ces marqueurs en texte surligné. `RulesScreen` garde la liste ordonnée des sections correspondantes et un pointeur de navigation dedans.

**Tech Stack:** Flutter/Dart, `flutter_markdown_plus` (déjà en dépendance), `markdown` (dépendance transitive à déclarer explicitement — requis par le lint `depend_on_referenced_packages` de `flutter_lints`, déjà actif dans `analysis_options.yaml`).

## Global Constraints

- Comparaison de texte insensible aux accents et à la casse, sous-chaîne exacte (pas de recherche floue) — inchangé par rapport à l'existant.
- Le surlignage réutilise exactement `selectionFill`/`onSelectionFill` de `lib/theme/app_theme.dart` — pas de nouvelle couleur hors palette.
- La navigation précédent/suivant se fait au niveau **section**, pas occurrence par occurrence (décision explicite du design, voir hors-périmètre du spec).
- Le seuil de déclenchement de la recherche reste 2 caractères minimum (comportement live inchangé).
- Aux extrémités de la liste de résultats, la navigation boucle (après le dernier résultat, "suivant" revient au premier ; l'inverse pour "précédent").
- 0 résultat : comportement actuel conservé (message "Aucun résultat pour « terme »", ni compteur ni flèches).
- Marqueurs de surlignage : `U+E000` (ouverture) / `U+E001` (fermeture), zone privée Unicode, jamais présents dans un texte français normal.

---

## File Structure

- `lib/utils/recherche_texte.dart` — modifié : ajoute la normalisation avec positions, `indexesSectionsCorrespondantes` (remplace `indexPremiereSectionCorrespondante`), `PlageSurlignage`, `plagesCorrespondantes`, `texteAvecMarqueurs`, les constantes de marqueurs.
- `lib/widgets/markdown_surlignage.dart` — créé : syntaxe inline + builder `flutter_markdown_plus` qui transforment les marqueurs en texte surligné.
- `lib/screens/rules_screen.dart` — modifié : état de navigation (liste des sections correspondantes + pointeur courant), UI compteur/flèches, rendu des sections avec surlignage.
- `test/utils/recherche_texte_test.dart` — modifié : tests des nouvelles fonctions, suppression des tests de la fonction retirée.
- `test/widgets/markdown_surlignage_test.dart` — créé.
- `test/screens/rules_screen_test.dart` — modifié : nouveaux tests compteur/navigation/surlignage, tests existants conservés.

---

### Task 1: Recherche multi-occurrences avec positions

**Files:**
- Modify: `lib/utils/recherche_texte.dart`
- Test: `test/utils/recherche_texte_test.dart`

**Interfaces:**
- Consumes: `SectionReglement` (`lib/models/section_reglement.dart`, inchangé : `titre`, `corps`, `texteComplet`).
- Produces : `String retirerAccents(String texte)` (signature inchangée), `final String marqueurOuverture`, `final String marqueurFermeture`, `class PlageSurlignage { final int debut; final int fin; }`, `List<int> indexesSectionsCorrespondantes(List<SectionReglement> sections, String terme)`, `List<PlageSurlignage> plagesCorrespondantes(String texte, String terme)`, `String texteAvecMarqueurs(String texte, List<PlageSurlignage> plages)`. Supprime `indexPremiereSectionCorrespondante` (remplacée).

- [ ] **Step 1: Réécrire le fichier de test avec les nouveaux cas**

Remplacer entièrement `test/utils/recherche_texte_test.dart` par :

```dart
import 'package:comptage_tarot/models/section_reglement.dart';
import 'package:comptage_tarot/utils/recherche_texte.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('retirerAccents normalise les caractères accentués et la casse', () {
    expect(retirerAccents('Écart'), 'ecart');
    expect(retirerAccents('DÉFENSE'), 'defense');
    expect(retirerAccents('Petit au Bout'), 'petit au bout');
  });

  group('indexesSectionsCorrespondantes', () {
    final sections = [
      const SectionReglement(
        titre: 'Les enchères',
        corps: 'Le joueur place a droite du donneur parle le premier.',
      ),
      const SectionReglement(
        titre: 'Le chelem',
        corps: 'Reussir le CHELEM, cest gagner toutes les levees.',
      ),
      const SectionReglement(
        titre: 'Le jeu à 5 joueurs',
        corps: 'Le mort procede a la distribution, et le CHELEM aussi.',
      ),
    ];

    test("retourne toutes les sections correspondantes, dans l'ordre du document", () {
      expect(indexesSectionsCorrespondantes(sections, 'CHELEM'), [1, 2]);
      expect(indexesSectionsCorrespondantes(sections, 'enchères'), [0]);
    });

    test('retourne une liste vide si aucune section ne correspond', () {
      expect(indexesSectionsCorrespondantes(sections, 'xyzabc'), isEmpty);
    });
  });

  group('plagesCorrespondantes', () {
    test('trouve toutes les occurrences, insensible aux accents et à la casse', () {
      final plages = plagesCorrespondantes('Le Petit et le petit sont différents', 'petit');
      expect(plages, hasLength(2));
      expect(plages[0].debut, 3);
      expect(plages[0].fin, 8);
      expect(plages[1].debut, 15);
      expect(plages[1].fin, 20);
    });

    test('gère un caractère qui se déplie (œ -> oe) sans décaler les positions', () {
      final plages = plagesCorrespondantes('Cœur', 'coeur');
      expect(plages, hasLength(1));
      expect(plages.single.debut, 0);
      expect(plages.single.fin, 4);
    });

    test('retourne une liste vide si le terme est vide ou absent', () {
      expect(plagesCorrespondantes('un texte', ''), isEmpty);
      expect(plagesCorrespondantes('un texte', 'absent'), isEmpty);
    });
  });

  group('texteAvecMarqueurs', () {
    test('encadre chaque occurrence des marqueurs', () {
      final resultat = texteAvecMarqueurs('Le Petit au Bout', [const PlageSurlignage(3, 8)]);
      expect(resultat, 'Le ${marqueurOuverture}Petit${marqueurFermeture} au Bout');
    });

    test("ne modifie pas le texte en l'absence de plage", () {
      expect(texteAvecMarqueurs('Le Petit au Bout', []), 'Le Petit au Bout');
    });
  });
}
```

- [ ] **Step 2: Lancer les tests pour vérifier qu'ils échouent**

Run: `flutter test test/utils/recherche_texte_test.dart`
Expected: FAIL — `indexesSectionsCorrespondantes`, `plagesCorrespondantes`, `texteAvecMarqueurs`, `PlageSurlignage`, `marqueurOuverture`, `marqueurFermeture` n'existent pas encore.

- [ ] **Step 3: Réécrire l'implémentation**

Remplacer entièrement `lib/utils/recherche_texte.dart` par :

```dart
import '../models/section_reglement.dart';

const Map<String, String> _accents = {
  'à': 'a', 'â': 'a', 'ä': 'a',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'î': 'i', 'ï': 'i',
  'ô': 'o', 'ö': 'o',
  'ù': 'u', 'û': 'u', 'ü': 'u',
  'ç': 'c',
  'œ': 'oe',
};

/// Marqueurs invisibles (zone privée Unicode, U+E000/U+E001) utilisés pour
/// délimiter une occurrence à surligner dans le markdown source d'une
/// section, avant de le donner à `MarkdownBody` (voir
/// `lib/widgets/markdown_surlignage.dart`). Construits via `fromCharCode`
/// plutôt qu'en tant que littéraux : ce sont des caractères non imprimables,
/// les garder comme code évite qu'un éditeur ou un outil de diff les altère
/// silencieusement dans le fichier source. Étant dans la zone privée, ces
/// points de code n'ont par définition aucune signification standard et ne
/// peuvent pas entrer en collision avec un caractère du règlement.
final String marqueurOuverture = String.fromCharCode(0xE000);
final String marqueurFermeture = String.fromCharCode(0xE001);

class TexteNormaliseAvecPositions {
  const TexteNormaliseAvecPositions(this.normalise, this._indexOriginaux);

  final String normalise;
  final List<int> _indexOriginaux;

  int indexOriginalDebut(int indexNormalise) => _indexOriginaux[indexNormalise];

  int indexOriginalFin(int indexNormaliseExclusif) =>
      _indexOriginaux[indexNormaliseExclusif - 1] + 1;
}

/// Normalise `texte` (minuscule, accents retirés) en conservant, pour
/// chaque caractère du résultat, l'indice du caractère d'origine dont il
/// provient. Nécessaire car certains caractères se déplient en plusieurs
/// caractères (`œ` -> `oe`), ce qui décalerait les indices si on ne les
/// suivait pas explicitement. Suppose que `texte` ne contient pas de
/// caractères en dehors du plan multilingue de base (vrai pour le
/// règlement, en français).
TexteNormaliseAvecPositions normaliserAvecPositions(String texte) {
  final normaliseBuffer = StringBuffer();
  final indexOriginaux = <int>[];

  for (var indexOriginal = 0; indexOriginal < texte.length; indexOriginal++) {
    final minuscule = texte[indexOriginal].toLowerCase();
    final remplace = _accents[minuscule] ?? minuscule;
    normaliseBuffer.write(remplace);
    for (var i = 0; i < remplace.length; i++) {
      indexOriginaux.add(indexOriginal);
    }
  }

  return TexteNormaliseAvecPositions(normaliseBuffer.toString(), indexOriginaux);
}

String retirerAccents(String texte) => normaliserAvecPositions(texte).normalise;

/// Sections (dans l'ordre du document) dont le titre ou le corps contient
/// `terme`, comparaison insensible aux accents et à la casse.
List<int> indexesSectionsCorrespondantes(
  List<SectionReglement> sections,
  String terme,
) {
  final termeNormalise = retirerAccents(terme.trim());
  if (termeNormalise.isEmpty) return [];

  final resultats = <int>[];
  for (var i = 0; i < sections.length; i++) {
    if (retirerAccents(sections[i].texteComplet).contains(termeNormalise)) {
      resultats.add(i);
    }
  }
  return resultats;
}

class PlageSurlignage {
  const PlageSurlignage(this.debut, this.fin);

  /// Indice de début (inclusif) dans le texte original.
  final int debut;

  /// Indice de fin (exclusif) dans le texte original.
  final int fin;
}

/// Bornes, dans `texte` (indices d'origine), de toutes les occurrences de
/// `terme`, comparaison insensible aux accents et à la casse. Occurrences
/// non chevauchantes, dans l'ordre d'apparition.
List<PlageSurlignage> plagesCorrespondantes(String texte, String terme) {
  final termeNormalise = retirerAccents(terme.trim());
  if (termeNormalise.isEmpty) return [];

  final texteNormalise = normaliserAvecPositions(texte);
  final plages = <PlageSurlignage>[];
  var indexRecherche = 0;
  while (true) {
    final indexTrouve = texteNormalise.normalise.indexOf(termeNormalise, indexRecherche);
    if (indexTrouve == -1) break;
    final debut = texteNormalise.indexOriginalDebut(indexTrouve);
    final fin = texteNormalise.indexOriginalFin(indexTrouve + termeNormalise.length);
    plages.add(PlageSurlignage(debut, fin));
    indexRecherche = indexTrouve + termeNormalise.length;
  }
  return plages;
}

/// Encadre chaque `plage` de `texte` avec `marqueurOuverture`/`marqueurFermeture`.
String texteAvecMarqueurs(String texte, List<PlageSurlignage> plages) {
  if (plages.isEmpty) return texte;

  final buffer = StringBuffer();
  var curseur = 0;
  for (final plage in plages) {
    buffer.write(texte.substring(curseur, plage.debut));
    buffer.write(marqueurOuverture);
    buffer.write(texte.substring(plage.debut, plage.fin));
    buffer.write(marqueurFermeture);
    curseur = plage.fin;
  }
  buffer.write(texte.substring(curseur));
  return buffer.toString();
}
```

- [ ] **Step 4: Lancer les tests pour vérifier qu'ils passent**

Run: `flutter test test/utils/recherche_texte_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/utils/recherche_texte.dart test/utils/recherche_texte_test.dart
git commit -m "feat: recherche multi-occurrences avec positions pour le surlignage"
```

---

### Task 2: Rendu du surlignage dans le markdown

**Files:**
- Create: `lib/widgets/markdown_surlignage.dart`
- Test: `test/widgets/markdown_surlignage_test.dart`

**Interfaces:**
- Consumes: `marqueurOuverture`, `marqueurFermeture`, `texteAvecMarqueurs`, `PlageSurlignage` (Task 1) ; `selectionFill`, `onSelectionFill` (`lib/theme/app_theme.dart`).
- Produces: `final md.ExtensionSet extensionSetSurlignage`, `final Map<String, MarkdownElementBuilder> buildersSurlignage` — consommés par `RulesScreen` (Task 3).

- [ ] **Step 1: Déclarer explicitement la dépendance `markdown`**

Run: `flutter pub add markdown`

(`markdown` est déjà une dépendance transitive de `flutter_markdown_plus`, mais `analysis_options.yaml` active le lint `depend_on_referenced_packages` de `flutter_lints`, qui exige une dépendance directe pour tout import explicite.)

- [ ] **Step 2: Créer le dossier de test et écrire le test qui échoue**

Créer `test/widgets/markdown_surlignage_test.dart` :

```dart
import 'package:comptage_tarot/theme/app_theme.dart';
import 'package:comptage_tarot/utils/recherche_texte.dart';
import 'package:comptage_tarot/widgets/markdown_surlignage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('surligne le texte encadré par les marqueurs avec la couleur de sélection',
      (tester) async {
    final donnees = texteAvecMarqueurs('avant surligne après', [const PlageSurlignage(6, 14)]);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MarkdownBody(
          data: donnees,
          extensionSet: extensionSetSurlignage,
          builders: buildersSurlignage,
        ),
      ),
    ));

    final texteSurligne = tester.widget<Text>(find.text('surligne'));
    expect(texteSurligne.style?.backgroundColor, selectionFill);
    expect(texteSurligne.style?.color, onSelectionFill);
  });

  testWidgets('un texte sans marqueur ne produit aucun surlignage', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: MarkdownBody(data: 'texte normal sans marqueur'),
      ),
    ));

    final textesSurlignes = tester
        .widgetList<Text>(find.byType(Text))
        .where((texte) => texte.style?.backgroundColor == selectionFill);
    expect(textesSurlignes, isEmpty);
  });
}
```

- [ ] **Step 3: Lancer le test pour vérifier qu'il échoue**

Run: `flutter test test/widgets/markdown_surlignage_test.dart`
Expected: FAIL — `package:comptage_tarot/widgets/markdown_surlignage.dart` n'existe pas.

- [ ] **Step 4: Implémenter la syntaxe inline et le builder**

Créer `lib/widgets/markdown_surlignage.dart` :

```dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

import '../theme/app_theme.dart';
import '../utils/recherche_texte.dart';

class _SurlignageInlineSyntax extends md.InlineSyntax {
  _SurlignageInlineSyntax() : super('$marqueurOuverture(.*?)$marqueurFermeture');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text('surlignage', match[1]!));
    return true;
  }
}

class SurlignageMarkdownBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitText(md.Text text, TextStyle? preferredStyle) {
    return Text(
      text.text,
      style: preferredStyle?.copyWith(
        backgroundColor: selectionFill,
        color: onSelectionFill,
      ),
    );
  }
}

final md.ExtensionSet extensionSetSurlignage = md.ExtensionSet(
  md.ExtensionSet.gitHubFlavored.blockSyntaxes,
  [...md.ExtensionSet.gitHubFlavored.inlineSyntaxes, _SurlignageInlineSyntax()],
);

final Map<String, MarkdownElementBuilder> buildersSurlignage = {
  'surlignage': SurlignageMarkdownBuilder(),
};
```

- [ ] **Step 5: Lancer le test pour vérifier qu'il passe**

Run: `flutter test test/widgets/markdown_surlignage_test.dart`
Expected: PASS

Si `md.InlineSyntax` refuse ce constructeur ou si `onMatch`/`parser.addNode` diffère dans la version de `markdown` résolue par `flutter pub add`, consulter `.dart_tool/package_config.json` pour la version exacte et ajuster l'implémentation en conséquence (l'API de `InlineSyntax` est stable depuis plusieurs versions majeures du package, mais à vérifier si le test échoue pour une raison de compilation plutôt que d'assertion).

- [ ] **Step 6: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/widgets/markdown_surlignage.dart test/widgets/markdown_surlignage_test.dart
git commit -m "feat: rendu du surlignage dans le markdown du règlement"
```

---

### Task 3: Navigation et compteur dans RulesScreen

**Files:**
- Modify: `lib/screens/rules_screen.dart`
- Test: `test/screens/rules_screen_test.dart`

**Interfaces:**
- Consumes: `indexesSectionsCorrespondantes`, `plagesCorrespondantes`, `texteAvecMarqueurs` (Task 1) ; `extensionSetSurlignage`, `buildersSurlignage` (Task 2).
- Produces: `RulesScreen` (constructeur inchangé) avec clés de test additionnelles `Key('rules_result_counter')`, `Key('rules_previous_button')`, `Key('rules_next_button')`.

- [ ] **Step 1: Étendre le fichier de test avec les nouveaux cas**

Remplacer entièrement `test/screens/rules_screen_test.dart` par :

```dart
import 'package:comptage_tarot/models/section_reglement.dart';
import 'package:comptage_tarot/screens/rules_screen.dart';
import 'package:comptage_tarot/theme/app_theme.dart';
import 'package:comptage_tarot/utils/recherche_texte.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

void main() {
  late String contenuReglement;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    contenuReglement = await rootBundle.loadString('assets/reglement/reglement.md');
  });

  Future<void> pumpRulesScreen(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: RulesScreen(chargeurReglement: () async => contenuReglement),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets("affiche le titre d'une section connue une fois le règlement chargé",
      (tester) async {
    await pumpRulesScreen(tester);

    expect(find.text('Les enchères'), findsOneWidget);
  });

  testWidgets('saisir un terme sans correspondance affiche le message "Aucun résultat"',
      (tester) async {
    await pumpRulesScreen(tester);

    await tester.enterText(find.byKey(const Key('rules_search_field')), 'zzzzzintrouvable');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('rules_no_results')), findsOneWidget);
    expect(find.byKey(const Key('rules_result_counter')), findsNothing);
  });

  testWidgets("un terme d'un seul caractère ne déclenche pas de recherche", (tester) async {
    await pumpRulesScreen(tester);

    await tester.enterText(find.byKey(const Key('rules_search_field')), 'z');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('rules_no_results')), findsNothing);
    expect(find.byKey(const Key('rules_result_counter')), findsNothing);
  });

  testWidgets("saisir un terme d'une section éloignée fait défiler la liste", (tester) async {
    await pumpRulesScreen(tester);

    final scrollable = find.descendant(
      of: find.byKey(const Key('rules_scroll_view')),
      matching: find.byType(Scrollable),
    );
    final positionAvant = tester.state<ScrollableState>(scrollable).position.pixels;

    await tester.enterText(find.byKey(const Key('rules_search_field')), 'jeu à 5 joueurs');
    await tester.pumpAndSettle();

    final positionApres = tester.state<ScrollableState>(scrollable).position.pixels;
    expect(positionApres, greaterThan(positionAvant));
    expect(find.byKey(const Key('rules_no_results')), findsNothing);
  });

  testWidgets('un terme présent dans plusieurs sections affiche un compteur et surligne le texte',
      (tester) async {
    final sectionsAnalysees = analyserSections(contenuReglement);
    final indexesAttendus = indexesSectionsCorrespondantes(sectionsAnalysees, 'poignée');
    expect(indexesAttendus.length, greaterThan(1));

    await pumpRulesScreen(tester);

    await tester.enterText(find.byKey(const Key('rules_search_field')), 'poignée');
    await tester.pumpAndSettle();

    expect(find.text('1/${indexesAttendus.length}'), findsOneWidget);

    final textesSurlignes = tester
        .widgetList<Text>(find.byType(Text))
        .where((texte) => texte.style?.backgroundColor == selectionFill);
    expect(textesSurlignes, isNotEmpty);
  });

  testWidgets('le bouton suivant avance au résultat suivant', (tester) async {
    final sectionsAnalysees = analyserSections(contenuReglement);
    final indexesAttendus = indexesSectionsCorrespondantes(sectionsAnalysees, 'poignée');

    await pumpRulesScreen(tester);
    await tester.enterText(find.byKey(const Key('rules_search_field')), 'poignée');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('rules_next_button')));
    await tester.pumpAndSettle();

    expect(find.text('2/${indexesAttendus.length}'), findsOneWidget);
  });

  testWidgets('le bouton précédent depuis le premier résultat boucle vers le dernier',
      (tester) async {
    final sectionsAnalysees = analyserSections(contenuReglement);
    final indexesAttendus = indexesSectionsCorrespondantes(sectionsAnalysees, 'poignée');

    await pumpRulesScreen(tester);
    await tester.enterText(find.byKey(const Key('rules_search_field')), 'poignée');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('rules_previous_button')));
    await tester.pumpAndSettle();

    expect(find.text('${indexesAttendus.length}/${indexesAttendus.length}'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Lancer les tests pour vérifier que les nouveaux cas échouent**

Run: `flutter test test/screens/rules_screen_test.dart`
Expected: les 4 anciens tests passent toujours ; les 3 nouveaux échouent (pas de `Key('rules_result_counter')`/`Key('rules_next_button')`/`Key('rules_previous_button')`, pas de surlignage).

- [ ] **Step 3: Réécrire RulesScreen**

Remplacer entièrement `lib/screens/rules_screen.dart` par :

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../models/section_reglement.dart';
import '../utils/recherche_texte.dart';
import '../widgets/markdown_surlignage.dart';

Future<String> _chargerAssetReglement() =>
    rootBundle.loadString('assets/reglement/reglement.md');

class RulesScreen extends StatefulWidget {
  const RulesScreen({super.key, this.chargeurReglement = _chargerAssetReglement});

  /// Permet d'injecter un chargeur alternatif dans les tests : recharger le
  /// même asset via `rootBundle` à répétition dans plusieurs `testWidgets`
  /// du même fichier ne se termine pas de façon fiable sur cette version de
  /// Flutter (l'appel natif ne se résout qu'une seule fois par process de
  /// test) — les tests chargent donc le contenu une fois via `setUpAll` et
  /// l'injectent ici plutôt que de rappeler `rootBundle.loadString`.
  final Future<String> Function() chargeurReglement;

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> {
  List<SectionReglement>? _sections;
  List<GlobalKey> _cles = [];
  String? _messageAucunResultat;
  String _termeActif = '';
  List<int> _indexesResultats = [];
  int? _indexResultatCourant;

  @override
  void initState() {
    super.initState();
    _chargerReglement();
  }

  Future<void> _chargerReglement() async {
    final contenu = await widget.chargeurReglement();
    final sections = analyserSections(contenu);
    if (!mounted) return;
    setState(() {
      _sections = sections;
      _cles = List.generate(sections.length, (_) => GlobalKey());
    });
  }

  void _onRechercheChangee(String requete) {
    final sections = _sections;
    if (sections == null) return;

    if (requete.trim().length < 2) {
      setState(() {
        _messageAucunResultat = null;
        _indexesResultats = [];
        _indexResultatCourant = null;
        _termeActif = '';
      });
      return;
    }

    final indexes = indexesSectionsCorrespondantes(sections, requete);
    if (indexes.isEmpty) {
      setState(() {
        _messageAucunResultat = 'Aucun résultat pour « $requete »';
        _indexesResultats = [];
        _indexResultatCourant = null;
        _termeActif = requete;
      });
      return;
    }

    setState(() {
      _messageAucunResultat = null;
      _indexesResultats = indexes;
      _indexResultatCourant = 0;
      _termeActif = requete;
    });
    _allerAuResultatCourant();
  }

  void _resultatSuivant() {
    final indexResultatCourant = _indexResultatCourant;
    if (indexResultatCourant == null) return;
    setState(() {
      _indexResultatCourant = (indexResultatCourant + 1) % _indexesResultats.length;
    });
    _allerAuResultatCourant();
  }

  void _resultatPrecedent() {
    final indexResultatCourant = _indexResultatCourant;
    if (indexResultatCourant == null) return;
    setState(() {
      _indexResultatCourant =
          (indexResultatCourant - 1 + _indexesResultats.length) % _indexesResultats.length;
    });
    _allerAuResultatCourant();
  }

  void _allerAuResultatCourant() {
    final indexResultatCourant = _indexResultatCourant;
    if (indexResultatCourant == null) return;
    final indexSection = _indexesResultats[indexResultatCourant];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contexteSection = _cles[indexSection].currentContext;
      if (contexteSection != null) {
        Scrollable.ensureVisible(
          contexteSection,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.0,
        );
      }
    });
  }

  String _donneesSection(SectionReglement section) {
    final texteSection = '## ${section.titre}\n\n${section.corps}';
    if (_termeActif.isEmpty) return texteSection;
    final plages = plagesCorrespondantes(texteSection, _termeActif);
    return plages.isEmpty ? texteSection : texteAvecMarqueurs(texteSection, plages);
  }

  @override
  Widget build(BuildContext context) {
    final sections = _sections;
    final indexResultatCourant = _indexResultatCourant;
    return Scaffold(
      appBar: AppBar(title: const Text('Règlement')),
      body: sections == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              key: const Key('rules_search_field'),
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.search),
                                hintText: 'Rechercher dans le règlement',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: _onRechercheChangee,
                            ),
                          ),
                          if (indexResultatCourant != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '${indexResultatCourant + 1}/${_indexesResultats.length}',
                              key: const Key('rules_result_counter'),
                            ),
                            IconButton(
                              key: const Key('rules_previous_button'),
                              icon: const Icon(Icons.keyboard_arrow_up),
                              onPressed: _resultatPrecedent,
                            ),
                            IconButton(
                              key: const Key('rules_next_button'),
                              icon: const Icon(Icons.keyboard_arrow_down),
                              onPressed: _resultatSuivant,
                            ),
                          ],
                        ],
                      ),
                      if (_messageAucunResultat != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _messageAucunResultat!,
                            key: const Key('rules_no_results'),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    key: const Key('rules_scroll_view'),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < sections.length; i++)
                          Container(
                            key: _cles[i],
                            padding: const EdgeInsets.only(bottom: 16),
                            child: MarkdownBody(
                              data: _donneesSection(sections[i]),
                              extensionSet: extensionSetSurlignage,
                              builders: buildersSurlignage,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
```

- [ ] **Step 4: Lancer les tests pour vérifier qu'ils passent**

Run: `flutter test test/screens/rules_screen_test.dart`
Expected: PASS (7 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/screens/rules_screen.dart test/screens/rules_screen_test.dart
git commit -m "feat: surlignage et navigation multi-résultats dans la recherche du règlement"
```

---

### Task 4: Vérification finale

**Files:** aucun fichier modifié — vérification transverse.

- [ ] **Step 1: Analyse statique complète**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 2: Suite de tests complète**

Run: `flutter test`
Expected: tous les tests passent, y compris les suites inchangées (`test/db/`, `test/scoring/`, `test/assets/`, `test/models/`, `test/screens/home_screen_test.dart`) et les suites modifiées/créées de ce plan.

Rien à committer à cette étape si les deux commandes passent du premier coup.
