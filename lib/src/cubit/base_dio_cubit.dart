import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'base_dio_cubit_request_mixin.dart';

part 'base_dio_state.dart';

abstract class BaseDioCubit<BaseState> extends Cubit<BaseState>
    with BaseDioCubitRequestMixin<BaseState> {
  BaseDioCubit(super.initialState);

  @override
  void emit(BaseState state) {
    if (!isClosed) {
      super.emit(state);
    }
  }
}
