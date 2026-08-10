import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('le règlement embarque toutes les sections attendues', () async {
    final contenu = await rootBundle.loadString('assets/reglement/reglement.md');

    expect(contenu, contains('## Avertissement'));
    expect(contenu, contains('## Présentation'));
    expect(contenu, contains('## Les cartes'));
    expect(contenu, contains('## Le principe du jeu'));
    expect(contenu, contains('## La distribution'));
    expect(contenu, contains('## La tenue des cartes'));
    expect(contenu, contains('## Les enchères'));
    expect(contenu, contains("## Le Chien et l'Ecart"));
    expect(contenu, contains('## Le chelem'));
    expect(contenu, contains('## La Poignée (10, 13 ou 15 Atouts)'));
    expect(contenu, contains('## Le Petit au Bout'));
    expect(contenu, contains('## Le jeu de la carte'));
    expect(contenu, contains('## Le calcul des scores'));
    expect(contenu, contains('## La marque en donnes libres'));
    expect(contenu, contains('## Le classement en donnes libres'));
    expect(contenu, contains('## Le tournoi libre par équipes'));
    expect(contenu, contains("## L'éthique du jeu"));
    expect(contenu, contains("## L'arbitre"));
    expect(contenu, contains('## Le jeu à 3 joueurs'));
    expect(contenu, contains('## Le jeu à 5 joueurs'));
  });
}
