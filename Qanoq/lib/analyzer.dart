import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'blockWidget.dart';
import 'variables.dart';
import 'tagging.dart';

// illoqarfimmiippoq
// illu+QAR+Der/nv+Gram/IV+VIK+Der/vn+N+Lok+Sg+Gram/Hyb+IP+Gram/IV+V+Ind+3Sg

// illoqarfianukarsimavoq
// illu+QAR+Der/nv+Gram/IV+Gram/IV+VIK+Der/vn+N+Trm+Sg+3PlPoss+Gram/Hyb+KAR+Der/nv+Gram/IV+SIMA+Der/vv+V+Ind+3Sg

// qaagit
// qaa+Gram/IV+V+Imp+2Sg

// illoqarfiga
// illu+QAR+Der/nv+Gram/IV+VIK+Der/vn+N+Abs+Sg+1SgPoss

// taasarpaa
// taa+Gram/TV+TAR+Der/vv+Gram/TV+V+Ind+3Sg+3SgO

class Morpheme {
  String form;
  String join;
  String endForm;
  String type;
  // join: n, iv, tv, nn, nv, vv, vn, enc, ev, end
  // type: enc, aff, end, root
  Morpheme({
    required this.join,
    required this.type,
    this.form = "",
    this.endForm = "",
  });
}

class ParsedWord {
  List<Morpheme> morphemes;
  ParsedWord({required this.morphemes});
}

String analyzerTypeConverter(String type) {
  if (type == "Gram/Hyb") {
    return "ev";
  } else if (type.startsWith("Gram") || type.startsWith("Der")) {
    return type.split('/')[1].toLowerCase();
  } else {
    return '?';
  }
}

ParsedWord parseWord(String str) {
  final parts = str.split('+');
  List<Morpheme> morphemes = [];
  bool inEnding = false;
  bool nextIsHyb = false;

  for (var i = 0; i < parts.length; i++) {
    final part = parts[i];
    if (part == 'Gram/Hyb') {
      nextIsHyb = true;
      inEnding = false;
      continue;
    }
    if (part.toUpperCase() == part) {
      // all caps, either an affix or an ending marker
      if (part == 'V' || part == 'N' || part == "Adv" || part == "Conj") {
        // ending start
        inEnding = true;
        morphemes.add(Morpheme(join: 'end', type: 'end', endForm: part));
      } else {
        // affix or enclitic
        if (nextIsHyb) {
          nextIsHyb = false;
          morphemes.add(Morpheme(join: 'ev', type: 'enc', form: part));
        } else if (inEnding) {
          morphemes.add(Morpheme(join: 'enc', type: 'enc', form: part));
        } else {
          // affix
          if (i != parts.length - 1) {
            morphemes.add(
              Morpheme(
                join: analyzerTypeConverter(parts[i + 1]),
                type: 'aff',
                form: part,
              ),
            );
          } else {
            // probably an enclitic on an adverb since the analyzer doesnt show end forms for those (so inEnding is always false)
            morphemes.add(Morpheme(join: 'enc', type: 'enc', form: part));
          }
        }
      }
    } else if (part.toLowerCase() == part) {
      // all lower, in a root
      morphemes.add(Morpheme(join: '?', type: 'root', form: part));
    } else {
      // in something that is not an affix, ending marker, or a root

      // add ending part (after ending marker)
      if (morphemes.length > 1 && inEnding) {
        for (var m = morphemes.length - 1; m >= 0; m--) {
          if (morphemes[m].type == 'end') {
            morphemes[m].endForm += ' + $part';
            break;
          }
        }
      }
    }
  }

  // find root type
  if (morphemes.length > 1) {
    if (morphemes[1].type == 'aff') {
      morphemes[0].join = morphemes[1].join.split('')[0];
    } else if (morphemes[1].type == 'end') {
      morphemes[0].join = morphemes[1].endForm.split('')[0].toLowerCase();
    }
  }

  print('------');

  for (var m in morphemes) {
    print(m.endForm + ' ' + m.form + ' ' + m.join + ' ' + m.type);
  }

  return ParsedWord(morphemes: morphemes);
}

Future<String?> analyzerRequest(String searchTerm) async {
  Uri url;

  if (kIsWeb) {
    url = Uri.parse(
      '${Uri.base.origin}/analyze',
    ).replace(queryParameters: {'word': searchTerm});
  } else {
    url = Uri.https('imlillith888.xyz', '/analyze', {'word': searchTerm});
  }
  print(url);

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  } catch (e) {
    print('An error occurred: $e');
  }
  return null;
}

class analyzerPage extends StatefulWidget {
  const analyzerPage({super.key});

  @override
  State<analyzerPage> createState() => _analyzerPageState();
}

class _analyzerPageState extends State<analyzerPage> {
  final TextEditingController _serverController = TextEditingController();
  final TextEditingController _wordController = TextEditingController();

  String _textValue = '';

  List<ParsedWord> _cleanedAnalyses = [];

  void _searchDictionary() {
    setState(() {
      _cleanedAnalyses = [];
    });
    analyzerRequest(_textValue).then((analyzed) {
      if (analyzed == null) {
        setState(() {
          _cleanedAnalyses = [];
        });
        return;
      }
      final analyzedObj = jsonDecode(analyzed);
      final analyses = analyzedObj['analyses'] as List<dynamic>?;

      List<String> analysesNoRepeats = [];

      for (int i = 0; i < analyses!.length; i++) {
        bool found = false;
        for (int j = 0; j < analysesNoRepeats.length; j++) {
          if (analysesNoRepeats[j] == analyses[i]['cleaned']) {
            found = true;
          }
        }
        if (!found) {
          analysesNoRepeats.add(analyses[i]['cleaned']);
          print(analyses[i]['cleaned']);
        }
      }

      final cleaned =
          analysesNoRepeats?.map((a) => parseWord(a)).toList() ?? [];
      setState(() {
        _cleanedAnalyses = cleaned.cast<ParsedWord>();
      });
    });
  }

  @override
  void dispose() {
    _serverController.dispose();
    _wordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          right: 15,
          top: 15,
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        title: Text(uiStrings['dictionary.settings']),
                        content: taggingPage(),
                      );
                    },
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(50, 50),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Icon(Icons.menu, size: 32),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(uiStrings['analyzer.title'], style: TextStyle(fontSize: 30)),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _wordController,
                          decoration: InputDecoration(
                            hintText: uiStrings['analyzer.enter-word'],
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (text) {
                            _textValue = text;
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      ElevatedButton(
                        onPressed: _searchDictionary,
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(50, 50),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Icon(Icons.pageview_outlined, size: 32),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // Render the custom widget for each analysis
                children: _cleanedAnalyses
                    .map(
                      (parsedWord) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ParsedWordWidget(word: parsedWord),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
