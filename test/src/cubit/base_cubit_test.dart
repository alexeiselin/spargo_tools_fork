import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cubit/test_base_cubit_cubit.dart';

void main() {
  test('Test BaseCubit', () async {
    int numberState = 0;
    final cubit = TestBaseCubitCubit();
    cubit.stream.listen((state) {
      numberState++;
      if (numberState == 1) {
        expect(state.runtimeType, TestBaseCubitLoading);
      } else if (numberState == 2) {
        expect(state.runtimeType, TestBaseCubitLoaded);
      }
    });
    expect(cubit.state.runtimeType, TestBaseCubitInitial);
    await cubit.load();
  });
}
