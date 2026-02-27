import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api/auth_service.dart';
import '../../utils/toast_utils.dart';
import '../Main/index.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nicknameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  final _phoneRegex = RegExp(r'^1[3-9]\d{9}$');
  final _passwordRegex = RegExp(r'^[a-zA-Z0-9_@*]{6,16}$');

  void _handleRegister() async {
    final nickname = _nicknameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (nickname.isEmpty) {
      ToastUtils.show("请输入昵称（目前不支持修改昵称）", isError: true);
      return;
    }
    if (nickname.length > 16) {
      ToastUtils.show("昵称最多16个字符", isError: true);
      return;
    }
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
    await authService.register(phone, password, nickname);
    ToastUtils.show("注册成功，欢迎加入元气计划！");

    // 注册成功后直接进入主页（清除路由栈）
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MainPage()),
      (route) => false,
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "注册账号",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "完善信息，开启元气之旅",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 40),

                        // 昵称
                        TextField(
                          controller: _nicknameController,
                          maxLength: 16,
                          decoration: InputDecoration(
                            labelText: "昵称",
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            counterText: "",
                          ),
                        ),
                        SizedBox(height: 20),

                        // 手机号
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

                        // 密码
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "设置密码",
                            prefixIcon: Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            helperText: "6-16位字母、数字、_@*",
                          ),
                        ),

                        Spacer(), // 自动占据剩余空间

                        SizedBox(height: 20),

                        // 注册按钮
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text("立即注册", style: TextStyle(fontSize: 18)),
                          ),
                        ),

                        SizedBox(height: 20),
                        // 返回登录
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "已有账号？去登录",
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
