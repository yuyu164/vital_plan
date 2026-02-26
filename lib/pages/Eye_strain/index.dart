import 'package:flutter/material.dart';

class EyeStrainPage extends StatefulWidget {
  EyeStrainPage({Key? key}) : super(key: key);

  @override
  _EyeStrainPageState createState() => _EyeStrainPageState();
}

class _EyeStrainPageState extends State<EyeStrainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("视疲劳")),
      body: Center(child: Text("视疲劳页面")),
    );
  }
}
