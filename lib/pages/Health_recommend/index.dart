import 'package:flutter/material.dart';

class HealthRecommendPage extends StatefulWidget {
  HealthRecommendPage({Key? key}) : super(key: key);

  @override
  _HealthRecommendPageState createState() => _HealthRecommendPageState();
}

class _HealthRecommendPageState extends State<HealthRecommendPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("养生推荐")),
      body: Center(child: Text("养生推荐页面")),
    );
  }
}
