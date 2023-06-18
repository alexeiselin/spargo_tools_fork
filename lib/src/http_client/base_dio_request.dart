import 'package:dio/dio.dart';

enum RequestDioType {
  get('GET'),
  post('POST'),
  put('PUT'),
  delete('DELETE');

  final String stringSignature;
  const RequestDioType(this.stringSignature);
}

abstract class BaseDioRequest {
  String get hostUrl;
  String get apiUrl;
  String get fullUrl {
    var mainUrl = '$hostUrl$apiUrl';
    final queryParams = getQueryParams();
    bool isFirstParam = true;
    for (final param in queryParams.entries) {
      final symbol = isFirstParam ? '?' : '&';
      mainUrl += '$symbol${param.key}=${param.value}';
      if (isFirstParam) {
        isFirstParam = false;
      }
    }
    return mainUrl;
  }

  Map<String, dynamic> getQueryParams();
  Map<String, dynamic> getBodyParams();
  RequestDioType get requestType;
  String contentType = Headers.jsonContentType;
  Duration timeout = const Duration(seconds: 30);
}
