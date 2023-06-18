import 'package:dio/dio.dart';

import 'base_dio_form_request.dart';
import 'base_dio_request.dart';

class DioClient {
  DioClient._();
  static DioClient? _instance;
  factory DioClient() {
    _instance ??= DioClient._();
    return _instance!;
  }
  final Dio _dio = Dio();

  Future<Response> request({
    required BaseDioRequest request,
    String? authToken,
    String? cookie,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    final headers = {
      'Accept': '*/*',
      'Content-Type': request.contentType,
      if (authToken != null) 'Authorization': authToken,
      if (cookie != null) 'Cookie': cookie,
    };
    final options = Options(
      headers: headers,
      method: request.requestType.stringSignature,
      sendTimeout: request.timeout,
      receiveTimeout: request.timeout,
    );
    FormData? formData;
    if (request is BaseDioFormRequest) {
      formData = FormData.fromMap(request.getBodyParams());
      formData.files.addAll(request.files.map((e) => MapEntry(e.fieldName,
          MultipartFile.fromBytes(e.bytes, filename: e.nameFile))));
    }
    try {
      final response = await _dio.request(
        request.fullUrl,
        data: formData ?? request.getBodyParams(),
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e, stackTrace) {
      print('DioClient in method request');
      print('Log: DioException - $e');
      rethrow;
    }
  }
}
