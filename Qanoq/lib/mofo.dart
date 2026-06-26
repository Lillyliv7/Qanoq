
import 'package:http/http.dart' as http;

import 'analyzer.dart';
import 'variables.dart';

String analyzerToMofo(String input, String type) {
  // search affixes/clitics
  for (int i = 0; i < analyzerMofoObj['entries'].length; i++) {
    if (analyzerMofoObj['entries'][i]['t'] == type) {
      if (analyzerMofoObj['entries'][i]['a'] == input) {
        return analyzerMofoObj['entries'][i]['m'];
      }
    }
  }
  // search endings
  for (int i = 0; i < endings['endings'].length; i++) {
    if (input == endings['endings'][i]['analyzer']) {
      return endings['endings'][i]['mofo'];
    }
  }


  return input;
}

String getMofoLink(Morpheme morph){
  String convertedType = "";
  if (morph.type == 'aff') {convertedType = 'affix';}
  else if (morph.type == 'enc') {
    if (morph.join == 'ev') {
      convertedType = 'declitic';
    } else {
      convertedType = 'enclitic';
    }
  }
  if (morph.join == 'ev') {
    return 'https://mofo.oqa.dk/Morphemes/kl/$convertedType/v/${analyzerToMofo(morph.form, morph.join).replaceAll(RegExp(r'[A-Z{}\*]'), '')}';
  } else if (morph.join == 'enc') {
    return 'https://mofo.oqa.dk/Morphemes/kl/$convertedType/${analyzerToMofo(morph.form, morph.join).replaceAll(RegExp(r'[A-Z{}\*]'), '')}';
  } else {
    return 'https://mofo.oqa.dk/Morphemes/kl/$convertedType/${morph.join}/${analyzerToMofo(morph.form, morph.join).replaceAll(RegExp(r'[A-Z{}\*]'), '')}';
  }
}

Future<String?> getMofoDefinition(Morpheme morph) async {
  var url;
  String convertedType = "";
  if (morph.type == 'aff') {convertedType = 'affix';}
  else if (morph.type == 'enc') {
    if (morph.join == 'ev') {
      convertedType = 'declitic';
    } else {
      convertedType = 'enclitic';
    }
  }
  try {
    url = Uri.https('mofo.oqa.dk', '/api/get/kl/$convertedType/${morph.join}/${analyzerToMofo(morph.form, morph.join).replaceAll(RegExp(r'[A-Z{}\*]'), '')}');
  } catch (e) {
    print('An error occurred: $e');
  }

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
