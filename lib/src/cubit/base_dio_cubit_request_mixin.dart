import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

mixin BaseDioCubitRequestMixin<BaseState> on Cubit<BaseState> {
  Future<ResponseType?> apiRequest<ResponseType>(
    Future<ResponseType> request, {
    Function(DioException? exception)? onError,
    Function(ResponseType response)? onSuccess,
    BaseState? loadingState,
    BaseState Function(ResponseType response)? loadedState,
    BaseState Function(DioException exception)? errorState,
  }) async {
    Function(DioException)? callbackWhenError;
    Function(ResponseType)? callbackWhenSuccess;
    if (onSuccess != null) {
      assert(onError != null,
          'Если есть callback onSuccess, то тогда нужно передавать и onError');

      if (loadingState != null) {
        emit(loadingState);
      }

      callbackWhenError = (response) => onError!.call(response);
      callbackWhenSuccess = (response) => onSuccess.call(response);
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
          // if (AppBaseSettings().logAppException) {
          // log(response.exception.toString());
          // }
          emit(errorState.call(response));
        };
      }
      if (loadedState != null) {
        callbackWhenSuccess = (response) => emit(loadedState.call(response));
      }
    }

    try {
      final response = await request;
      callbackWhenSuccess?.call(response);
      return response;
    } on DioException catch (e) {
      callbackWhenError?.call(e);
      return null;
    }
  }

  // Future<List<ResponseType>?> baseMultiRequest<ResponseType>(
  //   Iterable<Future<ResponseType>> requests, {
  //   Function(List<DioException>? exception)? onError,
  //   Function(List<ResponseType> response)? onSuccess,
  //   BaseState? loadingState,
  //   BaseState Function(List<ResponseType> response)? loadedState,
  //   BaseState Function(List<DioException> exception)? errorState,
  // }) async {
  //   Function(List<DioException>)? callbackWhenError;
  //   Function(List<ResponseType>)? callbackWhenSuccess;
  //   if (onSuccess != null) {
  //     assert(onError != null,
  //         'Если есть callback onSuccess, то тогда нужно передавать и onError');

  //     if (loadingState != null) {
  //       emit(loadingState);
  //     }

  //     callbackWhenError = (response) =>
  //         onError!.call(response);
  //     callbackWhenSuccess = (response) => onSuccess.call(response);
  //   } else {
  //     if (loadedState != null) {
  //       assert(errorState != null,
  //           'Если есть loadedState, то тогда нужно передавать и errorState');
  //     }

  //     if (loadingState != null) {
  //       emit(loadingState);
  //     }

  //     if (errorState != null) {
  //       callbackWhenError = (response) =>
  //           emit(errorState.call(response));
  //     }
  //     if (loadedState != null) {
  //       callbackWhenSuccess =
  //           (response) => emit(loadedState.call(response));
  //     }
  //   }

  //   try {
  //     final response = await Future.wait(requests);
  //     callbackWhenSuccess?.call(response);
  //     return response;
  //   } on DioException catch (e) {
  //     callbackWhenError?.call(e);
  //     return null;
  //   }
  // }
}
