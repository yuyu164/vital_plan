//管理路由
import 'package:flutter/material.dart';
import 'package:vital_plan/pages/Emo/index.dart';
import 'package:vital_plan/pages/Eye_strain/index.dart';
import 'package:vital_plan/pages/Game/index.dart';
import 'package:vital_plan/pages/Late_sleep/index.dart';
import 'package:vital_plan/pages/Login/index.dart';
import 'package:vital_plan/pages/Main/index.dart';
import 'package:vital_plan/pages/Neck_pain/index.dart';
import 'package:vital_plan/pages/Normal/index.dart';

Widget getRootWidget() {
  return MaterialApp(
    //命名路由
    initialRoute: "/",
    routes: getRootRoutes(),
  );
}

//返回路由配置
Map<String, Widget Function(BuildContext)> getRootRoutes() {
  return {
    "/": (context) => MainPage(), //主页路由
    "/login": (context) => LoginPage(), //登录路由
    "/game": (context) => GamePage(), //游戏路由
    "/normal": (context) => NormalPage(), //无异常
    "/late_sleep": (context) => LateSleepPage(), //睡得晚
    "/eye_strain": (context) => EyeStrainPage(), //视疲劳
    "/neck_pain": (context) => NeckPainPage(), //颈椎难受
    "/emo": (context) => EmoPage(), //emo了
  };
}
