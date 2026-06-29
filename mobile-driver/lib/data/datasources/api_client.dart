import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

const String _defaultBaseUrl = 'http://10.0.2.2:3000/api';

Dio createApiClient() {
  const baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: _defaultBaseUrl);
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    contentType: 'application/json',
  ));

  // Fecha conexões TCP ociosas rapidamente. Evita reaproveitar sockets mortos
  // pelo túnel (adb reverse / NAT do emulador), que causavam timeouts no polling.
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.idleTimeout = const Duration(seconds: 1);
      return client;
    },
  );

  return dio;
}
