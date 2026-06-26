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
  final TextEditingController _inputArea = TextEditingController();
  final TextEditingController _outputArea = TextEditingController();
  final TextEditingController _customAnalysesArea = TextEditingController();

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
    _inputArea.dispose();
    _outputArea.dispose();
    _customAnalysesArea.dispose();
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
          constraints: const BoxConstraints(maxWidth: 1000, minWidth: 800),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  children: [
                    TextField(
                      controller: _inputArea,
                      keyboardType: TextInputType.multiline,
                      minLines: 5,
                      maxLines: 1000,
                      decoration: InputDecoration(
                        labelText: uiStrings['tagging.input-label'],
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _outputArea,
                      keyboardType: TextInputType.multiline,
                      minLines: 5,
                      maxLines: 1000,
                      decoration: InputDecoration(
                        labelText: uiStrings['tagging.output-label'],
                      ),
                    ),
                  ],
                ),
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
