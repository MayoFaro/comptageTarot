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

String retirerAccents(String texte) {
  final buffer = StringBuffer();
  for (final code in texte.toLowerCase().runes) {
    final caractere = String.fromCharCode(code);
    buffer.write(_accents[caractere] ?? caractere);
  }
  return buffer.toString();
}

int? indexPremiereSectionCorrespondante(
  List<SectionReglement> sections,
  String terme,
) {
  final termeNormalise = retirerAccents(terme.trim());
  if (termeNormalise.isEmpty) return null;

  for (var i = 0; i < sections.length; i++) {
    if (retirerAccents(sections[i].texteComplet).contains(termeNormalise)) {
      return i;
    }
  }
  return null;
}
