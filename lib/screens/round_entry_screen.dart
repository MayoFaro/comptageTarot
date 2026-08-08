import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import '../providers/database_provider.dart';
import '../scoring/tarot_score_engine.dart';

String _libelleContrat(Contrat contrat) {
  switch (contrat) {
    case Contrat.prise:
      return 'Prise';
    case Contrat.garde:
      return 'Garde';
    case Contrat.gardeSans:
      return 'Garde Sans';
    case Contrat.gardeContre:
      return 'Garde Contre';
  }
}

class RoundEntryScreen extends ConsumerStatefulWidget {
  final int partieId;
  final Manche? manche;

  const RoundEntryScreen({super.key, required this.partieId, this.manche});

  @override
  ConsumerState<RoundEntryScreen> createState() => _RoundEntryScreenState();
}

class _RoundEntryScreenState extends ConsumerState<RoundEntryScreen> {
  Contrat? _contrat;
  int? _preneurId;
  int? _appeleId;
  int _pointsPreneur = 0;
  int _bouts = 0;
  PetitAuBout _petitAuBout = PetitAuBout.aucun;
  Poignee _poignee = Poignee.aucune;
  ChelemType _chelem = ChelemType.aucun;
  bool _envoiEnCours = false;

  @override
  void initState() {
    super.initState();
    final manche = widget.manche;
    if (manche != null) {
      _contrat = Contrat.values.byName(manche.contrat);
      _preneurId = manche.preneurId;
      _appeleId = manche.appeleId;
      _pointsPreneur = manche.pointsPreneur;
      _bouts = manche.bouts;
      _petitAuBout = PetitAuBout.values.byName(manche.petitAuBout);
      _poignee = Poignee.values.byName(manche.poignee);
      _chelem = ChelemType.values.byName(manche.chelem);
    }
  }

  bool _peutValider(int nombreJoueurs) {
    if (_envoiEnCours) return false;
    if (_contrat == null || _preneurId == null) return false;
    if (nombreJoueurs == 5 && _appeleId == null) return false;
    return true;
  }

  Future<void> _valider(List<Joueur> joueurs) async {
    setState(() => _envoiEnCours = true);
    final db = ref.read(databaseProvider);
    await db.enregistrerManche(
      id: widget.manche?.id,
      partieId: widget.partieId,
      contrat: _contrat!,
      preneurId: _preneurId!,
      appeleId: joueurs.length == 5 ? _appeleId : null,
      pointsPreneur: _pointsPreneur,
      bouts: _bouts,
      petitAuBout: _petitAuBout,
      poignee: _poignee,
      chelem: _chelem,
    );
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _supprimer() async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette manche ?'),
        content: const Text('Les totaux cumulés seront recalculés.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
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
    if (confirme != true) return;
    await ref.read(databaseProvider).supprimerManche(widget.manche!.id);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final joueursAsync = ref.watch(joueursDePartieProvider(widget.partieId));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.manche == null ? 'Nouvelle manche' : 'Modifier la manche'),
        actions: widget.manche == null
            ? null
            : [
                IconButton(icon: const Icon(Icons.delete_outline), onPressed: _supprimer),
              ],
      ),
      body: joueursAsync.when(
        data: (joueurs) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Contrat', style: Theme.of(context).textTheme.titleMedium),
            Wrap(
              spacing: 8,
              children: Contrat.values
                  .map((c) => ChoiceChip(
                        label: Text(_libelleContrat(c)),
                        selected: _contrat == c,
                        onSelected: (_) => setState(() => _contrat = c),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text('Preneur', style: Theme.of(context).textTheme.titleMedium),
            Wrap(
              spacing: 8,
              children: joueurs
                  .map((j) => ChoiceChip(
                        label: Text(j.nom),
                        selected: _preneurId == j.id,
                        onSelected: (_) => setState(() => _preneurId = j.id),
                      ))
                  .toList(),
            ),
            if (joueurs.length == 5) ...[
              const SizedBox(height: 16),
              Text('Appelé (tapez le preneur pour "preneur seul")',
                  style: Theme.of(context).textTheme.titleMedium),
              Wrap(
                spacing: 8,
                children: joueurs
                    .map((j) => ChoiceChip(
                          label: Text(j.nom),
                          selected: _appeleId == j.id,
                          onSelected: (_) => setState(() => _appeleId = j.id),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 16),
            Text('Bouts du preneur', style: Theme.of(context).textTheme.titleMedium),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('0')),
                ButtonSegment(value: 1, label: Text('1')),
                ButtonSegment(value: 2, label: Text('2')),
                ButtonSegment(value: 3, label: Text('3')),
              ],
              selected: {_bouts},
              onSelectionChanged: (selection) => setState(() => _bouts = selection.first),
            ),
            const SizedBox(height: 16),
            _BlocPointsPreneur(pointsPreneur: _pointsPreneur, bouts: _bouts),
            Slider(
              value: _pointsPreneur.toDouble(),
              min: 0,
              max: 91,
              divisions: 91,
              label: '$_pointsPreneur',
              onChanged: (value) => setState(() => _pointsPreneur = value.round()),
            ),
            const SizedBox(height: 16),
            Text('Petit au bout', style: Theme.of(context).textTheme.titleMedium),
            SegmentedButton<PetitAuBout>(
              segments: const [
                ButtonSegment(value: PetitAuBout.aucun, label: Text('Aucun')),
                ButtonSegment(value: PetitAuBout.preneur, label: Text('Preneur')),
                ButtonSegment(value: PetitAuBout.defense, label: Text('Défense')),
              ],
              selected: {_petitAuBout},
              onSelectionChanged: (selection) => setState(() => _petitAuBout = selection.first),
            ),
            const SizedBox(height: 16),
            Text('Poignée', style: Theme.of(context).textTheme.titleMedium),
            SegmentedButton<Poignee>(
              segments: const [
                ButtonSegment(value: Poignee.aucune, label: Text('Aucune')),
                ButtonSegment(value: Poignee.simple, label: Text('Simple')),
                ButtonSegment(value: Poignee.double, label: Text('Double')),
                ButtonSegment(value: Poignee.triple, label: Text('Triple')),
              ],
              selected: {_poignee},
              onSelectionChanged: (selection) => setState(() => _poignee = selection.first),
            ),
            const SizedBox(height: 16),
            Text('Chelem', style: Theme.of(context).textTheme.titleMedium),
            DropdownButtonFormField<ChelemType>(
              value: _chelem,
              items: const [
                DropdownMenuItem(value: ChelemType.aucun, child: Text('Aucun')),
                DropdownMenuItem(
                    value: ChelemType.preneurAnonceReussi,
                    child: Text('Preneur : annoncé et réussi')),
                DropdownMenuItem(
                    value: ChelemType.preneurNonAnonceReussi,
                    child: Text('Preneur : réussi non annoncé')),
                DropdownMenuItem(
                    value: ChelemType.preneurAnonceRate, child: Text('Preneur : annoncé et raté')),
                DropdownMenuItem(
                    value: ChelemType.defenseInflige, child: Text('Infligé par la défense')),
              ],
              onChanged: (value) => setState(() => _chelem = value ?? ChelemType.aucun),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _peutValider(joueurs.length) ? () => _valider(joueurs) : null,
              child: const Text('Valider'),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erreur : $error')),
      ),
    );
  }
}

/// Les deux carrés preneur/défense et l'écart par rapport au contrat à
/// faire, affichés au-dessus de la réglette de points.
class _BlocPointsPreneur extends StatelessWidget {
  final int pointsPreneur;
  final int bouts;

  const _BlocPointsPreneur({required this.pointsPreneur, required this.bouts});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ecart = pointsPreneur - seuilPreneur(bouts);
    final ecartTexte = ecart >= 0 ? '+$ecart' : '$ecart';
    final ecartCouleur = ecart >= 0 ? colorScheme.primary : colorScheme.secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _BoiteScore(
                    label: 'Preneur',
                    valeur: pointsPreneur,
                    couleur: colorScheme.primary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Écart contrat : $ecartTexte',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: ecartCouleur, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BoiteScore(
                label: 'Défense',
                valeur: 91 - pointsPreneur,
                couleur: colorScheme.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BoiteScore extends StatelessWidget {
  final String label;
  final int valeur;
  final Color couleur;

  const _BoiteScore({required this.label, required this.valeur, required this.couleur});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: couleur.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(
            '$valeur',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold, color: couleur),
          ),
        ],
      ),
    );
  }
}
