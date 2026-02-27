import 'package:flutter/material.dart';

class EnergyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isLarge;

  const EnergyCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isLarge = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 关键修复：将 Container 放在最外层，Material 放在 Container 内部
    // 原因：Material 默认会裁切点击区域，且如果外层有其他装饰（如圆角），可能会导致点击区域不匹配
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24), // 确保水波纹也是圆角
        child: InkWell(
          onTap: () {
            print("EnergyCard tapped: $title"); // 调试日志
            onTap();
          },
          borderRadius: BorderRadius.circular(24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // 背景装饰圆
                Positioned(
                  right: -20,
                  bottom: -25, // 调整位置，更隐蔽
                  child: IgnorePointer(
                    child: Container(
                      width: 90, // 减小尺寸 100 -> 90
                      height: 90,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(12.0), // 减小内边距 14 -> 12
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 图标容器
                      Container(
                        padding: EdgeInsets.all(8), // 减小 padding 10 -> 8
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 22,
                        ), // 减小图标 24 -> 22
                      ),

                      // 使用 Expanded 替代 Spacer，确保空间分配更合理
                      Expanded(child: SizedBox()),

                      // 文字信息
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            // 自动缩放标题
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 15, // 减小字号 16 -> 15
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                height: 1.2, // 显式设置行高
                              ),
                            ),
                          ),
                          SizedBox(height: 2),
                          FittedBox(
                            // 自动缩放副标题
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 11, // 减小字号 12 -> 11
                                color: Colors.grey[600],
                                height: 1.2, // 显式设置行高
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
