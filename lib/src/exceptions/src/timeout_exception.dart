import 'package:spargo_tools/src/exceptions/src/app_base_exception.dart';

class ServerTimeoutException extends AppBaseException {
  ServerTimeoutException({required super.type, required super.message, super.stackTrace});

  @override
  String toString() {
    return '${super.toString()} message: $message';
  }
}
