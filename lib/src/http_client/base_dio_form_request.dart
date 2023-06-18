import 'package:dio/dio.dart';

import 'base_dio_request.dart';

class FormDioRequestFile {
  const FormDioRequestFile({
    required this.bytes,
    required this.nameFile,
    required this.fieldName,
  });
  final List<int> bytes;
  final String nameFile;
  final String fieldName;
}

abstract class BaseDioFormRequest implements BaseDioRequest {
  List<FormDioRequestFile> get files;

  @override
  String get contentType => Headers.multipartFormDataContentType;
}
