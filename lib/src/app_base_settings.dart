/// Интрфейс для настроек приложения
abstract class AppBaseSettings {
  /// Задержка запроса для разработчика
  static const developerDelay = 0;

  /// флаг логгирования http-запросов
  static const logRequest = false;

  /// флаг логгирования ошибок приложения
  static const logAppException = true;

  /// Таймаут запросов к АПИ, в секундах.
  static const apiRequestTimeout = 30;

  /// Таймаут запроса для загрузки файла
  static const apiRequestTimeoutFile = 300;

  /// URL API
  static const apiUrl = '';
}
