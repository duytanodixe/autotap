import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/dot.dart';
import 'dot_cubit.dart';

class DotSettingCubit extends Cubit<List<Dot>> {
  final DotCubit dotCubit;
  final bool isGlobal;
  final String? dotId;

  DotSettingCubit({
    required this.dotCubit,
    this.isGlobal = true,
    this.dotId,
  }) : super(isGlobal
            ? List<Dot>.from(dotCubit.state.dots)
            : [
                dotCubit.state.dots.firstWhere(
                  (d) => d.id == dotId,
                  orElse: () => throw StateError('Dot not found'),
                ),
              ]);

  void setActionInterval(int value) {
    final updated = state.map((d) {
      if (isGlobal || d.id == dotId) {
        return d.copyWith(actionIntervalTime: value);
      }
      return d;
    }).toList();
    _updateDots(updated);
  }

  void setHoldTime(int value) {
    final updated = state.map((d) {
      if (isGlobal || d.id == dotId) {
        return d.copyWith(holdTime: value);
      }
      return d;
    }).toList();
    _updateDots(updated);
  }

  void setAntiDetection(int value) {
    final updated = state.map((d) {
      if (isGlobal || d.id == dotId) {
        return d.copyWith(antiDetection: value);
      }
      return d;
    }).toList();
    _updateDots(updated);
  }

  void setStartDelay(int value) {
    final updated = state.map((d) {
      if (isGlobal || d.id == dotId) {
        return d.copyWith(startDelay: value);
      }
      return d;
    }).toList();
    _updateDots(updated);
  }

  void _updateDots(List<Dot> updated) {
    emit(updated);
    for (final dot in updated) {
      dotCubit.updateDot(dot);
    }
  }
}
