import 'package:flutter/material.dart';
import 'package:vital_plan/pages/Board/index.dart';
import 'package:vital_plan/pages/Emo/index.dart';
// import 'package:vital_plan/pages/Eye_strain/index.dart';
import 'package:vital_plan/pages/Game/index.dart';
import 'package:vital_plan/pages/Health_recommend/index.dart';
// import 'package:vital_plan/pages/Late_sleep/index.dart';
import 'package:vital_plan/pages/Login/index.dart';
import 'package:vital_plan/pages/Main/index.dart';
import 'package:vital_plan/pages/auth_wrapper.dart';
// import 'package:vital_plan/pages/Neck_pain/index.dart';
// import 'package:vital_plan/pages/Normal/index.dart';

Widget getRootWidget() {
  return MaterialApp(initialRoute: "/", routes: getRootRoutes());
}

// 已移至顶部，与所有 import 指令保持一致

// 路由配置表
Map<String, Widget Function(BuildContext)> getRootRoutes() {
  return {
    "/": (context) => const AuthWrapper(), // 将根路由指向 AuthWrapper，由它决定显示什么
    "/main": (context) => MainPage(), // 显式定义 MainPage 路由
    "/login": (context) => LoginPage(), // 登录路由
    "/game": (context) => GamePage(), // 游戏路由
    "/health_recommend": (context) => HealthRecommendPage(), // 健康推荐路由
    // "/normal": (context) => NormalPage(), // 无异常
    // "/late_sleep": (context) => LateSleepPage(), // 睡得晚
    // "/eye_strain": (context) => EyeStrainPage(), // 视疲劳
    // "/neck_pain": (context) => NeckPainPage(), // 颈椎难受
    "/board": (context) => BoardPage(), // 看板路由
    "/emo": (context) => EmoPage(), // emo路由
  };
}
