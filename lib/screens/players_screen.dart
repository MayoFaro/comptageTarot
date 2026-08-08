import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/database_provider.dart';
import '../widgets/player_dialogs.dart';

class PlayersScreen extends ConsumerWidget {
  const PlayersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final joueursAsync = ref.watch(joueursProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des joueurs')),
      body: joueursAsync.when(
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
                      onPressed: () => ouvrirFormulaireJoueur(context, ref),
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter un joueur'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: joueurs.length,
                itemBuilder: (context, index) {
                  final joueur = joueurs[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                        child: Text(joueur.nom.isEmpty ? '?' : joueur.nom[0].toUpperCase()),
                      ),
                      title: Text(joueur.nom),
                      onTap: () => ouvrirFormulaireJoueur(context, ref, joueur: joueur),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => confirmerSuppressionJoueur(context, ref, joueur),
                      ),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erreur : $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ouvrirFormulaireJoueur(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Joueur'),
      ),
    );
  }
}
