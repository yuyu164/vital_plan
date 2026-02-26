import 'package:flutter/material.dart';
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
        leading: GestureDetector(
          onTap: () {},
          child: Row(
            children: [
              Image.asset(
                "lib/assets/images/user_default_avator/wingtilldie-avatar-1577909_1920.png",
                width: 20,
                height: 20,
              ),
              Text("用户"),
            ],
          ),
        ),
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
