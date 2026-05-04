import 'dart:convert';

import 'package:flutter/services.dart';

import 'variables.dart';

Future<void> changeLanguage(String? language) async {
  switch (language) {
    case "English": {
      final String uiStringsStr = await rootBundle.loadString('assets/ui-english.json');
      uiStrings = jsonDecode(uiStringsStr);
    }
    case "Español": {
      final String uiStringsStr = await rootBundle.loadString('assets/ui-spanish.json');
      uiStrings = jsonDecode(uiStringsStr);
    }
  }
}