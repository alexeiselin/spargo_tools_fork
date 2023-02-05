/// Интрфейс для настроек приложения
abstract class IAppSettings {
  /// Задержка запроса для разработчика
  int get developerDelay;

  /// флаг логгирования http-запросов
  bool get logRequest;

  /// флаг логгирования ошибок приложения
  bool get logAppException;

  /// Таймаут запросов к АПИ, в секундах.
  int get apiRequestTimeout;

  /// Таймаут запроса для загрузки файла
  int get apiRequestTimeoutFile;

  /// URL API
  String get apiUrl;
}

class AppBaseSettings implements IAppSettings {
  /// Задержка запроса для разработчика
  @override
  final developerDelay = 0;

  /// флаг логгирования http-запросов
  @override
  final logRequest = false;

  /// флаг логгирования ошибок приложения
  @override
  final logAppException = true;

  /// Таймаут запросов к АПИ, в секундах.
  @override
  final apiRequestTimeout = 30;

  /// Таймаут запроса для загрузки файла
  @override
  final apiRequestTimeoutFile = 300;

  /// URL API
  @override
  final apiUrl = '';
}
