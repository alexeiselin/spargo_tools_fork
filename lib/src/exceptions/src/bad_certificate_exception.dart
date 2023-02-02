import 'package:spargo_tools/src/exceptions/src/app_base_exception.dart';

class BadCertificateException extends AppBaseException {
  BadCertificateException({required super.type, required super.message, super.stackTrace});
}
