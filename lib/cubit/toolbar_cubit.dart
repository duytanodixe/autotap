import 'package:flutter_bloc/flutter_bloc.dart';
import '../state/toolbar_state.dart';
import 'dot_cubit.dart';

class ToolbarCubit extends Cubit<ToolbarState> {
  final DotCubit dotCubit;

  ToolbarCubit(this.dotCubit)
      : super(const ToolbarState(posX: 350, posY: 200));

  void updatePosition(double dx, double dy) {
    emit(state.copyWith(
      posX: state.posX + dx,
      posY: state.posY + dy,
    ));
  }

  void toggleExpanded() {
    emit(state.copyWith(isExpanded: !state.isExpanded));
  }

  void setExpanded(bool value) {
    emit(state.copyWith(isExpanded: value));
  }

  void toggleRunning() {
    final newRunning = !state.isRunning;
    emit(state.copyWith(isRunning: newRunning));

    if (newRunning) {
      dotCubit.startAutoTap();  // DotCubit tự lo gọi _autoTapAt
    } else {
      dotCubit.stopAutoTap();
    }
  }
}
