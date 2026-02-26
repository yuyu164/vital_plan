import 'package:flutter/material.dart';

class NeckPainPage extends StatefulWidget {
  NeckPainPage({Key? key}) : super(key: key);

  @override
  _NeckPainPageState createState() => _NeckPainPageState();
}

class _NeckPainPageState extends State<NeckPainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("颈椎难受")),
      body: Center(child: Text("颈椎难受页面")),
    );
  }
}
