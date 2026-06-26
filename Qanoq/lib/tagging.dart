import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

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

class _taggingPageState extends State<taggingPage> with AutomaticKeepAliveClientMixin<taggingPage> {
  final TextEditingController _serverController = TextEditingController();
  final TextEditingController _wordController = TextEditingController();

  String _textValue = '';

  String file = '';

  // Changed from List<String> to List<ParsedWord>
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

      final cleaned = analysesNoRepeats.map((a) => parseWord(a)).toList();
      setState(() {
        _cleanedAnalyses = cleaned;
      });
    });
  }

  @override
  void dispose() {
    _serverController.dispose();
    _wordController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(uiStrings['tagging.title'], style: TextStyle(fontSize: 30)),
              Tooltip(
                message: uiStrings['tagging.tooltip'],
                child: const Icon(Icons.info, size: 25),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          file = (await pickFile())!;
                          print(file);
                        },
                        style: ElevatedButton.styleFrom(
                          // fixedSize: const Size(50, 50),
                          padding: EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          uiStrings['tagging.file'],
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      const SizedBox(width: 15),
                      ElevatedButton(
                        onPressed: () {
                          saveFile(file);
                        },
                        style: ElevatedButton.styleFrom(
                          // fixedSize: const Size(50, 50),
                          padding: EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          uiStrings['tagging.save'],
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 15),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(50, 50),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Icon(Icons.arrow_left_sharp, size: 48),
                        ),
                        const SizedBox(width: 15),
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
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(50, 50),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Icon(Icons.arrow_right_sharp, size: 48),
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
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // Render the custom widget for each analysis
                      children: _cleanedAnalyses
                          .map(
                            (parsedWord) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: ParsedWordWidget(word: parsedWord),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  @override
  bool get wantKeepAlive => true;
}
