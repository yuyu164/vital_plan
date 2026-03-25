import 'package:flutter/material.dart';
import '../../viewmodels/action_model.dart';
import '../../utils/theme_helper.dart';

class VitalityCapsule extends StatelessWidget {
  final ActionModel action;

  const VitalityCapsule({Key? key, required this.action}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ThemeHelper.getTheme(action.board);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCapsule(
            context,
            icon: Icons.access_time_filled,
            label: "耗时",
            value: action.duration == "0" ? "即时" : action.duration,
            color: theme.primary, // 统一使用主题主色
            bgColor: theme.background, // 统一使用主题背景色
          ),
          // 注释掉原有的金币显示逻辑
          /*
          _buildCapsule(
            context,
            icon: Icons.monetization_on,
            label: "奖励",
            value: "${action.rewards.coins}",
            color: Colors.amber[700]!,
            bgColor: Colors.amber[50]!,
          ),
          */
          // 替换为经验值显示逻辑
          _buildCapsule(
            context,
            icon: Icons.star_rounded, // 使用星星图标代表经验
            label: "经验",
            value: "+${action.rewards.exp}", // 从模型中读取 exp
            color: theme.primary, // 统一使用主题主色，不再使用固定的蓝色
            bgColor: theme.background, // 统一使用主题背景色
          ),
          _buildCapsule(
            context,
            icon: Icons.category,
            label: "类型",
            value: _getTypeLabel(action.interactionType),
            color: theme.primary, // 统一使用主题主色，使其与另外两个一致
            bgColor: theme.background, // 统一使用主题背景色
          ),
        ],
      ),
    );
  }

  Widget _buildCapsule(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'TIMER':
        return '计时';
      case 'CHECKBOX':
        return '打卡';
      case 'INTERACTIVE':
        return '交互';
      default:
        return '动作';
    }
  }
}
