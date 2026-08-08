import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../scoring/tarot_score_engine.dart';

part 'database.g.dart';

class Joueurs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nom => text().withLength(min: 1, max: 50)();
}

@DataClassName('Partie')
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
  IntColumn get bouts => integer().customConstraint('NOT NULL CHECK (bouts BETWEEN 0 AND 3)')();
  TextColumn get petitAuBout => text()();
  TextColumn get poigneeAttaque => text()();
  TextColumn get poigneeDefense => text()();
  TextColumn get chelem => text()();
  DateTimeColumn get dateCreation => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Joueurs, Parties, PartieJoueurs, Manches])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (Migrator m, int from, int to) async {
          // Phase de développement précoce : pas de continuité de schéma
          // garantie (voir DESIGN.md Premise 1, perte de données locale
          // acceptée). On repart d'une base vierge à chaque changement de
          // schéma plutôt que d'écrire des migrations pas à pas.
          for (final table in allTables) {
            await m.deleteTable(table.actualTableName);
          }
          await m.createAll();
        },
      );

  Future<int> creerJoueur(String nom) => into(joueurs).insert(JoueursCompanion.insert(nom: nom));

  Future<void> modifierJoueur(int id, String nom) =>
      (update(joueurs)..where((j) => j.id.equals(id))).write(JoueursCompanion(nom: Value(nom)));

  Future<void> supprimerJoueur(int id) =>
      (delete(joueurs)..where((j) => j.id.equals(id))).go();

  Stream<List<Joueur>> watchJoueurs() =>
      (select(joueurs)..orderBy([(j) => OrderingTerm(expression: j.nom)])).watch();

  Future<int> creerPartie(int nombreJoueurs, List<int> joueurIds) async {
    final partieId =
        await into(parties).insert(PartiesCompanion.insert(nombreJoueurs: nombreJoueurs));
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
    required Poignee poigneeAttaque,
    required Poignee poigneeDefense,
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
      poigneeAttaque: Value(poigneeAttaque.name),
      poigneeDefense: Value(poigneeDefense.name),
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
