import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:kalaallisutdictionary/blockWidget.dart';
import 'variables.dart';
import 'tagging.dart';

// class ParsedWord {
//   final Root root;
//   final List<Affix> affixes;
//   final Ending ending;
//   final List<Clitic> clitics;

//   ParsedWord({
//     required this.root,
//     required this.affixes,
//     required this.ending,
//     required this.clitics,
//   });

//   @override
//   String toString() {
//     final buffer = StringBuffer();
//     buffer.writeln('1. Root: $root');
//     buffer.writeln('2. Affixes:');
//     if (affixes.isEmpty) {
//       buffer.writeln('   (None)');
//     } else {
//       for (var affix in affixes) {
//         buffer.writeln('   - $affix');
//       }
//     }
//     buffer.writeln('3. Ending: $ending');
//     return buffer.toString();
//   }
// }

// class Root {
//   final String text;
//   final String type; // Noun, Verb, Conj
//   final List<String> markers;

//   Root(this.text, this.type, this.markers);

//   @override
//   String toString() {
//     final markerStr = markers.isNotEmpty
//         ? ' [Markers: ${markers.join(' + ')}]'
//         : '';
//     return '$text ($type)$markerStr';
//   }
// }

// class Affix {
//   final String text;
//   final List<String> markers;

//   Affix(this.text, this.markers);

//   /// Translates the derivation tag into a readable join marker
//   String get joinEffect {
//     for (var m in markers) {
//       if (m == 'Der/nv') return 'Noun -> Verb';
//       if (m == 'Der/vn') return 'Verb -> Noun';
//       if (m == 'Der/vv') return 'Verb -> Verb';
//       if (m == 'Der/nn') return 'Noun -> Noun';
//     }
//     return 'Modifiers/Grammar Only';
//   }

//   @override
//   String toString() {
//     return '$text ($joinEffect) -> tags: ${markers.join(' + ')}';
//   }
// }

// class Ending {
//   final List<String> tags;

//   Ending(this.tags);

//   @override
//   String toString() => tags.join(' + ');
// }

// class Clitic {
//   final String text;

//   Clitic(this.text);

//   @override
//   String toString() {
//     return text;
//   }
// }

// /// Main parser function
// ParsedWord parseAnalyzerOutput(String input) {
//   final tokens = input.split('+');
//   if (tokens.isEmpty) throw ArgumentError('Input cannot be empty');

//   final String rootText = tokens.first;
//   final List<String> rootMarkers = [];
//   final List<Affix> affixes = [];
//   final List<String> endingTags = [];
//   final List<Clitic> clitics = [];

//   String? currentAffixText;
//   List<String> currentAffixMarkers = [];
//   bool inEnding = false;

//   // Helper to verify if a token is ALL CAPS (ignores symbols)
//   bool isAllCaps(String s) {
//     return s == s.toUpperCase() && s.contains(RegExp(r'[A-ZÆØÅ]'));
//   }

//   for (int i = 1; i < tokens.length; i++) {
//     final token = tokens[i];

//     // If we have transitioned into the ending, just collect the remaining tags
//     if (inEnding) {
//       endingTags.add(token);
//       continue;
//     }

//     // Determine if this token marks the start of the final inflectional ending.
//     // Rule: It is an ending base (like N or V) AND no 'Der/' tags appear after it.
//     if (['N', 'V', 'PTCL', 'NUM', 'PRON'].contains(token)) {
//       final hasSubsequentDer = tokens
//           .skip(i + 1)
//           .any((t) => t.startsWith('Der/'));
//       if (!hasSubsequentDer) {
//         inEnding = true;

//         // Save the last processed affix before entering the ending
//         if (currentAffixText != null) {
//           affixes.add(Affix(currentAffixText, currentAffixMarkers));
//           currentAffixText = null;
//         }

//         endingTags.add(token);
//         continue;
//       }
//     }

//     if (isAllCaps(token) && !token.startsWith('Gram/')) {
//       // We found a new Affix. Save the previous one if it exists.
//       if (currentAffixText != null) {
//         affixes.add(Affix(currentAffixText, currentAffixMarkers));
//       }
//       currentAffixText = token;
//       currentAffixMarkers = [];
//     } else {
//       // It's a grammatical or derivation marker
//       if (currentAffixText != null) {
//         currentAffixMarkers.add(token);
//       } else {
//         rootMarkers.add(token);
//       }
//     }
//   }

//   // Catch any dangling affix if an ending wasn't explicitly found
//   if (currentAffixText != null) {
//     affixes.add(Affix(currentAffixText, currentAffixMarkers));
//   }

//   // Determine if the Root is a Noun or a Verb
//   String rootType = 'Unknown';

//   // 1. Check root markers for Explicit Verb grammar
//   if (rootMarkers.any(
//     (m) => m.contains('IV') || m.contains('TV') || m.contains('V'),
//   )) {
//     rootType = 'Verb';
//   }
//   // 2. If no explicit root markers, reverse-engineer from the first affix's join condition
//   else if (affixes.isNotEmpty) {
//     final firstDer = affixes.first.markers.firstWhere(
//       (m) => m.startsWith('Der/'),
//       orElse: () => '',
//     );
//     if (firstDer == 'Der/nv' || firstDer == 'Der/nn') {
//       rootType = 'Noun';
//     } else if (firstDer == 'Der/vn' || firstDer == 'Der/vv') {
//       rootType = 'Verb';
//     }
//   }
//   // 3. If there are no affixes, look at the ending part of speech
//   else if (endingTags.isNotEmpty) {
//     if (endingTags.first == 'N') {
//       rootType = 'Noun';
//     } else if (endingTags.first == 'V') {
//       rootType = 'Verb';
//     } else {
//       print(endingTags);
//       rootType = 'Unknown';
//     }
//   }
//   for (var i = 0; i < endingTags.length; i++) {
//     if (endingTags[i] == endingTags[i].toUpperCase() &&
//         (endingTags[i] != 'N' && endingTags[i] != 'V')) {
//       // Special case for mitaava
//       if (i < endingTags.length - 1 &&
//           endingTags[i] == "MI" &&
//           endingTags[i + 1] == "TAAVA") {
//         clitics.add(Clitic("MITAAVA"));
//         endingTags.removeAt(i);
//         endingTags.removeAt(i);
//         i++;
//       } else {
//         clitics.add(Clitic(endingTags[i]));
//         endingTags.removeAt(i);
//       }
//     }
//   }

//   return ParsedWord(
//     root: Root(rootText, rootType, rootMarkers),
//     affixes: affixes,
//     ending: Ending(endingTags),
//     clitics: clitics,
//   );
// }

// illoqarfimmiippoq
// illu+QAR+Der/nv+Gram/IV+VIK+Der/vn+N+Lok+Sg+Gram/Hyb+IP+Gram/IV+V+Ind+3Sg

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
  // type: enc, aff, end. root
  Morpheme({required this.join, required this.type, this.form = "", this.endForm = ""});
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

  for (var i = 0; i < parts.length; i++) {
    final part = parts[i];
    if (part.toUpperCase() == part) {
      // all caps, either an affix or an ending marker
      if (part == 'V' || part == 'N' || part == "Adv" || part == "Conj") {
        // ending start
        inEnding = true;
      } else {
        // affix or enclitic
        if (inEnding) {
          morphemes.add(Morpheme(join: 'enc', type: 'enc', form: part));
        } else {
          // affix
          morphemes.add(Morpheme(join: analyzerTypeConverter(parts[i+1]), type: 'aff', form: part));
        }
      }
    } else if (part.toLowerCase() == part) {
      // all lower, in a root
      morphemes.add(Morpheme(join: '?', type: 'root', form: part));
    } else {
      // in something that is not an affix, ending marker, or a root
      if(morphemes[0].join == '?') { // has not found base join marker yet
        morphemes[0].join = analyzerTypeConverter(part);
      }
    }
  }

  return ParsedWord(morphemes: morphemes);
}

Future<String?> analyzerRequest(String URL, String searchTerm) async {
  final url = Uri.http(URL, '/analyze', {'word': searchTerm});
  print(url);

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      print('Request successful!');
      print('Response body: ${response.body}');
      return response.body;
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  } catch (e) {
    print('An error occurred: $e');
  }
  return null;
}

String analyzerToMofo(String input, String type) {
  for (int i = 0; i < analyzerMofoObj['entries'].length; i++) {
    if (analyzerMofoObj['entries'][i]['t'] == type) {
      if (analyzerMofoObj['entries'][i]['a'] == input) {
        return analyzerMofoObj['entries'][i]['m'];
      }
    }
  }

  return input;
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
  String _analyzerServer = 'imlillith888.xyz:8000';

  List<ParsedWord> _cleanedAnalyses = [];

  void _searchDictionary() {
    setState(() {
      _cleanedAnalyses = [];
    });
    analyzerRequest(_analyzerServer, _textValue).then((analyzed) {
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
          analysesNoRepeats
              ?.map((a) => parseWord(a))
              .toList() ??
          [];
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
                            setState(() {
                              _textValue = text;
                            });
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
