import 'package:flutter/material.dart';
import 'package:vital_plan/api/spark_service.dart';

class LLMChatWidget extends StatefulWidget {
  const LLMChatWidget({Key? key}) : super(key: key);

  @override
  _LLMChatWidgetState createState() => _LLMChatWidgetState();
}

class _LLMChatWidgetState extends State<LLMChatWidget> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 存储消息，格式兼容 OpenAI SDK: {'role': 'user'/'assistant'/'system', 'content': '...'}
  final List<Map<String, String>> _messages = [];

  bool _isGenerating = false; // 并发锁，防止重复发送

  // 设定的系统提示词，强制作为第一条上下文
  final Map<String, String> _systemPrompt = {
    'role': 'system',
    'content': '你是一个专为大学生服务的健康助手，你精通常规保健和中医知识，语气要温柔鼓励，回答尽量简短。',
  };

  // 获取用于请求上下文的消息列表，限制最大轮数防止 Token 超限
  List<Map<String, String>> _buildContextMessages() {
    // 假设我们只保留最近的 6 条消息（3轮对话）加上 system prompt
    const int maxHistoryLength = 6;
    List<Map<String, String>> context = [_systemPrompt];

    // 过滤掉当前正在生成的空 assistant 消息，因为星火 API 严格要求 content 不能为空！
    final validMessages = _messages
        .where((msg) => msg['content']!.isNotEmpty)
        .toList();

    if (validMessages.length > maxHistoryLength) {
      context.addAll(
        validMessages.sublist(validMessages.length - maxHistoryLength),
      );
    } else {
      context.addAll(validMessages);
    }
    return context;
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() async {
    if (_isGenerating) return; // 如果正在生成，直接拦截

    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // 限制单次输入长度
    if (text.length > 1000) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('输入内容过长，请精简后再试。')));
      return;
    }

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      // 预先插入一条空的助手回复，准备接收流式数据
      _messages.add({'role': 'assistant', 'content': ''});
      _isGenerating = true;
    });

    _textController.clear();

    // 等待 UI 渲染出新的空气泡后滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    try {
      final contextMessages = _buildContextMessages();
      print('Sending context: $contextMessages'); // 打印请求参数以便调试
      final stream = SparkService.streamChat(contextMessages);

      await for (final chunk in stream) {
        if (!mounted) break;
        setState(() {
          // 实时将新的片段追加到最后一条消息的 content 中
          _messages.last['content'] = (_messages.last['content'] ?? '') + chunk;
        });
        // 每次更新都尝试滚动到底部（打字机跟随效果）
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.last['content'] =
              (_messages.last['content'] ?? '') + "\n[发生错误，请稍后重试]";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 聊天区域
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return _buildMessageBubble(msg['content']!, isUser);
              },
            ),
          ),
          // 输入区域
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16.0),
              ),
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: "有什么想和我聊聊的吗...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 10.0,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).primaryColor.withOpacity(0.9)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16.0),
            topRight: const Radius.circular(16.0),
            bottomLeft: isUser
                ? const Radius.circular(16.0)
                : const Radius.circular(0),
            bottomRight: isUser
                ? const Radius.circular(0)
                : const Radius.circular(16.0),
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }
}
