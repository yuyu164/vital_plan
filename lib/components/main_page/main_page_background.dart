import 'package:flutter/material.dart';

class MainPageBackground extends StatelessWidget {
  final Widget child;

  const MainPageBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF0F4F8), // 极浅蓝 (类似晨曦)
            Color(0xFFF3E5F5), // 极浅紫 (类似晚霞)
            Color(0xFFFFF3E0), // 极浅橙 (类似阳光)
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }
}
