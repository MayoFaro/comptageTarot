# Compteur de points Tarot — MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement
> this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.
>
> **Note override:** the project owner already decided (see `STATUS.md`, 2026-08-08) to
> implement this directly in one session — no subagent-per-task, no git worktree, no ledger.
> Use `executing-plans`, not `subagent-driven-development`.

**Goal:** Build a fully offline Flutter Android app that scores Tarot games (3–5 players)
exactly per the FFT official rulebook, with persistent local storage, editable/deletable
rounds, and a reusable player list.

**Architecture:** Flutter + Drift (SQLite) + Riverpod. A pure-Dart scoring engine
(`lib/scoring/tarot_score_engine.dart`, zero Flutter/Drift imports) is the single source of
truth for point calculation; the DB layer stores raw round inputs (never pre-computed
scores) so totals are always recomputed live from the engine. Five screens: Accueil,
Gestion des joueurs, Config partie (folded into Accueil flow), Tableau de scores, Saisie de
manche.

**Tech Stack:** Flutter 3.32.8 / Dart 3.8.1 (already installed), `drift` + `sqlite3_flutter_libs`
+ `path_provider` (local SQLite), `flutter_riverpod` (state), `drift_dev` + `build_runner`
(codegen, dev-only).

## Global Constraints

- 100% hors-ligne : aucune dépendance réseau, aucun package qui téléphone à l'extérieur.
- Aucune permission réseau dans `AndroidManifest.xml`.
- Le moteur de calcul (`lib/scoring/`) ne doit importer ni `flutter`, ni `drift`.
- Réglette de points du preneur : entiers uniquement, 0 à 91, quel que soit le nombre de
  joueurs (pas de demi-points — décision utilisateur, voir DESIGN.md Open Questions).
- Une manche éditée ou supprimée doit recalculer tous les totaux cumulés (pas de score
  pré-calculé stocké en base — toujours recalculé par le moteur à partir des données brutes).
- `appeleId == preneurId` est la convention pour "preneur seul contre 4" à 5 joueurs.
- T8 (export visuel feuille de marque) est explicitement **hors de ce plan** — différé en
  V1.5 par décision déjà actée dans DESIGN.md. Ne pas l'implémenter ici.

---

## Task 1: Bootstrap du projet Flutter + schéma Drift

**Files:**
- Create: `pubspec.yaml` (via `flutter create`)
- Create: `lib/db/database.dart`
- Create: `test/db/database_test.dart`

**Interfaces:**
- Produces: `class AppDatabase extends _$AppDatabase` avec tables `Joueurs`, `Parties`,
  `PartieJoueurs`, `Manches` (noms de classes générés par Drift : `Joueur`, `Partie`,
  `PartieJoueur`, `Manche` pour les row types ; `JoueursCompanion`, etc. pour les inserts).

- [ ] **Step 1: Créer le squelette Flutter**

Run: `flutter create --org com.mayofaro --project-name comptage_tarot .`

Expected: `pubspec.yaml`, `lib/main.dart`, `android/`, etc. créés dans le repo existant
(DESIGN.md, STATUS.md, .git, .claude restent intacts).

- [ ] **Step 2: Ajouter les dépendances**

Run:
```bash
flutter pub add drift sqlite3_flutter_libs path_provider path flutter_riverpod
flutter pub add -d drift_dev build_runner
```

Expected: `pubspec.yaml` contient les 5 packages runtime + 2 packages dev.

- [ ] **Step 3: Écrire le schéma Drift**

Create `lib/db/database.dart`:

```dart
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class Joueurs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nom => text().withLength(min: 1, max: 50)();
}

class Parties extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get nombreJoueurs =>
      integer().customConstraint('NOT NULL CHECK (nombre_joueurs IN (3, 4, 5))')();
  DateTimeColumn get dateCreation => dateTime().withDefault(currentDateAndTime)();
}

class PartieJoueurs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get partieId => integer().references(Parties, #id)();
  IntColumn get joueurId => integer().references(Joueurs, #id)();
  IntColumn get ordre => integer()();
}

class Manches extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get partieId => integer().references(Parties, #id)();
  IntColumn get numero => integer()();
  TextColumn get contrat => text()();
  IntColumn get preneurId => integer().references(Joueurs, #id)();
  IntColumn get appeleId => integer().nullable().references(Joueurs, #id)();
  IntColumn get pointsPreneur =>
      integer().customConstraint('NOT NULL CHECK (points_preneur BETWEEN 0 AND 91)')();
  IntColumn get bouts =>
      integer().customConstraint('NOT NULL CHECK (bouts BETWEEN 0 AND 3)')();
  TextColumn get petitAuBout => text()();
  TextColumn get poignee => text()();
  TextColumn get chelem => text()();
  DateTimeColumn get dateCreation => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Joueurs, Parties, PartieJoueurs, Manches])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'tarot.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
```

- [ ] **Step 4: Générer le code Drift**

Run: `dart run build_runner build --delete-conflicting-outputs`

Expected: `lib/db/database.g.dart` généré sans erreur, contient `_$AppDatabase`.

- [ ] **Step 5: Écrire un test smoke de schéma**

Create `test/db/database_test.dart`:

```dart
import 'package:comptage_tarot/db/database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('crée un joueur et le relit', () async {
    final id = await db.into(db.joueurs).insert(JoueursCompanion.insert(nom: 'Alice'));
    final joueur = await (db.select(db.joueurs)..where((j) => j.id.equals(id))).getSingle();
    expect(joueur.nom, 'Alice');
  });

  test('une partie à 4 joueurs avec une manche se crée sans violer les contraintes', () async {
    final aliceId = await db.into(db.joueurs).insert(JoueursCompanion.insert(nom: 'Alice'));
    final bobId = await db.into(db.joueurs).insert(JoueursCompanion.insert(nom: 'Bob'));
    final partieId =
        await db.into(db.parties).insert(PartiesCompanion.insert(nombreJoueurs: 4));
    await db.into(db.manches).insert(ManchesCompanion.insert(
          partieId: partieId,
          numero: 1,
          contrat: 'garde',
          preneurId: aliceId,
          pointsPreneur: 49,
          bouts: 2,
          petitAuBout: 'preneur',
          poignee: 'simple',
          chelem: 'aucun',
        ));
    final manches = await db.select(db.manches).get();
    expect(manches, hasLength(1));
    expect(manches.single.preneurId, aliceId);
    expect(bobId, isNotNull);
  });
}
```

- [ ] **Step 6: Lancer les tests**

Run: `flutter test test/db/database_test.dart`

Expected: PASS (2 tests).

- [ ] **Step 7: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/db/database.dart lib/db/database.g.dart \
  test/db/database_test.dart android ios linux macos windows web analysis_options.yaml
git commit -m "feat(db): squelette Flutter + schéma Drift (Joueurs/Parties/PartieJoueurs/Manches)"
```

---

## Task 2: Moteur de calcul du score (Dart pur)

**Files:**
- Create: `lib/scoring/tarot_score_engine.dart`

**Interfaces:**
- Produces:
  - `enum Contrat { prise, garde, gardeSans, gardeContre }` avec `.coefficient` (1/2/4/6)
  - `enum PetitAuBout { aucun, preneur, defense }`
  - `enum Poignee { aucune, simple, double, triple }` avec `.prime` (0/20/30/40)
  - `enum ChelemType { aucun, preneurAnonceReussi, preneurNonAnonceReussi, preneurAnonceRate, defenseInflige }`
  - `int seuilPreneur(int bouts)` — 56/51/41/36
  - `class ManchInput` (champs : `nombreJoueurs`, `contrat`, `pointsPreneur`, `bouts`,
    `petitAuBout`, `poignee`, `chelem`, `joueurIds: List<int>`, `preneurId: int`,
    `appeleId: int?`)
  - `class ManchResult` (champs : `deltasParJoueur: Map<int, int>`, `montant: int`,
    `preneurGagne: bool`)
  - `ManchResult calculerManche(ManchInput input)`

- [ ] **Step 1: Écrire le test qui échoue (exemple officiel #1 du règlement FFT)**

Create `test/scoring/tarot_score_engine_test.dart` (fichier complet, sera enrichi en Task 3) :

```dart
import 'package:comptage_tarot/scoring/tarot_score_engine.dart';
import 'package:test/test.dart';

void main() {
  group('exemples officiels FFT (4 joueurs)', () {
    test('exemple 1 : Garde, poignée simple, petit au bout preneur, 49 pts / 2 bouts', () {
      final result = calculerManche(const ManchInput(
        nombreJoueurs: 4,
        contrat: Contrat.garde,
        pointsPreneur: 49,
        bouts: 2,
        petitAuBout: PetitAuBout.preneur,
        poignee: Poignee.simple,
        chelem: ChelemType.aucun,
        joueurIds: [1, 2, 3, 4],
        preneurId: 1,
      ));
      expect(result.montant, 106);
      expect(result.preneurGagne, isTrue);
      expect(result.deltasParJoueur, {1: 318, 2: -106, 3: -106, 4: -106});
    });
  });
}
```

- [ ] **Step 2: Lancer le test, vérifier qu'il échoue**

Run: `flutter test test/scoring/tarot_score_engine_test.dart`

Expected: FAIL — `Error: Not found: 'package:comptage_tarot/scoring/tarot_score_engine.dart'`.

- [ ] **Step 3: Implémenter le moteur**

Create `lib/scoring/tarot_score_engine.dart`:

```dart
enum Contrat { prise, garde, gardeSans, gardeContre }

extension ContratCoefficient on Contrat {
  int get coefficient {
    switch (this) {
      case Contrat.prise:
        return 1;
      case Contrat.garde:
        return 2;
      case Contrat.gardeSans:
        return 4;
      case Contrat.gardeContre:
        return 6;
    }
  }
}

enum PetitAuBout { aucun, preneur, defense }

enum Poignee { aucune, simple, double, triple }

extension PoigneePrime on Poignee {
  int get prime {
    switch (this) {
      case Poignee.aucune:
        return 0;
      case Poignee.simple:
        return 20;
      case Poignee.double:
        return 30;
      case Poignee.triple:
        return 40;
    }
  }
}

enum ChelemType {
  aucun,
  preneurAnonceReussi,
  preneurNonAnonceReussi,
  preneurAnonceRate,
  defenseInflige,
}

/// Seuil de points que le preneur doit atteindre selon le nombre de bouts
/// détenus dans ses levées (règlement FFT, version du 1er juillet 2012).
int seuilPreneur(int bouts) {
  switch (bouts) {
    case 0:
      return 56;
    case 1:
      return 51;
    case 2:
      return 41;
    case 3:
      return 36;
    default:
      throw ArgumentError('bouts doit être compris entre 0 et 3, reçu: $bouts');
  }
}

class ManchInput {
  final int nombreJoueurs;
  final Contrat contrat;
  final int pointsPreneur;
  final int bouts;
  final PetitAuBout petitAuBout;
  final Poignee poignee;
  final ChelemType chelem;
  final List<int> joueurIds;
  final int preneurId;
  final int? appeleId;

  const ManchInput({
    required this.nombreJoueurs,
    required this.contrat,
    required this.pointsPreneur,
    required this.bouts,
    this.petitAuBout = PetitAuBout.aucun,
    this.poignee = Poignee.aucune,
    this.chelem = ChelemType.aucun,
    required this.joueurIds,
    required this.preneurId,
    this.appeleId,
  });
}

class ManchResult {
  final Map<int, int> deltasParJoueur;
  final int montant;
  final bool preneurGagne;

  const ManchResult({
    required this.deltasParJoueur,
    required this.montant,
    required this.preneurGagne,
  });
}

/// Calcule la répartition des points d'une manche entre tous les joueurs
/// d'une partie, en appliquant exactement le barème officiel FFT.
///
/// Le "montant" est la valeur signée (positive si le preneur gagne, négative
/// sinon) après application du petit au bout, de la poignée et du chelem
/// poolé du preneur — avant multiplication par le coefficient de
/// distribution (3 à 4 joueurs, 2 à 3 joueurs, 2/1 ou 4 à 5 joueurs).
ManchResult calculerManche(ManchInput input) {
  if (input.nombreJoueurs != 3 && input.nombreJoueurs != 4 && input.nombreJoueurs != 5) {
    throw ArgumentError(
        'nombreJoueurs doit être 3, 4 ou 5, reçu: ${input.nombreJoueurs}');
  }
  if (input.pointsPreneur < 0 || input.pointsPreneur > 91) {
    throw ArgumentError(
        'pointsPreneur doit être entre 0 et 91, reçu: ${input.pointsPreneur}');
  }
  if (input.nombreJoueurs == 5 && input.appeleId == null) {
    throw ArgumentError('appeleId est requis à 5 joueurs');
  }

  final seuil = seuilPreneur(input.bouts);
  final ecart = (input.pointsPreneur - seuil).abs();
  final preneurGagne = input.pointsPreneur >= seuil;
  final signe = preneurGagne ? 1 : -1;
  final coefficient = input.contrat.coefficient;

  var net = signe * (25 + ecart) * coefficient;

  if (input.petitAuBout == PetitAuBout.preneur) {
    net += 10 * coefficient;
  } else if (input.petitAuBout == PetitAuBout.defense) {
    net -= 10 * coefficient;
  }

  if (input.poignee != Poignee.aucune) {
    net += signe * input.poignee.prime;
  }

  switch (input.chelem) {
    case ChelemType.preneurAnonceReussi:
      net += 400;
      break;
    case ChelemType.preneurNonAnonceReussi:
      net += 200;
      break;
    case ChelemType.preneurAnonceRate:
      net -= 200;
      break;
    case ChelemType.aucun:
    case ChelemType.defenseInflige:
      break;
  }

  final montant = net;
  final estSeul = input.nombreJoueurs == 5 && input.appeleId == input.preneurId;
  final deltas = <int, int>{};

  if (input.nombreJoueurs == 4) {
    deltas[input.preneurId] = montant * 3;
    for (final id in input.joueurIds) {
      if (id != input.preneurId) deltas[id] = -montant;
    }
  } else if (input.nombreJoueurs == 3) {
    deltas[input.preneurId] = montant * 2;
    for (final id in input.joueurIds) {
      if (id != input.preneurId) deltas[id] = -montant;
    }
  } else if (estSeul) {
    deltas[input.preneurId] = montant * 4;
    for (final id in input.joueurIds) {
      if (id != input.preneurId) deltas[id] = -montant;
    }
  } else {
    deltas[input.preneurId] = montant * 2;
    deltas[input.appeleId!] = montant;
    for (final id in input.joueurIds) {
      if (id != input.preneurId && id != input.appeleId) deltas[id] = -montant;
    }
  }

  if (input.chelem == ChelemType.defenseInflige) {
    for (final id in input.joueurIds) {
      final estAttaque = id == input.preneurId || (!estSeul && id == input.appeleId);
      if (!estAttaque) {
        deltas[id] = (deltas[id] ?? 0) + 200;
      }
    }
  }

  return ManchResult(deltasParJoueur: deltas, montant: montant, preneurGagne: preneurGagne);
}
```

- [ ] **Step 4: Lancer le test, vérifier qu'il passe**

Run: `flutter test test/scoring/tarot_score_engine_test.dart`

Expected: PASS (1 test).

- [ ] **Step 5: Commit**

```bash
git add lib/scoring/tarot_score_engine.dart test/scoring/tarot_score_engine_test.dart
git commit -m "feat(scoring): moteur de calcul Dart pur du barème FFT"
```

---

## Task 3: Tests complets du moteur de calcul

**Files:**
- Modify: `test/scoring/tarot_score_engine_test.dart`

**Interfaces:**
- Consumes: `calculerManche`, `ManchInput`, `ManchResult`, `Contrat`, `PetitAuBout`,
  `Poignee`, `ChelemType` (Task 2).

**Ne pas passer à l'UI (Tasks 5-7) avant que tous ces tests passent** — voir Success
Criteria de DESIGN.md.

- [ ] **Step 1: Ajouter les 4 exemples officiels FFT restants + 4 cas dérivés à la main**

Replace the full content of `test/scoring/tarot_score_engine_test.dart`:

```dart
import 'package:comptage_tarot/scoring/tarot_score_engine.dart';
import 'package:test/test.dart';

void main() {
  group('exemples officiels FFT (4 joueurs)', () {
    test('exemple 1 : Garde, poignée simple, petit au bout preneur, 49 pts / 2 bouts', () {
      final result = calculerManche(const ManchInput(
        nombreJoueurs: 4,
        contrat: Contrat.garde,
        pointsPreneur: 49,
        bouts: 2,
        petitAuBout: PetitAuBout.preneur,
        poignee: Poignee.simple,
        chelem: ChelemType.aucun,
        joueurIds: [1, 2, 3, 4],
        preneurId: 1,
      ));
      expect(result.montant, 106);
      expect(result.preneurGagne, isTrue);
      expect(result.deltasParJoueur, {1: 318, 2: -106, 3: -106, 4: -106});
    });

    test('exemple 2 : Garde Sans le chien, 4 pts au-dessus du seuil, petit au bout défense',
        () {
      final result = calculerManche(const ManchInput(
        nombreJoueurs: 4,
        contrat: Contrat.gardeSans,
        pointsPreneur: 55,
        bouts: 1,
        petitAuBout: PetitAuBout.defense,
        poignee: Poignee.aucune,
        chelem: ChelemType.aucun,
        joueurIds: [1, 2, 3, 4],
        preneurId: 1,
      ));
      expect(result.montant, 76);
      expect(result.preneurGagne, isTrue);
      expect(result.deltasParJoueur, {1: 228, 2: -76, 3: -76, 4: -76});
    });

    test('exemple 3 : Prise chutée de 7, poignée simple preneur, petit au bout preneur', () {
      final result = calculerManche(const ManchInput(
        nombreJoueurs: 4,
        contrat: Contrat.prise,
        pointsPreneur: 49,
        bouts: 0,
        petitAuBout: PetitAuBout.preneur,
        poignee: Poignee.simple,
        chelem: ChelemType.aucun,
        joueurIds: [1, 2, 3, 4],
        preneurId: 1,
      ));
      expect(result.montant, -42);
      expect(result.preneurGagne, isFalse);
      expect(result.deltasParJoueur, {1: -126, 2: 42, 3: 42, 4: 42});
    });

    test('exemple 4 : Garde gagnée de 11 pts, poignée présentée par la défense', () {
      final result = calculerManche(const ManchInput(
        nombreJoueurs: 4,
        contrat: Contrat.garde,
        pointsPreneur: 67,
        bouts: 0,
        petitAuBout: PetitAuBout.aucun,
        poignee: Poignee.simple,
        chelem: ChelemType.aucun,
        joueurIds: [1, 2, 3, 4],
        preneurId: 1,
      ));
      expect(result.montant, 92);
      expect(result.preneurGagne, isTrue);
      expect(result.deltasParJoueur, {1: 276, 2: -92, 3: -92, 4: -92});
    });

    test('exemple 5 : Garde, chelem annoncé et réussi, poignée simple, petit au bout preneur',
        () {
      final result = calculerManche(const ManchInput(
        nombreJoueurs: 4,
        contrat: Contrat.garde,
        pointsPreneur: 87,
        bouts: 2,
        petitAuBout: PetitAuBout.preneur,
        poignee: Poignee.simple,
        chelem: ChelemType.preneurAnonceReussi,
        joueurIds: [1, 2, 3, 4],
        preneurId: 1,
      ));
      expect(result.montant, 582);
      expect(result.preneurGagne, isTrue);
      expect(result.deltasParJoueur, {1: 1746, 2: -582, 3: -582, 4: -582});
    });
  });

  group('cas dérivés à la main (branches non couvertes par les 5 exemples)', () {
    test('3 joueurs : distribution ×2 pour le preneur, pas de demi-points', () {
      final result = calculerManche(const ManchInput(
        nombreJoueurs: 3,
        contrat: Contrat.prise,
        pointsPreneur: 60,
        bouts: 0,
        joueurIds: [1, 2, 3],
        preneurId: 1,
      ));
      // seuil(0)=56, écart=4, net=(25+4)*1=29
      expect(result.montant, 29);
      expect(result.deltasParJoueur, {1: 58, 2: -29, 3: -29});
    });

    test('5 joueurs, associé réel : preneur ×2, appelé ×1, 3 défenseurs ∓montant', () {
      final result = calculerManche(const ManchInput(
        nombreJoueurs: 5,
        contrat: Contrat.garde,
        pointsPreneur: 55,
        bouts: 1,
        joueurIds: [1, 2, 3, 4, 5],
        preneurId: 1,
        appeleId: 2,
      ));
      // seuil(1)=51, écart=4, net=(25+4)*2=58
      expect(result.montant, 58);
      expect(result.deltasParJoueur, {1: 116, 2: 58, 3: -58, 4: -58, 5: -58});
    });

    test('5 joueurs, preneur seul (appeleId == preneurId) : preneur ×4', () {
      final result = calculerManche(const ManchInput(
        nombreJoueurs: 5,
        contrat: Contrat.gardeSans,
        pointsPreneur: 50,
        bouts: 2,
        joueurIds: [1, 2, 3, 4, 5],
        preneurId: 1,
        appeleId: 1,
      ));
      // seuil(2)=41, écart=9, net=(25+9)*4=136
      expect(result.montant, 136);
      expect(result.deltasParJoueur, {1: 544, 2: -136, 3: -136, 4: -136, 5: -136});
    });

    test('chelem infligé par la défense : +200 forfaitaire à chaque défenseur, non poolé', () {
      final result = calculerManche(const ManchInput(
        nombreJoueurs: 4,
        contrat: Contrat.garde,
        pointsPreneur: 0,
        bouts: 0,
        petitAuBout: PetitAuBout.defense,
        chelem: ChelemType.defenseInflige,
        joueurIds: [1, 2, 3, 4],
        preneurId: 1,
      ));
      // seuil(0)=56, écart=56, net=-(25+56)*2=-162, petit au bout défense: -20 => -182
      expect(result.montant, -182);
      expect(result.preneurGagne, isFalse);
      // chaque défenseur reçoit +182 (marque normale) puis +200 (chelem infligé) = 382
      expect(result.deltasParJoueur, {1: -546, 2: 382, 3: 382, 4: 382});
    });
  });

  group('validation des entrées', () {
    test('pointsPreneur hors [0, 91] lève une ArgumentError', () {
      expect(
        () => calculerManche(const ManchInput(
          nombreJoueurs: 4,
          contrat: Contrat.prise,
          pointsPreneur: 92,
          bouts: 0,
          joueurIds: [1, 2, 3, 4],
          preneurId: 1,
        )),
        throwsArgumentError,
      );
    });

    test('5 joueurs sans appeleId lève une ArgumentError', () {
      expect(
        () => calculerManche(const ManchInput(
          nombreJoueurs: 5,
          contrat: Contrat.prise,
          pointsPreneur: 50,
          bouts: 0,
          joueurIds: [1, 2, 3, 4, 5],
          preneurId: 1,
        )),
        throwsArgumentError,
      );
    });
  });
}
```

- [ ] **Step 2: Lancer tous les tests du moteur**

Run: `flutter test test/scoring/tarot_score_engine_test.dart`

Expected: PASS (11 tests : 5 officiels + 4 dérivés + 2 validation).

- [ ] **Step 3: Commit**

```bash
git add test/scoring/tarot_score_engine_test.dart
git commit -m "test(scoring): couverture complète — 5 exemples officiels FFT + 4 cas dérivés"
```

---

## Task 4: Couche DAO (CRUD joueurs/parties + upsert manche)

**Files:**
- Modify: `lib/db/database.dart`
- Modify: `test/db/database_test.dart`

**Interfaces:**
- Consumes: `Contrat`, `PetitAuBout`, `Poignee`, `ChelemType` (Task 2, via `.name` /
  `.values.byName`).
- Produces (méthodes ajoutées à `AppDatabase`):
  - `Future<int> creerJoueur(String nom)`
  - `Future<void> modifierJoueur(int id, String nom)`
  - `Future<void> supprimerJoueur(int id)`
  - `Stream<List<Joueur>> watchJoueurs()`
  - `Future<int> creerPartie(int nombreJoueurs, List<int> joueurIds)`
  - `Stream<List<Partie>> watchParties()`
  - `Future<List<Joueur>> joueursDeLaPartie(int partieId)`
  - `Stream<List<Manche>> watchManches(int partieId)`
  - `Future<int> enregistrerManche({int? id, required int partieId, required Contrat contrat, required int preneurId, int? appeleId, required int pointsPreneur, required int bouts, required PetitAuBout petitAuBout, required Poignee poignee, required ChelemType chelem})`
  - `Future<void> supprimerManche(int id)`

- [ ] **Step 1: Écrire les tests qui échouent pour l'upsert et la suppression**

Append to `test/db/database_test.dart` (add inside `main()`, after the existing tests):

```dart
  test('enregistrerManche crée une manche avec numero auto-incrémenté', () async {
    final aliceId = await db.into(db.joueurs).insert(JoueursCompanion.insert(nom: 'Alice'));
    await db.into(db.joueurs).insert(JoueursCompanion.insert(nom: 'Bob'));
    final partieId =
        await db.into(db.parties).insert(PartiesCompanion.insert(nombreJoueurs: 4));

    final id1 = await db.enregistrerManche(
      partieId: partieId,
      contrat: Contrat.garde,
      preneurId: aliceId,
      pointsPreneur: 49,
      bouts: 2,
      petitAuBout: PetitAuBout.preneur,
      poignee: Poignee.simple,
      chelem: ChelemType.aucun,
    );
    final id2 = await db.enregistrerManche(
      partieId: partieId,
      contrat: Contrat.prise,
      preneurId: aliceId,
      pointsPreneur: 40,
      bouts: 1,
      petitAuBout: PetitAuBout.aucun,
      poignee: Poignee.aucune,
      chelem: ChelemType.aucun,
    );

    final manches = await db.watchManches(partieId).first;
    expect(manches, hasLength(2));
    expect(manches[0].id, id1);
    expect(manches[0].numero, 1);
    expect(manches[1].id, id2);
    expect(manches[1].numero, 2);
  });

  test('enregistrerManche avec id existant met à jour la manche sans créer de doublon',
      () async {
    final aliceId = await db.into(db.joueurs).insert(JoueursCompanion.insert(nom: 'Alice'));
    final partieId =
        await db.into(db.parties).insert(PartiesCompanion.insert(nombreJoueurs: 4));
    final id = await db.enregistrerManche(
      partieId: partieId,
      contrat: Contrat.prise,
      preneurId: aliceId,
      pointsPreneur: 40,
      bouts: 1,
      petitAuBout: PetitAuBout.aucun,
      poignee: Poignee.aucune,
      chelem: ChelemType.aucun,
    );

    await db.enregistrerManche(
      id: id,
      partieId: partieId,
      contrat: Contrat.garde,
      preneurId: aliceId,
      pointsPreneur: 60,
      bouts: 2,
      petitAuBout: PetitAuBout.aucun,
      poignee: Poignee.aucune,
      chelem: ChelemType.aucun,
    );

    final manches = await db.watchManches(partieId).first;
    expect(manches, hasLength(1));
    expect(manches.single.contrat, 'garde');
    expect(manches.single.pointsPreneur, 60);
  });

  test('supprimerManche retire la manche', () async {
    final aliceId = await db.into(db.joueurs).insert(JoueursCompanion.insert(nom: 'Alice'));
    final partieId =
        await db.into(db.parties).insert(PartiesCompanion.insert(nombreJoueurs: 4));
    final id = await db.enregistrerManche(
      partieId: partieId,
      contrat: Contrat.prise,
      preneurId: aliceId,
      pointsPreneur: 40,
      bouts: 1,
      petitAuBout: PetitAuBout.aucun,
      poignee: Poignee.aucune,
      chelem: ChelemType.aucun,
    );
    await db.supprimerManche(id);
    final manches = await db.watchManches(partieId).first;
    expect(manches, isEmpty);
  });

  test('creerPartie associe les joueurs dans l\'ordre fourni', () async {
    final aliceId = await db.into(db.joueurs).insert(JoueursCompanion.insert(nom: 'Alice'));
    final bobId = await db.into(db.joueurs).insert(JoueursCompanion.insert(nom: 'Bob'));
    final partieId = await db.creerPartie(4, [bobId, aliceId]);
    final joueurs = await db.joueursDeLaPartie(partieId);
    expect(joueurs.map((j) => j.id), [bobId, aliceId]);
  });
```

Also add the import at the top of the file:

```dart
import 'package:comptage_tarot/scoring/tarot_score_engine.dart';
```

- [ ] **Step 2: Lancer les tests, vérifier qu'ils échouent**

Run: `flutter test test/db/database_test.dart`

Expected: FAIL — `The method 'enregistrerManche' isn't defined for the type 'AppDatabase'`
(et similaires pour `creerPartie`, `joueursDeLaPartie`, `watchManches`, `supprimerManche`).

- [ ] **Step 3: Implémenter les méthodes DAO**

In `lib/db/database.dart`, add this import at the top:

```dart
import '../scoring/tarot_score_engine.dart';
```

Replace the `AppDatabase` class body:

```dart
@DriftDatabase(tables: [Joueurs, Parties, PartieJoueurs, Manches])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  Future<int> creerJoueur(String nom) =>
      into(joueurs).insert(JoueursCompanion.insert(nom: nom));

  Future<void> modifierJoueur(int id, String nom) =>
      (update(joueurs)..where((j) => j.id.equals(id)))
          .write(JoueursCompanion(nom: Value(nom)));

  Future<void> supprimerJoueur(int id) =>
      (delete(joueurs)..where((j) => j.id.equals(id))).go();

  Stream<List<Joueur>> watchJoueurs() =>
      (select(joueurs)..orderBy([(j) => OrderingTerm(expression: j.nom)])).watch();

  Future<int> creerPartie(int nombreJoueurs, List<int> joueurIds) async {
    final partieId = await into(parties)
        .insert(PartiesCompanion.insert(nombreJoueurs: nombreJoueurs));
    for (var i = 0; i < joueurIds.length; i++) {
      await into(partieJoueurs).insert(PartieJoueursCompanion.insert(
        partieId: partieId,
        joueurId: joueurIds[i],
        ordre: i,
      ));
    }
    return partieId;
  }

  Stream<List<Partie>> watchParties() => (select(parties)
        ..orderBy([(p) => OrderingTerm(expression: p.dateCreation, mode: OrderingMode.desc)]))
      .watch();

  Future<List<Joueur>> joueursDeLaPartie(int partieId) async {
    final query = select(partieJoueurs).join([
      innerJoin(joueurs, joueurs.id.equalsExp(partieJoueurs.joueurId)),
    ])
      ..where(partieJoueurs.partieId.equals(partieId))
      ..orderBy([OrderingTerm(expression: partieJoueurs.ordre)]);
    final rows = await query.get();
    return rows.map((row) => row.readTable(joueurs)).toList();
  }

  Stream<List<Manche>> watchManches(int partieId) => (select(manches)
        ..where((m) => m.partieId.equals(partieId))
        ..orderBy([(m) => OrderingTerm(expression: m.numero)]))
      .watch();

  Future<int> enregistrerManche({
    int? id,
    required int partieId,
    required Contrat contrat,
    required int preneurId,
    int? appeleId,
    required int pointsPreneur,
    required int bouts,
    required PetitAuBout petitAuBout,
    required Poignee poignee,
    required ChelemType chelem,
  }) async {
    final companion = ManchesCompanion(
      partieId: Value(partieId),
      contrat: Value(contrat.name),
      preneurId: Value(preneurId),
      appeleId: Value(appeleId),
      pointsPreneur: Value(pointsPreneur),
      bouts: Value(bouts),
      petitAuBout: Value(petitAuBout.name),
      poignee: Value(poignee.name),
      chelem: Value(chelem.name),
    );

    if (id != null) {
      await (update(manches)..where((m) => m.id.equals(id))).write(companion);
      return id;
    }

    final maxNumero = await (selectOnly(manches)
          ..addColumns([manches.numero.max()])
          ..where(manches.partieId.equals(partieId)))
        .map((row) => row.read(manches.numero.max()))
        .getSingleOrNull();
    final prochainNumero = (maxNumero ?? 0) + 1;

    return into(manches).insert(companion.copyWith(numero: Value(prochainNumero)));
  }

  Future<void> supprimerManche(int id) =>
      (delete(manches)..where((m) => m.id.equals(id))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'tarot.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
```

- [ ] **Step 4: Lancer tous les tests DB**

Run: `flutter test test/db/database_test.dart`

Expected: PASS (7 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/db/database.dart test/db/database_test.dart
git commit -m "feat(db): DAO joueurs/parties + upsert/suppression de manche"
```

---

## Task 5: Écran "Gestion des joueurs"

**Files:**
- Create: `lib/providers/database_provider.dart`
- Create: `lib/screens/players_screen.dart`
- Modify: `lib/main.dart`

**Interfaces:**
- Consumes: `AppDatabase`, `watchJoueurs`, `creerJoueur`, `modifierJoueur`, `supprimerJoueur`
  (Task 4).
- Produces: `databaseProvider` (Riverpod `Provider<AppDatabase>`), `joueursProvider`
  (`StreamProvider<List<Joueur>>`), route `/joueurs`.

- [ ] **Step 1: Créer les providers Riverpod de base**

Create `lib/providers/database_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final joueursProvider = StreamProvider<List<Joueur>>((ref) {
  return ref.watch(databaseProvider).watchJoueurs();
});

final partiesProvider = StreamProvider<List<Partie>>((ref) {
  return ref.watch(databaseProvider).watchParties();
});
```

- [ ] **Step 2: Créer l'écran de gestion des joueurs**

Create `lib/screens/players_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import '../providers/database_provider.dart';

class PlayersScreen extends ConsumerWidget {
  const PlayersScreen({super.key});

  Future<void> _ouvrirFormulaire(BuildContext context, WidgetRef ref, {Joueur? joueur}) async {
    final controller = TextEditingController(text: joueur?.nom ?? '');
    final nom = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(joueur == null ? 'Nouveau joueur' : 'Modifier le joueur'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nom'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    if (nom == null || nom.isEmpty) return;
    final db = ref.read(databaseProvider);
    if (joueur == null) {
      await db.creerJoueur(nom);
    } else {
      await db.modifierJoueur(joueur.id, nom);
    }
  }

  Future<void> _confirmerSuppression(BuildContext context, WidgetRef ref, Joueur joueur) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce joueur ?'),
        content: Text('${joueur.nom} sera retiré de la liste réutilisable.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirme == true) {
      await ref.read(databaseProvider).supprimerJoueur(joueur.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final joueursAsync = ref.watch(joueursProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des joueurs')),
      body: joueursAsync.when(
        data: (joueurs) => joueurs.isEmpty
            ? const Center(child: Text('Aucun joueur — ajoutez-en un avec le bouton +'))
            : ListView.builder(
                itemCount: joueurs.length,
                itemBuilder: (context, index) {
                  final joueur = joueurs[index];
                  return ListTile(
                    title: Text(joueur.nom),
                    onTap: () => _ouvrirFormulaire(context, ref, joueur: joueur),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _confirmerSuppression(context, ref, joueur),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erreur : $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _ouvrirFormulaire(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

- [ ] **Step 3: Brancher `ProviderScope` et une route minimale dans `main.dart`**

Replace the content of `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/players_screen.dart';

void main() {
  runApp(const ProviderScope(child: TarotApp()));
}

class TarotApp extends StatelessWidget {
  const TarotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comptage Tarot',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const PlayersScreen(),
    );
  }
}
```

(La navigation Accueil → Gestion des joueurs sera reconnectée à la Task 6 quand l'écran
Accueil existera ; `home:` pointe temporairement sur `PlayersScreen` pour valider l'écran de
façon isolée.)

- [ ] **Step 4: Vérifier que le projet compile et que les tests passent toujours**

Run: `flutter analyze && flutter test`

Expected: aucune erreur d'analyse, tous les tests (moteur + DB) toujours PASS.

- [ ] **Step 5: Lancer l'app sur l'émulateur et vérifier manuellement**

Run:
```bash
flutter emulators --launch Medium_Phone
flutter run -d emulator-5554
```

Manually verify: ajouter 2 joueurs, éditer le nom du premier, supprimer le second, fermer et
relancer l'app — la liste doit persister.

- [ ] **Step 6: Commit**

```bash
git add lib/providers/database_provider.dart lib/screens/players_screen.dart lib/main.dart
git commit -m "feat(ui): écran Gestion des joueurs (CRUD complet)"
```

---

## Task 6: Écrans Accueil, Config partie, Tableau de scores

**Files:**
- Create: `lib/screens/home_screen.dart`
- Create: `lib/screens/game_config_screen.dart`
- Create: `lib/screens/score_table_screen.dart`
- Modify: `lib/main.dart`

**Interfaces:**
- Consumes: `partiesProvider`, `joueursProvider`, `databaseProvider` (Task 5),
  `creerPartie`, `joueursDeLaPartie`, `watchManches` (Task 4), `calculerManche`, `ManchInput`,
  `Contrat`, `PetitAuBout`, `Poignee`, `ChelemType` (Task 2).
- Produces:
  - `manchesProvider` (`StreamProvider.family<List<Manche>, int>`)
  - `joueursDePartieProvider` (`FutureProvider.family<List<Joueur>, int>`)
  - Navigation: Accueil → (nouvelle partie) → Config partie → Tableau de scores ; Accueil →
    (reprendre) → Tableau de scores ; Accueil → Gestion des joueurs.
  - `ScoreTableScreen` expose un bouton "Ajouter une manche" qui pushe vers
    `RoundEntryScreen` (Task 7) avec `partieId` et, en édition, une `Manche` existante — cette
    route est créée ici mais `RoundEntryScreen` n'existe qu'à la Task 7 ; Task 6 laisse un
    `TODO` de navigation qui sera câblé en Task 7 (le bouton existe, son `onPressed` est
    complété à la Task 7 Step 3).

- [ ] **Step 1: Ajouter les providers family**

Append to `lib/providers/database_provider.dart`:

```dart

final manchesProvider = StreamProvider.family<List<Manche>, int>((ref, partieId) {
  return ref.watch(databaseProvider).watchManches(partieId);
});

final joueursDePartieProvider = FutureProvider.family<List<Joueur>, int>((ref, partieId) {
  return ref.watch(databaseProvider).joueursDeLaPartie(partieId);
});
```

- [ ] **Step 2: Écran Accueil**

Create `lib/screens/home_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/database_provider.dart';
import 'game_config_screen.dart';
import 'players_screen.dart';
import 'score_table_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partiesAsync = ref.watch(partiesProvider);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comptage Tarot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            tooltip: 'Gestion des joueurs',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PlayersScreen()),
            ),
          ),
        ],
      ),
      body: partiesAsync.when(
        data: (parties) => parties.isEmpty
            ? const Center(child: Text('Aucune partie — créez-en une avec le bouton +'))
            : ListView.builder(
                itemCount: parties.length,
                itemBuilder: (context, index) {
                  final partie = parties[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text('${partie.nombreJoueurs}')),
                    title: Text('Partie du ${dateFormat.format(partie.dateCreation)}'),
                    subtitle: Text('${partie.nombreJoueurs} joueurs'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScoreTableScreen(partieId: partie.id),
                      ),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erreur : $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GameConfigScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

- [ ] **Step 3: Ajouter `intl` aux dépendances**

Run: `flutter pub add intl`

- [ ] **Step 4: Écran Config partie**

Create `lib/screens/game_config_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/database_provider.dart';
import 'score_table_screen.dart';

class GameConfigScreen extends ConsumerStatefulWidget {
  const GameConfigScreen({super.key});

  @override
  ConsumerState<GameConfigScreen> createState() => _GameConfigScreenState();
}

class _GameConfigScreenState extends ConsumerState<GameConfigScreen> {
  int _nombreJoueurs = 4;
  final Set<int> _selectionnes = {};

  @override
  Widget build(BuildContext context) {
    final joueursAsync = ref.watch(joueursProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle partie')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 3, label: Text('3 joueurs')),
                ButtonSegment(value: 4, label: Text('4 joueurs')),
                ButtonSegment(value: 5, label: Text('5 joueurs')),
              ],
              selected: {_nombreJoueurs},
              onSelectionChanged: (selection) {
                setState(() {
                  _nombreJoueurs = selection.first;
                  _selectionnes.clear();
                });
              },
            ),
          ),
          Expanded(
            child: joueursAsync.when(
              data: (joueurs) => ListView.builder(
                itemCount: joueurs.length,
                itemBuilder: (context, index) {
                  final joueur = joueurs[index];
                  final selectionne = _selectionnes.contains(joueur.id);
                  return CheckboxListTile(
                    title: Text(joueur.nom),
                    value: selectionne,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          if (_selectionnes.length < _nombreJoueurs) {
                            _selectionnes.add(joueur.id);
                          }
                        } else {
                          _selectionnes.remove(joueur.id);
                        }
                      });
                    },
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Erreur : $error')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: _selectionnes.length == _nombreJoueurs
                  ? () async {
                      final db = ref.read(databaseProvider);
                      final partieId =
                          await db.creerPartie(_nombreJoueurs, _selectionnes.toList());
                      if (!context.mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScoreTableScreen(partieId: partieId),
                        ),
                      );
                    }
                  : null,
              child: Text(
                  'Démarrer la partie (${_selectionnes.length}/$_nombreJoueurs joueurs)'),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Écran Tableau de scores (avec ligne cumulée sticky)**

Create `lib/screens/score_table_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import '../providers/database_provider.dart';
import '../scoring/tarot_score_engine.dart';

class ScoreTableScreen extends ConsumerWidget {
  final int partieId;

  const ScoreTableScreen({super.key, required this.partieId});

  ManchInput _inputDepuisManche(Manche manche, List<Joueur> joueurs) {
    return ManchInput(
      nombreJoueurs: joueurs.length,
      contrat: Contrat.values.byName(manche.contrat),
      pointsPreneur: manche.pointsPreneur,
      bouts: manche.bouts,
      petitAuBout: PetitAuBout.values.byName(manche.petitAuBout),
      poignee: Poignee.values.byName(manche.poignee),
      chelem: ChelemType.values.byName(manche.chelem),
      joueurIds: joueurs.map((j) => j.id).toList(),
      preneurId: manche.preneurId,
      appeleId: manche.appeleId,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final joueursAsync = ref.watch(joueursDePartieProvider(partieId));
    final manchesAsync = ref.watch(manchesProvider(partieId));

    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de scores')),
      body: joueursAsync.when(
        data: (joueurs) => manchesAsync.when(
          data: (manches) {
            final resultats = manches.map((m) => _inputDepuisManche(m, joueurs))
                .map(calculerManche)
                .toList();
            final totaux = {for (final j in joueurs) j.id: 0};
            for (final resultat in resultats) {
              resultat.deltasParJoueur.forEach((joueurId, delta) {
                totaux[joueurId] = (totaux[joueurId] ?? 0) + delta;
              });
            }

            return Column(
              children: [
                _LigneJoueurs(joueurs: joueurs),
                _LigneTotauxSticky(joueurs: joueurs, totaux: totaux),
                Expanded(
                  child: manches.isEmpty
                      ? const Center(child: Text('Aucune manche — ajoutez-en une avec +'))
                      : ListView.builder(
                          itemCount: manches.length,
                          itemBuilder: (context, index) {
                            final manche = manches[index];
                            final resultat = resultats[index];
                            return ListTile(
                              onLongPress: () {
                                // Câblé à la Task 7 : ouvre RoundEntryScreen pré-rempli.
                              },
                              leading: CircleAvatar(child: Text('${manche.numero}')),
                              title: Row(
                                children: joueurs
                                    .map((j) => Expanded(
                                          child: Text(
                                            '${resultat.deltasParJoueur[j.id] ?? 0}',
                                            textAlign: TextAlign.center,
                                          ),
                                        ))
                                    .toList(),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Erreur : $error')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erreur : $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Câblé à la Task 7 : ouvre RoundEntryScreen en création.
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _LigneJoueurs extends StatelessWidget {
  final List<Joueur> joueurs;
  const _LigneJoueurs({required this.joueurs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: joueurs
            .map((j) => Expanded(
                  child: Text(j.nom, textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium),
                ))
            .toList(),
      ),
    );
  }
}

class _LigneTotauxSticky extends StatelessWidget {
  final List<Joueur> joueurs;
  final Map<int, int> totaux;
  const _LigneTotauxSticky({required this.joueurs, required this.totaux});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: joueurs
            .map((j) => Expanded(
                  child: Text(
                    '${totaux[j.id] ?? 0}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
```

(`_LigneTotauxSticky` reste fixée sous `_LigneJoueurs` car elle est placée hors du
`ListView` défilant — seule la liste des manches scrolle.)

- [ ] **Step 6: Pointer `main.dart` sur `HomeScreen`**

In `lib/main.dart`, replace:
```dart
import 'screens/players_screen.dart';
```
with:
```dart
import 'screens/home_screen.dart';
```
and replace `home: const PlayersScreen(),` with `home: const HomeScreen(),`.

- [ ] **Step 7: Vérifier compilation et tests**

Run: `flutter analyze && flutter test`

Expected: aucune erreur, tous les tests PASS.

- [ ] **Step 8: Test manuel sur l'émulateur**

Run: `flutter run -d emulator-5554` (relancer si déjà arrêté)

Manually verify: créer une partie à 4 joueurs depuis l'accueil, vérifier que le tableau de
scores s'affiche avec la ligne de joueurs et la ligne de totaux à 0 (aucune manche encore) ;
revenir à l'accueil, vérifier que la partie créée apparaît dans la liste et se rouvre au tap.

- [ ] **Step 9: Commit**

```bash
git add lib/screens/home_screen.dart lib/screens/game_config_screen.dart \
  lib/screens/score_table_screen.dart lib/providers/database_provider.dart \
  lib/main.dart pubspec.yaml pubspec.lock
git commit -m "feat(ui): écrans Accueil, Config partie, Tableau de scores (ligne sticky)"
```

---

## Task 7: Écran de saisie de manche (création + édition + suppression)

**Files:**
- Create: `lib/screens/round_entry_screen.dart`
- Modify: `lib/screens/score_table_screen.dart`

**Interfaces:**
- Consumes: `enregistrerManche`, `supprimerManche` (Task 4), `Contrat`, `PetitAuBout`,
  `Poignee`, `ChelemType` (Task 2), `joueursDePartieProvider` (Task 6).
- Produces: `RoundEntryScreen(partieId: int, manche: Manche?)` — `manche == null` signifie
  création, sinon édition pré-remplie.

- [ ] **Step 1: Créer l'écran de saisie de manche**

Create `lib/screens/round_entry_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import '../providers/database_provider.dart';
import '../scoring/tarot_score_engine.dart';

class RoundEntryScreen extends ConsumerStatefulWidget {
  final int partieId;
  final Manche? manche;

  const RoundEntryScreen({super.key, required this.partieId, this.manche});

  @override
  ConsumerState<RoundEntryScreen> createState() => _RoundEntryScreenState();
}

class _RoundEntryScreenState extends ConsumerState<RoundEntryScreen> {
  Contrat? _contrat;
  int? _preneurId;
  int? _appeleId;
  int _pointsPreneur = 45;
  int _bouts = 0;
  PetitAuBout _petitAuBout = PetitAuBout.aucun;
  Poignee _poignee = Poignee.aucune;
  ChelemType _chelem = ChelemType.aucun;
  bool _envoiEnCours = false;

  @override
  void initState() {
    super.initState();
    final manche = widget.manche;
    if (manche != null) {
      _contrat = Contrat.values.byName(manche.contrat);
      _preneurId = manche.preneurId;
      _appeleId = manche.appeleId;
      _pointsPreneur = manche.pointsPreneur;
      _bouts = manche.bouts;
      _petitAuBout = PetitAuBout.values.byName(manche.petitAuBout);
      _poignee = Poignee.values.byName(manche.poignee);
      _chelem = ChelemType.values.byName(manche.chelem);
    }
  }

  bool _peutValider(int nombreJoueurs) {
    if (_envoiEnCours) return false;
    if (_contrat == null || _preneurId == null) return false;
    if (nombreJoueurs == 5 && _appeleId == null) return false;
    return true;
  }

  Future<void> _valider(List<Joueur> joueurs) async {
    setState(() => _envoiEnCours = true);
    final db = ref.read(databaseProvider);
    await db.enregistrerManche(
      id: widget.manche?.id,
      partieId: widget.partieId,
      contrat: _contrat!,
      preneurId: _preneurId!,
      appeleId: joueurs.length == 5 ? _appeleId : null,
      pointsPreneur: _pointsPreneur,
      bouts: _bouts,
      petitAuBout: _petitAuBout,
      poignee: _poignee,
      chelem: _chelem,
    );
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _supprimer() async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette manche ?'),
        content: const Text('Les totaux cumulés seront recalculés.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirme != true) return;
    await ref.read(databaseProvider).supprimerManche(widget.manche!.id);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final joueursAsync = ref.watch(joueursDePartieProvider(widget.partieId));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.manche == null ? 'Nouvelle manche' : 'Modifier la manche'),
        actions: widget.manche == null
            ? null
            : [
                IconButton(icon: const Icon(Icons.delete_outline), onPressed: _supprimer),
              ],
      ),
      body: joueursAsync.when(
        data: (joueurs) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<Contrat>(
              initialValue: _contrat,
              decoration: const InputDecoration(labelText: 'Contrat'),
              items: const [
                DropdownMenuItem(value: Contrat.prise, child: Text('Prise')),
                DropdownMenuItem(value: Contrat.garde, child: Text('Garde')),
                DropdownMenuItem(value: Contrat.gardeSans, child: Text('Garde Sans le chien')),
                DropdownMenuItem(
                    value: Contrat.gardeContre, child: Text('Garde Contre le chien')),
              ],
              onChanged: (value) => setState(() => _contrat = value),
            ),
            const SizedBox(height: 16),
            Text('Preneur', style: Theme.of(context).textTheme.titleMedium),
            Wrap(
              spacing: 8,
              children: joueurs
                  .map((j) => ChoiceChip(
                        label: Text(j.nom),
                        selected: _preneurId == j.id,
                        onSelected: (_) => setState(() => _preneurId = j.id),
                      ))
                  .toList(),
            ),
            if (joueurs.length == 5) ...[
              const SizedBox(height: 16),
              Text('Appelé (tapez le preneur pour "preneur seul")',
                  style: Theme.of(context).textTheme.titleMedium),
              Wrap(
                spacing: 8,
                children: joueurs
                    .map((j) => ChoiceChip(
                          label: Text(j.nom),
                          selected: _appeleId == j.id,
                          onSelected: (_) => setState(() => _appeleId = j.id),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 16),
            Text('Points du preneur : $_pointsPreneur',
                style: Theme.of(context).textTheme.titleMedium),
            Slider(
              value: _pointsPreneur.toDouble(),
              min: 0,
              max: 91,
              divisions: 91,
              label: '$_pointsPreneur',
              onChanged: (value) => setState(() => _pointsPreneur = value.round()),
            ),
            const SizedBox(height: 16),
            Text('Bouts du preneur', style: Theme.of(context).textTheme.titleMedium),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('0')),
                ButtonSegment(value: 1, label: Text('1')),
                ButtonSegment(value: 2, label: Text('2')),
                ButtonSegment(value: 3, label: Text('3')),
              ],
              selected: {_bouts},
              onSelectionChanged: (selection) => setState(() => _bouts = selection.first),
            ),
            const SizedBox(height: 16),
            Text('Petit au bout', style: Theme.of(context).textTheme.titleMedium),
            SegmentedButton<PetitAuBout>(
              segments: const [
                ButtonSegment(value: PetitAuBout.aucun, label: Text('Aucun')),
                ButtonSegment(value: PetitAuBout.preneur, label: Text('Preneur')),
                ButtonSegment(value: PetitAuBout.defense, label: Text('Défense')),
              ],
              selected: {_petitAuBout},
              onSelectionChanged: (selection) => setState(() => _petitAuBout = selection.first),
            ),
            const SizedBox(height: 16),
            Text('Poignée', style: Theme.of(context).textTheme.titleMedium),
            SegmentedButton<Poignee>(
              segments: const [
                ButtonSegment(value: Poignee.aucune, label: Text('Aucune')),
                ButtonSegment(value: Poignee.simple, label: Text('Simple')),
                ButtonSegment(value: Poignee.double, label: Text('Double')),
                ButtonSegment(value: Poignee.triple, label: Text('Triple')),
              ],
              selected: {_poignee},
              onSelectionChanged: (selection) => setState(() => _poignee = selection.first),
            ),
            const SizedBox(height: 16),
            Text('Chelem', style: Theme.of(context).textTheme.titleMedium),
            DropdownButtonFormField<ChelemType>(
              initialValue: _chelem,
              items: const [
                DropdownMenuItem(value: ChelemType.aucun, child: Text('Aucun')),
                DropdownMenuItem(
                    value: ChelemType.preneurAnonceReussi,
                    child: Text('Preneur : annoncé et réussi')),
                DropdownMenuItem(
                    value: ChelemType.preneurNonAnonceReussi,
                    child: Text('Preneur : réussi non annoncé')),
                DropdownMenuItem(
                    value: ChelemType.preneurAnonceRate,
                    child: Text('Preneur : annoncé et raté')),
                DropdownMenuItem(
                    value: ChelemType.defenseInflige,
                    child: Text('Infligé par la défense')),
              ],
              onChanged: (value) => setState(() => _chelem = value ?? ChelemType.aucun),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed:
                  _peutValider(joueurs.length) ? () => _valider(joueurs) : null,
              child: const Text('Valider'),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erreur : $error')),
      ),
    );
  }
}
```

- [ ] **Step 2: Vérifier que le bouton "Valider" respecte l'anti double-submit**

Ce comportement est déjà couvert par `_envoiEnCours` dans `_peutValider` (Step 1) : dès le
premier tap, `setState(() => _envoiEnCours = true)` désactive le bouton avant l'écriture en
base. Pas de step de code supplémentaire — vérifié par relecture.

- [ ] **Step 3: Câbler la navigation depuis `ScoreTableScreen`**

In `lib/screens/score_table_screen.dart`, add the import:

```dart
import 'round_entry_screen.dart';
```

Replace the `onLongPress` callback body:

```dart
                              onLongPress: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RoundEntryScreen(
                                    partieId: partieId,
                                    manche: manche,
                                  ),
                                ),
                              ),
```

Replace the `floatingActionButton`'s `onPressed` body:

```dart
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoundEntryScreen(partieId: partieId),
          ),
        ),
```

- [ ] **Step 4: Vérifier compilation et tests**

Run: `flutter analyze && flutter test`

Expected: aucune erreur, tous les tests PASS.

- [ ] **Step 5: Test manuel complet sur l'émulateur**

Run: `flutter run -d emulator-5554` (relancer si nécessaire)

Manually verify (correspond à l'exemple officiel #1 du règlement) : créer une partie à 4
joueurs, ajouter une manche — Garde, preneur = premier joueur, 49 points, 2 bouts, petit au
bout = preneur, poignée = simple, chelem = aucun — valider, et vérifier que le tableau de
scores affiche bien +318 pour le preneur et -106 pour chacun des 3 autres. Puis appui long
sur la ligne de manche, changer les points à 87 et le chelem à "annoncé et réussi", valider,
et vérifier que le total recalculé correspond à l'exemple officiel #5 (+1746 / -582).
Supprimer la manche depuis l'écran d'édition et vérifier que les totaux repassent à 0.

- [ ] **Step 6: Commit**

```bash
git add lib/screens/round_entry_screen.dart lib/screens/score_table_screen.dart
git commit -m "feat(ui): écran de saisie de manche (création, édition, suppression)"
```

---

## Task 9: Vérification manuelle finale + garde-fous de build

**Files:**
- None créé — validation uniquement.

**Interfaces:**
- Consumes : l'application complète (Tasks 1-7).

- [ ] **Step 1: Suite complète de tests automatisés**

Run: `flutter analyze && flutter test`

Expected: 0 erreur d'analyse statique, tous les tests PASS (moteur + DB).

- [ ] **Step 2: Vérifier l'absence de permission réseau dans le manifeste**

Run: `grep -i "uses-permission" android/app/src/main/AndroidManifest.xml || echo "aucune permission déclarée"`

Expected: aucune ligne contenant `INTERNET` ou tout autre `uses-permission` réseau.

- [ ] **Step 3: Partie factice à 0 manche**

Sur l'émulateur : créer une partie à 3 joueurs sans y ajouter de manche, revenir à l'accueil,
la rouvrir. Vérifier que le tableau de scores s'affiche avec des totaux à 0 sans erreur.

- [ ] **Step 4: Suppression de la dernière manche d'une partie**

Ajouter une seule manche à une partie, la supprimer depuis l'écran d'édition (appui long →
icône poubelle). Vérifier que le tableau de scores repasse à "Aucune manche" sans crash.

- [ ] **Step 5: Défilement sticky sur 25+ manches**

Sur une partie à 4 joueurs, ajouter au moins 25 manches (valeurs arbitraires valides).
Vérifier que la ligne de totaux cumulés reste visible et fixe pendant que la liste des
manches défile.

- [ ] **Step 6: Cas "preneur seul" à 5 joueurs**

Créer une partie à 5 joueurs, ajouter une manche où le bloc "Appelé" a le même joueur tapé que
le bloc "Preneur". Valider et vérifier dans le tableau de scores que le preneur encaisse bien
4× le montant et que les 4 autres joueurs marquent chacun -1× le montant (pas de répartition
2/3-1/3).

- [ ] **Step 7: Commit final (si des ajustements ont eu lieu pendant la vérification)**

```bash
git add -A
git commit -m "test: vérification manuelle finale (partie 0 manche, suppression, scroll sticky, preneur seul)"
```

(Ne committer que s'il y a effectivement eu des changements de code pendant cette étape — si
la vérification manuelle n'a rien modifié, ne pas créer de commit vide.)
