import 'exception_type.dart';

///Базовый класс ошибки в приложении
class AppBaseException implements Exception {
  const AppBaseException({
    required this.type,
    required this.message,
    this.stackTrace,
  });

  final ExceptionType type;
  final String message;
  final StackTrace? stackTrace;
}
