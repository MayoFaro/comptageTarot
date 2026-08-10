import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../models/section_reglement.dart';
import '../utils/recherche_texte.dart';

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
      setState(() => _messageAucunResultat = null);
      return;
    }

    final index = indexPremiereSectionCorrespondante(sections, requete);
    if (index == null) {
      setState(() => _messageAucunResultat = 'Aucun résultat pour « $requete »');
      return;
    }

    setState(() => _messageAucunResultat = null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contexteSection = _cles[index].currentContext;
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

  @override
  Widget build(BuildContext context) {
    final sections = _sections;
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
                      TextField(
                        key: const Key('rules_search_field'),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Rechercher dans le règlement',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: _onRechercheChangee,
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
                              data: '## ${sections[i].titre}\n\n${sections[i].corps}',
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
