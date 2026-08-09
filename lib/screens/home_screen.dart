import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/database_provider.dart';
import 'game_config_screen.dart';
import 'players_screen.dart';
import 'score_table_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<bool> _confirmerSuppressionPartie(BuildContext context) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette partie ?'),
        content: const Text('Toutes ses manches enregistrées seront perdues.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    return confirme ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partiesAsync = ref.watch(partiesProvider);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('Comptage Tarot')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Gérer les joueurs'),
              subtitle: const Text('Ajouter, modifier ou supprimer un joueur'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PlayersScreen()),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: partiesAsync.when(
              data: (parties) => parties.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.style_outlined,
                              size: 64, color: Theme.of(context).colorScheme.outline),
                          const SizedBox(height: 16),
                          const Text('Aucune partie en cours'),
                          const SizedBox(height: 8),
                          const Text('Créez-en une avec le bouton "Nouvelle partie"'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: parties.length,
                      itemBuilder: (context, index) {
                        final partie = parties[index];
                        return Dismissible(
                          key: ValueKey(partie.id),
                          direction: DismissDirection.horizontal,
                          confirmDismiss: (_) => _confirmerSuppressionPartie(context),
                          onDismissed: (_) =>
                              ref.read(databaseProvider).supprimerPartie(partie.id),
                          background: _fondSuppression(context, Alignment.centerLeft),
                          secondaryBackground: _fondSuppression(context, Alignment.centerRight),
                          child: Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                                child: Text('${partie.nombreJoueurs}'),
                              ),
                              title: Text('Partie du ${dateFormat.format(partie.dateCreation)}'),
                              subtitle: Text('${partie.nombreJoueurs} joueurs'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ScoreTableScreen(partieId: partie.id),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Erreur : $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GameConfigScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle partie'),
      ),
    );
  }
}

Widget _fondSuppression(BuildContext context, Alignment alignment) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    padding: const EdgeInsets.symmetric(horizontal: 20),
    alignment: alignment,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.error,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.onError),
  );
}
