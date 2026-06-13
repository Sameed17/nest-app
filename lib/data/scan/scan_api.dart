import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:nest/configs/app/app_globals.dart';
import 'package:nest/configs/app/remote/api/api_endpoints.dart';

abstract class ScanApi {
  static final Dio _dio = AppGlobals.dio;

  static Future<String> submitCode({
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

  static Future<Uint8List> getStudentPhoto(String rollNumber) async {
    final Response<List<int>> response =
        await _dio.get<List<int>>(
      '/getfile/student/$rollNumber/image',
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );

    return Uint8List.fromList(response.data!);
  }
}

