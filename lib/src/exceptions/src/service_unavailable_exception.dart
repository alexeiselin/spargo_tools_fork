import 'package:spargo_tools/src/exceptions/src/app_base_exception.dart';

class ServiceUnavailableExcecption extends AppBaseException {
  ServiceUnavailableExcecption({required super.type, required super.message, super.stackTrace});
}
