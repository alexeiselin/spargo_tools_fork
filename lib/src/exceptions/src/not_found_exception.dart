import 'package:spargo_tools/src/exceptions/src/app_base_exception.dart';

class NotFoundException extends AppBaseException {
  NotFoundException({required super.type, required super.message, super.stackTrace});
}
