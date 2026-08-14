import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import '../providers/database_provider.dart';

/// Ouvre le formulaire de création/édition d'un joueur.
///
/// Retourne l'id du joueur créé ou édité, ou `null` si l'utilisateur a
/// annulé — utile pour pré-sélectionner un joueur qu'on vient de créer
/// (voir `GameConfigScreen`).
Future<int?> ouvrirFormulaireJoueur(
  BuildContext context,
  WidgetRef ref, {
  Joueur? joueur,
}) async {
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

/// Ouvre en boucle le formulaire "Nouveau joueur" : le bouton "Suivant"
/// enregistre le joueur courant et rouvre aussitôt un formulaire vierge,
/// pour ajouter plusieurs joueurs d'affilée sans repasser par le bouton
/// d'ajout entre chacun. "Annuler" referme la boucle. Un nom déjà pris par
/// un joueur existant est refusé (comparaison insensible à la casse) : un
/// message l'explique et fait réapparaître le formulaire avec le nom
/// litigieux pré-rempli, pour correction.
///
/// Retourne les ids des joueurs créés au cours de cette session (liste vide
/// si l'utilisateur annule sans avoir rien enregistré).
Future<List<int>> ouvrirFormulaireAjoutJoueurs(
  BuildContext context,
  WidgetRef ref,
) async {
  final idsCrees = <int>[];
  var texteInitial = '';

  while (true) {
    if (!context.mounted) break;
    final controller = TextEditingController(text: texteInitial);
    final resultat = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouveau joueur'),
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
            child: const Text('Suivant'),
          ),
        ],
      ),
    );
    if (resultat == null || resultat.isEmpty) break;

    final db = ref.read(databaseProvider);
    final joueursExistants = await db.select(db.joueurs).get();
    final existeDeja = joueursExistants.any(
      (j) => j.nom.trim().toLowerCase() == resultat.toLowerCase(),
    );
    if (existeDeja) {
      texteInitial = resultat;
      if (!context.mounted) break;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Nom déjà utilisé'),
          content: Text(
            'Un joueur nommé « $resultat » existe déjà. Choisis un autre nom.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      continue;
    }

    idsCrees.add(await db.creerJoueur(resultat));
    texteInitial = '';
  }

  return idsCrees;
}

Future<void> confirmerSuppressionJoueur(
  BuildContext context,
  WidgetRef ref,
  Joueur joueur,
) async {
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
  if (confirme == true) {
    await ref.read(databaseProvider).supprimerJoueur(joueur.id);
  }
}
