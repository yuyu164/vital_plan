import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api/auth_service.dart';
import '../../utils/toast_utils.dart';
import '../Main/index.dart';
import '../Register/index.dart'; // 引入注册页

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  final _phoneRegex = RegExp(r'^1[3-9]\d{9}$');
  final _passwordRegex = RegExp(r'^[a-zA-Z0-9_@*]{6,16}$');

  void _handleLogin() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (!_phoneRegex.hasMatch(phone)) {
      ToastUtils.show("手机号格式错误，请输入11位手机号", isError: true);
      return;
    }
    if (!_passwordRegex.hasMatch(password)) {
      ToastUtils.show("密码格式错误，需6-16位字母、数字或_@*", isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.login(phone, password);

    if (success) {
      ToastUtils.show("登录成功");
      // 登录成功后进入主页（清除路由栈）
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MainPage()),
        (route) => false,
      );
    } else {
      ToastUtils.show("账号或密码错误", isError: true);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _goToRegister() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => RegisterPage()));
  }

  @override
  Widget build(BuildContext context) {
    // 使用 LayoutBuilder 获取屏幕高度，防止在小屏幕上溢出
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: ClampingScrollPhysics(), // 允许在内容过多时滚动
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        // Logo
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.spa,
                                size: 80,
                                color: Colors.blueAccent,
                              ),
                              SizedBox(height: 16),
                              Text(
                                "元气计划",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey[900],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 40),

                        // 欢迎语
                        Text(
                          "欢迎回来",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "请登录您的账号",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 30),

                        // 手机号输入
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: "手机号",
                            prefixIcon: Icon(Icons.phone_android),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // 密码输入
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "密码",
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            helperText: "6-16位字母、数字、_@*",
                          ),
                        ),

                        Spacer(), // 自动占据剩余空间

                        SizedBox(height: 20),

                        // 登录按钮
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text("登录", style: TextStyle(fontSize: 18)),
                          ),
                        ),

                        SizedBox(height: 20),
                        // 注册跳转
                        Center(
                          child: TextButton(
                            onPressed: _goToRegister,
                            child: Text(
                              "没有账号？去注册",
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                          ),
                        ),
                        SizedBox(height: 20), // 底部留白
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
