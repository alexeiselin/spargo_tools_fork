part of 'base_cubit.dart';

abstract class BaseState {
  const BaseState();
}

abstract class BaseInitial extends BaseState {}

abstract class BaseLoading extends BaseState {}

abstract class BaseRefresh extends BaseState {}

abstract class BaseUpdate extends BaseState {}

abstract class BaseLoaded extends BaseState {}

@Deprecated('Используйте [BaseException] для получения детальной информации об ошибке')
abstract class BaseError extends BaseState {
  const BaseError({required this.type, this.message = 'Error'});

  final String message;
  final ExceptionType type;
}

abstract class BaseException extends BaseState {
  BaseException(this.exception);

  final AppBaseException exception;
}
