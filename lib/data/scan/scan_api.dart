import 'package:dio/dio.dart';
import 'package:nest/configs/app/remote/api/api_endpoints.dart';

class ScanApi {
  const ScanApi({
    required Dio dio,
  }) : _dio = dio;

  final Dio _dio;

  Future<String> submitCode({
    required String code,
    required String contextLabel,
    required String endpoint,
  }) async {
    final Response<dynamic> res = await _dio.post<dynamic>(
      XEndpoint.scanHostelMessEndpoint,
      data: <String, dynamic>{
        'code': code,
        'context': contextLabel,
      },
    );

    final dynamic data = res.data;
    if (data is String) {
      return data;
    }
    if (data is Map<String, dynamic>) {
      final dynamic html = data['html'];
      if (html is String) {
        return html;
      }
      final dynamic message = data['message'];
      if (message is String) {
        return message;
      }
    }
    return data?.toString() ?? '';
  }
}

