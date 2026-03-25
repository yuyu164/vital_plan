import 'package:flutter/material.dart';

class UserAgreementPage extends StatelessWidget {
  const UserAgreementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('用户协议'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text('''
【元气计划】用户协议
1. 服务说明
本APP集成【Spark Lite星火认知大模型】API服务，为用户提供AI对话、问答功能。AI生成内容仅供参考，不构成专业建议（法律/医疗/金融等）。

2. 用户行为规范
用户不得利用本服务输入违法、违规、侵权、危害他人安全的内容。
因用户输入内容产生的法律责任，由用户自行承担。

3. 服务限制
我们不保证AI回答的绝对准确性、完整性、及时性。
我们有权对违规使用行为暂停/终止服务。

4. API服务说明
本APP使用第三方AI模型服务，服务稳定性、响应速度受第三方接口影响。


          ''', style: const TextStyle(fontSize: 14, height: 1.6)),
      ),
    );
  }
}

// （建议使用长文本或引入 flutter_markdown 等库来渲染富文本内容）
