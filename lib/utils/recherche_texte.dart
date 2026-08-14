import '../models/section_reglement.dart';

const Map<String, String> _accents = {
  'à': 'a', 'â': 'a', 'ä': 'a',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'î': 'i', 'ï': 'i',
  'ô': 'o', 'ö': 'o',
  'ù': 'u', 'û': 'u', 'ü': 'u',
  'ç': 'c',
  'œ': 'oe',
};

/// Marqueurs invisibles (zone privée Unicode, U+E000/U+E001) utilisés pour
/// délimiter une occurrence à surligner dans le markdown source d'une
/// section, avant de le donner à `MarkdownBody` (voir
/// `lib/widgets/markdown_surlignage.dart`). Construits via `fromCharCode`
/// plutôt qu'en tant que littéraux : ce sont des caractères non imprimables,
/// les garder comme code évite qu'un éditeur ou un outil de diff les altère
/// silencieusement dans le fichier source. Étant dans la zone privée, ces
/// points de code n'ont par définition aucune signification standard et ne
/// peuvent pas entrer en collision avec un caractère du règlement.
final String marqueurOuverture = String.fromCharCode(0xE000);
final String marqueurFermeture = String.fromCharCode(0xE001);

class TexteNormaliseAvecPositions {
  const TexteNormaliseAvecPositions(this.normalise, this._indexOriginaux);

  final String normalise;
  final List<int> _indexOriginaux;

  int indexOriginalDebut(int indexNormalise) => _indexOriginaux[indexNormalise];

  int indexOriginalFin(int indexNormaliseExclusif) =>
      _indexOriginaux[indexNormaliseExclusif - 1] + 1;
}

/// Normalise `texte` (minuscule, accents retirés) en conservant, pour
/// chaque caractère du résultat, l'indice du caractère d'origine dont il
/// provient. Nécessaire car certains caractères se déplient en plusieurs
/// caractères (`œ` -> `oe`), ce qui décalerait les indices si on ne les
/// suivait pas explicitement. Suppose que `texte` ne contient pas de
/// caractères en dehors du plan multilingue de base (vrai pour le
/// règlement, en français).
TexteNormaliseAvecPositions normaliserAvecPositions(String texte) {
  final normaliseBuffer = StringBuffer();
  final indexOriginaux = <int>[];

  for (var indexOriginal = 0; indexOriginal < texte.length; indexOriginal++) {
    final minuscule = texte[indexOriginal].toLowerCase();
    final remplace = _accents[minuscule] ?? minuscule;
    normaliseBuffer.write(remplace);
    for (var i = 0; i < remplace.length; i++) {
      indexOriginaux.add(indexOriginal);
    }
  }

  return TexteNormaliseAvecPositions(normaliseBuffer.toString(), indexOriginaux);
}

String retirerAccents(String texte) => normaliserAvecPositions(texte).normalise;

/// Sections (dans l'ordre du document) dont le titre ou le corps contient
/// `terme`, comparaison insensible aux accents et à la casse.
List<int> indexesSectionsCorrespondantes(
  List<SectionReglement> sections,
  String terme,
) {
  final termeNormalise = retirerAccents(terme.trim());
  if (termeNormalise.isEmpty) return [];

  final resultats = <int>[];
  for (var i = 0; i < sections.length; i++) {
    if (retirerAccents(sections[i].texteComplet).contains(termeNormalise)) {
      resultats.add(i);
    }
  }
  return resultats;
}

class PlageSurlignage {
  const PlageSurlignage(this.debut, this.fin);

  /// Indice de début (inclusif) dans le texte original.
  final int debut;

  /// Indice de fin (exclusif) dans le texte original.
  final int fin;
}

/// Bornes, dans `texte` (indices d'origine), de toutes les occurrences de
/// `terme`, comparaison insensible aux accents et à la casse. Occurrences
/// non chevauchantes, dans l'ordre d'apparition.
List<PlageSurlignage> plagesCorrespondantes(String texte, String terme) {
  final termeNormalise = retirerAccents(terme.trim());
  if (termeNormalise.isEmpty) return [];

  final texteNormalise = normaliserAvecPositions(texte);
  final plages = <PlageSurlignage>[];
  var indexRecherche = 0;
  while (true) {
    final indexTrouve = texteNormalise.normalise.indexOf(termeNormalise, indexRecherche);
    if (indexTrouve == -1) break;
    final debut = texteNormalise.indexOriginalDebut(indexTrouve);
    final fin = texteNormalise.indexOriginalFin(indexTrouve + termeNormalise.length);
    plages.add(PlageSurlignage(debut, fin));
    indexRecherche = indexTrouve + termeNormalise.length;
  }
  return plages;
}

/// Encadre chaque `plage` de `texte` avec `marqueurOuverture`/`marqueurFermeture`.
String texteAvecMarqueurs(String texte, List<PlageSurlignage> plages) {
  if (plages.isEmpty) return texte;

  final buffer = StringBuffer();
  var curseur = 0;
  for (final plage in plages) {
    buffer.write(texte.substring(curseur, plage.debut));
    buffer.write(marqueurOuverture);
    buffer.write(texte.substring(plage.debut, plage.fin));
    buffer.write(marqueurFermeture);
    curseur = plage.fin;
  }
  buffer.write(texte.substring(curseur));
  return buffer.toString();
}
