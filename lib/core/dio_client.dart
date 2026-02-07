import 'package:dio/dio.dart';

class DioClient {
  static Dio? _dio;

  static Dio getInstance() {
    if (_dio == null) {
      _dio = Dio(BaseOptions(
        baseUrl: '你的小说接口地址', // 比如测试用的开源接口
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      // 添加拦截器（打印日志、处理错误）
      _dio!.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          print('请求：${options.uri}');
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          print('网络错误：${e.message}');
          return handler.next(e);
        },
      ));
    }
    return _dio!;
  }
}