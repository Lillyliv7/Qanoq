import 'package:flutter/material.dart';

class tablePage extends StatefulWidget {
  const tablePage({super.key});

  @override
  State<tablePage> createState() => _tablePageState();
}

class _tablePageState extends State<tablePage> with AutomaticKeepAliveClientMixin<tablePage> {
  @override
  Widget build(BuildContext context) {
    return Column();
  }

  @override
  bool get wantKeepAlive => true;
}
