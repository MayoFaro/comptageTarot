import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/database_provider.dart';
import '../widgets/player_dialogs.dart';
import 'score_table_screen.dart';

const int _maxJoueurs = 5;

class GameConfigScreen extends ConsumerStatefulWidget {
  const GameConfigScreen({super.key});

  @override
  ConsumerState<GameConfigScreen> createState() => _GameConfigScreenState();
}

class _GameConfigScreenState extends ConsumerState<GameConfigScreen> {
  final Set<int> _selectionnes = {};

  bool get _nombreValide =>
      _selectionnes.length == 3 || _selectionnes.length == 4 || _selectionnes.length == 5;

  Future<void> _ajouterJoueur() async {
    final id = await ouvrirFormulaireJoueur(context, ref);
    if (id != null && _selectionnes.length < _maxJoueurs) {
      setState(() => _selectionnes.add(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final joueursAsync = ref.watch(joueursProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle partie')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Joueurs sélectionnés : ${_selectionnes.length}',
                    style: Theme.of(context).textTheme.titleMedium),
                TextButton.icon(
                  onPressed: _ajouterJoueur,
                  icon: const Icon(Icons.person_add_alt),
                  label: const Text('Nouveau joueur'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Le Tarot se joue à 3, 4 ou 5 — cochez les joueurs présents ce soir.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: joueursAsync.when(
              data: (joueurs) => joueurs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_outline,
                              size: 64, color: Theme.of(context).colorScheme.outline),
                          const SizedBox(height: 16),
                          const Text('Aucun joueur enregistré'),
                          const SizedBox(height: 8),
                          FilledButton.icon(
                            onPressed: _ajouterJoueur,
                            icon: const Icon(Icons.add),
                            label: const Text('Ajouter un joueur'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: joueurs.length,
                      itemBuilder: (context, index) {
                        final joueur = joueurs[index];
                        final selectionne = _selectionnes.contains(joueur.id);
                        final pleinSansSelection =
                            !selectionne && _selectionnes.length >= _maxJoueurs;
                        return CheckboxListTile(
                          title: Text(joueur.nom),
                          value: selectionne,
                          onChanged: pleinSansSelection
                              ? null
                              : (value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectionnes.add(joueur.id);
                                    } else {
                                      _selectionnes.remove(joueur.id);
                                    }
                                  });
                                },
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Erreur : $error')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: _nombreValide
                  ? () async {
                      final db = ref.read(databaseProvider);
                      final partieId =
                          await db.creerPartie(_selectionnes.length, _selectionnes.toList());
                      if (!context.mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScoreTableScreen(partieId: partieId),
                        ),
                      );
                    }
                  : null,
              child: Text('Démarrer la partie (${_selectionnes.length} joueurs)'),
            ),
          ),
        ],
      ),
    );
  }
}
