import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'variables.dart';

const double dictionaryElementHeight = 50;

String kalEngTypeToEng(String? kalEngType) {
  if (kalEngType == null) {
    return 'unknown';
  }
  if (kalEngType.toLowerCase() == "taggit") {
    // noun
    return 'noun';
  }
  if (kalEngType.toLowerCase() == 'oqaluut susaatsoq') {
    // intransitive
    return 'verb';
  }
  if (kalEngType.toLowerCase() == 'oqaluut susalik') {
    // transitive
    return 'verb';
  }
  if (kalEngType.toLowerCase() == "oqaluut susaasalik") {
    // HTR
    return 'verb';
  }
  if (kalEngType.toLowerCase() == "proprium/egennavn") {
    // proper noun
    return 'noun';
  }
  return 'unknown';
}

List<String> dictionarySearchType(String type, String term) {
  List<String> engOutputs = [];
  List<int> lengths = [];
  List<String> done = [];
  int minLength = 9999;

  for (int i = 0; i < kalEngObj['entries'].length; i++) {
    if (kalEngObj['entries'][i]['kal'].toLowerCase().startsWith(
      term.toLowerCase(),
    )) {
      if (kalEngTypeToEng(kalEngObj['entries'][i]['type']) ==
          type.toLowerCase()) {
        engOutputs.add(kalEngObj['entries'][i]['eng']);
        lengths.add(kalEngObj['entries'][i]['kal'].length);
        if (lengths[lengths.length - 1] < minLength) {
          minLength = lengths[lengths.length - 1];
        }
      }
    }
  }

  for (int i = 0; i < engOutputs.length; i++) {
    if (lengths[i] == minLength) {
      done.add(engOutputs[i]);
    }
  }

  return done;
}

String localDictionarySearchAll(String searchTerm) {
  String toReturn = '';

  for (int i = 1; i < kalEngObj['entries'].length; i++) {
    if (kalEngObj['entries'][i]['kal'].startsWith(searchTerm)) {
      toReturn = toReturn + kalEngObj['entries'][i]['eng'] + '; ';
    }
  }

  return toReturn;
}

class dictionaryPage extends StatefulWidget {
  const dictionaryPage({super.key});

  @override
  State<dictionaryPage> createState() => _dictionaryPageState();
}

class _dictionaryPageState extends State<dictionaryPage> {
  final _scrollController = ScrollController();

  final TextEditingController _wordController = TextEditingController();

  String _textValue = '';

  bool searchGreenlandic = true;
  bool searchEnglish = true;
  bool caseSensitive = false;
  bool searchFromStart = false;

  void _searchDictionary() {
    if (_textValue == '') {
      return;
    }

    String searchTerm;
    if (caseSensitive) {
      searchTerm = _textValue;
    } else {
      searchTerm = _textValue.toLowerCase();
    }

    // search for exact match
    var index = 0;
    for (var i = 0; i < kalEngObj['entries'].length; i++) {
      // sort out case sensitivity
      String currentKalElement;
      String currentEngElement;
      if (caseSensitive) {
        currentEngElement = kalEngObj['entries'][i]['eng'];
        currentKalElement = kalEngObj['entries'][i]['kal'];
      } else {
        currentEngElement = kalEngObj['entries'][i]['eng'].toLowerCase();
        currentKalElement = kalEngObj['entries'][i]['kal'].toLowerCase();
      }

      // search
      if (currentEngElement == searchTerm ||
          currentKalElement == searchTerm) {
        index = i;
      }
    }

    if (index != 0) {
      // found an exact match, go to it
      _scrollController.animateTo(
        index * dictionaryElementHeight,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
      return;
    } else {
      // no exact match found, search for the closest ones
      List<Object> indexes = [];
      for (var i = 0; i < kalEngObj['entries'].length; i++) {

      // sort out case sensitivity
      String currentKalElement;
      String currentEngElement;
      if (caseSensitive) {
        currentEngElement = kalEngObj['entries'][i]['eng'];
        currentKalElement = kalEngObj['entries'][i]['kal'];
      } else {
        currentEngElement = kalEngObj['entries'][i]['eng'].toLowerCase();
        currentKalElement = kalEngObj['entries'][i]['kal'].toLowerCase();
      }

        // search dictionary
        if ((searchEnglish &&
                currentEngElement.startsWith(
                  _textValue.toLowerCase(),
                )) ||
            (searchGreenlandic &&
                currentKalElement.startsWith(
                  _textValue.toLowerCase(),
                ))) {
          indexes.add({
            "eng": kalEngObj['entries'][i]['eng'],
            "kal": kalEngObj['entries'][i]['kal'],
            "type": kalEngObj['entries'][i]['type'],
          });
        }
      }
      Navigator.of(context).restorablePush(_resultsBuilder, arguments: indexes);
    }
  }

  void _optionsBuilder() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(uiStrings['dictionary.settings']),
              content: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                  maxHeight: 400,
                  minWidth: 300,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(uiStrings['dictionary.english']),

                        Switch(
                          value: searchEnglish,
                          onChanged: (value) {
                            setState(() {
                              searchEnglish = value;
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(uiStrings['dictionary.greenlandic']),

                        Switch(
                          value: searchGreenlandic,
                          onChanged: (value) {
                            setState(() {
                              searchGreenlandic = value;
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(uiStrings['dictionary.case-sensitive']),

                        Switch(
                          value: caseSensitive,
                          onChanged: (value) {
                            setState(() {
                              caseSensitive = value;
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(uiStrings['dictionary.search-start']),

                        Switch(
                          value: searchFromStart,
                          onChanged: (value) {
                            setState(() {
                              searchFromStart = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @pragma('vm:entry-point')
  static Route<Object?> _resultsBuilder(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<void>(
      context: context,
      builder: (BuildContext context) {
        final List<dynamic> indexes = arguments as List<dynamic>;
        return AlertDialog(
          title: Text(uiStrings['dictionary.search']),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
            child: SizedBox(
              width:
                  double.maxFinite, // Ensures the dialog takes up proper width
              height: double.maxFinite, // Give it a specific height
              child: ListView.builder(
                padding: EdgeInsets.all(15),
                // controller: _scrollController,
                itemExtent: dictionaryElementHeight,
                itemCount: indexes.length,

                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.0,
                        ),
                      ),
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            indexes[index]['kal'] +
                                ' (${indexes[index]['type'].toLowerCase()})',
                          ),
                        ),
                        Expanded(
                          child: Tooltip(
                            message: indexes[index]['eng'],
                            child: Text(
                              indexes[index]['eng'],
                              textAlign: TextAlign.end,
                              softWrap: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(uiStrings['ui.close']),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(uiStrings['dictionary.title'], style: TextStyle(fontSize: 30)),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _wordController,
                  decoration: InputDecoration(
                    hintText: uiStrings['dictionary.enter-word'],
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
                onPressed: () {
                  // Navigator.of(context).restorablePush(_optionsBuilder);
                  _optionsBuilder();
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(50, 50),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Icon(Icons.settings, size: 32),
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
        ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: ListView.builder(
                padding: EdgeInsets.all(15),
                controller: _scrollController,
                itemExtent: dictionaryElementHeight,
                itemCount: kalEngObj['entries'].length,

                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.0,
                        ),
                      ),
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            kalEngObj['entries'][index]['kal'] +
                                ' (${kalEngObj['entries'][index]['type'].toLowerCase()})',
                          ),
                        ),
                        Expanded(
                          child: Tooltip(
                            message: kalEngObj['entries'][index]['eng'],
                            child: Text(
                              kalEngObj['entries'][index]['eng'],
                              textAlign: TextAlign.end,
                              softWrap: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
