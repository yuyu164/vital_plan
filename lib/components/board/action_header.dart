import 'package:flutter/material.dart';
import 'action_video.dart';
import '../../api/action_video_source.dart';
import '../../viewmodels/action_model.dart';

class ActionHeader extends StatelessWidget {
  final ActionModel action;

  const ActionHeader({Key? key, required this.action}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 240, // 移除固定高度，让父容器决定
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. 背景图片/GIF (优先GIF，失败显示占位)
          // 实际项目中应使用 Image.asset(action.assets.gif)
          // 这里为了美观，我们使用一个渐变的彩色占位，或者如果 assets 存在则尝试加载
          _buildBackground(),

          // 2. 渐变蒙层 (提升文字可读性)
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  stops: [0.6, 1.0],
                ),
              ),
            ),
          ),

          // 3. 底部标题信息
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: IgnorePointer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 难度星级
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < action.difficulty
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
                  SizedBox(height: 8),
                  // 标题
                  Text(
                    action.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black45,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    if (ActionVideoSource.hasVideo(action.id)) {
      return ActionVideo(action: action);
    }

    return Container(
      decoration: BoxDecoration(color: Colors.grey[800]),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 尝试加载本地图片（GIF或Poster）
          if (action.assets.gif.isNotEmpty)
            Image.asset(
              "lib/${action.assets.gif}",
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print("Error loading GIF: $error");
                if (action.assets.poster.isNotEmpty) {
                  return Image.asset(
                    "lib/${action.assets.poster}",
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) {
                      print("Error loading Poster: $e");
                      return _buildPlaceholder();
                    },
                  );
                }
                return _buildPlaceholder();
              },
            )
          else
            _buildPlaceholder(),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(Icons.play_circle_outline, color: Colors.white24, size: 80),
    );
  }
}
