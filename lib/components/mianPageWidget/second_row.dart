import 'package:flutter/material.dart';
import '../main_page/energy_card.dart';

class SecondRow extends StatelessWidget {
  const SecondRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170, // 增加高度 160 -> 170
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5, // 调整比例
            child: EnergyCard(
              title: "颈椎",
              subtitle: "拒绝僵硬",
              icon: Icons.accessibility_new_rounded,
              color: Colors.green,
              onTap: () => Navigator.pushNamed(
                context,
                "/board",
                arguments: {'boardId': 'neck_pain'},
              ),
              isLarge: true, // 可用于样式区分
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: EnergyCard(
              title: "EMO",
              subtitle: "心灵按摩",
              icon: Icons.mood_bad_rounded,
              color: Colors.pinkAccent,
              onTap: () => Navigator.pushNamed(context, "/emo"),
            ),
          ),
        ],
      ),
    );
  }
}
