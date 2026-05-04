import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:kalaallisutdictionary/assistedTagging.dart';
import 'package:kalaallisutdictionary/conjugationTables.dart';
import 'dart:convert';

import 'analyzer.dart';
import 'dictionary.dart';
import 'variables.dart';
import 'settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadDatabases(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        return StreamBuilder<bool>(
        initialData: false,
        stream: darkModeStream.stream,
        builder: (context, snapshot) {
        darkModeBoolValue = snapshot.data!;
        return MaterialApp(
          title: 'Kalaallisut Dictionary',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: uiColor,
              brightness: snapshot.data! ? Brightness.dark : Brightness.light,
            ),
          ),
          home: const app(),
        );});
      },
    );
  }
}

class app extends StatefulWidget {
  const app({super.key});

  @override
  State<app> createState() => _appState();
}

class _appState extends State<app> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        body: Center(
          child: SafeArea(
            child: Column(
              children: [
                const TabBar(
                  labelColor: Colors.black,
                  tabs: [
                    Tab(icon: Icon(Icons.pageview_outlined)), // word lookup
                    Tab(icon: Icon(Icons.library_books)), // dictionary view
                    Tab(icon: Icon(Icons.reorder)), // tagging
                    Tab(icon: Icon(Icons.table_chart)),
                    Tab(icon: Icon(Icons.settings)), // settings
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      const analyzerPage(),
                      const dictionaryPage(),
                      const taggingPage(),
                      const tablePage(),
                      const settingsPage(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
