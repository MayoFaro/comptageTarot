import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import '../providers/database_provider.dart';
import '../scoring/tarot_score_engine.dart';

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
  int _pointsPreneur = 45;
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
              onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
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
            DropdownButtonFormField<Contrat>(
              value: _contrat,
              decoration: const InputDecoration(labelText: 'Contrat'),
              items: const [
                DropdownMenuItem(value: Contrat.prise, child: Text('Prise')),
                DropdownMenuItem(value: Contrat.garde, child: Text('Garde')),
                DropdownMenuItem(value: Contrat.gardeSans, child: Text('Garde Sans le chien')),
                DropdownMenuItem(value: Contrat.gardeContre, child: Text('Garde Contre le chien')),
              ],
              onChanged: (value) => setState(() => _contrat = value),
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
            Text('Points du preneur : $_pointsPreneur',
                style: Theme.of(context).textTheme.titleMedium),
            Slider(
              value: _pointsPreneur.toDouble(),
              min: 0,
              max: 91,
              divisions: 91,
              label: '$_pointsPreneur',
              onChanged: (value) => setState(() => _pointsPreneur = value.round()),
            ),
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
