import 'package:flutter/material.dart';

import 'analyzer.dart';
import 'dictionary.dart';
import 'variables.dart';

String getBlockText(Morpheme morph) {
  if (morph.type == 'end') {
    return analyzerToMofo(morph.endForm, '');
  }
  return analyzerToMofo(morph.form, morph.join);
}

String getTooltipText(Morpheme morph) {
  if(morph.type == 'root') {
    return dictionarySearchType(morph.join, morph.form).join('\n');
  }
  if (morph.type == 'end') {
    return morph.endForm;
  }
  if (morph.type == 'aff') {
    return getMofoDefinition(morph.form, morph.join);
  }
  return '?';
}

Color getBlockColor(Morpheme morph) {
  if (morph.type == 'root') {
    return Colors.blue.shade100;
  }
  if (morph.type == 'aff') {
    return Colors.green.shade100;
  }
  if (morph.type == 'end') {
    return Colors.orange.shade100;
  }
  if (morph.type == 'enc') {
    return Colors.purple.shade100;
  }
  return Colors.black;
}

Color getBorderColor(Morpheme morph) {
  if (morph.type == 'root') {
    return Colors.blue.shade400;
  }
  if (morph.type == 'aff') {
    return Colors.green.shade400;
  }
  if (morph.type == 'end') {
    return Colors.orange.shade400;
  }
  if (morph.type == 'enc') {
    return Colors.purple.shade400;
  }
  return Colors.black;
}

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
        return Wrap(
          spacing: 6.0,
          runSpacing: 8.0,
          children: [
            ...widget.word.morphemes.map((e) => _MorphBlock(text: getBlockText(e), tooltipText: getTooltipText(e), backgroundColor: getBlockColor(e), borderColor: getBorderColor(e)))
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