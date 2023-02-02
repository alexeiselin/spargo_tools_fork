import 'package:spargo_tools/src/exceptions/src/app_base_exception.dart';

class NoCacheDataException extends AppBaseException {
  NoCacheDataException({required super.type, required super.message, super.stackTrace});
}
