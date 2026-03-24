import 'package:flutter/material.dart';

class ImageDialogUtils {
  /// 显示穴位图片弹窗
  /// [context] 上下文
  /// [imageUrl] 图片的地址（可以是本地资产路径或网络图片），目前预留接口
  /// [title] 弹窗的标题，比如穴位名称
  static void showAcupointImageDialog(BuildContext context, String title, String? imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5), // 周围背景蒙上灰色滤镜的效果
      barrierDismissible: true, // 点击弹窗区域外可以关闭弹窗
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent, // 弹窗背景透明
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题区域
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 图片区域
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  color: Colors.white, // 图片未加载时的占位背景色
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? _buildImage(imageUrl)
                      : _buildPlaceholder(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 预留的图片构建方法，根据需要可以切换为 Image.network 或 Image.asset
  static Widget _buildImage(String imageUrl) {
    // 这里以网络图片为例，如果之后用本地图片，可以改为 Image.asset(imageUrl)
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(errorText: "图片加载失败");
        },
      );
    } else {
      return Image.asset(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(errorText: "图片加载失败");
        },
      );
    }
  }

  static Widget _buildPlaceholder({String errorText = "图片暂未配置\n(预留接口)"}) {
    return Container(
      height: 300,
      alignment: Alignment.center,
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            errorText,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
