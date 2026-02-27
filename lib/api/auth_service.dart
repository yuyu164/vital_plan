import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  static const _keyPhone = 'user_phone';
  static const _keyPassword = 'user_password';
  static const _keyIsRegistered = 'is_registered';

  static const _keyNickname = 'user_nickname';

  bool _isLoggedIn = false;
  String _nickname = "游客";

  bool get isLoggedIn => _isLoggedIn;
  String get nickname => _nickname;

  // 检查是否已注册（即是否存在本地密码）
  Future<bool> isRegistered() async {
    final registered = await _storage.read(key: _keyIsRegistered);
    return registered == 'true';
  }

  // 初始化（App启动时调用，如果需要自动登录可以在这里加逻辑，目前默认游客）
  Future<void> init() async {
    // 这里可以加自动登录逻辑，如果不需要自动登录，保持默认游客即可
    // 如果想要记住登录状态，可以读取 token
    // 目前保持默认：启动即游客，需要手动登录
  }

  // 注册/设置密码
  Future<void> register(String phone, String password, String nickname) async {
    await _storage.write(key: _keyPhone, value: phone);
    await _storage.write(key: _keyPassword, value: password);
    await _storage.write(key: _keyNickname, value: nickname);
    await _storage.write(key: _keyIsRegistered, value: 'true');

    _nickname = nickname;
    _isLoggedIn = true;
    notifyListeners();
  }

  // 登录/验证密码
  Future<bool> login(String phone, String password) async {
    final savedPhone = await _storage.read(key: _keyPhone);
    final savedPassword = await _storage.read(key: _keyPassword);

    if (savedPhone == phone && savedPassword == password) {
      final savedNickname = await _storage.read(key: _keyNickname);
      _nickname = savedNickname ?? "用户";
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  // 退出登录
  void logout() {
    _isLoggedIn = false;
    _nickname = "游客";
    notifyListeners();
  }
}
