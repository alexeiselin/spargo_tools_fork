import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spargo_tools/src/app/app_base_settings.dart';
import 'package:spargo_tools/src/cubit/base_cubit.dart';
import 'package:spargo_tools/src/exceptions/src/exception_type.dart';
import 'package:spargo_tools/src/http_client/http_client.dart';

mixin BaseCubitRequestMixinOld<BaseState> on Cubit<BaseState> {
  @Deprecated(
      'Устарело, используйте apiRequest, чтобы получать детальную информацию об ошибках')
  Future<ResponseType?> baseRequest<ResponseType>(
    Future<ResponseType> request, {
    Function(String message, ExceptionType type)? onError,
    Function(ResponseType response)? onSuccess,
    BaseState? loadingState,
    BaseState Function(ResponseType response)? loadedState,
    BaseState Function(String message, ExceptionType type)? errorState,
  }) async {
    Function(ApiRequestData<ResponseType>)? callbackWhenError;
    Function(ApiRequestData<ResponseType>)? callbackWhenSuccess;
    if (onSuccess != null) {
      assert(onError != null,
          'Если есть callback onSuccess, то тогда нужно передавать и onError');

      if (loadingState != null) {
        emit(loadingState);
      }

      callbackWhenError = (response) =>
          onError!.call(response.errorMessage!, response.errorType!);
      callbackWhenSuccess =
          (response) => onSuccess.call(response.response as ResponseType);
    } else {
      if (loadedState != null) {
        assert(errorState != null,
            'Если есть loadedState, то тогда нужно передавать и errorState');
      }

      if (loadingState != null) {
        emit(loadingState);
      }

      if (errorState != null) {
        callbackWhenError = (response) {
          if (AppBaseSettings().logAppException) {
            log('${response.errorType!}: ${response.errorMessage!}');
          }
          emit(errorState.call(response.errorMessage!, response.errorType!));
        };
      }
      if (loadedState != null) {
        callbackWhenSuccess = (response) =>
            emit(loadedState.call(response.response as ResponseType));
      }
    }

    final response = await ApiRequest.request(request);
    if (response.errorMessage != null) {
      if (!isClosed && callbackWhenError != null) {
        callbackWhenError(response);
      }
    } else {
      if (!isClosed) {
        if (callbackWhenSuccess != null) {
          callbackWhenSuccess(response);
        }
        return response.response;
      }
    }
    return null;
  }

  @Deprecated('Необходимо перейти на [baseRequest]')
  Future<void> baseRequestOld<ResponseType>(
    Future<ResponseType> Function() request, {
    Function(String message, ExceptionType type)? onError,
    Function(ResponseType response)? onSuccess,
    BaseState? loadingState,
    BaseState Function(ResponseType? response)? loadedState,
    BaseState Function(String message, ExceptionType type)? errorState,
  }) async {
    Function(ApiRequestData<ResponseType>) callbackWhenError;
    Function(ApiRequestData<ResponseType>) callbackWhenSuccess;
    if (onSuccess != null) {
      assert(onError != null,
          'Если есть callback onSuccess, то тогда нужно передавать и onError');

      if (loadingState != null) {
        emit(loadingState);
      }

      callbackWhenError = (response) =>
          onError!.call(response.errorMessage!, response.errorType!);
      callbackWhenSuccess =
          (response) => onSuccess.call(response.response as ResponseType);
    } else {
      assert(loadedState != null,
          "Если не передавать callBack'и, то нужно передать все state'ы");
      assert(errorState != null,
          "Если не передавать callBack'и, то нужно передать все state'ы");
      //assert(loadingState != null, "Если не передавать callBack'и, то нужно передать все state'ы");

      if (loadingState != null) {
        emit(loadingState);
      }
      callbackWhenError = (response) =>
          emit(errorState!.call(response.errorMessage!, response.errorType!));
      callbackWhenSuccess =
          (response) => emit(loadedState!.call(response.response));
    }

    final response = await ApiRequest.requestOld(request);
    if (response.errorMessage != null) {
      if (!isClosed) {
        callbackWhenError(response);
      }
    } else {
      if (!isClosed) {
        callbackWhenSuccess(response);
      }
    }
  }
}
