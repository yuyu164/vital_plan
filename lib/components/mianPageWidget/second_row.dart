import 'package:flutter/material.dart';
import 'package:vital_plan/components/main_page/energy_card.dart';

class SecondRow extends StatefulWidget {
  SecondRow({Key? key}) : super(key: key);

  @override
  _SecondRowState createState() => _SecondRowState();
}

class _SecondRowState extends State<SecondRow> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      height: 145, // 调整高度 130 -> 145
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: EnergyCard(
              title: "日常",
              subtitle: "保持活力",
              icon: Icons.wb_sunny_rounded,
              color: Colors.orange,
              onTap: () => Navigator.pushNamed(
                context,
                "/board",
                arguments: {'boardId': 'normal'},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
