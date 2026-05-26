import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/dot.dart';
import 'dot_cubit.dart';

class DotSettingCubit extends Cubit<List<Dot>> {
  final DotCubit dotCubit;
  final bool isGlobal;
  final String? dotId;

  DotSettingCubit({
    required this.dotCubit,
    required this.isGlobal,
    this.dotId,
  }) : super([]) {
    _init();
  }

  void _init() {
    if (isGlobal) {
      emit(List.from(dotCubit.state.dots));
    } else if (dotId != null) {
      final dot = dotCubit.state.dots.where((d) => d.id == dotId).toList();
      emit(dot);
    }
  }

  void setActionInterval(int value) {
    if (isGlobal) {
      dotCubit.updateAllDots(actionIntervalTime: value);
    } else if (dotId != null) {
      dotCubit.updateDotById(dotId!, actionIntervalTime: value);
    }
    _init();
  }

  void setHoldTime(int value) {
    if (isGlobal) {
      dotCubit.updateAllDots(holdTime: value);
    } else if (dotId != null) {
      dotCubit.updateDotById(dotId!, holdTime: value);
    }
    _init();
  }

  void setStartDelay(int value) {
    if (isGlobal) {
      dotCubit.updateAllDots(startDelay: value);
    } else if (dotId != null) {
      dotCubit.updateDotById(dotId!, startDelay: value);
    }
    _init();
  }

  void setAntiDetection(int value) {
    if (isGlobal) {
      dotCubit.updateAllDots(antiDetection: value);
    } else if (dotId != null) {
      dotCubit.updateDotById(dotId!, antiDetection: value);
    }
    _init();
  }
}
