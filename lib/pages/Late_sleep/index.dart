import 'package:flutter/material.dart';

class LateSleepPage extends StatefulWidget {
  LateSleepPage({Key? key}) : super(key: key);

  @override
  _LateSleepPageState createState() => _LateSleepPageState();
}

class _LateSleepPageState extends State<LateSleepPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("睡得晚")),
      body: Center(child: Text("睡得晚页面")),
    );
  }
}
