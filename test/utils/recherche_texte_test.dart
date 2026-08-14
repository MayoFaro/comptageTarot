import 'package:comptage_tarot/models/section_reglement.dart';
import 'package:comptage_tarot/utils/recherche_texte.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('retirerAccents normalise les caractères accentués et la casse', () {
    expect(retirerAccents('Écart'), 'ecart');
    expect(retirerAccents('DÉFENSE'), 'defense');
    expect(retirerAccents('Petit au Bout'), 'petit au bout');
  });

  group('indexesSectionsCorrespondantes', () {
    final sections = [
      const SectionReglement(
        titre: 'Les enchères',
        corps: 'Le joueur place a droite du donneur parle le premier.',
      ),
      const SectionReglement(
        titre: 'Le chelem',
        corps: 'Reussir le CHELEM, cest gagner toutes les levees.',
      ),
      const SectionReglement(
        titre: 'Le jeu à 5 joueurs',
        corps: 'Le mort procede a la distribution, et le CHELEM aussi.',
      ),
    ];

    test("retourne toutes les sections correspondantes, dans l'ordre du document", () {
      expect(indexesSectionsCorrespondantes(sections, 'CHELEM'), [1, 2]);
      expect(indexesSectionsCorrespondantes(sections, 'enchères'), [0]);
    });

    test('retourne une liste vide si aucune section ne correspond', () {
      expect(indexesSectionsCorrespondantes(sections, 'xyzabc'), isEmpty);
    });
  });

  group('plagesCorrespondantes', () {
    test('trouve toutes les occurrences, insensible aux accents et à la casse', () {
      final plages = plagesCorrespondantes('Le Petit et le petit sont différents', 'petit');
      expect(plages, hasLength(2));
      expect(plages[0].debut, 3);
      expect(plages[0].fin, 8);
      expect(plages[1].debut, 15);
      expect(plages[1].fin, 20);
    });

    test('gère un caractère qui se déplie (œ -> oe) sans décaler les positions', () {
      final plages = plagesCorrespondantes('Cœur', 'coeur');
      expect(plages, hasLength(1));
      expect(plages.single.debut, 0);
      expect(plages.single.fin, 4);
    });

    test('retourne une liste vide si le terme est vide ou absent', () {
      expect(plagesCorrespondantes('un texte', ''), isEmpty);
      expect(plagesCorrespondantes('un texte', 'absent'), isEmpty);
    });
  });

  group('texteAvecMarqueurs', () {
    test('encadre chaque occurrence des marqueurs', () {
      final resultat = texteAvecMarqueurs('Le Petit au Bout', [const PlageSurlignage(3, 8)]);
      expect(resultat, 'Le ${marqueurOuverture}Petit${marqueurFermeture} au Bout');
    });

    test("ne modifie pas le texte en l'absence de plage", () {
      expect(texteAvecMarqueurs('Le Petit au Bout', []), 'Le Petit au Bout');
    });
  });
}
