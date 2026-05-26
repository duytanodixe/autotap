import 'dart:math';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/dot.dart';
import '../services/dot_local_service.dart';
import '../state/dot_state.dart';

class DotCubit extends Cubit<DotState> {
  final DotLocalService _service = DotLocalService();

  DotCubit() : super(const DotState());

  Future<void> loadDots({String? profileId}) async {
    emit(state.copyWith(isLoading: true));
    try {
      final dots = await _service.fetchDots(profileId: profileId ?? state.currentProfileId);
      emit(state.copyWith(dots: dots, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void setProfile(String profileId) {
    emit(state.copyWith(currentProfileId: profileId));
  }

  void addDot(Offset position) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final dot = Dot(id: id, position: position);
    final updatedDots = [...state.dots, dot];
    emit(state.copyWith(dots: updatedDots));
    _service.saveDots(updatedDots, profileId: state.currentProfileId);
  }

  void updateDot(Dot dot) {
    final updatedDots = state.dots.map((d) => d.id == dot.id ? dot : d).toList();
    emit(state.copyWith(dots: updatedDots));
    _service.saveDots(updatedDots, profileId: state.currentProfileId);
  }

  void deleteDot(String id) {
    final updatedDots = state.dots.where((d) => d.id != id).toList();
    emit(state.copyWith(dots: updatedDots));
    _service.saveDots(updatedDots, profileId: state.currentProfileId);
  }

  void toggleDot(String id) {
    final updatedDots = state.dots.map((d) {
      if (d.id == id) {
        return d.copyWith(isRunning: !d.isRunning);
      }
      return d;
    }).toList();
    emit(state.copyWith(dots: updatedDots));
  }

  void clearAllDots() {
    emit(state.copyWith(dots: []));
    _service.clearDots(profileId: state.currentProfileId);
  }
}
