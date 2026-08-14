import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

import '../theme/app_theme.dart';
import '../utils/recherche_texte.dart';

class _SurlignageInlineSyntax extends md.InlineSyntax {
  _SurlignageInlineSyntax() : super('$marqueurOuverture(.*?)$marqueurFermeture');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text('surlignage', match[1]!));
    return true;
  }
}

class SurlignageMarkdownBuilder extends MarkdownElementBuilder {
  // `visitText` est indexé par le tag du bloc englobant (paragraphe, titre,
  // cellule de tableau...), pas par le tag de l'élément inline lui-même : ce
  // n'est donc pas le bon point d'extension pour un tag inline personnalisé
  // comme `surlignage`. `visitElementAfter` en revanche est bien indexé par
  // le tag de l'élément — c'est le hook à utiliser ici.
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    // `preferredStyle` est `null` ici (aucun style enregistré pour le tag
    // `surlignage` dans la feuille de style) : partir d'un `TextStyle()`
    // vide plutôt que de `?.copyWith` évite de perdre le surlignage.
    // `Text` fusionne de toute façon ce style avec le `DefaultTextStyle`
    // ambiant pour tout ce qui n'est pas précisé ici (police, taille...).
    return Text(
      element.textContent,
      style: (preferredStyle ?? const TextStyle()).copyWith(
        backgroundColor: selectionFill,
        color: onSelectionFill,
      ),
    );
  }
}

final md.ExtensionSet extensionSetSurlignage = md.ExtensionSet(
  md.ExtensionSet.gitHubFlavored.blockSyntaxes,
  [...md.ExtensionSet.gitHubFlavored.inlineSyntaxes, _SurlignageInlineSyntax()],
);

final Map<String, MarkdownElementBuilder> buildersSurlignage = {
  'surlignage': SurlignageMarkdownBuilder(),
};
