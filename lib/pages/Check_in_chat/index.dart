import 'package:flutter/material.dart';

class CheckInChatPage extends StatefulWidget {
  CheckInChatPage({Key? key}) : super(key: key);

  @override
  _CheckInChatPageState createState() => _CheckInChatPageState();
}

class _CheckInChatPageState extends State<CheckInChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("打卡记录")),
      body: Center(child: Text("helloworld")),
    );
  }
}
