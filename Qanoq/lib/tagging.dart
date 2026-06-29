import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

import 'mofo.dart';
import 'variables.dart';
import 'analyzer.dart';
import 'blockWidget.dart';

Future<String?> pickFile() async {
  FilePickerResult? result = await FilePicker.pickFiles();

  if (result != null) {
    File file = File(result.files.single.path!);
    return await file.readAsString();
  } else {
    return null;
  }
}

void saveFile(String text) async {
  String? outputFile = await FilePicker.saveFile(
    dialogTitle: 'Please select an output file:',
    fileName: 'output.txt',
  );

  if (outputFile == null) {
    return;
  } else {
    File file = File(outputFile);
    await file.writeAsString(text);
  }
}

class taggingPage extends StatefulWidget {
  const taggingPage({super.key});

  @override
  State<taggingPage> createState() => _taggingPageState();
}

class _taggingPageState extends State<taggingPage>
    with AutomaticKeepAliveClientMixin<taggingPage> {
  final TextEditingController _inputArea = TextEditingController();
  final TextEditingController _outputArea = TextEditingController();
  final TextEditingController _wordController = TextEditingController();

  String file = '';

  List<ParsedWord> _cleanedAnalyses = [];

  var currentPosition = 0;
  List<String> inputList = [];

  void _addNextWord() {
    if (currentPosition < inputList.length) {
      setState(() {
        _wordController.text = inputList[currentPosition];
      });
      currentPosition++;
    }
  }

  void _searchDictionary() {
    setState(() {
      _cleanedAnalyses = [];
    });
    analyzerRequest(_wordController.text).then((analyzed) {
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

      final cleaned = analysesNoRepeats.map((a) => parseWord(a)).toList();
      setState(() {
        _cleanedAnalyses = cleaned;
      });
    });
  }

  @override
  void dispose() {
    _inputArea.dispose();
    _outputArea.dispose();
    _wordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  uiStrings['tagging.title'],
                  style: const TextStyle(fontSize: 30),
                ),
                Tooltip(
                  message: uiStrings['tagging.tooltip'],
                  child: const Icon(Icons.info, size: 25),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.stretch, // Makes columns match height
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Input"),
                          TextField(
                            controller: _inputArea,
                            onChanged: (value) {
                              setState(() {
                                currentPosition = 0;
                                inputList = value.split(' ');
                                _addNextWord();
                              });
                            },
                            keyboardType: TextInputType.multiline,
                            minLines: 5,
                            maxLines: 10000,
                            decoration: InputDecoration(
                              labelText: uiStrings['tagging.input-label'],
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Text("Output"),
                          TextField(
                            controller: _outputArea,
                            keyboardType: TextInputType.multiline,
                            minLines: 5,
                            maxLines: 10000,
                            decoration: InputDecoration(
                              labelText: uiStrings['tagging.output-label'],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _wordController,
                                  decoration: InputDecoration(
                                    hintText: uiStrings['analyzer.enter-word'],
                                    border: const OutlineInputBorder(),
                                  ),
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
                                child: const Icon(
                                  Icons.pageview_outlined,
                                  size: 32,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => {},
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: const Size(50, 50),
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Load',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => {},
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: const Size(50, 50),
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Save',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => {_addNextWord()},
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: const Size(50, 50),
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Skip Word',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _cleanedAnalyses.isEmpty
                                  ? [
                                      Text(
                                        uiStrings['analyzer.no-analyses'],
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ]
                                  : _cleanedAnalyses
                                        .map(
                                          (parsedWord) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8.0,
                                            ),
                                            child: Row(
                                              children: [
                                                IconButton(
                                                  tooltip:
                                                      uiStrings['tagging.add-to-output'],
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(
                                                        minWidth: 40,
                                                        minHeight: 40,
                                                      ),
                                                  icon: const Icon(Icons.add),
                                                  onPressed: () {
                                                    setState(() {
                                                      final current =
                                                          _outputArea.text;
                                                      _outputArea.text =
                                                          '$current$parsedWord ';

                                                      _addNextWord();
                                                      // for (var morph
                                                      //     in parsedWord
                                                      //         .morphemes) {
                                                      //   print(
                                                      //     getMofoPath(morph),
                                                      //   );
                                                      // }
                                                    });
                                                  },
                                                ),
                                                const SizedBox(width: 8),
                                                Flexible(
                                                  fit: FlexFit.loose,
                                                  child: ParsedWordWidget(
                                                    word: parsedWord,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                            ),
                          ),
                        ],
                      ),
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

  @override
  bool get wantKeepAlive => true;
}
