import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../state/toolbar_state.dart';

class ToolbarCubit extends Cubit<ToolbarState> {
  ToolbarCubit() : super(const ToolbarState());

  void toggleRunning() {
    emit(state.copyWith(isRunning: !state.isRunning));
  }

  void setRunning(bool running) {
    emit(state.copyWith(isRunning: running));
  }

  void toggleExpanded() {
    emit(state.copyWith(isExpanded: !state.isExpanded));
  }

  void setExpanded(bool expanded) {
    emit(state.copyWith(isExpanded: expanded));
  }

  void updatePosition(Offset position) {
    emit(state.copyWith(position: position));
  }
}
