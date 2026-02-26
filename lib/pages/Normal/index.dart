import 'package:flutter/material.dart';

class NormalPage extends StatefulWidget {
  NormalPage({Key? key}) : super(key: key);

  @override
  _NormalPageState createState() => _NormalPageState();
}

class _NormalPageState extends State<NormalPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("正常")),
      body: Center(child: Text("正常页面")),
    );
  }
}
