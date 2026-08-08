import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import '../providers/database_provider.dart';

/// Ouvre le formulaire de création/édition d'un joueur.
///
/// Retourne l'id du joueur créé ou édité, ou `null` si l'utilisateur a
/// annulé — utile pour pré-sélectionner un joueur qu'on vient de créer
/// (voir `GameConfigScreen`).
Future<int?> ouvrirFormulaireJoueur(BuildContext context, WidgetRef ref, {Joueur? joueur}) async {
  final controller = TextEditingController(text: joueur?.nom ?? '');
  final nom = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(joueur == null ? 'Nouveau joueur' : 'Modifier le joueur'),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(labelText: 'Nom'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: const Text('Enregistrer'),
        ),
      ],
    ),
  );
  if (nom == null || nom.isEmpty) return null;

  final db = ref.read(databaseProvider);
  if (joueur == null) {
    return db.creerJoueur(nom);
  }
  await db.modifierJoueur(joueur.id, nom);
  return joueur.id;
}

Future<void> confirmerSuppressionJoueur(BuildContext context, WidgetRef ref, Joueur joueur) async {
  final confirme = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Supprimer ce joueur ?'),
      content: Text('${joueur.nom} sera retiré de la liste réutilisable.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Supprimer'),
        ),
      ],
    ),
  );
  if (confirme == true) {
    await ref.read(databaseProvider).supprimerJoueur(joueur.id);
  }
}
