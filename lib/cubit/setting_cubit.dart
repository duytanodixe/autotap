import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/dot.dart';
import 'dot_cubit.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class DotSettingCubit extends Cubit<List<Dot>> {
  final DotCubit dotCubit;
  final bool isGlobal; // true = chỉnh tất cả dot, false = chỉnh 1 dot
  final String? dotId; // id của dot nếu chỉnh 1 dot

  DotSettingCubit({
    required this.dotCubit,
    this.isGlobal = true,
    this.dotId,
  }) : super(isGlobal
            ? List<Dot>.from(dotCubit.state.dots) // copy toàn bộ
            : [
                dotCubit.state.dots
                    .firstWhere((d) => d.id == dotId) // chỉ 1 dot
              ]);

    void setActionInterval(int value) {
      final updated = isGlobal
          ? state.map((d) => d.copyWith(actionIntervalTime: value)).toList()
          : state.map((d) => d.id == dotId ? d.copyWith(actionIntervalTime: value) : d).toList();
      _updateDots(updated);
    }

  void setHoldTime(int value) {
    final updated = isGlobal
        ? state.map((d) => d.copyWith(holdTime: value)).toList()
        : state
            .map((d) => d.id == dotId ? d.copyWith(holdTime: value) : d)
            .toList();
    _updateDots(updated);
  }

  void setAntiDetection(int value) {
    final updated = isGlobal
        ? state.map((d) => d.copyWith(antiDetection: value)).toList()
        : state
            .map((d) =>
                d.id == dotId ? d.copyWith(antiDetection: value) : d)
            .toList();
    _updateDots(updated);
  }

  void setStartDelay(int value) {
    final updated = isGlobal
        ? state.map((d) => d.copyWith(startDelay: value)).toList()
        : state
            .map((d) => d.id == dotId ? d.copyWith(startDelay: value) : d)
            .toList();
    _updateDots(updated);
  }

  void _updateDots(List<Dot> updated) {
    // cập nhật state cho SettingScreen rebuild
    emit(updated);

    // gọi DotCubit để cập nhật thực tế
    for (var dot in updated) {
      dotCubit.updateDot(dot);
    }
  }
}

// Extension copyWith cho Dot
extension DotCopy on Dot {
  Dot copyWith({
    String? id,
    int? actionIntervalTime,
    int? holdTime,
    int? antiDetection,
    int? startDelay,
    Offset? position,
    Timer? timer,
  }) {
    return Dot(
      id: id ?? this.id,
      actionIntervalTime: actionIntervalTime ?? this.actionIntervalTime,
      holdTime: holdTime ?? this.holdTime,
      antiDetection: antiDetection ?? this.antiDetection,
      startDelay: startDelay ?? this.startDelay,
      position: position ?? this.position,
    )..timer = timer ?? this.timer;
  }
}
