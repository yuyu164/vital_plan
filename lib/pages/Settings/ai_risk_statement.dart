import 'package:flutter/material.dart';

class AiRiskStatementPage extends StatelessWidget {
  const AiRiskStatementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI服务风险声明'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text('''
AI服务声明
1. 本工具基于Spark Lite星火认知大模型提供，生成内容由AI模型自动产生，不代表本APP立场。

2. AI回答可能存在错误、偏差，请勿直接用于法律、医疗、投资等重要决策。

3. 请勿输入隐私信息（身份证、手机号、住址、密码等）。

4. 如使用AI内容造成损失，本APP不承担相关责任。
          ''', style: const TextStyle(fontSize: 14, height: 1.6)),
      ),
    );
  }
}
