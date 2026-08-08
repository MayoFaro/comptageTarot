import 'package:comptage_tarot/db/database.dart';
import 'package:comptage_tarot/scoring/tarot_score_engine.dart';
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
          poigneeAttaque: 'simple',
          poigneeDefense: 'aucune',
          chelem: 'aucun',
        ));
    final manches = await db.select(db.manches).get();
    expect(manches, hasLength(1));
    expect(manches.single.preneurId, aliceId);
    expect(bobId, isNotNull);
  });

  test('enregistrerManche crée une manche avec numero auto-incrémenté', () async {
    final aliceId = await db.into(db.joueurs).insert(JoueursCompanion.insert(nom: 'Alice'));
    await db.into(db.joueurs).insert(JoueursCompanion.insert(nom: 'Bob'));
    final partieId = await db.into(db.parties).insert(PartiesCompanion.insert(nombreJoueurs: 4));

    final id1 = await db.enregistrerManche(
      partieId: partieId,
      contrat: Contrat.garde,
      preneurId: aliceId,
      pointsPreneur: 49,
      bouts: 2,
      petitAuBout: PetitAuBout.preneur,
      poigneeAttaque: Poignee.simple,
      poigneeDefense: Poignee.aucune,
      chelem: ChelemType.aucun,
    );
    final id2 = await db.enregistrerManche(
      partieId: partieId,
      contrat: Contrat.prise,
      preneurId: aliceId,
      pointsPreneur: 40,
      bouts: 1,
      petitAuBout: PetitAuBout.aucun,
      poigneeAttaque: Poignee.aucune,
      poigneeDefense: Poignee.aucune,
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
    final partieId = await db.into(db.parties).insert(PartiesCompanion.insert(nombreJoueurs: 4));
    final id = await db.enregistrerManche(
      partieId: partieId,
      contrat: Contrat.prise,
      preneurId: aliceId,
      pointsPreneur: 40,
      bouts: 1,
      petitAuBout: PetitAuBout.aucun,
      poigneeAttaque: Poignee.aucune,
      poigneeDefense: Poignee.aucune,
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
      poigneeAttaque: Poignee.aucune,
      poigneeDefense: Poignee.aucune,
      chelem: ChelemType.aucun,
    );

    final manches = await db.watchManches(partieId).first;
    expect(manches, hasLength(1));
    expect(manches.single.contrat, 'garde');
    expect(manches.single.pointsPreneur, 60);
  });

  test('supprimerManche retire la manche', () async {
    final aliceId = await db.into(db.joueurs).insert(JoueursCompanion.insert(nom: 'Alice'));
    final partieId = await db.into(db.parties).insert(PartiesCompanion.insert(nombreJoueurs: 4));
    final id = await db.enregistrerManche(
      partieId: partieId,
      contrat: Contrat.prise,
      preneurId: aliceId,
      pointsPreneur: 40,
      bouts: 1,
      petitAuBout: PetitAuBout.aucun,
      poigneeAttaque: Poignee.aucune,
      poigneeDefense: Poignee.aucune,
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
}
