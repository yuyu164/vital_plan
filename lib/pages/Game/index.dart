import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:vital_plan/api/coin_service.dart';

class GamePage extends StatefulWidget {
  GamePage({Key? key}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  InAppLocalhostServer? _server;
  late final String _initialUrl;
  @override
  void initState() {
    super.initState();
    // 隐藏状态栏和导航栏，实现全屏
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky, // 沉浸式全屏，点击屏幕不会弹出状态栏
      overlays: [],
    );
    // 平台自适配：
    // - Android/iOS：使用本地 http 服务承载游戏资源，避免 file:// + WASM 的兼容问题
    // - Web：走 Flutter Web 的 assets 路径
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      _server = InAppLocalhostServer(documentRoot: 'lib/assets/game');
      _server!.start();
      _initialUrl = 'http://localhost:8080/game.html';
    } else {
      _initialUrl = 'assets/lib/assets/game/game.html';
    }
  }

  @override
  void dispose() {
    // 退出游戏时恢复系统UI和屏幕方向
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _server?.close();
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
            // Android 通过本地 http 服务访问；Web 使用 assets 路径
            initialUrlRequest: URLRequest(url: WebUri(_initialUrl)),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                // 关键配置：禁用缩放、启用JS、支持WASM
                javaScriptEnabled: true,
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: false,
                allowFileAccessFromFileURLs: true,
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
              controller.addJavaScriptHandler(
                handlerName: 'getCoins',
                callback: (args) async {
                  final coins = await CoinService().getCoins();
                  return coins;
                },
              );
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
                
                (function() {
                  const origFetch = window.fetch;
                  window.fetch = async function(input, init) {
                    try {
                      const url = typeof input === 'string' ? input : (input && input.url ? input.url : '');
                      if (url && /data\\.json(\\?.*)?\$/.test(url)) {
                        const coins = await window.flutter_inappwebview.callHandler('getCoins');
                        const body = JSON.stringify([{ coin: Number(coins) || 0 }]);
                        return new Response(body, { status: 200, headers: { 'Content-Type': 'application/json' } });
                      }
                    } catch (e) {}
                    return origFetch.apply(this, arguments);
                  }
                })();
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
