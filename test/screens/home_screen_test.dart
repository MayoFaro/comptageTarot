import 'package:comptage_tarot/db/database.dart';
import 'package:comptage_tarot/providers/database_provider.dart';
import 'package:comptage_tarot/screens/home_screen.dart';
import 'package:comptage_tarot/screens/rules_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  Future<void> pumpHomeScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets("affiche une carte d'accès au règlement", (tester) async {
    await pumpHomeScreen(tester);

    expect(find.text('Règlement du jeu'), findsOneWidget);
  });

  testWidgets('taper sur la carte règlement ouvre RulesScreen', (tester) async {
    await pumpHomeScreen(tester);

    await tester.tap(find.text('Règlement du jeu'));
    // Pas de pumpAndSettle ici : RulesScreen affiche un indicateur de
    // chargement pendant la lecture (asynchrone) de son asset, et seule la
    // navigation nous intéresse dans ce test, pas la fin du chargement.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(RulesScreen), findsOneWidget);
  });
}
