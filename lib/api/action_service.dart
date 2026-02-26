import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../viewmodels/action_model.dart';

class ActionService {
  List<ActionModel> _allActions = [];
  bool _isLoaded = false;

  // 加载本地 JSON 数据
  Future<void> _loadData() async {
    if (_isLoaded) return;
    try {
      print('Loading actions from assets...');
      final String response =
          await rootBundle.loadString('lib/assets/data/actions.json');
      print('Loaded JSON: ${response.length} chars');
      
      final List<dynamic> data = json.decode(response);
      _allActions = data.map((json) => ActionModel.fromJson(json)).toList();
      _isLoaded = true;
      print('Parsed ${_allActions.length} actions');
    } catch (e) {
      print('Error loading actions: $e');
      _allActions = [];
    }
  }

  // 根据板块 ID 获取推荐动作
  // 如果 actions 为空，返回 null
  Future<ActionModel?> getActionByBoard(String boardId) async {
    print('Getting action for board: $boardId');
    await _loadData();
    final boardActions =
        _allActions.where((action) => action.board == boardId).toList();
    
    print('Found ${boardActions.length} actions for board: $boardId');
    if (boardActions.isEmpty) return null;
    
    // 默认返回第一个，或者随机返回一个
    final random = Random();
    return boardActions[random.nextInt(boardActions.length)];
  }

  // 获取特定板块的所有动作（用于“换一换”）
  Future<List<ActionModel>> getAllActionsByBoard(String boardId) async {
    await _loadData();
    return _allActions.where((action) => action.board == boardId).toList();
  }

  // 获取板块内“奖励最高”的动作（用于“来点猛的”）
  // 逻辑：按 coins 降序排列取第一个
  Future<ActionModel?> getHardActionByBoard(String boardId) async {
    await _loadData();
    final boardActions = _allActions.where((action) => action.board == boardId).toList();
    
    if (boardActions.isEmpty) return null;

    // 排序：奖励金币多的排前面
    boardActions.sort((a, b) => b.rewards.coins.compareTo(a.rewards.coins));
    
    return boardActions.first;
  }
}
