import 'package:flutter/material.dart';
import 'package:vital_plan/api/check_in_service.dart';
import 'package:vital_plan/api/coin_service.dart';
import 'package:vital_plan/components/common/charge_button.dart';
import 'package:vital_plan/pages/Reward/index.dart';
import 'package:vital_plan/utils/image_dialog_utils.dart'; // 引入图片弹窗工具类
import 'emo_data.dart'; // 引入刚才创建的静态数据
import '../../components/main_page/main_page_background.dart'; // 复用主页背景

class EmoPage extends StatefulWidget {
  EmoPage({Key? key}) : super(key: key);

  @override
  _EmoPageState createState() => _EmoPageState();
}

class _EmoPageState extends State<EmoPage> {
  // 当前选中的情绪索引，默认选中第一个（"喜"）
  int _selectedIndex = 0;
  final CoinService _coinService = CoinService();

  @override
  Widget build(BuildContext context) {
    // 获取当前选中的情绪数据
    final currentData = emoDataList[_selectedIndex];

    return MainPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent, // 必须透明以显示底层背景
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "情绪调理",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          iconTheme: IconThemeData(color: Colors.black87),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 引导语
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                child: Text(
                  "此刻的你，遇到了什么烦恼？",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              // 2. 情绪选择器 (横向滑动的高级卡片)
              Container(
                height: 100,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: emoDataList.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedIndex;
                    final emotion = emoDataList[index].emotion;

                    // 为每种情绪分配一个基础色调
                    Color cardColor = isSelected
                        ? _getEmotionColor(emotion)
                        : Colors.white;
                    Color textColor = isSelected
                        ? Colors.white
                        : Colors.black54;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 250),
                        margin: EdgeInsets.only(right: 16, bottom: 10, top: 5),
                        width: 70,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? cardColor.withOpacity(0.4)
                                  : Colors.black.withOpacity(0.05),
                              blurRadius: isSelected ? 12 : 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                          border: isSelected
                              ? null
                              : Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getEmotionEmoji(emotion),
                              style: TextStyle(fontSize: 28),
                            ),
                            SizedBox(height: 4),
                            Text(
                              emotion,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 3. 详情卡片
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: _getEmotionColor(
                            currentData.emotion,
                          ).withOpacity(0.15),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 核心情绪标题
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _getEmotionColor(
                                    currentData.emotion,
                                  ).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.favorite_rounded,
                                  color: _getEmotionColor(currentData.emotion),
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  currentData.coreSymptom,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),

                          // 辅助症状
                          Text(
                            "常见表现：${currentData.assistSymptom}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              height: 1.5,
                            ),
                          ),

                          Divider(height: 40, color: Colors.grey.shade200),

                          // 经络信息
                          Text(
                            "调理经络",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.waves,
                                  size: 16,
                                  color: Colors.blueGrey,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  currentData.meridian,
                                  style: TextStyle(
                                    color: Colors.blueGrey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 24),

                          // 穴位推荐
                          Text(
                            "推荐按揉穴位",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              _buildAcupointCard(
                                context,
                                "原穴",
                                currentData.primaryAcupoint,
                                currentData.emotion,
                              ),
                              SizedBox(width: 12),
                              _buildAcupointCard(
                                context,
                                "输穴",
                                currentData.secondaryAcupoint,
                                currentData.emotion,
                              ),
                            ],
                          ),

                          SizedBox(height: 40),

                          // 底部打卡按钮
                          Center(
                            child: Column(
                              children: [
                                ChargeButton(
                                  rewardCoins: 30, // 情绪打卡默认给 30 金币
                                  isHardAction: false,
                                  onCompleted: () async {
                                    // 添加金币
                                    await _coinService.addCoins(30);
                                    // 记录打卡
                                    await CheckInService.addCheckInRecord(
                                      DateTime.now(),
                                      CheckInModule.emo,
                                    );
                                    // 跳转奖励页
                                    if (mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RewardPage(earnedCoins: 30),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: Text(
                                    "长按 1.2s 完成情绪调理打卡",
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
      ),
    );
  }

  // 辅助方法：构建穴位小卡片
  Widget _buildAcupointCard(
    BuildContext context,
    String label,
    String acupointName,
    String emotion,
  ) {
    Color themeColor = _getEmotionColor(emotion);

    // 根据穴位名称匹配对应的图片路径
    String imageUrl = "";
    switch (acupointName) {
      case "神门":
        imageUrl = "lib/assets/images/acupoints/shenmen_daling_taiyuan.png";
        break;
      case "太冲":
        imageUrl = "lib/assets/images/acupoints/taichong.png";
        break;
      case "太渊":
        imageUrl = "lib/assets/images/acupoints/shenmen_daling_taiyuan.png";
        break;
      case "太白":
        imageUrl = "lib/assets/images/acupoints/taibai_taixi.png";
        break;
      case "大陵":
        imageUrl = "lib/assets/images/acupoints/shenmen_daling_taiyuan.png";
        break;
      case "太溪":
        imageUrl = "lib/assets/images/acupoints/taibai_taixi.png";
        break;
      case "丘墟":
        imageUrl = "lib/assets/images/acupoints/zulinqi_qiuxu.png";
        break;
      case "足临泣":
        imageUrl = "lib/assets/images/acupoints/zulinqi_qiuxu.png";
        break;
      default:
        imageUrl = ""; // 默认不显示或使用占位图
        break;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          ImageDialogUtils.showAcupointImageDialog(
            context,
            acupointName,
            imageUrl,
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: themeColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: themeColor.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: themeColor.withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                acupointName,
                style: TextStyle(
                  fontSize: 18,
                  color: themeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 辅助方法：根据情绪返回主题色
  Color _getEmotionColor(String emotion) {
    switch (emotion) {
      case "喜":
        return Colors.pinkAccent;
      case "怒":
        return Colors.redAccent;
      case "忧":
        return Colors.indigoAccent;
      case "思":
        return Colors.orangeAccent;
      case "悲":
        return Colors.blueAccent;
      case "恐":
        return Colors.teal;
      case "惊":
        return Colors.purpleAccent;
      default:
        return Colors.deepPurpleAccent;
    }
  }

  // 辅助方法：根据情绪返回 Emoji
  String _getEmotionEmoji(String emotion) {
    switch (emotion) {
      case "喜":
        return "😊";
      case "怒":
        return "😠";
      case "忧":
        return "😔";
      case "思":
        return "🤔";
      case "悲":
        return "😢";
      case "恐":
        return "😨";
      case "惊":
        return "😲";
      default:
        return "😐";
    }
  }
}
