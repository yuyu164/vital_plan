import 'dart:convert';
import 'package:dio/dio.dart';
import '../utils/dio_client.dart';

class SparkService {
  // 替换为您在讯飞开放平台申请的真实 APIPassword
  static const String _apiPassword =
      "SECRET";

  // 兼容 OpenAI SDK 格式的星火统一 HTTP 调用地址
  static const String _baseUrl =
      "https://spark-api-open.xf-yun.com/v1/chat/completions";

  /// 发起流式对话请求
  /// [messages] 格式: [{'role': 'user', 'content': '你好'}, ...]
  /// 返回一个 Stream，实时产出模型生成的字符串片段
  static Stream<String> streamChat(List<Map<String, String>> messages) async* {
    final dio = DioClient().dio;

    final requestData = {
      "model": "lite", // 使用 lite 版本
      "messages": messages,
      "stream": true, // 开启流式返回
      // 移除 temperature，使用星火默认配置，避免部分模型版本不兼容该参数导致 10003 错误
    };

    try {
      final response = await dio.post(
        _baseUrl,
        data: requestData,
        options: Options(
          headers: {
            "Authorization": "Bearer $_apiPassword",
            "Content-Type": "application/json",
            "Accept": "text/event-stream",
          },
          // 必须设置为 stream
          responseType: ResponseType.stream,
        ),
      );

      // 获取原始 stream 并做兼容处理
      final rawStream = response.data.stream;

      // 不管是 List<int> 还是 Uint8List，都可以映射为普通的 List<int>
      // 必须显式指定 map 的泛型类型为 <List<int>>，否则 Dart 推导为 dynamic
      final Stream<List<int>> byteStream = rawStream.map<List<int>>((chunk) {
        if (chunk is List<int>) {
          return chunk;
        } else {
          return List<int>.from(chunk as Iterable<dynamic>);
        }
      });

      // 使用 LineSplitter 来确保我们拿到的是完整的行
      final lineStream = byteStream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in lineStream) {
        print("Received line: $line"); // 增加调试日志，查看是否收到了数据
        if (line.startsWith('data: ')) {
          final dataStr = line.substring(6).trim();
          if (dataStr == '[DONE]') {
            // 流结束
            return;
          }
          if (dataStr.isNotEmpty) {
            try {
              final jsonData = jsonDecode(dataStr);

              // 检查是否有星火返回的错误码
              if (jsonData['code'] != null && jsonData['code'] != 0) {
                final code = jsonData['code'];
                final msg = jsonData['message'] ?? '未知错误';
                yield "\n[星火接口报错: $code - $msg]";
                return;
              }

              final choices = jsonData['choices'] as List<dynamic>?;
              if (choices != null && choices.isNotEmpty) {
                final delta = choices[0]['delta'] as Map<String, dynamic>?;
                if (delta != null && delta.containsKey('content')) {
                  final content = delta['content'] as String;
                  yield content; // 产出一段文本
                }
              }
            } catch (e) {
              print("解析流片段失败: $e, data: $dataStr");
            }
          }
        }
      }
    } on DioException catch (e) {
      print("Dio 请求异常: ${e.message}");
      if (e.response != null) {
        print("Dio 响应状态码: ${e.response?.statusCode}");
        print("Dio 响应数据: ${e.response?.data}");
      }
      yield "\n[网络请求异常，请稍后重试。详情: ${e.message}]";
    } catch (e) {
      print("发生未知异常: $e");
      yield "\n[系统异常，请稍后重试]";
    }
  }
}
