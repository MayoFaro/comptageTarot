# Surlignage et navigation multi-occurrences dans la recherche du Règlement — Design

## Contexte

L'écran Règlement (`lib/screens/rules_screen.dart`) dispose déjà d'une recherche live qui saute vers la première section contenant le terme cherché (voir `docs/superpowers/specs/2026-08-10-reglement-search-design.md`). Ce premier design excluait explicitement le surlignage et la navigation multi-résultats, jugés hors périmètre pour une "recherche simple". À l'usage, ce n'est pas suffisant : il n'y a aucun moyen de voir où se trouvent les autres occurrences du terme dans le reste du document, ni de les visualiser une fois sur place.

Cette évolution ajoute :
1. Le surlignage visuel de **toutes** les occurrences du terme recherché, dans toutes les sections où il apparaît.
2. Une navigation précédent/suivant entre les **sections** contenant au moins une occurrence (pas occurrence par occurrence — décision explicite, voir "Granularité de navigation" ci-dessous), avec un compteur de position (ex: "2/5").

## Hors périmètre

- Distinction visuelle entre "l'occurrence courante" et "les autres occurrences" : toutes les occurrences visibles à l'écran sont surlignées de la même façon, en permanence, tant qu'un terme de recherche est actif.
- Navigation occurrence par occurrence à l'intérieur d'une même section : la navigation précédent/suivant se fait au niveau section. Si une section contient plusieurs occurrences, elles sont toutes visibles (et surlignées) une fois la section atteinte — pas de sous-navigation entre elles.
- Recherche floue / tolérante aux fautes de frappe : inchangé, sous-chaîne exacte après normalisation accents/casse.

## Granularité de navigation

Le pointeur de navigation avance/recule parmi la liste **ordonnée des sections contenant au moins une occurrence** (pas parmi les occurrences individuelles). C'est un compromis délibéré : la navigation occurrence-par-occurrence demanderait un scroll précis vers chaque occurrence individuelle (clé de widget par occurrence, pas seulement par section), ce qui est nettement plus complexe pour un gain d'usage marginal ici — une fois sur une section, toutes ses occurrences sont déjà visibles et surlignées ensemble.

## Mécanisme de surlignage

`flutter_markdown_plus` ne fournit pas de surlignage de texte. Le mécanisme retenu :

1. **Localisation des occurrences avec positions** : extension de `lib/utils/recherche_texte.dart` avec une normalisation accents/casse qui conserve la correspondance vers les indices du texte original (contrairement à `retirerAccents` actuel qui ne fait que comparer des chaînes). Nécessaire car certains caractères se déplient en plusieurs caractères lors de la normalisation (`œ` → `oe`), ce qui décale les indices si on ne les suit pas explicitement. Cette normalisation avec suivi de position est utilisée à la fois pour déterminer si une section correspond (remplace l'usage actuel de `retirerAccents`) et pour localiser précisément chaque occurrence à surligner — un seul algorithme, pour éviter toute incohérence entre "la section est détectée comme correspondante" et "aucune occurrence n'y est surlignée".

2. **Marquage du markdown source** : avant de passer le texte d'une section à `MarkdownBody`, chaque occurrence détectée (sur le texte original, casse et accents d'origine préservés) est encadrée par une paire de marqueurs invisibles utilisant deux points de code Unicode de la zone privée (jamais présents dans un texte français normal, par exemple U+E000 et U+E001) — l'un en ouverture, l'autre en fermeture. Étant dans la zone privée, ces points de code n'ont par définition aucune signification standard et ne peuvent pas entrer en collision avec un caractère du règlement.

3. **Rendu du surlignage** : une syntaxe inline personnalisée (`md.InlineSyntax`) reconnaît la paire de marqueurs et produit un élément markdown dédié (tag `surlignage`). Un `MarkdownElementBuilder` associé à ce tag restitue le texte encadré avec `TextStyle(backgroundColor: selectionFill, color: onSelectionFill)` — réutilisant telles quelles les couleurs de sélection déjà définies dans `lib/theme/app_theme.dart` et employées partout ailleurs dans l'application pour signaler un état "sélectionné", plutôt que d'introduire une nouvelle teinte hors palette.

4. Cette syntaxe et ce builder ne sont actifs que lorsqu'une recherche est en cours (terme ≥ 2 caractères) ; sans recherche active, le rendu des sections est strictement identique à aujourd'hui (pas de marqueurs insérés, pas de builder invoqué).

## Navigation et compteur

- Taper un terme (≥ 2 caractères, comportement live inchangé) calcule la liste ordonnée des sections correspondantes, positionne le pointeur sur la première, y fait défiler l'écran (comme aujourd'hui) et affiche "1/N" à côté du champ de recherche.
- Deux flèches (▲ précédent / ▼ suivant) à droite du champ déplacent ce pointeur d'une section à l'autre parmi celles qui correspondent, avec un défilement animé vers la section ciblée à chaque déplacement. Aux extrémités, la navigation boucle (après la dernière section correspondante, "suivant" revient à la première ; "précédent" depuis la première va à la dernière).
- Aucune section correspondante (0 résultat) : comportement actuel conservé — message "Aucun résultat pour « terme »" affiché sous le champ, ni compteur ni flèches.
- Effacer le champ de recherche (ou repasser sous 2 caractères) retire tout surlignage, le compteur et les flèches, et n'entraîne aucun scroll automatique — comportement identique à aujourd'hui.

## Interface

Le compteur ("2/5") et les deux flèches sont intégrés dans la même ligne que le champ de recherche existant (`TextField`), à sa droite — pas de nouvelle ligne, pas de réorganisation de l'écran. Ils n'apparaissent que lorsqu'il y a au moins un résultat.

## Tests

- Extension des tests unitaires de `recherche_texte.dart` : la nouvelle fonction de normalisation avec positions retrouve correctement les bornes d'une occurrence, y compris avec un caractère qui se déplie (`œ` → `oe`) et avec des accents/casse différents entre le terme cherché et le texte original.
- Nouvelle fonction retournant la liste ordonnée des sections correspondantes (remplace `indexPremiereSectionCorrespondante`, qui ne retournait que la première) : testée avec 0, 1 et plusieurs sections correspondantes.
- Test widget sur `RulesScreen` : taper un terme présent dans plusieurs sections affiche le compteur attendu ("1/N") et au moins une occurrence surlignée (présence du `TextStyle` avec `backgroundColor: selectionFill` dans l'arbre de widgets, ou du texte du tag surligné) ; appuyer sur "suivant" fait défiler vers la section suivante et met à jour le compteur ("2/N") ; boucle vérifiée en dépassant la dernière section.
- Test widget : un terme sans correspondance n'affiche ni compteur ni flèches, uniquement le message "Aucun résultat".
