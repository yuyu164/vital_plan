import 'package:flutter/material.dart';
import 'package:vital_plan/utils/toast_utils.dart';
import 'package:vital_plan/pages/auth_wrapper.dart';
import 'package:vital_plan/routes/index.dart'; // 引入路由配置

class VitalPlanApp extends StatelessWidget {
  const VitalPlanApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vital Plan',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: ToastUtils.messengerKey, // 配置全局 Toast Key
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      // home: const AuthWrapper(), // 移除 home，改用 routes 中的 "/"
      initialRoute: "/", // 明确指定初始路由
      routes: getRootRoutes(), // 关键：挂载路由表
    );
  }
}
