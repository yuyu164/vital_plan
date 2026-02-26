import 'package:flutter/material.dart';

class BoardPage extends StatefulWidget {
  BoardPage({Key? key}) : super(key: key);

  @override
  _BoardPageState createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("看板")),
      body: Center(child: Text("看板页面")),
    );
  }
}
