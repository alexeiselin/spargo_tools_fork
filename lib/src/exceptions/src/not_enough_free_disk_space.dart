import 'package:spargo_tools/src/exceptions/src/app_base_exception.dart';

class NotEnoughFreeDiskSpace extends AppBaseException {
  NotEnoughFreeDiskSpace({required super.type, required super.message, super.stackTrace});
}
