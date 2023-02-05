import 'dart:async';

import 'package:spargo_tools/src/exceptions/src/app_base_exception.dart';
import 'package:spargo_tools/src/exceptions/src/exception_type.dart';
import 'package:spargo_tools/src/exceptions/src/request_canceled_exception.dart';

class CancelCompleter {
  CancelCompleter() {
    _completer = Completer();
  }

  late Completer<AppBaseException> _completer;

  AppBaseException? _cancelError;
  AppBaseException? get cancelError => _cancelError;
  bool get isCanceled => _cancelError != null;

  Future<AppBaseException> get whenCanceled => _completer.future;

  void cancel() {
    _cancelError = RequestCanceledException(
      type: ExceptionType.manual,
      message: 'Запрос был отменен вручную',
      stackTrace: StackTrace.current,
    );
    if (!_completer.isCompleted) {
      _completer.complete(_cancelError);
    }
  }
}
