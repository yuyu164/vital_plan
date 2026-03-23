import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 将枚举定义在这里，作为统一的数据模型
enum CheckInModule { emo, sleep, eye, normal, neck }

class CheckInService {
  static const String _checkInPrefsKey = 'check_in_records';

  // 使用 ValueNotifier 提供一个全局的刷新信号
  // 任何地方调用了 addCheckInRecord 导致数据变化时，都会通知它的监听者
  static final ValueNotifier<int> checkInUpdateNotifier = ValueNotifier<int>(0);

  /// 获取所有打卡记录
  static Future<Map<DateTime, List<CheckInModule>>> getCheckInRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recordsJson = prefs.getString(_checkInPrefsKey);
    final Map<DateTime, List<CheckInModule>> records = {};

    if (recordsJson != null) {
      try {
        final Map<String, dynamic> decodedMap = jsonDecode(recordsJson);
        decodedMap.forEach((key, value) {
          final DateTime date = DateTime.parse(key);
          final List<dynamic> moduleNames = value as List<dynamic>;
          final List<CheckInModule> modules = moduleNames.map((name) {
            return CheckInModule.values.firstWhere(
              (e) => e.toString().split('.').last == name,
            );
          }).toList();
          records[date] = modules;
        });
      } catch (e) {
        print("Error parsing check-in records: $e");
      }
    }
    return records;
  }

  /// 保存打卡记录
  static Future<void> _saveCheckInRecords(
    Map<DateTime, List<CheckInModule>> records,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, List<String>> encodedMap = {};

    records.forEach((date, modules) {
      final String dateKey = DateTime(
        date.year,
        date.month,
        date.day,
      ).toIso8601String();
      encodedMap[dateKey] = modules
          .map((m) => m.toString().split('.').last)
          .toList();
    });

    await prefs.setString(_checkInPrefsKey, jsonEncode(encodedMap));
  }

  /// 记录某天的打卡（如果当天尚未打过该板块）
  static Future<void> addCheckInRecord(
    DateTime date,
    CheckInModule module,
  ) async {
    final Map<DateTime, List<CheckInModule>> records =
        await getCheckInRecords();

    // 只保留年月日作为 key
    final key = DateTime(date.year, date.month, date.day);

    if (records.containsKey(key)) {
      if (!records[key]!.contains(module)) {
        records[key]!.add(module);
      }
    } else {
      records[key] = [module];
    }

    await _saveCheckInRecords(records);
    // 通知监听者数据已更新
    checkInUpdateNotifier.value++;
  }
}
