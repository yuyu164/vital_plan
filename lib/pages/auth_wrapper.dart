import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vital_plan/api/auth_service.dart';
import 'package:vital_plan/pages/Login/index.dart';
import 'package:vital_plan/pages/Main/index.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // 模拟初始化检查，目前仅做简单延时或立即完成
    // 如果未来有异步初始化逻辑（如读取本地token），可以在这里添加
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 不再根据登录状态强制跳转，而是直接进入主页（主页会根据状态显示不同内容）
    // 只有当用户主动点击主页左上角时，才会跳转 LoginPage
    return MainPage();
  }
}
