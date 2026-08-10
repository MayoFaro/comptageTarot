import 'package:comptage_tarot/models/section_reglement.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('découpe un markdown en sections sur les titres ##', () {
    const markdown = '''
# Règlement officiel

## Première section
Contenu A
suite A

## Deuxième section
Contenu B
''';
    final sections = analyserSections(markdown);

    expect(sections, hasLength(2));
    expect(sections[0].titre, 'Première section');
    expect(sections[0].corps, 'Contenu A\nsuite A');
    expect(sections[1].titre, 'Deuxième section');
    expect(sections[1].corps, 'Contenu B');
  });

  test('ignore le contenu avant le premier titre ##', () {
    const markdown = '# Titre principal\nTexte orphelin\n\n## Section\nCorps';
    final sections = analyserSections(markdown);

    expect(sections, hasLength(1));
    expect(sections.single.titre, 'Section');
  });

  test('texteComplet concatène le titre et le corps', () {
    const section = SectionReglement(titre: 'Titre', corps: 'Corps');
    expect(section.texteComplet, 'Titre\nCorps');
  });
}
