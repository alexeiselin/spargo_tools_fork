import 'package:spargo_tools/src/exceptions/src/app_base_exception.dart';

class ForbiddenException extends AppBaseException {
  ForbiddenException({required super.type, required super.message, super.stackTrace});
}
