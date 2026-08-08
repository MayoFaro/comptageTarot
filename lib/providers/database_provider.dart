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

final manchesProvider = StreamProvider.family<List<Manche>, int>((ref, partieId) {
  return ref.watch(databaseProvider).watchManches(partieId);
});

final joueursDePartieProvider = FutureProvider.family<List<Joueur>, int>((ref, partieId) {
  return ref.watch(databaseProvider).joueursDeLaPartie(partieId);
});
