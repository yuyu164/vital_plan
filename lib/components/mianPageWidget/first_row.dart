import 'package:flutter/material.dart';
import '../main_page/energy_card.dart';

class FirstRow extends StatelessWidget {
  const FirstRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 145, // 调整高度 130 -> 145
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Expanded(
          //   child: EnergyCard(
          //     title: "日常",
          //     subtitle: "保持活力",
          //     icon: Icons.wb_sunny_rounded,
          //     color: Colors.orange,
          //     onTap: () => Navigator.pushNamed(
          //       context,
          //       "/board",
          //       arguments: {'boardId': 'normal'},
          //     ),
          //   ),
          // ),
          SizedBox(width: 12),
          Expanded(
            child: EnergyCard(
              title: "熬夜",
              subtitle: "紧急补救",
              icon: Icons.nights_stay_rounded,
              color: Colors.indigo,
              onTap: () => Navigator.pushNamed(
                context,
                "/board",
                arguments: {'boardId': 'late_sleep'},
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: EnergyCard(
              title: "护眼",
              subtitle: "缓解疲劳",
              icon: Icons.visibility_rounded,
              color: Colors.teal,
              onTap: () => Navigator.pushNamed(
                context,
                "/board",
                arguments: {'boardId': 'eye_strain'},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
