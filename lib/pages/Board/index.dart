import 'package:flutter/material.dart';
import 'package:vital_plan/components/board/info_row.dart';
import '../../api/action_service.dart';
import '../../api/coin_service.dart';
import '../../viewmodels/action_model.dart';
import '../../components/common/charge_button.dart';
import '../../components/board/action_header.dart';
import '../../components/board/vitality_capsule.dart'; // 新组件
import '../../utils/theme_helper.dart'; // 主题工具
import '../Reward/index.dart';

class BoardPage extends StatefulWidget {
  final String? boardId;

  const BoardPage({Key? key, this.boardId}) : super(key: key);

  @override
  _BoardPageState createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  final ActionService _actionService = ActionService();
  final CoinService _coinService = CoinService();
  ActionModel? _currentAction;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 优先使用传入的 boardId，如果为空则尝试从路由参数获取
    final routeArgs =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final boardIdFromRoute = routeArgs?['boardId'];
    final targetBoardId = widget.boardId ?? boardIdFromRoute ?? 'normal';

    // 只有当目标ID变化或尚未加载时才加载
    if (_currentAction == null || _currentAction!.board != targetBoardId) {
      _loadAction(targetBoardId);
    }
  }

  // 加载动作数据
  Future<void> _loadAction(String targetBoardId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final action = await _actionService.getActionByBoard(targetBoardId);

      if (mounted) {
        setState(() {
          _currentAction = action;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '加载失败: $e';
          _isLoading = false;
        });
      }
    }
  }

  // 换一换逻辑
  void _switchAction() async {
    setState(() {
      _isLoading = true;
    }); // 先显示loading

    final routeArgs =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final boardIdFromRoute = routeArgs?['boardId'];
    final targetBoardId = widget.boardId ?? boardIdFromRoute ?? 'normal';

    await _loadAction(targetBoardId);
  }

  // 切换到“来点猛的”
  void _switchToHardAction() async {
    setState(() {
      _isLoading = true;
    });

    final routeArgs =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final boardIdFromRoute = routeArgs?['boardId'];
    final targetBoardId = widget.boardId ?? boardIdFromRoute ?? 'normal';

    final hardAction = await _actionService.getHardActionByBoard(targetBoardId);

    if (mounted) {
      setState(() {
        if (hardAction != null) {
          _currentAction = hardAction;
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("本板块暂无高难度挑战")));
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 尝试从路由参数获取 boardId (如果构造函数没传)
    final routeArgs =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final boardIdFromRoute = routeArgs?['boardId'];

    // 隐藏 AppBar，改用 SliverAppBar 实现沉浸式效果
    return Scaffold(backgroundColor: Colors.white, body: _buildBody());
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            ElevatedButton(
              onPressed: () => _loadAction(_currentAction!.board),
              child: Text("重试"),
            ),
          ],
        ),
      );
    }

    if (_currentAction == null) {
      return Center(child: Text("该板块暂无推荐动作"));
    }

    // 获取当前板块主题
    final theme = ThemeHelper.getTheme(_currentAction!.board);

    // 使用 Stack 实现 Header 与 内容的重叠效果
    return Stack(
      children: [
        // 1. 顶部 Header (固定高度)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.45, // 增加高度以便重叠
          child: Stack(
            children: [
              ActionHeader(action: _currentAction!),
              // 返回按钮
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 10,
                child: _buildCircleBtn(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                ),
              ),
              // 刷新按钮
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 10,
                child: _buildCircleBtn(
                  icon: Icons.refresh,
                  onTap: _switchAction,
                ),
              ),
            ],
          ),
        ),

        // 2. 底部白色容器 (向上位移覆盖)
        Positioned(
          top: MediaQuery.of(context).size.height * 0.35, // 从 35% 处开始覆盖
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 30,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 信息胶囊行
                  VitalityCapsule(action: _currentAction!),

                  // 描述卡片 (带装饰)
                  Expanded(
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(vertical: 20),
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.background, // 主题背景色
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: theme.cardBg, width: 2),
                        ),
                        child: Stack(
                          children: [
                            // 装饰性引号
                            Positioned(
                              top: -10,
                              left: -10,
                              child: Icon(
                                Icons.format_quote,
                                color: theme.decorationColor,
                                size: 40,
                              ),
                            ),
                            Center(
                              child: SingleChildScrollView(
                                child: Text(
                                  _currentAction!.description,
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.8, // 增加行高
                                    color: Colors.black87,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 底部操作区
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ChargeButton(
                        rewardCoins: _currentAction!.rewards.coins,
                        isHardAction: _currentAction!.difficulty >= 4,
                        onCompleted: () async {
                          final earned = _currentAction!.rewards.coins;
                          await _coinService.addCoins(earned);
                          if (mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RewardPage(earnedCoins: earned),
                              ),
                            );
                          }
                        },
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text(
                          _currentAction!.difficulty >= 4
                              ? "挑战极限，赢取大奖！"
                              : "长按 1.2s 完成打卡",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // 高难度切换按钮
                      if (_currentAction != null &&
                          _currentAction!.difficulty < 4)
                        Container(
                          height: 44,
                          child: TextButton.icon(
                            onPressed: _switchToHardAction,
                            icon: Icon(
                              Icons.local_fire_department,
                              color: Colors.redAccent,
                              size: 18,
                            ),
                            label: Text(
                              "来点猛的？",
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.red[50],
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              shape: StadiumBorder(),
                            ),
                          ),
                        )
                      else
                        SizedBox(height: 44),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircleBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onTap,
      ),
    );
  }
}
