import 'package:flutter_test/flutter_test.dart';
import 'package:spargo_tools/src/exceptions/src/request_canceled_exception.dart';
import 'package:spargo_tools/src/http_client/cancel_completer.dart';

void main() {
  test('Test Cancel Completer', () {
    final cancelCompleter = CancelCompleter();
    expect(cancelCompleter.isCanceled, false);
    expect(cancelCompleter.cancelError, null);
    cancelCompleter.whenCanceled.then((e) {
      expect(e.runtimeType, RequestCanceledException);
    });
    cancelCompleter.cancel();

    expect(cancelCompleter.isCanceled, true);
    expect(cancelCompleter.cancelError.runtimeType, RequestCanceledException);
  });
}
