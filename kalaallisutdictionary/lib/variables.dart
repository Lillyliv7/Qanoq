import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'language.dart';

var analyzerMofoObj;
var kalEngObj;
var uiStrings;
var preferences;
var endings;
var uiColor = Colors.green;
StreamController<bool> darkModeStream = StreamController();
bool darkModeBoolValue = false;


Future<bool> loadDatabases() async {
  final String analyzerMofoStr = await rootBundle.loadString('assets/analyzer-mofo.json');
  analyzerMofoObj = jsonDecode(analyzerMofoStr);

  final String kalEngStr = await rootBundle.loadString('assets/kal-eng.json');
  kalEngObj = jsonDecode(kalEngStr);

  final String uiStringsStr = await rootBundle.loadString('assets/ui-english.json');
  uiStrings = jsonDecode(uiStringsStr);

  final String endingsStr = await rootBundle.loadString('assets/endings.json');
  endings = jsonDecode(endingsStr);

  preferences = await SharedPreferences.getInstance();

  changeLanguage(preferences.getString('Language'));

  return true;
}