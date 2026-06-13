import 'package:dio/dio.dart';

const String _defaultBaseUrl = 'http://10.0.2.2:3000/api';

Dio createApiClient({String? baseUrl}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl ?? const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: _defaultBaseUrl,
      ),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ),
  );

  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    logPrint: (o) => debugPrint(o.toString()),
  ));

  return dio;
}

void debugPrint(String message) {
  assert(() {
    // ignore: avoid_print
    print('[API] $message');
    return true;
  }());
}
