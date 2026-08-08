import 'package:comptage_tarot/scoring/player_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const joueurId = 1;

  group('scénario complet', () {
    final manches = [
      // 4 joueurs, Alice preneur, contrat réussi (seuil 41, écart +8)
      const ManchePourStats(
          pointsPreneur: 49, bouts: 2, preneurId: 1, appeleId: null, nombreJoueurs: 4),
      // 4 joueurs, Alice preneur, contrat chuté (seuil 56, écart -26)
      const ManchePourStats(
          pointsPreneur: 30, bouts: 0, preneurId: 1, appeleId: null, nombreJoueurs: 4),
      // 4 joueurs, Alice simple défenseur
      const ManchePourStats(
          pointsPreneur: 45, bouts: 1, preneurId: 2, appeleId: null, nombreJoueurs: 4),
      // 5 joueurs, Alice appelée par le joueur 3
      const ManchePourStats(
          pointsPreneur: 50, bouts: 1, preneurId: 3, appeleId: 1, nombreJoueurs: 5),
      // 5 joueurs, Alice preneuse, contrat réussi (seuil 51, écart +9)
      const ManchePourStats(
          pointsPreneur: 60, bouts: 1, preneurId: 1, appeleId: 4, nombreJoueurs: 5),
      // 5 joueurs, Alice simple défenseuse (ni preneuse ni appelée)
      const ManchePourStats(
          pointsPreneur: 55, bouts: 2, preneurId: 2, appeleId: 3, nombreJoueurs: 5),
    ];

    test('calcule les 5 indicateurs sur un historique mixte', () {
      final stats = calculerStatistiquesJoueur(
        joueurId: joueurId,
        nombrePartiesJouees: 2,
        manches: manches,
      );

      expect(stats.nombrePartiesJouees, 2);
      expect(stats.manchesJouees, 6);
      // preneuse sur 3 des 6 manches jouées
      expect(stats.tauxContratsDemandes, closeTo(3 / 6, 1e-9));
      // réussie sur 2 des 3 manches prises
      expect(stats.tauxContratsReussis, closeTo(2 / 3, 1e-9));
      // appelée sur 1 des 3 manches à 5 joueurs
      expect(stats.tauxAssocie, closeTo(1 / 3, 1e-9));
      // moyenne des écarts (+8, +9) sur les seuls contrats réussis
      expect(stats.moyenneEcartReussite, closeTo(8.5, 1e-9));
    });
  });

  group('cas limites (dénominateurs à 0 → null, jamais une division par zéro)', () {
    test('aucune manche jouée : tous les taux sont null', () {
      final stats = calculerStatistiquesJoueur(
        joueurId: joueurId,
        nombrePartiesJouees: 0,
        manches: const [],
      );
      expect(stats.manchesJouees, 0);
      expect(stats.tauxContratsDemandes, isNull);
      expect(stats.tauxContratsReussis, isNull);
      expect(stats.tauxAssocie, isNull);
      expect(stats.moyenneEcartReussite, isNull);
    });

    test('jamais preneur : taux de contrats demandés à 0, taux de réussite null', () {
      final stats = calculerStatistiquesJoueur(
        joueurId: joueurId,
        nombrePartiesJouees: 1,
        manches: const [
          ManchePourStats(
              pointsPreneur: 45, bouts: 1, preneurId: 2, appeleId: null, nombreJoueurs: 4),
        ],
      );
      expect(stats.tauxContratsDemandes, 0.0);
      expect(stats.tauxContratsReussis, isNull);
      expect(stats.moyenneEcartReussite, isNull);
    });

    test('jamais joué à 5 : taux d\'associé null', () {
      final stats = calculerStatistiquesJoueur(
        joueurId: joueurId,
        nombrePartiesJouees: 1,
        manches: const [
          ManchePourStats(
              pointsPreneur: 45, bouts: 1, preneurId: 1, appeleId: null, nombreJoueurs: 4),
        ],
      );
      expect(stats.tauxAssocie, isNull);
    });

    test('preneur seul à 5 joueurs (appeleId == preneurId) n\'est jamais compté comme associé',
        () {
      final stats = calculerStatistiquesJoueur(
        joueurId: joueurId,
        nombrePartiesJouees: 1,
        manches: const [
          ManchePourStats(
              pointsPreneur: 50, bouts: 2, preneurId: 1, appeleId: 1, nombreJoueurs: 5),
        ],
      );
      expect(stats.tauxAssocie, 0.0);
    });
  });
}
