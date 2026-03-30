import 'package:flutter/material.dart';
import 'package:vital_plan/components/main_page/main_page_background.dart';
import 'package:vital_plan/components/CheckInChat/CalendarWidget.dart';
import 'package:vital_plan/components/CheckInChat/LLMChatWidget.dart';

class CheckInChatPage extends StatefulWidget {
  CheckInChatPage({Key? key}) : super(key: key);

  @override
  _CheckInChatPageState createState() => _CheckInChatPageState();
}

class _CheckInChatPageState extends State<CheckInChatPage> {
  @override
  Widget build(BuildContext context) {
    // 获取屏幕高度
    final screenHeight = MediaQuery.of(context).size.height;

    return MainPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent, // 必须透明，否则会遮挡背景
        appBar: AppBar(
          backgroundColor: Colors.transparent, // 透明 AppBar
          elevation: 0,
          centerTitle: true,
          title: Text(
            "打卡日历",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: IconThemeData(color: Colors.black87), // 返回按钮颜色
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 1. 日历组件 (去掉固定高度，让其自适应内部日历的大小，避免留白或溢出)
                const CalendarWidget(),

                const SizedBox(height: 16),

                // 2. LLM 聊天组件 (给一个合适的高度，或者在后续实现中让其内部自适应)
                SizedBox(
                  height: screenHeight * 0.6, // 给定一个大致高度以保证页面可滚动并有足够空间聊天
                  child: const LLMChatWidget(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
