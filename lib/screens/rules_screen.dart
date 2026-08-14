import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../models/section_reglement.dart';
import '../utils/recherche_texte.dart';
import '../widgets/markdown_surlignage.dart';

Future<String> _chargerAssetReglement() =>
    rootBundle.loadString('assets/reglement/reglement.md');

class RulesScreen extends StatefulWidget {
  const RulesScreen({super.key, this.chargeurReglement = _chargerAssetReglement});

  /// Permet d'injecter un chargeur alternatif dans les tests : recharger le
  /// même asset via `rootBundle` à répétition dans plusieurs `testWidgets`
  /// du même fichier ne se termine pas de façon fiable sur cette version de
  /// Flutter (l'appel natif ne se résout qu'une seule fois par process de
  /// test) — les tests chargent donc le contenu une fois via `setUpAll` et
  /// l'injectent ici plutôt que de rappeler `rootBundle.loadString`.
  final Future<String> Function() chargeurReglement;

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> {
  List<SectionReglement>? _sections;
  List<GlobalKey> _cles = [];
  String? _messageAucunResultat;
  String _termeActif = '';
  List<int> _indexesResultats = [];
  int? _indexResultatCourant;

  @override
  void initState() {
    super.initState();
    _chargerReglement();
  }

  Future<void> _chargerReglement() async {
    final contenu = await widget.chargeurReglement();
    final sections = analyserSections(contenu);
    if (!mounted) return;
    setState(() {
      _sections = sections;
      _cles = List.generate(sections.length, (_) => GlobalKey());
    });
  }

  void _onRechercheChangee(String requete) {
    final sections = _sections;
    if (sections == null) return;

    if (requete.trim().length < 2) {
      setState(() {
        _messageAucunResultat = null;
        _indexesResultats = [];
        _indexResultatCourant = null;
        _termeActif = '';
      });
      return;
    }

    final indexes = indexesSectionsCorrespondantes(sections, requete);
    if (indexes.isEmpty) {
      setState(() {
        _messageAucunResultat = 'Aucun résultat pour « $requete »';
        _indexesResultats = [];
        _indexResultatCourant = null;
        _termeActif = requete;
      });
      return;
    }

    setState(() {
      _messageAucunResultat = null;
      _indexesResultats = indexes;
      _indexResultatCourant = 0;
      _termeActif = requete;
    });
    _allerAuResultatCourant();
  }

  void _resultatSuivant() {
    final indexResultatCourant = _indexResultatCourant;
    if (indexResultatCourant == null) return;
    setState(() {
      _indexResultatCourant = (indexResultatCourant + 1) % _indexesResultats.length;
    });
    _allerAuResultatCourant();
  }

  void _resultatPrecedent() {
    final indexResultatCourant = _indexResultatCourant;
    if (indexResultatCourant == null) return;
    setState(() {
      _indexResultatCourant =
          (indexResultatCourant - 1 + _indexesResultats.length) % _indexesResultats.length;
    });
    _allerAuResultatCourant();
  }

  void _allerAuResultatCourant() {
    final indexResultatCourant = _indexResultatCourant;
    if (indexResultatCourant == null) return;
    final indexSection = _indexesResultats[indexResultatCourant];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contexteSection = _cles[indexSection].currentContext;
      if (contexteSection != null) {
        Scrollable.ensureVisible(
          contexteSection,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.0,
        );
      }
    });
  }

  String _donneesSection(SectionReglement section) {
    final texteSection = '## ${section.titre}\n\n${section.corps}';
    if (_termeActif.isEmpty) return texteSection;
    final plages = plagesCorrespondantes(texteSection, _termeActif);
    return plages.isEmpty ? texteSection : texteAvecMarqueurs(texteSection, plages);
  }

  @override
  Widget build(BuildContext context) {
    final sections = _sections;
    final indexResultatCourant = _indexResultatCourant;
    return Scaffold(
      appBar: AppBar(title: const Text('Règlement')),
      body: sections == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              key: const Key('rules_search_field'),
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.search),
                                hintText: 'Rechercher dans le règlement',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: _onRechercheChangee,
                            ),
                          ),
                          if (indexResultatCourant != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '${indexResultatCourant + 1}/${_indexesResultats.length}',
                              key: const Key('rules_result_counter'),
                            ),
                            IconButton(
                              key: const Key('rules_previous_button'),
                              icon: const Icon(Icons.keyboard_arrow_up),
                              onPressed: _resultatPrecedent,
                            ),
                            IconButton(
                              key: const Key('rules_next_button'),
                              icon: const Icon(Icons.keyboard_arrow_down),
                              onPressed: _resultatSuivant,
                            ),
                          ],
                        ],
                      ),
                      if (_messageAucunResultat != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _messageAucunResultat!,
                            key: const Key('rules_no_results'),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    key: const Key('rules_scroll_view'),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < sections.length; i++)
                          Container(
                            key: _cles[i],
                            padding: const EdgeInsets.only(bottom: 16),
                            child: MarkdownBody(
                              data: _donneesSection(sections[i]),
                              extensionSet: extensionSetSurlignage,
                              builders: buildersSurlignage,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
