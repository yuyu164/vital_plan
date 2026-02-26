import 'package:flutter/material.dart';
import '../../viewmodels/action_model.dart';

class InfoRow extends StatelessWidget {
  final ActionModel action;

  const InfoRow({Key? key, required this.action}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoItem(
            icon: Icons.access_time_filled,
            label: "耗时",
            value: action.duration == "0" ? "即时" : action.duration,
            color: Colors.blueAccent,
          ),
          _buildDivider(),
          _buildInfoItem(
            icon: Icons.monetization_on,
            label: "奖励",
            value: "${action.rewards.coins}",
            color: Colors.amber,
          ),
          _buildDivider(),
          _buildInfoItem(
            icon: Icons.category,
            label: "类型",
            value: _getTypeLabel(action.interactionType),
            color: Colors.purpleAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[300],
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
