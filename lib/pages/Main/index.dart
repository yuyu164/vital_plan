import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vital_plan/api/auth_service.dart';
import 'package:vital_plan/pages/Login/index.dart';
import 'package:vital_plan/components/mianPageWidget/first_row.dart';
import 'package:vital_plan/components/mianPageWidget/recommend_card.dart';
import 'package:vital_plan/components/mianPageWidget/second_row.dart';
import 'package:vital_plan/components/common/coin_badge.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("元气计划"),
        leading: Consumer<AuthService>(
          builder: (context, auth, _) {
            return GestureDetector(
              onTap: () {
                if (auth.isLoggedIn) {
                  // 已登录：显示注销弹窗
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("提示"),
                      content: Text("是否注销登录？"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "取消",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            auth.logout();
                            Navigator.pop(context); // 关闭弹窗
                          },
                          child: Text(
                            "确定",
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  // 未登录：跳转登录页
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => LoginPage()));
                }
              },
              child: Row(
                children: [
                  SizedBox(width: 8),
                  CircleAvatar(
                    radius: 14,
                    backgroundImage: AssetImage(
                      "lib/assets/images/user_default_avator/wingtilldie-avatar-1577909_1920.png",
                    ),
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      auth.nickname,
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        leadingWidth: 100, // 增加 leading 宽度以容纳头像和昵称
        actions: [CoinBadge()],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            children: [
              // 1. 顶部推荐卡片 (固定高度或比例)
              RecommendDart(),
              SizedBox(height: 16),

              // 2. 第一行板块 (自适应高度)
              Expanded(flex: 3, child: FirstRow()),
              SizedBox(height: 16),

              // 3. 第二行板块 (自适应高度)
              Expanded(flex: 2, child: SecondRow()),
              SizedBox(height: 16),

              // 4. 底部游戏入口 (固定高度)
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  "游戏入口",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
