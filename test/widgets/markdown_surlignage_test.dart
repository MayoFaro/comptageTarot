import 'package:comptage_tarot/theme/app_theme.dart';
import 'package:comptage_tarot/utils/recherche_texte.dart';
import 'package:comptage_tarot/widgets/markdown_surlignage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('surligne le texte encadré par les marqueurs avec la couleur de sélection',
      (tester) async {
    final donnees = texteAvecMarqueurs('avant surligne après', [const PlageSurlignage(6, 14)]);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MarkdownBody(
          data: donnees,
          extensionSet: extensionSetSurlignage,
          builders: buildersSurlignage,
        ),
      ),
    ));

    final texteSurligne = tester.widget<Text>(find.text('surligne'));
    expect(texteSurligne.style?.backgroundColor, selectionFill);
    expect(texteSurligne.style?.color, onSelectionFill);
  });

  testWidgets('un texte sans marqueur ne produit aucun surlignage', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: MarkdownBody(data: 'texte normal sans marqueur'),
      ),
    ));

    final textesSurlignes = tester
        .widgetList<Text>(find.byType(Text))
        .where((texte) => texte.style?.backgroundColor == selectionFill);
    expect(textesSurlignes, isEmpty);
  });
}
