import 'package:comptage_tarot/models/section_reglement.dart';
import 'package:comptage_tarot/utils/recherche_texte.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('retirerAccents normalise les caractères accentués et la casse', () {
    expect(retirerAccents('Écart'), 'ecart');
    expect(retirerAccents('DÉFENSE'), 'defense');
    expect(retirerAccents('Petit au Bout'), 'petit au bout');
  });

  group('indexPremiereSectionCorrespondante', () {
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
        corps: 'Le mort procede a la distribution.',
      ),
    ];

    test('trouve la première section correspondante, insensible aux accents et à la casse', () {
      expect(indexPremiereSectionCorrespondante(sections, 'CHELEM'), 1);
      expect(indexPremiereSectionCorrespondante(sections, 'enchères'), 0);
      expect(indexPremiereSectionCorrespondante(sections, 'jeu à 5 joueurs'), 2);
    });

    test('retourne null si aucune section ne correspond', () {
      expect(indexPremiereSectionCorrespondante(sections, 'xyzabc'), isNull);
    });
  });
}
