import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:flutter/foundation.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: 'https://httpbin.org')
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @GET('/get')
  Future<Map<String, dynamic>> ping();
}

Dio createDio() {
  final dio = Dio(BaseOptions(receiveTimeout: const Duration(seconds: 20)));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (o, handler) {
        if (kDebugMode) debugPrint('[DIO] => ${o.method} ${o.uri}');
        handler.next(o);
      },
      onError: (e, handler) {
        if (kDebugMode) debugPrint('[DIO][E] ${e.message}');
        handler.next(e);
      },
    ),
  );
  return dio;
}

