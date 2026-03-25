import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('隐私政策'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text('''
【元气计划】隐私政策
1. 我们收集的信息
- 用户与AI对话的文本内容（用于发送至SparkLite API获取回答）
- 设备基础信息/网络信息（用于APP运行与服务稳定性）

2. 信息使用与共享
用户对话内容仅用于调用星火认知大模型API生成回答，不会用于其他用途。
我们会将必要的对话数据传输给【讯飞星火】服务商，用于提供AI服务。

3. 数据安全
我们采取安全措施保护用户数据，不向无关第三方泄露。

4. 用户权利
用户可停止使用服务，不再产生新的对话数据。
          ''', style: const TextStyle(fontSize: 14, height: 1.6)),
      ),
    );
  }
}
