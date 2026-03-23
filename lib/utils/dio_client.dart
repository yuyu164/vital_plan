import 'package:dio/dio.dart';

class DioClient {
  // 单例模式
  static final DioClient _instance = DioClient._internal();
  late Dio _dio;

  factory DioClient() => _instance;

  DioClient._internal() {
    BaseOptions options = BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      responseType: ResponseType.json,
    );

    _dio = Dio(options);

    // 添加日志拦截器，方便调试
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
    ));

    // 自定义业务拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 可以在这里统一添加通用的 Header
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        // 统一错误处理
        print('Dio Error: ${e.message}');
        return handler.next(e);
      },
    ));
  }

  // 暴露 dio 实例供外部（如流式请求）使用
  Dio get dio => _dio;

  // 基础的 GET 请求封装
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) async {
    return await _dio.get(path, queryParameters: queryParameters, options: options);
  }

  // 基础的 POST 请求封装
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    return await _dio.post(path, data: data, queryParameters: queryParameters, options: options);
  }
}
