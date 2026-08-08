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
