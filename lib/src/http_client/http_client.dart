import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:l/l.dart';
import 'package:spargo_tools/src/http_client/cancel_completer.dart';
import 'package:spargo_tools/src/shared_preferences_base_repository.dart';

import '../app/app_base_settings.dart';
import '../exceptions/exceptions.dart';

enum RequestType { get, post, put, delete }

abstract class AppHttp {
  static Future<Response> apiHttpRequest(
    String url, {
    dynamic data,
    String? basicUrl,
    bool isXwwwForm = false,
    bool abortOnBadRequest = true,
    String? cookie,
    int? timeout,
    String? contentType,
    bool checkToken = true,
    RequestType type = RequestType.get,
    CancelCompleter? cancelCompleter,
    String? authorizationToken,
  }) async {
    if (AppBaseSettings().developerDelay > 0) {
      await Future.delayed(const Duration());
    }
    // URI
    final uri = Uri.parse(
      Uri.encodeFull((basicUrl ?? AppBaseSettings().apiUrl) + url).replaceAll('+', '%2B'),
    );
    // Body
    String body = '';
    if (isXwwwForm && data != null) {
      final listItems = [];
      (data as Map<String, dynamic>).forEach((key, value) {
        final valueEncoded = Uri.encodeFull(value.toString()).replaceAll('+', '%2B');
        listItems.add('$key=$valueEncoded');
      });
      body = listItems.join('&');
    } else {
      body = jsonEncode(data);
    }

    if (AppBaseSettings().logRequest) {
      log(uri.toString());
      log(body);
    }

    // Headers
    final headers = <String, String>{
      'Accept': '*/*',
      'Content-Type': isXwwwForm ? 'application/x-www-form-urlencoded' : contentType ?? ContentType.json.toString(),
      'Authorization': authorizationToken ??
          await SharedPreferencesBaseRepository.getToken() ??
          '', // TODO: Желательно убрать зависимость на SharedPreferencesBaseRepository, т.к. может быть несколько токенов для для разных api, прокинул authorizationToken
      if (cookie != null) 'Cookie': cookie,
    };
    if (AppBaseSettings().logRequest) {
      log(headers.toString());
    }
    final httpClient = http.Client();
    try {
      late Future<Response> request;
      switch (type) {
        case RequestType.get:
          request = httpClient.get(uri, headers: headers);
          break;
        case RequestType.post:
          request = httpClient.post(uri, headers: headers, body: body);
          break;
        case RequestType.put:
          request = httpClient.put(uri, headers: headers, body: body);
          break;
        case RequestType.delete:
          request = httpClient.delete(uri, headers: headers, body: body);
          break;
      }

      //Проверяем жизнеспособность токена перед запросом
      if (checkToken) {
        await checkUserToken();
      }

      final response = await Future.any([
        if (cancelCompleter != null) cancelCompleter.whenCanceled.then((value) => throw (value)),
        request.timeout(
          Duration(seconds: timeout ?? AppBaseSettings().apiRequestTimeout),
          onTimeout: () {
            throw ServerTimeoutException(message: '', type: ExceptionType.timeout, stackTrace: StackTrace.fromString(request.toString()));
          },
        )
      ]);
      if (AppBaseSettings().logRequest) {
        l.i(response.body);
      }
      handleApiError(response, abortOnBadRequest);
      httpClient.close();
      return response;
    } on SocketException catch (e, stackTrace) {
      l.e(e.message, stackTrace);
      httpClient.close();
      throw ServiceUnavailableExcecption(message: e.message, stackTrace: stackTrace, type: ExceptionType.noApi);
    } on HandshakeException catch (e, stackTrace) {
      l.e(e.message, stackTrace);
      httpClient.close();
      throw ServiceUnavailableExcecption(message: e.message, stackTrace: stackTrace, type: ExceptionType.noApi);
    } on ClientException catch (e, stackTrace) {
      l.e(e.message, stackTrace);
      httpClient.close();
      throw ServiceUnavailableExcecption(message: e.message, stackTrace: stackTrace, type: ExceptionType.noApi);
    } on RequestCanceledException catch (e, stackTrace) {
      l.e(e.message, stackTrace);
      httpClient.close();
      rethrow;
    }
  }

  static Future<void> checkUserToken() async {}

  static Future<Response> apiMultipartRequest(
    String url, {
    required Map<String, dynamic> fields,
    bool abortOnBadRequest = true,
    String? basicUrl,
  }) async {
    final uri = Uri.parse(
      (Uri.encodeFull((basicUrl ?? AppBaseSettings().apiUrl) + url)).replaceAll('+', '%2B'),
    );
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = await SharedPreferencesBaseRepository.getToken() ?? '';
    for (final key in fields.keys) {
      request.fields[key] = '${fields[key]}';
    }
    final sResponse = await request.send();
    final response = await http.Response.fromStream(sResponse);
    handleApiError(response, abortOnBadRequest);
    return response;
  }

  static Future<StreamedResponse> apiSendFile(
    String url, {
    String? basicUrl,
    required Uint8List file,
    required String field,
    required String filename,
  }) async {
    final uri = Uri.parse(
      (Uri.encodeFull((basicUrl ?? AppBaseSettings().apiUrl) + url)).replaceAll('+', '%2B'),
    );

    final headers = <String, String>{
      'Accept': '*/*',
      'Accept-Encoding': 'gzip',
      'Authorization': await SharedPreferencesBaseRepository.getToken() ?? '',
      'Content-Type': ContentType.json.toString(),
    };

    final multiFile = http.MultipartFile.fromBytes(
      field,
      file,
      filename: filename,
    );

    final request = http.MultipartRequest('POST', uri)
      ..files.add(multiFile)
      ..headers.addAll(headers);

    final response = await request.send();
    if (AppBaseSettings().logRequest) {
      log(response.toString());
    }
    return response;
  }

  /// Анализирует и возвращает текст ошибки, полученной с бэка
  static void handleApiError(Response response, bool abortOnBarRequest) {
    switch (response.statusCode) {
      /// 2**
      case HttpStatus.ok:
        return;
      case HttpStatus.created:
        return;
      case HttpStatus.accepted:
        return;

      /// 4**
      case HttpStatus.badRequest:
        logErrorInfo(response);
        if (abortOnBarRequest) {
          throw BadRequestException(
            message: response.reasonPhrase ?? 'Bad Request',
            body: jsonDecode(response.body) as Map<String, dynamic>?,
            type: ExceptionType.noApi,
          );
        }
        break;
      case HttpStatus.unauthorized:
        logErrorInfo(response);

        throw UnauthorizedException(message: 'Unauthorized', type: ExceptionType.noAuth);
      case HttpStatus.forbidden:
        logErrorInfo(response);
        throw OtherClientException(message: 'Forbidden', type: ExceptionType.noApi);
      case HttpStatus.notFound:
        logErrorInfo(response);
        throw OtherClientException(message: 'Not Found', type: ExceptionType.noApi);
      case HttpStatus.methodNotAllowed:
        logErrorInfo(response);
        throw OtherClientException(message: 'Method Not Allowed', type: ExceptionType.noApi);
      case HttpStatus.notAcceptable:
        logErrorInfo(response);
        throw OtherClientException(message: 'Not Acceptable', type: ExceptionType.noApi);
      case HttpStatus.proxyAuthenticationRequired:
        logErrorInfo(response);
        throw OtherClientException(message: 'Proxy Authentication Required', type: ExceptionType.noApi);
      case HttpStatus.requestTimeout:
        logErrorInfo(response);
        throw OtherClientException(message: 'Request Timeout', type: ExceptionType.noApi);
      case HttpStatus.conflict:
        logErrorInfo(response);
        throw OtherClientException(message: 'Method Not Allowed', type: ExceptionType.noApi);
      case HttpStatus.gone:
        logErrorInfo(response);
        throw OtherClientException(message: 'Gone', type: ExceptionType.noApi);
      case HttpStatus.lengthRequired:
        logErrorInfo(response);
        throw OtherClientException(message: 'Length Required', type: ExceptionType.noApi);
      case HttpStatus.preconditionFailed:
        logErrorInfo(response);
        throw OtherClientException(message: 'Precondition Failed', type: ExceptionType.noApi);
      case HttpStatus.requestEntityTooLarge:
        logErrorInfo(response);
        throw OtherClientException(message: 'Request Entity Too Large', type: ExceptionType.noApi);
      case HttpStatus.requestUriTooLong:
        logErrorInfo(response);
        throw OtherClientException(message: 'Request-URI Too Long', type: ExceptionType.noApi);
      case HttpStatus.unsupportedMediaType:
        logErrorInfo(response);
        throw OtherClientException(message: 'Unsupported Media Type', type: ExceptionType.noApi);
      case HttpStatus.requestedRangeNotSatisfiable:
        logErrorInfo(response);
        throw OtherClientException(message: 'Requested Range Not Satisfiable', type: ExceptionType.noApi);
      case HttpStatus.expectationFailed:
        logErrorInfo(response);
        throw OtherClientException(message: 'Expectation Failed', type: ExceptionType.noApi);

      /// 5**
      case HttpStatus.internalServerError:
        logErrorInfo(response);
        throw ServerException(message: 'Internal Server Error', type: ExceptionType.noApi);
      case HttpStatus.notImplemented:
        logErrorInfo(response);
        throw ServerException(message: 'Not Implemented', type: ExceptionType.noApi);
      case HttpStatus.badGateway:
        logErrorInfo(response);
        throw ServerException(message: 'Bad Gateway', type: ExceptionType.noApi);
      case HttpStatus.serviceUnavailable:
        logErrorInfo(response);
        throw ServiceUnavailableExcecption(message: 'Service Unavailable', type: ExceptionType.noApi);
      case HttpStatus.gatewayTimeout:
        logErrorInfo(response);
        throw ServerException(message: 'Gateway Timeout', type: ExceptionType.noApi);
      case HttpStatus.httpVersionNotSupported:
        logErrorInfo(response);
        throw ServerException(message: 'HTTP Version Not Supported', type: ExceptionType.noApi);

      default:
        logErrorInfo(response);
        throw UnknownException(message: 'Unknown Exception', type: ExceptionType.noApi);
    }
  }

  static void logErrorInfo(Response response) {
    if (AppBaseSettings().logRequest) {
      log(response.request!.url.toString());
      if (response.reasonPhrase != null) {
        log(response.reasonPhrase!);
      }
      log(response.body);
    }
  }
}

class ApiRequestData<T> {
  const ApiRequestData({
    this.response,
    this.errorMessage,
    this.errorType,
  });
  final T? response;
  final String? errorMessage;
  final ExceptionType? errorType;
}

class ApiResponseData<T> {
  const ApiResponseData({
    this.response,
    this.exception,
  });
  final T? response;
  final AppBaseException? exception;
}

class ApiMultiRequestData<T> {
  const ApiMultiRequestData({
    this.response,
    this.errorMessage,
    this.errorType,
  });
  final List<T>? response;
  final String? errorMessage;
  final ExceptionType? errorType;
}

abstract class ApiRequest {
  static Future<ApiRequestData<T>> requestOld<T>(
    Future<T> Function() func, [
    ExceptionType? error,
  ]) async {
    String? errorMessage;
    ExceptionType? errorType;
    T? response;
    try {
      if (error != null) {
        throw error;
      }
      response = await func();
    } on NoInternetException {
      errorMessage = 'No Internet Exception';
      errorType = ExceptionType.noInternet;
    } on ServiceUnavailableExcecption catch (e) {
      errorMessage = e.message;
      errorType = ExceptionType.noApi;
    } on UnauthorizedException catch (e) {
      errorMessage = e.message;
      errorType = ExceptionType.noAuth;
    } on ServerTimeoutException catch (e) {
      errorMessage = e.message;
      errorType = ExceptionType.timeout;
    } catch (e) {
      errorMessage = e.toString();
      errorType = ExceptionType.other;
    }

    return ApiRequestData(
      response: response,
      errorMessage: errorMessage,
      errorType: errorType,
    );
  }

  static Future<ApiRequestData<T>> request<T>(
    Future<T> request, [
    ExceptionType? error,
  ]) async {
    String? errorMessage;
    ExceptionType? errorType;
    T? response;
    try {
      if (error != null) {
        throw error;
      }
      response = await request;
    } on NoInternetException {
      errorMessage = 'No Internet Exception';
      errorType = ExceptionType.noInternet;
    } on ServiceUnavailableExcecption catch (e) {
      errorMessage = e.message;
      errorType = ExceptionType.noApi;
    } on UnauthorizedException catch (e) {
      errorMessage = e.message;
      errorType = ExceptionType.noAuth;
    } on ServerTimeoutException catch (e) {
      errorMessage = e.message;
      errorType = ExceptionType.timeout;
    } catch (e) {
      errorMessage = e.toString();
      errorType = ExceptionType.other;
    }

    return ApiRequestData(
      response: response,
      errorMessage: errorMessage,
      errorType: errorType,
    );
  }

  static Future<ApiResponseData<T>> apiRequest<T>(Future<T> request) async {
    AppBaseException? exception;
    T? response;
    try {
      response = await request;
    } on NoInternetException catch (e) {
      exception = e;
    } on ServiceUnavailableExcecption catch (e) {
      exception = e;
    } on UnauthorizedException catch (e) {
      exception = e;
    } on ServerTimeoutException catch (e) {
      exception = e;
    } on RequestCanceledException catch (e) {
      exception = e;
    } catch (e, stackTrace) {
      exception = OtherClientException(
        message: 'Other Exception',
        type: ExceptionType.other,
        stackTrace: stackTrace,
      );
    }

    return ApiResponseData(
      response: response,
      exception: exception,
    );
  }

  static Future<ApiMultiRequestData<T>> multiRequest<T>(
    Iterable<Future<T>> requests, [
    ExceptionType? error,
  ]) async {
    String? errorMessage;
    ExceptionType? errorType;
    List<T>? response;
    try {
      if (error != null) {
        throw error;
      }
      response = await Future.wait(requests);
    } on NoInternetException {
      errorMessage = 'No Internet Exception';
      errorType = ExceptionType.noInternet;
    } on ServiceUnavailableExcecption catch (e) {
      errorMessage = e.message;
      errorType = ExceptionType.noApi;
    } on UnauthorizedException catch (e) {
      errorMessage = e.message;
      errorType = ExceptionType.noAuth;
    } on ServerTimeoutException catch (e) {
      errorMessage = e.message;
      errorType = ExceptionType.timeout;
    } catch (e) {
      errorMessage = e.toString();
      errorType = ExceptionType.other;
    }

    return ApiMultiRequestData(
      response: response,
      errorMessage: errorMessage,
      errorType: errorType,
    );
  }
}
