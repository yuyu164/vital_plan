import 'package:flutter/material.dart';

class BoardTheme {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color cardBg;
  final Color text;
  final IconData icon;
  
  // 新增：渐变色组
  final List<Color> gradientColors;
  // 新增：阴影色
  final Color shadowColor;
  // 新增：装饰图标颜色
  final Color decorationColor;

  const BoardTheme({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.cardBg,
    required this.text,
    required this.icon,
    required this.gradientColors,
    required this.shadowColor,
    required this.decorationColor,
  });
}

class ThemeHelper {
  static BoardTheme getTheme(String boardId) {
    switch (boardId) {
      case 'neck_pain': // 颈椎 - 治愈森林绿
        return BoardTheme(
          primary: Color(0xFF2E7D32), // 深绿
          secondary: Color(0xFF81C784),
          background: Color(0xFFF1F8E9), // 极浅绿背景
          cardBg: Color(0xFFFFFFFF), // 纯白卡片
          text: Color(0xFF1B5E20),
          icon: Icons.spa,
          gradientColors: [Color(0xFF66BB6A), Color(0xFF43A047)],
          shadowColor: Color(0x332E7D32), // 绿色阴影
          decorationColor: Color(0x1A2E7D32),
        );
      case 'eye_strain': // 视疲劳 - 舒缓薰衣草紫
        return BoardTheme(
          primary: Color(0xFF673AB7), // 深紫
          secondary: Color(0xFFB39DDB),
          background: Color(0xFFF3E5F5), // 极浅紫背景
          cardBg: Color(0xFFFFFFFF),
          text: Color(0xFF4A148C),
          icon: Icons.visibility,
          gradientColors: [Color(0xFF9575CD), Color(0xFF7E57C2)],
          shadowColor: Color(0x33673AB7),
          decorationColor: Color(0x1A673AB7),
        );
      case 'late_sleep': // 睡得晚 - 静谧星空蓝
        return BoardTheme(
          primary: Color(0xFF283593), // 深蓝
          secondary: Color(0xFF7986CB),
          background: Color(0xFFE8EAF6),
          cardBg: Color(0xFFFFFFFF),
          text: Color(0xFF1A237E),
          icon: Icons.nights_stay,
          gradientColors: [Color(0xFF3F51B5), Color(0xFF303F9F)],
          shadowColor: Color(0x33283593),
          decorationColor: Color(0x1A283593),
        );
      case 'emo': // Emo - 温暖治愈橙
        return BoardTheme(
          primary: Color(0xFFEF6C00), // 深橙
          secondary: Color(0xFFFFCC80),
          background: Color(0xFFFFF3E0),
          cardBg: Color(0xFFFFFFFF),
          text: Color(0xFFE65100),
          icon: Icons.mood,
          gradientColors: [Color(0xFFFF9800), Color(0xFFF57C00)],
          shadowColor: Color(0x33EF6C00),
          decorationColor: Color(0x1AEF6C00),
        );
      case 'normal': // 无异常 - 清爽天空蓝
      default:
        return BoardTheme(
          primary: Color(0xFF0277BD), // 海蓝
          secondary: Color(0xFF81D4FA),
          background: Color(0xFFE1F5FE),
          cardBg: Color(0xFFFFFFFF),
          text: Color(0xFF01579B),
          icon: Icons.wb_sunny,
          gradientColors: [Color(0xFF29B6F6), Color(0xFF039BE5)],
          shadowColor: Color(0x330277BD),
          decorationColor: Color(0x1A0277BD),
        );
    }
  }
}
