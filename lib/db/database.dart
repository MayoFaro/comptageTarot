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
  IntColumn get bouts => integer().customConstraint('NOT NULL CHECK (bouts BETWEEN 0 AND 3)')();
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
