import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vital_plan/api/auth_service.dart';
import 'package:vital_plan/components/mianPageWidget/second_row.dart';
import 'package:vital_plan/pages/Game/index.dart';
// import 'package:vital_plan/pages/Login/index.dart';
import 'package:vital_plan/components/mianPageWidget/first_row.dart';
import 'package:vital_plan/components/mianPageWidget/recommend_card.dart';
import 'package:vital_plan/components/mianPageWidget/third_row.dart';
// import 'package:vital_plan/components/common/coin_badge.dart';
import 'package:vital_plan/components/common/exp_badge.dart'; // 引入新的经验值徽章
import 'package:vital_plan/components/main_page/main_page_background.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return MainPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent, // 必须透明，否则会遮挡背景
        appBar: AppBar(
          backgroundColor: Colors.transparent, // 透明 AppBar
          elevation: 0,
          centerTitle: true,
          title: Text(
            "元气计划",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.settings, color: Colors.black87),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          // leading: Consumer<AuthService>(
          //   builder: (context, auth, _) {
          //     return GestureDetector(
          //       onTap: () {
          //         if (auth.isLoggedIn) {
          //           // 已登录：显示注销弹窗
          //           showDialog(
          //             context: context,
          //             builder: (context) => AlertDialog(
          //               title: Text("提示"),
          //               content: Text("是否注销登录？"),
          //               actions: [
          //                 TextButton(
          //                   onPressed: () => Navigator.pop(context),
          //                   child: Text(
          //                     "取消",
          //                     style: TextStyle(color: Colors.grey),
          //                   ),
          //                 ),
          //                 TextButton(
          //                   onPressed: () {
          //                     auth.logout();
          //                     Navigator.pop(context); // 关闭弹窗
          //                   },
          //                   child: Text(
          //                     "确定",
          //                     style: TextStyle(color: Colors.redAccent),
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           );
          //         } else {
          //           // 未登录：跳转登录页
          //           Navigator.of(context).push(
          //             MaterialPageRoute(builder: (context) => LoginPage()),
          //           );
          //         }
          //       },
          //       child: Row(
          //         children: [
          //           SizedBox(width: 8),
          //           CircleAvatar(
          //             radius: 14,
          //             backgroundImage: AssetImage(
          //               "lib/assets/images/user_default_avator/wingtilldie-avatar-1577909_1920.png",
          //             ),
          //           ),
          //           SizedBox(width: 4),
          //           Expanded(
          //             child: Text(
          //               auth.nickname,
          //               style: TextStyle(fontSize: 12, color: Colors.black87),
          //               overflow: TextOverflow.ellipsis,
          //             ),
          //           ),
          //         ],
          //       ),
          //     );
          //   },
          // ),
          // leadingWidth: 100, // 增加 leading 宽度以容纳头像和昵称
          // actions: [CoinBadge()],
          actions: [const ExpBadge()], // 在原来放 CoinBadge 的地方放 ExpBadge
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: Column(
              children: [
                // 1. 顶部推荐卡片 (固定高度或比例)
                RecommendDart(),
                SizedBox(height: 10),

                // 2. 第一行板块 (自适应高度)
                Expanded(flex: 2, child: FirstRow()),
                SizedBox(height: 10),

                //2.第二行板块（自适应高度）
                Expanded(flex: 2, child: SecondRow()),
                SizedBox(height: 10),

                // 3. 第三行板块 (自适应高度)
                Expanded(flex: 2, child: ThirdRow()),
                SizedBox(height: 10),

                // 4. 底部游戏入口 (固定高度)
                Container(
                  height: 80,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF2C3E50),
                        Color(0xFF4CA1AF),
                      ], // 星空深蓝 -> 极光蓝
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF2C3E50).withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => GamePage()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "🎮 探索草木层生小游戏",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "解压合成独特画卷",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white,
                                size: 20,
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
      ),
    );
  }
}
