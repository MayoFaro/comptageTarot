# Écran Règlement avec recherche — Design

## Contexte

L'application permet de compter les scores d'une partie de tarot, mais ne donne aucun accès aux règles du jeu. Une version PDF du règlement officiel FFT existe (`reglement tarot.pdf`, 28 pages) mais un PDF est peu pratique à consulter sur mobile (mise en page fixe, texte minuscule, zoom/pan pénibles). Cette fonctionnalité ajoute un écran "Règlement" natif, accessible depuis l'accueil, avec une recherche textuelle simple.

## Périmètre du contenu

Le PDF FFT couvre deux univers : les règles du jeu (pages 3 à 12 : jeu à 4/3/5 joueurs) et les formats de compétition FFT (pages 13 à 28 : tournois duplicates, triplettes, quadrettes, équipes, arbitrage détaillé). Seul le premier bloc est transcrit, car l'application ne gère que des parties libres à 3, 4 ou 5 joueurs, pas les tournois duplicates.

Sections à transcrire, dans l'ordre du PDF (pages 3-12) :

1. Avertissement
2. Présentation
3. Les cartes
4. Le principe du jeu
5. La distribution
6. La tenue des cartes
7. Les enchères
8. Le Chien et l'Ecart
9. Le chelem
10. La Poignée (10, 13 ou 15 Atouts)
11. Le Petit au Bout
12. Le jeu de la carte
13. Le calcul des scores
14. La marque en donnes libres
15. Le classement en donnes libres
16. Le tournoi libre par équipes
17. L'éthique du jeu
18. L'arbitre
19. Le jeu à 3 joueurs
20. Le jeu à 5 joueurs

Chaque section devient un bloc markdown `##` dans un unique fichier source. Les tableaux du PDF (valeurs des cartes, points à réaliser, primes de Poignée) sont retranscrits en tableaux markdown. Les exemples chiffrés et la feuille de marque d'exemple sont conservés sous forme de texte/liste (pas besoin de reproduire l'image de la feuille de marque).

## Contenu source

- Fichier : `assets/reglement/reglement.md`
- Déclaré comme asset Flutter dans `pubspec.yaml` (`assets: - assets/reglement/reglement.md`)
- Format : un titre `#` (ex: "Règlement officiel du Tarot") suivi des sections `##` listées ci-dessus, dans l'ordre.

## Package de rendu markdown

`flutter_markdown` (le package officiel Flutter) est discontinué depuis mai 2026 — Google l'a marqué "discontinued" sur pub.dev et ne le maintient plus. Le remplacement retenu est **`flutter_markdown_plus`**, fork maintenu par Foresight Mobile avec une API strictement compatible (même classes `MarkdownBody`/`Markdown`), ce qui évite tout risque de dépendance morte dès la sortie de la fonctionnalité.

## Architecture d'écran

Nouveau fichier `lib/screens/rules_screen.dart` :

- `RulesScreen` (StatefulWidget) :
  - Au `initState`, charge `assets/reglement/reglement.md` via `rootBundle.loadString`.
  - Parse le contenu en une liste de sections `RuleSection { String titre; String corps }` en découpant sur les lignes commençant par `## `.
  - Génère un `GlobalKey` par section (stocké en parallèle de la liste).
  - Affiche :
    - `AppBar` avec titre "Règlement"
    - Une barre de recherche fixe (`TextField`) juste sous l'AppBar
    - Un `SingleChildScrollView` contenant, pour chaque section, un `Container(key: sectionKey)` enveloppant un `MarkdownBody` (titre + corps de la section rendus ensemble, pour que le titre serve d'ancre de scroll).
  - Pendant le chargement initial de l'asset, affiche un `CircularProgressIndicator` centré.

Modèle de données minimal, pas de package externe pour le parsing markdown des sections (un simple split sur les lignes suffit, pas de dépendance à un parseur markdown complet pour ça).

## Recherche

- Champ `TextField` avec `onChanged`, déclenché dès que le texte atteint 2 caractères (en dessous, aucune action, pour éviter les faux positifs sur une seule lettre).
- Normalisation : minuscule + suppression des accents (fonction utilitaire locale, ex: `unaccent(String s)`), appliquée à la fois au terme recherché et au texte de chaque section (titre + corps concaténés, syntaxe markdown brute incluse — les `#`, `*`, etc. n'interfèrent pas avec une recherche par sous-chaîne sur des mots).
- Recherche : on parcourt les sections dans l'ordre du document et on prend la première dont le texte normalisé contient le terme normalisé.
  - Si trouvée : `Scrollable.ensureVisible(sectionKey.currentContext, duration: ..., curve: ...)` pour un scroll animé jusqu'à la section.
  - Si aucune section ne correspond : affichage d'un texte discret sous le champ de recherche ("Aucun résultat pour « … »"), pas de scroll, pas de blocage de la saisie.
- Pas de surlignage du terme dans le texte rendu, pas de navigation résultat suivant/précédent : uniquement un saut vers la première occurrence (portée volontairement réduite, cf. discussion avec l'utilisateur — le règlement est assez court pour que ce soit suffisant).

## Accès depuis l'accueil

Dans `lib/screens/home_screen.dart`, ajout d'une nouvelle `Card` juste après la `Card` "Gérer les joueurs" existante (avant le `Divider`), avec le même style (`ListTile` + icône + sous-titre + chevron) :

- Icône : `Icons.menu_book_outlined`
- Titre : "Règlement du jeu"
- Sous-titre : "Consulter les règles du Tarot"
- `onTap` : `Navigator.push` vers `RulesScreen`

## Gestion des erreurs

Le fichier markdown est un asset embarqué dans l'application (pas de téléchargement réseau) : aucune gestion d'erreur réseau n'est nécessaire. Si le chargement de l'asset échoue (cas anormal, ex: asset mal déclaré), une erreur remonte naturellement via le `Future` — pas de fallback silencieux à prévoir, ce cas ne doit simplement pas se produire une fois l'asset correctement déclaré et testé.

## Tests

- Test widget : `RulesScreen` charge et affiche au moins une section connue du règlement (ex: le titre "Les enchères" apparaît dans l'arbre de widgets après chargement).
- Test unitaire sur la fonction de normalisation (`unaccent`) : vérifie que "Ecart" et "écart" se normalisent de façon identique.
- Test unitaire sur la logique de recherche (trouver la première section correspondante) sur un jeu de sections factice, y compris le cas "aucune correspondance".
- Test widget sur `HomeScreen` : vérifie la présence de la nouvelle carte "Règlement du jeu" et qu'un tap navigue vers `RulesScreen`.

## Hors périmètre

- Pas de surlignage du terme recherché dans le texte affiché.
- Pas de navigation résultat suivant/précédent.
- Pas de contenu sur les tournois duplicates/triplettes/quadrettes/équipes (pages 13-28 du PDF).
- Pas de recherche floue/tolérante aux fautes de frappe : sous-chaîne exacte (après normalisation accents/casse) uniquement.
