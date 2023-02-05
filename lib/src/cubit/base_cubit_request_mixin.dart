import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spargo_tools/src/app/app_base_settings.dart';
import 'package:spargo_tools/src/exceptions/src/app_base_exception.dart';
import 'package:spargo_tools/src/exceptions/src/exception_type.dart';
import 'package:spargo_tools/src/http_client/http_client.dart';

mixin BaseCubitRequestMixin<BaseState> on Cubit<BaseState> {
  Future<ResponseType?> apiRequest<ResponseType>(
    Future<ResponseType> request, {
    Function(AppBaseException? exception)? onError,
    Function(ResponseType response)? onSuccess,
    BaseState? loadingState,
    BaseState Function(ResponseType response)? loadedState,
    BaseState Function(AppBaseException exception)? errorState,
  }) async {
    Function(ApiResponseData<ResponseType>)? callbackWhenError;
    Function(ApiResponseData<ResponseType>)? callbackWhenSuccess;
    if (onSuccess != null) {
      assert(onError != null,
          'Если есть callback onSuccess, то тогда нужно передавать и onError');

      if (loadingState != null) {
        emit(loadingState);
      }

      callbackWhenError = (response) => onError!.call(response.exception);
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
            log(response.exception.toString());
          }
          emit(errorState.call(response.exception!));
        };
      }
      if (loadedState != null) {
        callbackWhenSuccess = (response) =>
            emit(loadedState.call(response.response as ResponseType));
      }
    }

    final response = await ApiRequest.apiRequest(request);
    if (response.exception != null) {
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

  Future<List<ResponseType>?> baseMultiRequest<ResponseType>(
    Iterable<Future<ResponseType>> requests, {
    Function(String message, ExceptionType type)? onError,
    Function(List<ResponseType> response)? onSuccess,
    BaseState? loadingState,
    BaseState Function(List<ResponseType>? response)? loadedState,
    BaseState Function(String message, ExceptionType type)? errorState,
  }) async {
    Function(ApiMultiRequestData<ResponseType>) callbackWhenError =
        (response) => {};
    Function(ApiMultiRequestData<ResponseType>) callbackWhenSuccess =
        (response) => {};
    if (onSuccess != null) {
      assert(onError != null,
          'Если есть callback onSuccess, то тогда нужно передавать и onError');

      if (loadingState != null) {
        emit(loadingState);
      }

      callbackWhenError = (response) =>
          onError!.call(response.errorMessage!, response.errorType!);
      callbackWhenSuccess = (response) => onSuccess.call(response.response!);
    } else {
      if (loadedState != null) {
        assert(errorState != null,
            'Если есть loadedState, то тогда нужно передавать и errorState');
      }

      if (loadingState != null) {
        emit(loadingState);
      }

      if (errorState != null) {
        callbackWhenError = (response) =>
            emit(errorState.call(response.errorMessage!, response.errorType!));
      }
      if (loadedState != null) {
        callbackWhenSuccess =
            (response) => emit(loadedState.call(response.response!));
      }
    }

    final response = await ApiRequest.multiRequest(requests);
    if (response.errorMessage != null) {
      if (!isClosed) {
        callbackWhenError.call(response);
      }
    } else {
      if (!isClosed) {
        callbackWhenSuccess.call(response);
      }
      return response.response;
    }
    return null;
  }
}
