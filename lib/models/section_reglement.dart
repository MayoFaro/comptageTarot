class SectionReglement {
  const SectionReglement({required this.titre, required this.corps});

  final String titre;
  final String corps;

  String get texteComplet => '$titre\n$corps';
}

List<SectionReglement> analyserSections(String markdown) {
  final lignes = markdown.split('\n');
  final sections = <SectionReglement>[];
  String? titreCourant;
  final corpsCourant = StringBuffer();

  void cloreSectionCourante() {
    if (titreCourant != null) {
      sections.add(SectionReglement(
        titre: titreCourant!,
        corps: corpsCourant.toString().trim(),
      ));
    }
  }

  for (final ligne in lignes) {
    if (ligne.startsWith('## ')) {
      cloreSectionCourante();
      titreCourant = ligne.substring(3).trim();
      corpsCourant.clear();
    } else if (titreCourant != null) {
      corpsCourant.writeln(ligne);
    }
  }
  cloreSectionCourante();

  return sections;
}
