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

  tearDown(() async {
    await db.close();
  });

  Future<void> pumpHomeScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  Future<void> disposeWidgetTree(WidgetTester tester) async {
    // Démonte explicitement le ProviderScope et donc les providers Riverpod.
    await tester.pumpWidget(const SizedBox.shrink());

    // Drift programme un Timer(Duration.zero) lors de la fermeture de certains
    // flux. Ces pumps lui permettent de s'exécuter avant que flutter_test
    // vérifie qu'aucun timer ne reste en attente.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets(
    "affiche une carte d'accès au règlement",
    (tester) async {
      await pumpHomeScreen(tester);

      expect(
        find.text('Règlement du jeu'),
        findsOneWidget,
      );

      await disposeWidgetTree(tester);
    },
  );

  testWidgets(
    'taper sur la carte règlement ouvre RulesScreen',
    (tester) async {
      await pumpHomeScreen(tester);

      await tester.tap(
        find.text('Règlement du jeu'),
      );

      // Pas de pumpAndSettle ici : RulesScreen affiche un indicateur de
      // chargement pendant la lecture asynchrone de son asset. Ici, seule
      // la navigation vers RulesScreen nous intéresse.
      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: 300),
      );

      expect(
        find.byType(RulesScreen),
        findsOneWidget,
      );

      await disposeWidgetTree(tester);
    },
  );
}