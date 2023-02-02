import 'package:spargo_tools/src/exceptions/src/app_base_exception.dart';

class ServerException extends AppBaseException {
  ServerException({required super.type, required super.message, super.stackTrace});

  @override
  String toString() {
    return 'Сервер недоступен';
  }
}
