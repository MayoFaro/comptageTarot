import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import '../scoring/player_stats.dart';

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

final manchesProvider = StreamProvider.family<List<Manche>, int>((ref, partieId) {
  return ref.watch(databaseProvider).watchManches(partieId);
});

final joueursDePartieProvider = FutureProvider.family<List<Joueur>, int>((ref, partieId) {
  return ref.watch(databaseProvider).joueursDeLaPartie(partieId);
});

final statistiquesJoueurProvider =
    FutureProvider.family<StatistiquesJoueur, int>((ref, joueurId) async {
  final db = ref.watch(databaseProvider);
  final nombrePartiesJouees = await db.nombrePartiesJouees(joueurId);
  final manches = await db.manchesDuJoueur(joueurId);
  return calculerStatistiquesJoueur(
    joueurId: joueurId,
    nombrePartiesJouees: nombrePartiesJouees,
    manches: manches
        .map((m) => ManchePourStats(
              pointsPreneur: m.$1.pointsPreneur,
              bouts: m.$1.bouts,
              preneurId: m.$1.preneurId,
              appeleId: m.$1.appeleId,
              nombreJoueurs: m.$2,
            ))
        .toList(),
  );
});
