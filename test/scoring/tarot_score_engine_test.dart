import 'package:comptage_tarot/scoring/tarot_score_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('exemples officiels FFT (4 joueurs)', () {
    test('exemple 1 : Garde, poignée simple, petit au bout preneur, 49 pts / 2 bouts', () {
      final result = calculerManche(const ManchInput(
        nombreJoueurs: 4,
        contrat: Contrat.garde,
        pointsPreneur: 49,
        bouts: 2,
        petitAuBout: PetitAuBout.preneur,
        poigneeAttaque: Poignee.simple,
        chelem: ChelemType.aucun,
        joueurIds: [1, 2, 3, 4],
        preneurId: 1,
      ));
      expect(result.montant, 106);
      expect(result.preneurGagne, isTrue);
      expect(result.deltasParJoueur, {1: 318, 2: -106, 3: -106, 4: -106});
    });

    test('exemple 2 : Garde Sans le chien, 4 pts au-dessus du seuil, petit au bout défense', () {
      final result = calculerManche(const ManchInput(
        nombreJoueurs: 4,
        contrat: Contrat.gardeSans,
        pointsPreneur: 55,
        bouts: 1,
        petitAuBout: PetitAuBout.defense,
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
        poigneeAttaque: Poignee.simple,
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
        poigneeDefense: Poignee.simple,
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
        poigneeAttaque: Poignee.simple,
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

    test(
        'les deux camps déclarent une poignée : les primes s\'additionnent au bénéfice du '
        'vainqueur', () {
      final result = calculerManche(const ManchInput(
        nombreJoueurs: 4,
        contrat: Contrat.garde,
        pointsPreneur: 70,
        bouts: 0,
        poigneeAttaque: Poignee.simple,
        poigneeDefense: Poignee.double,
        joueurIds: [1, 2, 3, 4],
        preneurId: 1,
      ));
      // seuil(0)=56, écart=14, net=(25+14)*2=78, +20 (attaque) +30 (défense) = 128
      expect(result.montant, 128);
      expect(result.preneurGagne, isTrue);
      expect(result.deltasParJoueur, {1: 384, 2: -128, 3: -128, 4: -128});
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
