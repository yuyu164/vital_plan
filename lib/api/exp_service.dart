import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpService {
  static const String _expKey = 'user_exp';
  
  // 使用 ValueNotifier 以便 UI 能够监听经验值变化
  static final ValueNotifier<int> expNotifier = ValueNotifier<int>(0);

  /// 初始化，加载本地经验值
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final int savedExp = prefs.getInt(_expKey) ?? 0;
    expNotifier.value = savedExp;
  }

  /// 获取当前经验值
  static int getExp() {
    return expNotifier.value;
  }

  /// 增加经验值
  static Future<void> addExp(int amount) async {
    if (amount <= 0) return;
    
    final prefs = await SharedPreferences.getInstance();
    final int currentExp = expNotifier.value;
    final int newExp = currentExp + amount;
    
    await prefs.setInt(_expKey, newExp);
    expNotifier.value = newExp;
  }

  /// 获取当前等级
  /// 简单的等级计算公式：等级 = 1 + 经验值 // 100 （每 100 经验升一级）
  static int getLevel() {
    return 1 + (expNotifier.value ~/ 100);
  }

  /// 获取当前等级已累积的经验值（用于进度条显示）
  static int getCurrentLevelExp() {
    return expNotifier.value % 100;
  }

  /// 获取升级所需的总经验值（当前设定每级都是 100）
  static int getExpToNextLevel() {
    return 100;
  }
}
