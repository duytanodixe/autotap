import 'package:flutter_bloc/flutter_bloc.dart';
import '../state/browser_state.dart';

class BrowserCubit extends Cubit<BrowserState> {
  BrowserCubit() : super(const BrowserState(isLoading: true));

  /// Gọi khi bắt đầu load trang
  void startLoading() {
    emit(state.copyWith(
      isLoading: true,
      loadFail: false,
      loadSuccess: false,
    ));
  }

  /// Gọi khi load thành công
  void loadingSuccess() {
    emit(state.copyWith(
      isLoading: false,
      loadFail: false,
      loadSuccess: true,
    ));
  }

  /// Gọi khi load thất bại
  void loadingFail() {
    emit(state.copyWith(
      isLoading: false,
      loadFail: true,
      loadSuccess: false,
    ));
  }
}
