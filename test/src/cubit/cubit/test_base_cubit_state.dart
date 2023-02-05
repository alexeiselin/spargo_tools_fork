part of 'test_base_cubit_cubit.dart';

@immutable
abstract class TestBaseCubitState implements BaseState {
  const TestBaseCubitState();
}

class TestBaseCubitInitial extends TestBaseCubitState implements BaseInitial {}

class TestBaseCubitLoading extends TestBaseCubitState implements BaseLoading {}

class TestBaseCubitLoaded extends TestBaseCubitState implements BaseLoaded {
  const TestBaseCubitLoaded({required this.result});
  final String result;
}

class TestBaseCubitError extends TestBaseCubitState implements BaseException {
  const TestBaseCubitError({required this.exception});

  @override
  final AppBaseException exception;
}
