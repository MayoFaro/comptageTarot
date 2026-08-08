import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import '../providers/database_provider.dart';
import '../scoring/tarot_score_engine.dart';
import 'round_entry_screen.dart';

class ScoreTableScreen extends ConsumerWidget {
  final int partieId;

  const ScoreTableScreen({super.key, required this.partieId});

  ManchInput _inputDepuisManche(Manche manche, List<Joueur> joueurs) {
    return ManchInput(
      nombreJoueurs: joueurs.length,
      contrat: Contrat.values.byName(manche.contrat),
      pointsPreneur: manche.pointsPreneur,
      bouts: manche.bouts,
      petitAuBout: PetitAuBout.values.byName(manche.petitAuBout),
      poignee: Poignee.values.byName(manche.poignee),
      chelem: ChelemType.values.byName(manche.chelem),
      joueurIds: joueurs.map((j) => j.id).toList(),
      preneurId: manche.preneurId,
      appeleId: manche.appeleId,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final joueursAsync = ref.watch(joueursDePartieProvider(partieId));
    final manchesAsync = ref.watch(manchesProvider(partieId));

    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de scores')),
      body: joueursAsync.when(
        data: (joueurs) => manchesAsync.when(
          data: (manches) {
            final resultats =
                manches.map((m) => _inputDepuisManche(m, joueurs)).map(calculerManche).toList();
            final totaux = {for (final j in joueurs) j.id: 0};
            for (final resultat in resultats) {
              resultat.deltasParJoueur.forEach((joueurId, delta) {
                totaux[joueurId] = (totaux[joueurId] ?? 0) + delta;
              });
            }

            return Column(
              children: [
                _LigneJoueurs(joueurs: joueurs),
                _LigneTotauxSticky(joueurs: joueurs, totaux: totaux),
                Expanded(
                  child: manches.isEmpty
                      ? const Center(child: Text('Aucune manche — ajoutez-en une avec +'))
                      : ListView.builder(
                          itemCount: manches.length,
                          itemBuilder: (context, index) {
                            final manche = manches[index];
                            final resultat = resultats[index];
                            return ListTile(
                              onLongPress: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RoundEntryScreen(
                                    partieId: partieId,
                                    manche: manche,
                                  ),
                                ),
                              ),
                              leading: CircleAvatar(child: Text('${manche.numero}')),
                              title: Row(
                                children: joueurs
                                    .map((j) => Expanded(
                                          child: Text(
                                            '${resultat.deltasParJoueur[j.id] ?? 0}',
                                            textAlign: TextAlign.center,
                                          ),
                                        ))
                                    .toList(),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Erreur : $error')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erreur : $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoundEntryScreen(partieId: partieId),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _LigneJoueurs extends StatelessWidget {
  final List<Joueur> joueurs;
  const _LigneJoueurs({required this.joueurs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: joueurs
            .map((j) => Expanded(
                  child: Text(j.nom,
                      textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
                ))
            .toList(),
      ),
    );
  }
}

class _LigneTotauxSticky extends StatelessWidget {
  final List<Joueur> joueurs;
  final Map<int, int> totaux;
  const _LigneTotauxSticky({required this.joueurs, required this.totaux});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: joueurs
            .map((j) => Expanded(
                  child: Text(
                    '${totaux[j.id] ?? 0}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
