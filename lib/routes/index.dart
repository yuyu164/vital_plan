import 'package:flutter/material.dart';
import 'package:vital_plan/pages/Board/index.dart';
import 'package:vital_plan/pages/Emo/index.dart';
import 'package:vital_plan/pages/Game/index.dart';
import 'package:vital_plan/pages/Check_in_chat/index.dart';
import 'package:vital_plan/pages/Login/index.dart';
import 'package:vital_plan/pages/Main/index.dart';
import 'package:vital_plan/pages/Settings/index.dart';
import 'package:vital_plan/pages/Settings/user_agreement.dart';
import 'package:vital_plan/pages/Settings/privacy_policy.dart';
import 'package:vital_plan/pages/Settings/ai_risk_statement.dart';
import 'package:vital_plan/pages/auth_wrapper.dart';

Widget getRootWidget() {
  return MaterialApp(initialRoute: "/", routes: getRootRoutes());
}

// 路由配置表
Map<String, Widget Function(BuildContext)> getRootRoutes() {
  return {
    "/": (context) => const AuthWrapper(), // 将根路由指向 AuthWrapper，由它决定显示什么
    "/main": (context) => MainPage(), // 显式定义 MainPage 路由
    "/login": (context) => LoginPage(), // 登录路由
    "/game": (context) => GamePage(), // 游戏路由
    "/check_in_chat": (context) => CheckInChatPage(),
    "/board": (context) => BoardPage(), // 看板路由
    "/emo": (context) => EmoPage(), // emo路由
    "/settings": (context) => const SettingsPage(), // 关于页面路由
    "/settings/user_agreement": (context) => const UserAgreementPage(),
    "/settings/privacy_policy": (context) => const PrivacyPolicyPage(),
    "/settings/ai_risk_statement": (context) => const AiRiskStatementPage(),
  };
}
