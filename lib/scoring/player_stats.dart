import 'tarot_score_engine.dart';

/// Les champs d'une manche nécessaires au calcul des statistiques d'un
/// joueur — extraits du type `Manche` (Drift) par l'appelant, pour garder
/// ce module aussi pur que le moteur de calcul (zéro dépendance Flutter/Drift).
class ManchePourStats {
  final int pointsPreneur;
  final int bouts;
  final int preneurId;
  final int? appeleId;
  final int nombreJoueurs;

  const ManchePourStats({
    required this.pointsPreneur,
    required this.bouts,
    required this.preneurId,
    required this.appeleId,
    required this.nombreJoueurs,
  });
}

class StatistiquesJoueur {
  final int nombrePartiesJouees;
  final int manchesJouees;

  /// Fraction des manches jouées où le joueur était le preneur.
  /// `null` si le joueur n'a jamais joué de manche.
  final double? tauxContratsDemandes;

  /// Fraction des manches prises (en tant que preneur) qui ont été
  /// réussies. `null` si le joueur n'a jamais été preneur.
  final double? tauxContratsReussis;

  /// Fraction des manches à 5 joueurs où le joueur était l'appelé (hors
  /// convention "preneur seul"). `null` si le joueur n'a jamais joué à 5.
  final double? tauxAssocie;

  /// Moyenne du nombre de points au-dessus du seuil du contrat, sur les
  /// seules manches prises et réussies. `null` si aucune réussite.
  final double? moyenneEcartReussite;

  const StatistiquesJoueur({
    required this.nombrePartiesJouees,
    required this.manchesJouees,
    required this.tauxContratsDemandes,
    required this.tauxContratsReussis,
    required this.tauxAssocie,
    required this.moyenneEcartReussite,
  });
}

double? _ratio(int numerateur, int denominateur) {
  if (denominateur == 0) return null;
  return numerateur / denominateur;
}

/// Calcule les statistiques cumulées d'un joueur à partir de l'ensemble des
/// manches auxquelles il a participé, tous formats et toutes parties
/// confondus. Fonction pure — aucune donnée n'est stockée séparément, tout
/// est recalculé depuis les manches brutes (même esprit que le moteur de
/// calcul).
StatistiquesJoueur calculerStatistiquesJoueur({
  required int joueurId,
  required int nombrePartiesJouees,
  required List<ManchePourStats> manches,
}) {
  final manchesPreneur = manches.where((m) => m.preneurId == joueurId).toList();
  final manchesPreneurReussies =
      manchesPreneur.where((m) => m.pointsPreneur >= seuilPreneur(m.bouts)).toList();
  final manches5Joueurs = manches.where((m) => m.nombreJoueurs == 5).toList();
  final manchesAssocie = manches5Joueurs
      .where((m) => m.appeleId == joueurId && m.preneurId != joueurId)
      .toList();

  double? moyenneEcartReussite;
  if (manchesPreneurReussies.isNotEmpty) {
    final sommeEcarts = manchesPreneurReussies
        .map((m) => m.pointsPreneur - seuilPreneur(m.bouts))
        .reduce((a, b) => a + b);
    moyenneEcartReussite = sommeEcarts / manchesPreneurReussies.length;
  }

  return StatistiquesJoueur(
    nombrePartiesJouees: nombrePartiesJouees,
    manchesJouees: manches.length,
    tauxContratsDemandes: _ratio(manchesPreneur.length, manches.length),
    tauxContratsReussis: _ratio(manchesPreneurReussies.length, manchesPreneur.length),
    tauxAssocie: _ratio(manchesAssocie.length, manches5Joueurs.length),
    moyenneEcartReussite: moyenneEcartReussite,
  );
}
