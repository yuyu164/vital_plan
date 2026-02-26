import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoinService {
  static const String _keyCoins = 'user_coins';
  
  // 单例模式，确保全局共享同一个Notifier
  static final CoinService _instance = CoinService._internal();
  factory CoinService() => _instance;
  CoinService._internal();

  // 金币数监听器
  final ValueNotifier<int> coinsNotifier = ValueNotifier<int>(0);

  // 初始化（APP启动时调用）
  Future<void> init() async {
    final coins = await getCoins();
    coinsNotifier.value = coins;
  }

  // 获取当前金币数
  Future<int> getCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCoins) ?? 0;
  }

  // 增加金币
  Future<int> addCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyCoins) ?? 0;
    final newTotal = current + amount;
    await prefs.setInt(_keyCoins, newTotal);
    
    // 更新监听器
    coinsNotifier.value = newTotal;
    
    return newTotal;
  }
}
