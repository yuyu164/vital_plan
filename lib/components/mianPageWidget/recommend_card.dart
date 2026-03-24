import 'package:flutter/material.dart';
import 'dart:ui'; // 用于 ImageFilter

class RecommendDart extends StatefulWidget {
  const RecommendDart({Key? key}) : super(key: key);

  @override
  _RecommendDartState createState() => _RecommendDartState();
}

class _RecommendDartState extends State<RecommendDart> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 140, // 保持高度
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, "/check_in_chat");
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // 1. 渐变背景底色
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF81D4FA).withOpacity(0.6), // 浅蓝
                      Color(0xFFB39DDB).withOpacity(0.6), // 浅紫
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // 2. 玻璃拟态效果 (BackdropFilter)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.white.withOpacity(0.2), // 半透明白
                ),
              ),

              // 3. 内容层
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    // 左侧文案
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "我的健康档案",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1D5CBB),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            "回顾健康，有问必答",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "查看我的调理记录 · 召唤 AI 助手",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF888888),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 右侧装饰图
                    Container(
                      width: 84,
                      height: 84,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDBD4EC), // 图标背景底色
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.local_florist_rounded, // 圆润的花朵图标
                          size: 44,
                          color: Color(0xFFF36195),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
