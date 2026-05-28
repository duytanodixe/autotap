import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/toolbar_storage.dart';
import '../state/toolbar_state.dart';

class ToolbarCubit extends Cubit<ToolbarState> {
  final ToolbarStorage _storage;

  ToolbarCubit(this._storage) : super(const ToolbarState(posX: 350, posY: 200));

  Future<void> loadPosition() async {
    final (x, y) = await _storage.loadPosition();
    emit(state.copyWith(posX: x, posY: y));
  }

  Future<void> updatePosition(double dx, double dy) async {
    final newX = state.posX + dx;
    final newY = state.posY + dy;
    
    emit(state.copyWith(posX: newX, posY: newY));
    await _storage.savePosition(newX, newY);
  }

  void toggleExpanded() {
    emit(state.copyWith(isExpanded: !state.isExpanded));
  }

  void setExpanded(bool value) {
    emit(state.copyWith(isExpanded: value));
  }

  void toggleRunning() {
    emit(state.copyWith(isRunning: !state.isRunning));
  }
}
