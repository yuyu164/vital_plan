import 'package:flutter/material.dart';

class EmoPage extends StatefulWidget {
  EmoPage({Key? key}) : super(key: key);

  @override
  _EmoPageState createState() => _EmoPageState();
}

class _EmoPageState extends State<EmoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("emo")),
      body: Center(child: Text("emo页面")),
    );
  }
}
