import 'package:flutter/material.dart';

class ToastUtils {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// 显示轻提示
  /// [message] 提示内容
  /// [isError] 是否为错误提示（红色背景）
  static void show(String message, {bool isError = false}) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;

    // 清除当前正在显示的 SnackBar，实现“同一时间只能弹出一个”
    messenger.removeCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
