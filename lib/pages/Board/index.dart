import 'package:flutter/material.dart';
import 'package:vital_plan/components/board/info_row.dart';
import '../../api/action_service.dart';
import '../../api/action_video_source.dart';
import '../../api/coin_service.dart';
import '../../api/exp_service.dart'; // 引入 ExpService
import '../../api/check_in_service.dart'; // 引入打卡服务
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
    final isVideoAction = ActionVideoSource.hasVideo(_currentAction!.id);
    final screenSize = MediaQuery.of(context).size;
    final videoHeaderHeightByAspect = screenSize.width * 9 / 16;
    final videoHeaderHeight = videoHeaderHeightByAspect.clamp(
      screenSize.height * 0.48,
      screenSize.height * 0.58,
    );
    final defaultHeaderHeight = MediaQuery.of(context).size.height * 0.4;
    final headerHeight = isVideoAction
        ? videoHeaderHeight
        : defaultHeaderHeight;

    // 使用 Column + Transform.translate 实现稳定的覆盖效果
    return Column(
      children: [
        // 1. 顶部 Header (固定高度)
        Container(
          height: headerHeight,
          width: double.infinity,
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

        // 2. 底部白色容器 (使用 Expanded 填满剩余空间，通过 Stack 的 top -20 覆盖顶部而不留底部空隙)
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                top: isVideoAction ? -12 : -20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
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
                    padding: EdgeInsets.fromLTRB(
                      24,
                      isVideoAction ? 20 : 30,
                      24,
                      0,
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: isVideoAction ? 8 : 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // 信息胶囊行
                          VitalityCapsule(action: _currentAction!),

                          // 描述卡片 (带装饰)
                          SizedBox(height: 12),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: 100,
                              maxHeight: 200,
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: theme.background,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: theme.cardBg,
                                  width: 2,
                                ),
                              ),
                              child: SingleChildScrollView(
                                child: Text(
                                  _currentAction!.description,
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.8,
                                    color: Colors.black87,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.left,
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
                                  final earnedExp =
                                      _currentAction!.rewards.exp; // 获取经验值
                                  await _coinService.addCoins(earned);
                                  await ExpService.addExp(earnedExp); // 增加经验值

                                  // 记录打卡状态
                                  CheckInModule? module;
                                  switch (_currentAction!.board) {
                                    case 'normal':
                                      module = CheckInModule.normal;
                                      break;
                                    case 'neck_pain':
                                      module = CheckInModule.neck;
                                      break;
                                    case 'eye_strain':
                                      module = CheckInModule.eye;
                                      break;
                                    case 'late_sleep':
                                      module = CheckInModule.sleep;
                                      break;
                                    case 'emo':
                                      module = CheckInModule.emo;
                                      break;
                                  }
                                  if (module != null) {
                                    await CheckInService.addCheckInRecord(
                                      DateTime.now(),
                                      module,
                                    );
                                  }

                                  if (mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RewardPage(
                                          earnedCoins: earned,
                                          earnedExp: earnedExp, // 传入经验值
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),

                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Text(
                                  _currentAction!.difficulty >= 4
                                      ? "养生悦己，活力续航"
                                      : "长按 1.2s 完成打卡",
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ),

                              SizedBox(height: 8),

                              // 高难度切换按钮 (仅当不是 late_sleep 或 neck_pain 时显示)
                              if (_currentAction != null &&
                                  _currentAction!.difficulty < 4 &&
                                  _currentAction!.board != 'late_sleep' &&
                                  _currentAction!.board != 'neck_pain')
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
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 24,
                                      ),
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
              ),
            ],
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
