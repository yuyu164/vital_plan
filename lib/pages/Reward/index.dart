import 'package:flutter/material.dart';

class RewardPage extends StatefulWidget {
  final int earnedCoins;

  const RewardPage({Key? key, required this.earnedCoins}) : super(key: key);

  @override
  _RewardPageState createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8), // 半透明黑色背景模拟弹窗
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 300,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "🎉 任务完成！",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(height: 20),
                Image.asset(
                  "lib/assets/images/coin/honest_graphic-money-bag-9772256_1920.png",
                  width: 80,
                  height: 80,
                ),
                SizedBox(height: 10),
                Text(
                  "+ ${widget.earnedCoins} 金币",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[700],
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // 返回首页
                          Navigator.popUntil(context, ModalRoute.withName('/'));
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text("返回首页"),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // 继续（返回上一页，即看板页）
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text("继续"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
