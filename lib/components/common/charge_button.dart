import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChargeButton extends StatefulWidget {
  final VoidCallback onCompleted;
  final int rewardCoins;
  final bool isHardAction; // 是否为高难度动作
  
  // 阈值：0.6秒完成轻量任务
  final double quickThreshold = 0.6;
  // 阈值：1.2秒完成深度任务（暂未启用分档，目前统一按长按结束结算）
  
  const ChargeButton({
    Key? key,
    required this.onCompleted,
    required this.rewardCoins,
    this.isHardAction = false,
  }) : super(key: key);

  @override
  _ChargeButtonState createState() => _ChargeButtonState();
}

class _ChargeButtonState extends State<ChargeButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _scale = 1.0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200), // 1.2秒充满
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleCompletion();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePressDown() {
    if (_isCompleted) return;
    HapticFeedback.lightImpact();
    setState(() {
      _scale = 0.95;
    });
    _controller.forward();
  }

  void _handlePressUp() {
    if (_isCompleted) return;
    
    setState(() {
      _scale = 1.0;
    });

    if (_controller.value >= widget.quickThreshold / 1.2) {
      // 达到最小阈值，视为完成（或者可以根据需求决定是否必须满1.2s）
      // 这里逻辑：松手时如果没满，则重置；如果满了自动触发了 listener
      // 目前逻辑：必须按住直到动画结束才算完成
    }
    
    if (!_isCompleted) {
      _controller.reverse(); // 回退进度
    }
  }

  void _handleCompletion() {
    setState(() {
      _isCompleted = true;
      _scale = 1.1; // 瞬间放大
    });
    
    // 高难度震动更强
    if (widget.isHardAction) {
       HapticFeedback.vibrate(); 
    } else {
       HapticFeedback.heavyImpact();
    }
    
    // 播放完成动画后再回调
    Future.delayed(Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
           _scale = 1.0;
           _isCompleted = false; // 重置状态以便下次操作（或者保持完成态由父组件处理）
           _controller.reset();
        });
        widget.onCompleted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _handlePressDown(),
      onTapUp: (_) => _handlePressUp(),
      onTapCancel: () => _handlePressUp(),
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 背景圆
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
            ),
            
            // 进度环
            SizedBox(
              width: 130,
              height: 130,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CircularProgressIndicator(
                    value: _controller.value,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.isHardAction 
                        ? Color.lerp(Colors.orangeAccent, Colors.redAccent, _controller.value)!
                        : Color.lerp(Colors.blueAccent, Colors.purpleAccent, _controller.value)!
                    ),
                  );
                },
              ),
            ),

            // 中心按钮与文字
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: widget.isHardAction
                      ? [Colors.orange, Colors.deepOrange] // 高难度：橙红渐变
                      : [Colors.blueAccent, Colors.lightBlueAccent], // 普通：蓝紫渐变
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: widget.isHardAction 
                  ? [
                      BoxShadow(color: Colors.orange.withOpacity(0.6), blurRadius: 20, spreadRadius: 2)
                    ]
                  : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.isHardAction ? Icons.flash_on : Icons.touch_app, 
                    color: Colors.white, 
                    size: 32
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.isHardAction ? "终极挑战" : "长按蓄力",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
