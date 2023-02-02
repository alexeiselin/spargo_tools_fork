import 'package:spargo_tools/src/exceptions/src/app_base_exception.dart';

class BadRequestException extends AppBaseException {
  const BadRequestException({
    required super.type,
    required super.message,
    required this.body,
    super.stackTrace,
  });

  final Map<String, dynamic>? body;

  @override
  String toString() => message;
}
