# Status — reprise de session

Dernière mise à jour : 2026-08-08, depuis Windows (poste sans Flutter/Android SDK installé).

## Où on en est

- Design doc complet et approuvé : voir `DESIGN.md` (issu de `/office-hours` + `/plan-eng-review`,
  barème FFT vérifié, architecture tranchée, 9 tâches d'implémentation T1-T9 listées à la fin).
- Aucun code écrit. Le dépôt ne contient que ce fichier, `DESIGN.md`, et ce statut.
- Décision prise avec l'utilisateur : implémentation directe (pas de sous-agents, pas de
  worktree, pas de ledger) — un seul agent code, teste, avance sur les 9 tâches dans l'ordre
  T1 → T9, en respectant les dépendances (T1/T2 d'abord, T3 dépend de T2, T4 dépend de T1,
  T5/T6/T7 dépendent de T1+T2+T4, T8 dépend de T6, T9 dépend de tout).

## Pourquoi on s'arrête là

Ce poste Windows n'a ni `flutter` ni `dart` dans le PATH, ni Android SDK visible. Rien n'a pu
être compilé ni testé. L'utilisateur a cet outillage sous Linux (dual-boot / autre partition
sur la même machine) et reprend la session de ce côté-là.

## Comment reprendre depuis Linux

1. `git clone https://github.com/MayoFaro/comptageTarot.git` (ou `git pull` si déjà cloné).
2. Lire `DESIGN.md` en entier — c'est la source de vérité complète (barème, architecture,
   décisions, 9 tâches).
3. Vérifier l'outillage : `flutter doctor`.
4. Démarrer par **T1 + T2 en parallèle** (indépendantes) :
   - T1 : squelette `flutter create`, ajouter `drift`, `drift_dev`, `build_runner`,
     `flutter_riverpod` au `pubspec.yaml`, définir le schéma (tables Parties, Joueurs,
     Manches — voir DESIGN.md pour les contraintes exactes, notamment la convention
     `appele_id == preneur_id` pour "preneur seul" à 5 joueurs).
   - T2 : écrire `lib/scoring/tarot_score_engine.dart`, module Dart pur (aucun import
     Flutter/Drift), qui implémente exactement la formule du barème décrite dans DESIGN.md.
5. **T3** (dépend de T2) : tests unitaires du moteur de calcul — les 5 exemples officiels
   (déjà dans DESIGN.md, tous vérifiés à la main) + dériver des cas de test pour les branches
   non couvertes par ces 5 exemples : 3 joueurs, 5 joueurs (associé réel), 5 joueurs (preneur
   seul), chelem infligé par la défense. **Ne pas passer à l'UI avant que ces tests passent.**
6. **T4** (dépend de T1) : `enregistrerManche()` (upsert création+édition), `supprimerManche()`.
7. **T5, T6, T7** (dépendent de T1+T2+T4) : écrans gestion des joueurs, tableau de scores
   (JOIN Drift, ligne sticky), saisie de manche (validation stricte, anti double-submit).
8. **T8** (dépend de T6, différable en V1.5) : export visuel "feuille de marque".
9. **T9** (dépend de tout) : test manuel avec données factices avant le test en conditions
   réelles à une vraie table.

## Notes de correctness à ne pas perdre

- Poignée : la prime va TOUJOURS au camp qui **gagne** la donne, jamais forcément à celui qui
  l'a présentée (piège vérifié contre le texte officiel, cf. exemple #4 dans DESIGN.md).
- Chelem réussi par le preneur (+400/+200/−200) : mis en commun dans le montant AVANT
  multiplication par le coefficient de distribution. Chelem infligé par la défense (+200) :
  mécanisme SÉPARÉ, forfait ajouté après coup à chaque défenseur, jamais multiplié.
- Pas de demi-points dans l'appli — entiers uniquement sur la réglette 0-91, à tout nombre de
  joueurs (décision utilisateur, diverge volontairement du règlement papier sur ce point
  précis, qui prévoit un arrondi au ½ point à 3 et 5 joueurs).
