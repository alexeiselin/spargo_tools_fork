import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:spargo_tools/spargo_tools.dart';

part 'test_base_cubit_state.dart';

class TestBaseCubitCubit extends BaseCubit<TestBaseCubitState> {
  TestBaseCubitCubit() : super(TestBaseCubitInitial());

  @override
  Future<void> load() async {
    await apiRequest(
      AppHttp.apiHttpRequest('https://api.publicapis.org/entries',
          authorizationToken: ''),
      loadingState: TestBaseCubitLoading(),
      loadedState: (response) => TestBaseCubitLoaded(result: response.body),
      errorState: (exception) => TestBaseCubitError(exception: exception),
    );
  }
}
