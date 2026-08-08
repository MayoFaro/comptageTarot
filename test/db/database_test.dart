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
    final partieId = await db.into(db.parties).insert(PartiesCompanion.insert(nombreJoueurs: 4));
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
