import 'package:flutter/material.dart';
import '../../api/action_service.dart';
import '../../api/coin_service.dart';
import '../../viewmodels/action_model.dart';
import '../../components/common/charge_button.dart';
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

    // 如果还没加载过且有路由参数，可以触发重载（这里简化，假设initState已处理或通过key更新）

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentAction?.title ?? "养生动作"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _switchAction,
            tooltip: "换一换",
          ),
        ],
      ),
      body: _buildBody(),
    );
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

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 演示区域 (GIF/视频占位)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                Icons.play_circle_outline,
                size: 64,
                color: Colors.grey,
              ),
              // TODO: 实际接入 Image.asset(_currentAction!.assets.gif)
            ),
          ),
          SizedBox(height: 24),

          // 动作说明
          Text(
            _currentAction!.title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            _currentAction!.description,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Chip(
            label: Text("耗时: ${_currentAction!.duration}"),
            backgroundColor: Colors.blue[50],
          ),

          SizedBox(height: 40),

          // 长按交互区域
          ChargeButton(
            rewardCoins: _currentAction!.rewards.coins,
            isHardAction: _currentAction!.difficulty >= 4, // 难度大于等于4算高难度
            onCompleted: () async {
              // 1. 增加金币
              final earned = _currentAction!.rewards.coins;
              await _coinService.addCoins(earned);

              // 2. 跳转到奖励页
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RewardPage(earnedCoins: earned),
                  ),
                );
              }
            },
          ),

          // 高难度动作切换按钮
          if (_currentAction != null && _currentAction!.difficulty < 4)
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ElevatedButton.icon(
                onPressed: _switchToHardAction,
                icon: Icon(Icons.fitness_center),
                label: Text("来点猛的？"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
