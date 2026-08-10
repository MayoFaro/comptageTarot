import 'package:comptage_tarot/screens/rules_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

void main() {
  late String contenuReglement;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    contenuReglement = await rootBundle.loadString('assets/reglement/reglement.md');
  });

  Future<void> pumpRulesScreen(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: RulesScreen(chargeurReglement: () async => contenuReglement),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets("affiche le titre d'une section connue une fois le règlement chargé",
      (tester) async {
    await pumpRulesScreen(tester);

    expect(find.text('Les enchères'), findsOneWidget);
  });

  testWidgets('saisir un terme sans correspondance affiche le message "Aucun résultat"',
      (tester) async {
    await pumpRulesScreen(tester);

    await tester.enterText(find.byKey(const Key('rules_search_field')), 'zzzzzintrouvable');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('rules_no_results')), findsOneWidget);
  });

  testWidgets("un terme d'un seul caractère ne déclenche pas de recherche", (tester) async {
    await pumpRulesScreen(tester);

    await tester.enterText(find.byKey(const Key('rules_search_field')), 'z');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('rules_no_results')), findsNothing);
  });

  testWidgets("saisir un terme d'une section éloignée fait défiler la liste", (tester) async {
    await pumpRulesScreen(tester);

    final scrollable = find.descendant(
      of: find.byKey(const Key('rules_scroll_view')),
      matching: find.byType(Scrollable),
    );
    final positionAvant = tester.state<ScrollableState>(scrollable).position.pixels;

    await tester.enterText(find.byKey(const Key('rules_search_field')), 'jeu à 5 joueurs');
    await tester.pumpAndSettle();

    final positionApres = tester.state<ScrollableState>(scrollable).position.pixels;
    expect(positionApres, greaterThan(positionAvant));
    expect(find.byKey(const Key('rules_no_results')), findsNothing);
  });
}
