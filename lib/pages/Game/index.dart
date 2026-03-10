import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class GamePage extends StatefulWidget {
  GamePage({Key? key}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  // InAppLocalhostServer? _server;
  @override
  void initState() {
    super.initState();
    // 隐藏状态栏和导航栏，实现全屏
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky, // 沉浸式全屏，点击屏幕不会弹出状态栏
      overlays: [],
    );
    // 使用本地 http 服务承载游戏资源，避免 file:// 加载 WASM 的兼容问题
    // _server = InAppLocalhostServer(documentRoot: 'lib/assets/game');
    // _server!.start();
  }

  @override
  void dispose() {
    // 退出游戏时恢复系统UI和屏幕方向
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // _server?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 去除Scaffold的默认边距，实现真正全屏
      body: Stack(
        children: [
          // 核心：加载本地Godot H5游戏
          InAppWebView(
            initialFile: 'lib/assets/game/game.html', // 本地H5入口文件（已确认实际文件名）
            // // 通过本地 http 服务访问，兼容 WASM、相对路径、MIME 等问题
            // initialUrlRequest:
            //     URLRequest(url: WebUri('http://localhost:8080/game.html')),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                // 关键配置：禁用缩放、启用JS、支持WASM
                javaScriptEnabled: true,
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: false,
                allowFileAccessFromFileURLs: true, // 允许本地文件访问
                allowUniversalAccessFromFileURLs: true,
                cacheEnabled: true,
                clearCache: false,
              ),
              android: AndroidInAppWebViewOptions(
                hardwareAcceleration: true, // 硬件加速提升性能
                useHybridComposition: true, // 解决渲染问题
                disableDefaultErrorPage: true, // 禁用默认错误页
                builtInZoomControls: false, // 禁用缩放控件
                displayZoomControls: false,
              ),
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onLoadStart: (controller, url) {
              setState(() => _isLoading = true);
            },
            onLoadStop: (controller, url) async {
              setState(() => _isLoading = false);
              // 可选：加载完成后执行JS，调整游戏尺寸
              await controller.evaluateJavascript(
                source: """
                // 强制游戏画布占满整个WebView
                document.body.style.margin = '0';
                document.body.style.padding = '0';
                document.querySelector('canvas').style.width = '100%';
                document.querySelector('canvas').style.height = '100%';
              """,
              );
            },
            // Android 物理返回键处理建议放在 WillPopScope 外层，这里移除 onKeyDown 以兼容当前插件版本
          ),
          // 加载中提示
          // if (_isLoading)
          //   const Center(
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         CircularProgressIndicator(),
          //         SizedBox(height: 20),
          //         Text('正在加载游戏...', style: TextStyle(fontSize: 16)),
          //       ],
          //     ),
          //   ),
        ],
      ),
    );
  }
}
