import 'dart:convert';
import 'package:dio/dio.dart';
import '../utils/dio_client.dart';

class SparkService {
  static const String _baseUrl = String.fromEnvironment(
    'LLM_PROXY_URL',
    defaultValue:
        'https://qnowezjtbhashvlrrrit.supabase.co/functions/v1/llm-proxy',
  );
  static const int _maxAttempts = 2;
  static const Duration _streamReceiveTimeout = Duration(minutes: 5);

  static bool _shouldRetry(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return true;
    }
    if (e.type == DioExceptionType.badResponse) {
      final statusCode = e.response?.statusCode;
      return statusCode == 408 ||
          statusCode == 429 ||
          statusCode == 500 ||
          statusCode == 502 ||
          statusCode == 503 ||
          statusCode == 504;
    }
    return false;
  }

  /// 发起流式对话请求
  /// [messages] 格式: [{'role': 'user', 'content': '你好'}, ...]
  /// 返回一个 Stream，实时产出模型生成的字符串片段
  static Stream<String> streamChat(
    List<Map<String, String>> messages, {
    CancelToken? cancelToken,
  }) async* {
    final dio = DioClient().dio;

    final requestData = {
      "model": "lite", // 使用 lite 版本
      "messages": messages,
      "stream": true, // 开启流式返回
      // 移除 temperature，使用星火默认配置，避免部分模型版本不兼容该参数导致 10003 错误
    };

    for (int attempt = 1; attempt <= _maxAttempts; attempt++) {
      bool hasYieldedContent = false;
      try {
        final response = await dio.post(
          _baseUrl,
          data: requestData,
          cancelToken: cancelToken,
          options: Options(
            headers: {
              "Content-Type": "application/json",
              "Accept": "text/event-stream",
            },
            responseType: ResponseType.stream,
            receiveTimeout: _streamReceiveTimeout,
          ),
        );

        final rawStream = response.data.stream;
        final Stream<List<int>> byteStream = rawStream.map<List<int>>((chunk) {
          if (chunk is List<int>) {
            return chunk;
          } else {
            return List<int>.from(chunk as Iterable<dynamic>);
          }
        });

        final lineStream = byteStream
            .transform(utf8.decoder)
            .transform(const LineSplitter());
        final eventDataLines = <String>[];

        String? parseEventData() {
          if (eventDataLines.isEmpty) {
            return null;
          }
          final dataStr = eventDataLines.join('\n').trim();
          eventDataLines.clear();
          if (dataStr.isEmpty) {
            return null;
          }
          if (dataStr == '[DONE]') {
            return '[DONE]';
          }
          try {
            final jsonData = jsonDecode(dataStr);
            if (jsonData['code'] != null && jsonData['code'] != 0) {
              final code = jsonData['code'];
              final msg = jsonData['message'] ?? '未知错误';
              return "\n[星火接口报错: $code - $msg]";
            }
            final choices = jsonData['choices'] as List<dynamic>?;
            if (choices != null && choices.isNotEmpty) {
              final delta = choices[0]['delta'] as Map<String, dynamic>?;
              if (delta != null && delta.containsKey('content')) {
                final content = delta['content'];
                if (content is String && content.isNotEmpty) {
                  return content;
                }
              }
            }
          } catch (_) {}
          return null;
        }

        await for (final line in lineStream) {
          if (line.isEmpty) {
            final chunk = parseEventData();
            if (chunk == '[DONE]') {
              return;
            }
            if (chunk != null) {
              hasYieldedContent = true;
              yield chunk;
              if (chunk.startsWith('\n[星火接口报错:')) {
                return;
              }
            }
            continue;
          }
          if (line.startsWith('data:')) {
            final payload = line.substring(5).trimLeft();
            eventDataLines.add(payload);
          }
        }

        final remainingChunk = parseEventData();
        if (remainingChunk == '[DONE]') {
          return;
        }
        if (remainingChunk != null) {
          hasYieldedContent = true;
          yield remainingChunk;
        }
        return;
      } on DioException catch (e) {
        if (e.type == DioExceptionType.cancel) {
          return;
        }
        final canRetry =
            !hasYieldedContent && attempt < _maxAttempts && _shouldRetry(e);
        if (canRetry) {
          continue;
        }
        yield "\n[网络请求异常，请稍后重试]";
        return;
      } catch (_) {
        yield "\n[系统异常，请稍后重试]";
        return;
      }
    }
  }
}
