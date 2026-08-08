import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/database_provider.dart';

String _pourcentage(double? valeur) => valeur == null ? '—' : '${(valeur * 100).round()} %';

class PlayerStatsScreen extends ConsumerWidget {
  final int joueurId;
  final String nomJoueur;

  const PlayerStatsScreen({super.key, required this.joueurId, required this.nomJoueur});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statistiquesJoueurProvider(joueurId));
    return Scaffold(
      appBar: AppBar(title: Text('Statistiques — $nomJoueur')),
      body: statsAsync.when(
        data: (stats) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _CarteStat(label: 'Parties jouées', valeur: '${stats.nombrePartiesJouees}'),
            _CarteStat(label: 'Manches jouées', valeur: '${stats.manchesJouees}'),
            _CarteStat(
                label: 'Taux de contrats demandés',
                valeur: _pourcentage(stats.tauxContratsDemandes)),
            _CarteStat(
                label: 'Taux de contrats réussis',
                valeur: _pourcentage(stats.tauxContratsReussis)),
            _CarteStat(label: 'Taux de parties associé', valeur: _pourcentage(stats.tauxAssocie)),
            _CarteStat(
              label: 'Points moyens au-dessus du contrat (réussites)',
              valeur: stats.moyenneEcartReussite == null
                  ? '—'
                  : '+${stats.moyenneEcartReussite!.toStringAsFixed(1)}',
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erreur : $error')),
      ),
    );
  }
}

class _CarteStat extends StatelessWidget {
  final String label;
  final String valeur;

  const _CarteStat({required this.label, required this.valeur});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(label),
        trailing: Text(
          valeur,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}
