import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import '../providers/database_provider.dart';
import '../scoring/tarot_score_engine.dart';
import 'round_entry_screen.dart';

String _abregeContrat(Contrat contrat) {
  switch (contrat) {
    case Contrat.prise:
      return 'P';
    case Contrat.garde:
      return 'G';
    case Contrat.gardeSans:
      return 'GS';
    case Contrat.gardeContre:
      return 'GC';
  }
}

/// Largeur de la cellule de tête (numéro + contrat), partagée par les 3
/// types de lignes du tableau pour garantir l'alignement des colonnes
/// joueurs entre l'en-tête, les totaux et chaque ligne de manche.
const double _largeurTete = 52;

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
      poigneeAttaque: Poignee.values.byName(manche.poigneeAttaque),
      poigneeDefense: Poignee.values.byName(manche.poigneeDefense),
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
                _LigneTableau(
                  cellules: joueurs
                      .map((j) => FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(j.nom,
                                maxLines: 1,
                                softWrap: false,
                                style: Theme.of(context).textTheme.titleMedium),
                          ))
                      .toList(),
                ),
                _LigneTableau(
                  couleurFond: Theme.of(context).colorScheme.surfaceContainerHighest,
                  cellules: joueurs
                      .map((j) => Text(
                            '${totaux[j.id] ?? 0}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ))
                      .toList(),
                ),
                Expanded(
                  child: manches.isEmpty
                      ? const Center(child: Text('Aucune manche — ajoutez-en une avec +'))
                      : ListView.separated(
                          itemCount: manches.length + 1,
                          separatorBuilder: (context, index) => index == manches.length - 1
                              ? const SizedBox(height: 24)
                              : const Divider(height: 1),
                          itemBuilder: (context, index) {
                            if (index == manches.length) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Center(
                                  child: Text(
                                    'Appui long sur une manche pour la modifier ou la supprimer',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.5)),
                                  ),
                                ),
                              );
                            }
                            final manche = manches[index];
                            final resultat = resultats[index];
                            final colorScheme = Theme.of(context).colorScheme;
                            return InkWell(
                              onLongPress: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RoundEntryScreen(
                                    partieId: partieId,
                                    manche: manche,
                                  ),
                                ),
                              ),
                              child: _LigneTableau(
                                tete: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('${manche.numero}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(fontWeight: FontWeight.bold)),
                                    Text(_abregeContrat(Contrat.values.byName(manche.contrat)),
                                        style: Theme.of(context).textTheme.labelSmall),
                                  ],
                                ),
                                cellules: joueurs.map((j) {
                                  final valeur = resultat.deltasParJoueur[j.id] ?? 0;
                                  if (j.id != manche.preneurId) {
                                    return Text('$valeur', textAlign: TextAlign.center);
                                  }
                                  final couleur = resultat.preneurGagne
                                      ? colorScheme.primary
                                      : colorScheme.secondary;
                                  final couleurTexte = resultat.preneurGagne
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSecondary;
                                  return Center(
                                    child: Container(
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: couleur,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '$valeur',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold, color: couleurTexte),
                                      ),
                                    ),
                                  );
                                }).toList(),
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

/// Gabarit de ligne partagé par l'en-tête, la ligne de totaux et chaque
/// ligne de manche : une cellule de tête à largeur fixe (vide pour
/// l'en-tête/totaux) suivie des colonnes joueurs en largeur égale — garantit
/// l'alignement des colonnes entre les 3 types de lignes.
class _LigneTableau extends StatelessWidget {
  final Widget? tete;
  final List<Widget> cellules;
  final Color? couleurFond;

  const _LigneTableau({this.tete, required this.cellules, this.couleurFond});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: couleurFond,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          SizedBox(width: _largeurTete, child: Center(child: tete)),
          ...cellules.map((c) => Expanded(child: c)),
        ],
      ),
    );
  }
}
