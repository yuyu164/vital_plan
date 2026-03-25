import 'package:flutter/material.dart';
import 'package:vital_plan/api/exp_service.dart';

class ExpBadge extends StatefulWidget {
  const ExpBadge({Key? key}) : super(key: key);

  @override
  State<ExpBadge> createState() => _ExpBadgeState();
}

class _ExpBadgeState extends State<ExpBadge> {
  @override
  void initState() {
    super.initState();
    // 组件加载时，确保经验值服务已初始化
    ExpService.init();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: ExpService.expNotifier,
      builder: (context, totalExp, child) {
        final level = ExpService.getLevel();
        final currentLevelExp = ExpService.getCurrentLevelExp();
        final expToNextLevel = ExpService.getExpToNextLevel();
        final progress = currentLevelExp / expToNextLevel;

        return Container(
          margin: const EdgeInsets.only(right: 16.0, top: 10, bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 等级徽章
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF1D5CBB),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "Lv.$level",
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 经验条和数值
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "EXP: $totalExp",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // 迷你进度条
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CA1AF),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
