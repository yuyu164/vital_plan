import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:vital_plan/api/check_in_service.dart';

// 由于 CheckInModule 枚举被移动到了 check_in_service.dart 中，
// 所以这里不需要再定义一遍，只需要使用即可。

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({Key? key}) : super(key: key);

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // 存储真实的打卡数据
  Map<DateTime, List<CheckInModule>> _checkInRecords = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchRealCheckInRecords();

    // 监听全局打卡更新信号
    CheckInService.checkInUpdateNotifier.addListener(_onCheckInUpdated);
  }

  void _onCheckInUpdated() {
    // 当收到打卡更新信号时，重新拉取数据
    _fetchRealCheckInRecords();
  }

  @override
  void dispose() {
    // 移除监听
    CheckInService.checkInUpdateNotifier.removeListener(_onCheckInUpdated);
    super.dispose();
  }

  // 获取真实打卡数据
  Future<void> _fetchRealCheckInRecords() async {
    final records = await CheckInService.getCheckInRecords();
    if (mounted) {
      setState(() {
        _checkInRecords = records;
      });
    }
  }

  List<CheckInModule> _getCheckInModules(DateTime date) {
    // 只比较年月日
    final key = DateTime(date.year, date.month, date.day);
    return _checkInRecords[key] ?? [];
  }

  // 自定义单元格构建
  Widget? _buildCalendarCell(
    BuildContext context,
    DateTime date,
    DateTime focusedDay, {
    bool isToday = false,
    bool isSelected = false,
  }) {
    final modules = _getCheckInModules(date);
    final hasRecord = modules.isNotEmpty;

    Color bgColor = Colors.transparent;
    Color textColor = Colors.black87;
    Border? border;
    FontWeight fontWeight = FontWeight.normal;

    // 打卡后的基础样式
    if (hasRecord) {
      bgColor = const Color(0xFFE8F5E9); // 浅绿色背景表示已打卡
      border = Border.all(color: Colors.green.shade400, width: 1.5); // 绿色边框
      textColor = Colors.green.shade800; // 绿色字体
      fontWeight = FontWeight.bold;
    }

    // 处理选中状态和今天的状态
    if (isSelected) {
      bgColor = Theme.of(context).primaryColor;
      textColor = Colors.white;
      // 选中时如果有打卡记录，保留绿色边框；否则不显示边框
      border = hasRecord
          ? Border.all(color: Colors.green.shade400, width: 2.0)
          : null;
    } else if (isToday) {
      if (!hasRecord) {
        bgColor = Colors.orangeAccent.withOpacity(0.2); // 没打卡时今天的背景色
        border = Border.all(color: Colors.orange, width: 2); // 今天的橙色边框
      } else {
        // 今天已打卡：优先显示打卡的绿色边框（稍微加粗一点以示区别，或者保持一致）
        border = Border.all(color: Colors.green.shade400, width: 2.0);
      }
      textColor = hasRecord ? Colors.green.shade800 : Colors.orange.shade800;
      fontWeight = FontWeight.bold;
    }

    // 将整个单元格包裹在一个方形容器中，而不是圆形的数字容器
    // 这样外层就可以画一个整体的方形边框
    Widget cellContent = Container(
      margin: const EdgeInsets.all(4.0), // 调整整体边距
      decoration: BoxDecoration(
        color: isSelected && !hasRecord
            ? Theme.of(context).primaryColor
            : Colors
                  .transparent, // 只有没打卡且选中时才给整个背景上色（为了兼容原本的选中圆圈样式，这里先设透明，后面单独画圆圈）
        border: hasRecord
            ? Border.all(color: Colors.green.shade400, width: 2.0)
            : (isToday && !hasRecord
                  ? Border.all(color: Colors.orange, width: 2.0)
                  : null), // 只要有打卡，整个格子加上绿色边框
        borderRadius: BorderRadius.circular(8.0), // 稍微给点圆角，显得不那么生硬
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 渲染日期数字的中心容器 (如果是选中状态或者是已打卡的背景色，在这里渲染)
          Container(
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).primaryColor : bgColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${date.day}',
              style: TextStyle(color: textColor, fontWeight: fontWeight),
            ),
          ),

          // 如果有打卡记录，在四个角渲染对应板块的图标
          if (hasRecord) ..._buildIcons(modules),
        ],
      ),
    );

    return cellContent;
  }

  // 提取图标渲染逻辑
  List<Widget> _buildIcons(List<CheckInModule> modules) {
    List<Widget> icons = [];
    final int count = modules.length;

    // 如果模块数 <= 4，使用原四角布局
    if (count <= 4) {
      final positions = [
        {'top': 2.0, 'left': 2.0},
        {'top': 2.0, 'right': 2.0},
        {'bottom': 2.0, 'left': 2.0},
        {'bottom': 2.0, 'right': 2.0},
      ];

      for (int i = 0; i < count; i++) {
        final module = modules[i];
        final iconInfo = _getIconInfo(module);
        final pos = positions[i];

        icons.add(
          Positioned(
            top: pos['top'],
            bottom: pos['bottom'],
            left: pos['left'],
            right: pos['right'],
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(iconInfo.icon, size: 10, color: iconInfo.color),
            ),
          ),
        );
      }
    }
    // 如果集齐了5个模块，使用星轨环绕（正五边形分布）布局
    else {
      // 使用 Align 和 FractionalOffset 实现中心环绕效果
      // (x, y) 的坐标系范围是 -1.0 到 1.0
      final positions = [
        {'x': 0.0, 'y': -0.95}, // 顶部正中
        {'x': 0.85, 'y': -0.2}, // 右上
        {'x': 0.6, 'y': 0.85}, // 右下
        {'x': -0.6, 'y': 0.85}, // 左下
        {'x': -0.85, 'y': -0.2}, // 左上
      ];

      for (int i = 0; i < count; i++) {
        final module = modules[i];
        final iconInfo = _getIconInfo(module);
        final pos = positions[i];

        icons.add(
          Align(
            alignment: FractionalOffset(
              (pos['x']! + 1) / 2, // 将 -1~1 映射到 0~1 的 FractionalOffset 坐标
              (pos['y']! + 1) / 2,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(iconInfo.icon, size: 10, color: iconInfo.color),
            ),
          ),
        );
      }
    }

    return icons;
  }

  // 辅助方法：获取图标数据
  _IconDataInfo _getIconInfo(CheckInModule module) {
    switch (module) {
      case CheckInModule.emo:
        return _IconDataInfo(Icons.mood_rounded, Colors.pinkAccent);
      case CheckInModule.sleep:
        return _IconDataInfo(Icons.nights_stay_rounded, Colors.indigo);
      case CheckInModule.eye:
        return _IconDataInfo(Icons.remove_red_eye_rounded, Colors.teal);
      case CheckInModule.normal:
        return _IconDataInfo(Icons.wb_sunny_rounded, Colors.orange);
      case CheckInModule.neck:
        return _IconDataInfo(Icons.accessibility_new_rounded, Colors.green);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            availableCalendarFormats: const {
              CalendarFormat.month: '月',
              CalendarFormat.twoWeeks: '双周',
              CalendarFormat.week: '周',
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(20.0),
              ),
              formatButtonTextStyle: const TextStyle(color: Colors.white),
            ),
            // 使用 calendarBuilders 自定义渲染每天的样式
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) =>
                  _buildCalendarCell(context, day, focusedDay),
              todayBuilder: (context, day, focusedDay) =>
                  _buildCalendarCell(context, day, focusedDay, isToday: true),
              selectedBuilder: (context, day, focusedDay) => _buildCalendarCell(
                context,
                day,
                focusedDay,
                isSelected: true,
              ),
              outsideBuilder: (context, day, focusedDay) {
                // 不在当前月份的日期样式
                return Center(
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// 辅助类：用于传递图标和颜色
class _IconDataInfo {
  final IconData icon;
  final Color color;
  _IconDataInfo(this.icon, this.color);
}
