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

enum _CampPoignee { attaque, defense }

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
  Poignee _poigneeAttaque = Poignee.aucune;
  Poignee _poigneeDefense = Poignee.aucune;
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
      _poigneeAttaque = Poignee.values.byName(manche.poigneeAttaque);
      _poigneeDefense = Poignee.values.byName(manche.poigneeDefense);
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
      poigneeAttaque: _poigneeAttaque,
      poigneeDefense: _poigneeDefense,
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

  void _onCampsPoigneeChanges(Set<_CampPoignee> camps) {
    setState(() {
      _poigneeAttaque = camps.contains(_CampPoignee.attaque)
          ? (_poigneeAttaque == Poignee.aucune ? Poignee.simple : _poigneeAttaque)
          : Poignee.aucune;
      _poigneeDefense = camps.contains(_CampPoignee.defense)
          ? (_poigneeDefense == Poignee.aucune ? Poignee.simple : _poigneeDefense)
          : Poignee.aucune;
    });
  }

  @override
  Widget build(BuildContext context) {
    final joueursAsync = ref.watch(joueursDePartieProvider(widget.partieId));
    final campsActifs = {
      if (_poigneeAttaque != Poignee.aucune) _CampPoignee.attaque,
      if (_poigneeDefense != Poignee.aucune) _CampPoignee.defense,
    };

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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          children: [
            Text('Contrat', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            _GrilleContrat(
              contratSelectionne: _contrat,
              onSelectionner: (c) => setState(() => _contrat = c),
            ),
            const SizedBox(height: 10),
            Text('Preneur', style: Theme.of(context).textTheme.titleMedium),
            Wrap(
              spacing: 8,
              children: joueurs
                  .map((j) => ChoiceChip(
                        label: Text(j.nom),
                        showCheckmark: false,
                        selected: _preneurId == j.id,
                        onSelected: (_) => setState(() => _preneurId = j.id),
                      ))
                  .toList(),
            ),
            if (joueurs.length == 5) ...[
              const SizedBox(height: 10),
              Text('Appelé', style: Theme.of(context).textTheme.titleMedium),
              Wrap(
                spacing: 8,
                children: joueurs
                    .map((j) => ChoiceChip(
                          label: Text(j.nom),
                          showCheckmark: false,
                          selected: _appeleId == j.id,
                          onSelected: (_) => setState(() => _appeleId = j.id),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
            _BlocPointsPreneur(pointsPreneur: _pointsPreneur, bouts: _bouts),
            Slider(
              value: _pointsPreneur.toDouble(),
              min: 0,
              max: 91,
              divisions: 91,
              label: '$_pointsPreneur',
              onChanged: (value) => setState(() => _pointsPreneur = value.round()),
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
            Text('Poignée (les deux camps peuvent en présenter une)',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            SegmentedButton<_CampPoignee>(
              multiSelectionEnabled: true,
              emptySelectionAllowed: true,
              segments: const [
                ButtonSegment(value: _CampPoignee.attaque, label: Text('Attaque')),
                ButtonSegment(value: _CampPoignee.defense, label: Text('Défense')),
              ],
              selected: campsActifs,
              onSelectionChanged: _onCampsPoigneeChanges,
            ),
            if (_poigneeAttaque != Poignee.aucune) ...[
              const SizedBox(height: 8),
              Text('Type de poignée — Attaque', style: Theme.of(context).textTheme.labelLarge),
              SegmentedButton<Poignee>(
                segments: const [
                  ButtonSegment(value: Poignee.simple, label: Text('Simple')),
                  ButtonSegment(value: Poignee.double, label: Text('Double')),
                  ButtonSegment(value: Poignee.triple, label: Text('Triple')),
                ],
                selected: {_poigneeAttaque},
                onSelectionChanged: (selection) =>
                    setState(() => _poigneeAttaque = selection.first),
              ),
            ],
            if (_poigneeDefense != Poignee.aucune) ...[
              const SizedBox(height: 8),
              Text('Type de poignée — Défense', style: Theme.of(context).textTheme.labelLarge),
              SegmentedButton<Poignee>(
                segments: const [
                  ButtonSegment(value: Poignee.simple, label: Text('Simple')),
                  ButtonSegment(value: Poignee.double, label: Text('Double')),
                  ButtonSegment(value: Poignee.triple, label: Text('Triple')),
                ],
                selected: {_poigneeDefense},
                onSelectionChanged: (selection) =>
                    setState(() => _poigneeDefense = selection.first),
              ),
            ],
            const SizedBox(height: 10),
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
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erreur : $error')),
      ),
      bottomNavigationBar: joueursAsync.maybeWhen(
        data: (joueurs) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: FilledButton(
              onPressed: _peutValider(joueurs.length) ? () => _valider(joueurs) : null,
              child: const Text('Valider'),
            ),
          ),
        ),
        orElse: () => null,
      ),
    );
  }
}

/// Grille 2×2 de tuiles de taille identique pour le choix du contrat.
class _GrilleContrat extends StatelessWidget {
  final Contrat? contratSelectionne;
  final ValueChanged<Contrat> onSelectionner;

  const _GrilleContrat({required this.contratSelectionne, required this.onSelectionner});

  @override
  Widget build(BuildContext context) {
    Widget tuile(Contrat c) => _TuileSelection(
          label: _libelleContrat(c),
          selected: contratSelectionne == c,
          onTap: () => onSelectionner(c),
        );

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: tuile(Contrat.prise)),
            const SizedBox(width: 8),
            Expanded(child: tuile(Contrat.garde)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: tuile(Contrat.gardeSans)),
            const SizedBox(width: 8),
            Expanded(child: tuile(Contrat.gardeContre)),
          ],
        ),
      ],
    );
  }
}

class _TuileSelection extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TuileSelection({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// Les deux carrés preneur/défense, de taille identique, colorés en direct
/// selon qui est actuellement en réussite sur le contrat.
class _BlocPointsPreneur extends StatelessWidget {
  final int pointsPreneur;
  final int bouts;

  const _BlocPointsPreneur({required this.pointsPreneur, required this.bouts});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ecartAttaque = pointsPreneur - seuilPreneur(bouts);
    final attaqueGagne = ecartAttaque >= 0;
    final couleurAttaque = attaqueGagne ? colorScheme.primary : colorScheme.secondary;
    final couleurDefense = attaqueGagne ? colorScheme.secondary : colorScheme.primary;

    return Row(
      children: [
        Expanded(
          child: _BoiteScore(
            label: 'Preneur',
            valeur: pointsPreneur,
            ecart: ecartAttaque,
            couleur: couleurAttaque,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BoiteScore(
            label: 'Défense',
            valeur: 91 - pointsPreneur,
            ecart: -ecartAttaque,
            couleur: couleurDefense,
          ),
        ),
      ],
    );
  }
}

class _BoiteScore extends StatelessWidget {
  final String label;
  final int valeur;
  final int ecart;
  final Color couleur;

  const _BoiteScore({
    required this.label,
    required this.valeur,
    required this.ecart,
    required this.couleur,
  });

  @override
  Widget build(BuildContext context) {
    final ecartTexte = ecart >= 0 ? '+$ecart' : '$ecart';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: couleur.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          Text(
            '$valeur',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold, color: couleur),
          ),
          Text(
            'Écart : $ecartTexte',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: couleur, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
