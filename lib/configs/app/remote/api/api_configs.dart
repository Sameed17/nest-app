import 'package:dio/dio.dart';

class ApiConfigs {
  ApiConfigs({bool public = false}) : _public = public {
    _dio.options.connectTimeout = _connectTimeout;
    _dio.options.receiveTimeout = _receiveTimeout;
    _dio.options.sendTimeout = _sendTimeout;
  }

  final bool _public;
  final Dio _dio = Dio();

  final Duration _connectTimeout = const Duration(seconds: 20);
  final Duration _receiveTimeout = const Duration(seconds: 30);
  final Duration _sendTimeout = const Duration(seconds: 30);

  Dio get dioAdapter => _dio;

  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  bool get isPublic => _public;
}

class ApiManager {
  ApiManager._privateConstructor();

  final ApiConfigs apiConfigs = ApiConfigs();
  static final ApiManager instance = ApiManager._privateConstructor();
}

class ApiManagerPublic {
  ApiManagerPublic._privateConstructor();

  final ApiConfigs apiConfigs = ApiConfigs(public: true);
  static final ApiManagerPublic instance = ApiManagerPublic._privateConstructor();
}
