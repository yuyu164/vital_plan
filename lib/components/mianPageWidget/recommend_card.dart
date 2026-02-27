import 'package:flutter/material.dart';
import 'dart:ui'; // 用于 ImageFilter

class RecommendDart extends StatefulWidget {
  RecommendDart({Key? key}) : super(key: key);

  @override
  _RecommendDartState createState() => _RecommendDartState();
}

class _RecommendDartState extends State<RecommendDart> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 140, // 增加高度以容纳更多内容
      child: GestureDetector(
        onTap: () {
          // Navigator.pushNamed(context, "/healthRecommend"); // 暂时注释，等待路由实现
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // 1. 渐变背景
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
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "✨ 每日元气签(待施工)",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            "今天也要好好爱自己",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "点击开启今日份的治愈",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 右侧装饰图 (占位)
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.local_florist,
                        size: 40,
                        color: Colors.pinkAccent.withOpacity(0.8),
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
