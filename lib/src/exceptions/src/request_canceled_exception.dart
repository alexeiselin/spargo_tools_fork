import 'package:spargo_tools/src/exceptions/src/app_base_exception.dart';

class RequestCanceledException extends AppBaseException {
  RequestCanceledException(
      {required super.type, required super.message, super.stackTrace});
}
