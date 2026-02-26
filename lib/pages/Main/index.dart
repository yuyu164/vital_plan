import 'package:flutter/material.dart';
import 'package:vital_plan/components/mianPageWidget/first_row.dart';
import 'package:vital_plan/components/mianPageWidget/recommend_card.dart';
import 'package:vital_plan/components/mianPageWidget/second_row.dart';

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
        actions: [
          Text("金币"),
          SizedBox(width: 10),
          Image.asset(
            "lib/assets/images/coin/honest_graphic-money-bag-9772256_1920.png",
            width: 20,
            height: 20,
          ),
        ],
      ),
      body: Flex(
        direction: Axis.vertical,
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              RecommendDart(),
              SizedBox(height: 10),
              FirstRow(),
              SizedBox(height: 10),
              SecondRow(),
              SizedBox(height: 10),
              Container(height: 100, color: Colors.red, child: Text("游戏入口")),
            ],
          ),
        ],
      ),
    );
  }
}
