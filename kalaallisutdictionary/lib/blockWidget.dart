import 'package:flutter/material.dart';

import 'analyzer.dart';
import 'dictionary.dart';
import 'variables.dart';



class ParsedWordWidget extends StatefulWidget {
  final ParsedWord word;

  const ParsedWordWidget({Key? key, required this.word}) : super(key: key);

  @override
  State<ParsedWordWidget> createState() => _ParsedWordWidgetState();
}

class _ParsedWordWidgetState extends State<ParsedWordWidget> {

  @override
  void initState() {
    super.initState();
    print(widget.word.morphemes[0].type);
  }

  @override
  Widget build(BuildContext context) {

        // return Wrap(
        //   spacing: 6.0,
        //   runSpacing: 8.0,
        //   children: [
        //     // 1. Root Block
        //     _MorphBlock(
        //       text: widget.word.root.text,
        //       // Now uses the loaded definition
        //       tooltipText: '${uiStrings['grammar.root']} (${uiStrings['grammar.'+widget.word.root.type.toLowerCase()]})\n${dictionarySearchType(widget.word.root.type, kalEngTypeToEng(widget.word.root.type) == 'verb' ? widget.word.root.text.substring(0,widget.word.root.text.length-1) : widget.word.root.text).join('\n')}',
        //       backgroundColor: Colors.blue.shade100,
        //       borderColor: Colors.blue.shade400,
        //     ),
            
        //     // 2. Affix Blocks
        //     ...widget.word.affixes.map((affix) => _MorphBlock(
        //       text: analyzerToMofo(affix.text, affix.joinEffect),
        //       tooltipText: uiStrings[affix.joinEffect] ?? '',
        //       backgroundColor: Colors.green.shade100,
        //       borderColor: Colors.green.shade400,
        //     )),

        //     // 3. Ending Block
        //     _MorphBlock(
        //       text: '-${widget.word.ending.tags.isEmpty ? '∅' : widget.word.ending.tags.first}',
        //       tooltipText: '${uiStrings['grammar.ending']}\n${widget.word.ending.tags.join(" + ")}',
        //       backgroundColor: Colors.orange.shade100,
        //       borderColor: Colors.orange.shade400,
        //     ),

        //     // clitics!!!
        //     ...widget.word.clitics.map((clitic) => _MorphBlock(
        //       text: analyzerToMofo(clitic.text, 'Clitic'),
        //       tooltipText: uiStrings['grammar.clitic'],
        //       backgroundColor: Colors.purple.shade100,
        //       borderColor: Colors.purple.shade400,
        //     )),
        //   ],
        // );
        return Wrap(
          spacing: 6.0,
          runSpacing: 8.0,
          children: [
            ...widget.word.morphemes.map((e) => _MorphBlock(text: e.type, tooltipText: 'hi', backgroundColor: Colors.purple.shade100, borderColor: Colors.purple.shade400))
          ]
        );
  }
}

class _MorphBlock extends StatelessWidget {
  final String text;
  final String tooltipText;
  final Color backgroundColor;
  final Color borderColor;

  const _MorphBlock({
    required this.text,
    required this.tooltipText,
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltipText,
      padding: const EdgeInsets.all(12.0),
      textStyle: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}