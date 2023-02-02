import 'package:spargo_tools/src/exceptions/src/app_base_exception.dart';

class NoInternetException extends AppBaseException {
  NoInternetException({required super.type, required super.message, super.stackTrace});

  @override
  String toString() {
    return 'Проверьте подключение к интернету';
  }
}
