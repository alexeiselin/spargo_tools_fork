part of 'base_dio_cubit.dart';

abstract class BaseDioState {
  const BaseDioState();
}

abstract class BaseDioInitial extends BaseDioState {}

abstract class BaseDioLoading extends BaseDioState {}

abstract class BaseDioLoaded extends BaseDioState {}

abstract class BaseDioException extends BaseDioState {
  const BaseDioException(this.exception);

  final DioException exception;
}
