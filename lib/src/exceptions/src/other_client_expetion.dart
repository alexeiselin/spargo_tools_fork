import 'package:spargo_tools/src/exceptions/src/app_base_exception.dart';

class OtherClientException extends AppBaseException {
  OtherClientException({required super.type, required super.message, super.stackTrace});
}
