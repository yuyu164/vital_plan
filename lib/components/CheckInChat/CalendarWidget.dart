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
      border = null; // 选中时不显示打卡边框
    } else if (isToday) {
      if (!hasRecord) {
        bgColor = Colors.orangeAccent.withOpacity(0.2); // 没打卡时今天的背景色
      }
      border = Border.all(color: Colors.orange, width: 2); // 今天的橙色边框
      textColor = hasRecord ? Colors.green.shade800 : Colors.orange.shade800;
      fontWeight = FontWeight.bold;
    }

    // 渲染日期数字的中心容器
    Widget dayContainer = Container(
      margin: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: border,
      ),
      alignment: Alignment.center,
      child: Text(
        '${date.day}',
        style: TextStyle(color: textColor, fontWeight: fontWeight),
      ),
    );

    // 如果没有打卡记录，直接返回日期容器
    if (!hasRecord) {
      return dayContainer;
    }

    // 如果有打卡记录，在四个角渲染对应板块的图标
    List<Widget> icons = [];
    final positions = [
      {'top': 2.0, 'left': 2.0},
      {'top': 2.0, 'right': 2.0},
      {'bottom': 2.0, 'left': 2.0},
      {'bottom': 2.0, 'right': 2.0},
    ];

    for (int i = 0; i < modules.length && i < 4; i++) {
      final module = modules[i];
      IconData iconData;
      Color iconColor;
      switch (module) {
        case CheckInModule.emo:
          iconData = Icons.mood_rounded;
          iconColor = Colors.pinkAccent;
          break;
        case CheckInModule.sleep:
          iconData = Icons.nights_stay_rounded;
          iconColor = Colors.indigo;
          break;
        case CheckInModule.eye:
          iconData = Icons.remove_red_eye_rounded;
          iconColor = Colors.teal;
          break;
        case CheckInModule.normal:
          iconData = Icons.wb_sunny_rounded;
          iconColor = Colors.orange;
          break;
        case CheckInModule.neck:
          iconData = Icons.accessibility_new_rounded;
          iconColor = Colors.green;
          break;
      }

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
            child: Icon(iconData, size: 12, color: iconColor),
          ),
        ),
      );
    }

    return Stack(children: [dayContainer, ...icons]);
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
