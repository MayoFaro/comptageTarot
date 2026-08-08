# Status — reprise de session

Dernière mise à jour : 2026-08-08, depuis Linux (implémentation en cours).

## Où on en est

- Design doc complet et approuvé : voir `DESIGN.md` (issu de `/office-hours` + `/plan-eng-review`,
  barème FFT vérifié, architecture tranchée, 9 tâches d'implémentation T1-T9 listées à la fin).
- Plan d'implémentation détaillé : `docs/superpowers/plans/2026-08-08-comptage-tarot-mvp.md`.
- **T1 à T7 implémentées et vérifiées par `flutter analyze` + `flutter test`** (18 tests
  passent : 12 sur le moteur de calcul dont les 5 exemples officiels FFT, 6 sur la couche DAO
  Drift). Les 5 écrans (Accueil, Gestion des joueurs, Config partie, Tableau de scores, Saisie
  de manche) sont écrits et navigables.
- **Deuxième round de retours UI/UX (2026-08-08, premiers tests sur device) — traité :**
  - Palette vert/bordeaux inspirée des atouts, déclinée sur toute l'appli, surfaces
    explicitement teintées (plus de blanc — `lib/theme/app_theme.dart`).
  - Écran de saisie de manche : contrat sélectionné par tuiles 2×2 de taille identique
    (au lieu du menu déroulant), chips preneur/appelé sans coche de sélection, bouts
    déplacés au-dessus de la réglette, bloc points preneur/défense harmonisé et coloré en
    direct (vert/bordeaux selon qui est en réussite sur le contrat), poignée déclarable par
    les deux camps indépendamment (attaque et/ou défense, avec type propre à chacun).
  - **Moteur de calcul modifié en conséquence** : `Poignee poignee` → `poigneeAttaque` +
    `poigneeDefense` (les deux primes s'additionnent, acquises au camp vainqueur — voir
    Notes de correctness ci-dessous). **Schéma Drift changé sans migration** (schemaVersion
    2, conforme à la décision "perte de données locale acceptée") : après mise à jour, vider
    les données de l'appli sur le téléphone de test ou désinstaller/réinstaller.
  - Tableau de scores : alignement des colonnes corrigé (l'ancien `ListTile` décalait les
    lignes de manche par rapport à l'en-tête/aux totaux — remplacé par un gabarit de ligne
    partagé), abréviation du contrat (P/G/GS/GC) ajoutée sous le numéro de manche, score du
    preneur coloré vert/bordeaux selon réussite du contrat.
  - Barre de navigation virtuelle Android masquée au démarrage (`SystemUiMode.manual`,
    overlays: [top] — statut visible, nav bar cachée).
  - **Pas encore re-testé visuellement par l'utilisateur — à confirmer au prochain test.**
- **T8 (export visuel feuille de marque) volontairement non fait** — différé en V1.5 comme
  prévu dans DESIGN.md.
- **T9 (vérification manuelle) : à faire par l'utilisateur sur son téléphone physique.**
  Décision explicite (2026-08-08) : Claude ne doit plus jamais lancer `flutter run` ni
  d'émulateur sur ce projet — seuls `flutter analyze` / `flutter test` sont exécutés côté
  agent. Tests manuels sur device réel, branché en USB.
- Retour utilisateur après premier aperçu (émulateur, avant la consigne ci-dessus) :
  l'accès "Gestion des joueurs" n'était pas assez visible depuis l'accueil, et l'écran de
  config de partie ne permettait pas de créer un joueur si la liste était vide. Les deux ont
  été corrigés (bloc "Gérer les joueurs" en pleine largeur sur l'accueil, bouton "Nouveau
  joueur" directement dans l'écran de config de partie). **Ce retour n'a pas encore été
  re-vérifié visuellement — à confirmer par l'utilisateur au prochain test sur device.**
- Décision prise avec l'utilisateur : implémentation directe (pas de sous-agents, pas de
  worktree, pas de ledger) — un seul agent code, teste, avance sur les 9 tâches dans l'ordre
  T1 → T9, en respectant les dépendances (T1/T2 d'abord, T3 dépend de T2, T4 dépend de T1,
  T5/T6/T7 dépendent de T1+T2+T4, T8 dépend de T6, T9 dépend de tout).

## Chantier en pause : tests widgets automatisés

Tentative de couvrir les 5 écrans par des tests `WidgetTester` (en plus des 18 tests
moteur/DAO déjà verts), demandée explicitement par l'utilisateur avant le prochain test
visuel. **Abandonnée en cours de session à cause d'un hang non résolu** — à reprendre.

- Chaque `flutter test test/screens/*_test.dart` se bloquait indéfiniment (aucune sortie,
  process quasi idle en CPU), y compris après avoir ajouté `test/flutter_test_config.dart`
  avec `EditableText.debugDeterministicCursor = true` (fix standard pour le hang classique du
  curseur clignotant d'un `TextField(autofocus: true)` dans `pumpAndSettle()`). Le fix seul
  n'a pas suffi — cause exacte non identifiée avant l'arrêt de la session.
- Fichiers de la tentative **supprimés** (non commités) pour ne pas laisser un `flutter test`
  qui hang dans le dépôt : `test/test_helpers.dart` (wrapper `ProviderScope` + DB en mémoire
  pour les tests widgets), `test/screens/{players,home,game_config,round_entry,score_table}
  _screen_test.dart`, `test/flutter_test_config.dart`.
- Pistes pour la reprise : isoler le hang sur le test le plus simple d'abord (juste
  `pumpWidget` + `pumpAndSettle` sur `PlayersScreen` vide, sans ouvrir de dialog) pour
  confirmer si `pumpAndSettle` lui-même pose problème indépendamment du `TextField` ; sinon
  remplacer les `pumpAndSettle()` après ouverture de dialog par des `pump()` bornés
  (`await tester.pump(); await tester.pump(const Duration(milliseconds: 300));`) plutôt que
  de compter sur `debugDeterministicCursor`.

## Comment reprendre

1. `git pull` si besoin.
2. Lancer l'app sur le téléphone physique branché en USB (`flutter run -d <device-id>`,
   voir `flutter devices` pour l'id) — **c'est l'utilisateur qui fait ce test, pas Claude.**
3. Parcourir le flux complet : Accueil → "Gérer les joueurs" (ajouter 3-5 joueurs) → "Nouvelle
   partie" → choisir le nombre de joueurs et les sélectionner → Tableau de scores → "+" pour
   saisir une manche → vérifier le calcul contre l'exemple officiel #1 de DESIGN.md (Garde, 49
   pts, 2 bouts, petit au bout preneur, poignée simple → +318 / -106 / -106 / -106).
4. Signaler tout bug de calcul, de navigation, ou de rendu visuel pour correction.
5. Si tout est validé : envisager T8 (export visuel feuille de marque, différé en V1.5) ou
   des ajustements de polish UI selon retour utilisateur.

## Comment relancer les vérifications automatiques (sans device)

```bash
flutter analyze && flutter test
```

18 tests doivent passer (12 moteur de calcul + 6 DAO Drift).

## Notes de correctness à ne pas perdre

- Poignée : la prime va TOUJOURS au camp qui **gagne** la donne, jamais forcément à celui qui
  l'a présentée (piège vérifié contre le texte officiel, cf. exemple #4 dans DESIGN.md). **Les
  deux camps peuvent chacun présenter une poignée dans la même manche** — dans ce cas les
  deux primes s'additionnent avant d'être acquises au camp vainqueur (même règle, montant
  cumulé). Voir `ManchInput.poigneeAttaque` / `poigneeDefense` dans le moteur.
- Chelem réussi par le preneur (+400/+200/−200) : mis en commun dans le montant AVANT
  multiplication par le coefficient de distribution. Chelem infligé par la défense (+200) :
  mécanisme SÉPARÉ, forfait ajouté après coup à chaque défenseur, jamais multiplié.
- Pas de demi-points dans l'appli — entiers uniquement sur la réglette 0-91, à tout nombre de
  joueurs (décision utilisateur, diverge volontairement du règlement papier sur ce point
  précis, qui prévoit un arrondi au ½ point à 3 et 5 joueurs).
