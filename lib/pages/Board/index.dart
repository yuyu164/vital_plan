import 'package:flutter/material.dart';
import '../../api/action_service.dart';
import '../../api/coin_service.dart';
import '../../viewmodels/action_model.dart';
import '../../components/common/charge_button.dart';
import '../../components/board/action_header.dart';
import '../../components/board/info_row.dart';
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

    // 使用 Column + Expanded 实现无滚动固定布局
    return SafeArea(
      child: Column(
        children: [
          // 1. 顶部 Header (固定高度占比，例如 35%)
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            child: Stack(
              children: [
                ActionHeader(action: _currentAction!),
                // 返回按钮
                Positioned(
                  top: 10,
                  left: 10,
                  child: _buildCircleBtn(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                // 刷新按钮
                Positioned(
                  top: 10,
                  right: 10,
                  child: _buildCircleBtn(
                    icon: Icons.refresh,
                    onTap: _switchAction,
                  ),
                ),
              ],
            ),
          ),

          // 2. 中间内容区 (自适应剩余空间)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 均匀分布
                children: [
                  // 信息栏
                  InfoRow(action: _currentAction!),

                  // 描述卡片 (限制最大高度，防止溢出)
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SingleChildScrollView(
                        // 仅描述文字内部可滚动
                        child: Text(
                          _currentAction!.description,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.blueGrey[900],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),

                  // 蓄力按钮区域
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
                        padding: const EdgeInsets.only(top: 8.0),
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
                    ],
                  ),

                  // 高难度切换按钮 (如果不需要显示，用 SizedBox 占位保持布局稳定，或者直接不显示)
                  if (_currentAction != null && _currentAction!.difficulty < 4)
                    Container(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _switchToHardAction,
                        icon: Icon(Icons.local_fire_department, size: 20),
                        label: Text("来点猛的？"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: StadiumBorder(),
                          elevation: 2,
                        ),
                      ),
                    )
                  else
                    SizedBox(height: 50), // 保持底部间距一致
                ],
              ),
            ),
          ),

          SizedBox(height: 10), // 底部安全边距
        ],
      ),
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
