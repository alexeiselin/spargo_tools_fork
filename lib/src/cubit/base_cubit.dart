import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spargo_tools/src/cubit/base_cubit_request_mixin.dart';

import '../exceptions/exceptions.dart';

part 'base_state.dart';

abstract class BaseCubit<BaseState> extends Cubit<BaseState>
    with BaseCubitRequestMixin<BaseState> {
  BaseCubit(super.initialState);

  @override
  void emit(BaseState state) {
    if (!isClosed) {
      super.emit(state);
    }
  }

  Future<void> load();

  Future<void> refreshCubit() async => load();
}
