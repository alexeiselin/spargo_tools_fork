import 'package:spargo_tools/src/exceptions/src/app_base_exception.dart';

class UnknownException extends AppBaseException {
  UnknownException({required super.type, required super.message, super.stackTrace});
}
