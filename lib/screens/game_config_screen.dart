import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/database_provider.dart';
import '../widgets/player_dialogs.dart';
import 'score_table_screen.dart';

class GameConfigScreen extends ConsumerStatefulWidget {
  const GameConfigScreen({super.key});

  @override
  ConsumerState<GameConfigScreen> createState() => _GameConfigScreenState();
}

class _GameConfigScreenState extends ConsumerState<GameConfigScreen> {
  int _nombreJoueurs = 4;
  final Set<int> _selectionnes = {};

  Future<void> _ajouterJoueur() async {
    final id = await ouvrirFormulaireJoueur(context, ref);
    if (id != null && _selectionnes.length < _nombreJoueurs) {
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
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 3, label: Text('3 joueurs')),
                ButtonSegment(value: 4, label: Text('4 joueurs')),
                ButtonSegment(value: 5, label: Text('5 joueurs')),
              ],
              selected: {_nombreJoueurs},
              onSelectionChanged: (selection) {
                setState(() {
                  _nombreJoueurs = selection.first;
                  _selectionnes.clear();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Joueurs (${_selectionnes.length}/$_nombreJoueurs)',
                    style: Theme.of(context).textTheme.titleMedium),
                TextButton.icon(
                  onPressed: _ajouterJoueur,
                  icon: const Icon(Icons.person_add_alt),
                  label: const Text('Nouveau joueur'),
                ),
              ],
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
                            !selectionne && _selectionnes.length >= _nombreJoueurs;
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
              onPressed: _selectionnes.length == _nombreJoueurs
                  ? () async {
                      final db = ref.read(databaseProvider);
                      final partieId =
                          await db.creerPartie(_nombreJoueurs, _selectionnes.toList());
                      if (!context.mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScoreTableScreen(partieId: partieId),
                        ),
                      );
                    }
                  : null,
              child: Text('Démarrer la partie (${_selectionnes.length}/$_nombreJoueurs joueurs)'),
            ),
          ),
        ],
      ),
    );
  }
}
