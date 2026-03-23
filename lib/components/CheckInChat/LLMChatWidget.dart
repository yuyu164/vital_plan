import 'package:flutter/material.dart';

class LLMChatWidget extends StatefulWidget {
  const LLMChatWidget({Key? key}) : super(key: key);

  @override
  _LLMChatWidgetState createState() => _LLMChatWidgetState();
}

class _LLMChatWidgetState extends State<LLMChatWidget> {
  @override
  Widget build(BuildContext context) {
    // 占位，稍后实现
    return Container(
      color: Colors.white.withOpacity(0.3),
      child: const Center(child: Text("LLM Chat Widget Placeholder")),
    );
  }
}
