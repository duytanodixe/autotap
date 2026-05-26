import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/dot.dart';
import '../services/dot_local_service.dart';
import '../state/dot_state.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/material.dart';
import '../services/profile_local_service.dart';
import 'dart:math' as math;
class DotCubit extends Cubit<DotState> {
   final DotLocalService _service;
  final InAppWebViewController webController;
  final ProfileLocalService _profileService = ProfileLocalService();
  DotCubit(this._service, this.webController)
      : super(const DotState(dots: [], isLoading: false, errorMessage: null));

  Future<void> loadDots({String? profileId}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      String? effectiveProfileId = profileId ?? state.currentProfileId;
      effectiveProfileId ??= await _profileService.getActiveProfileId();
      final dots = await _service.fetchDots(profileId: effectiveProfileId);
      emit(state.copyWith(dots: dots, isLoading: false, currentProfileId: effectiveProfileId));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void addDot(Dot dot) {
    final updatedDots = List<Dot>.from(state.dots)..add(dot);
    emit(state.copyWith(dots: updatedDots));
  }

  void updateDot(Dot dot) {
    final updatedDots = state.dots.map((d) {
      if (d.id == dot.id) {
        return dot;
      }
      return d;
    }).toList();
    emit(state.copyWith(dots: updatedDots));
  }

  void deleteDot(String dotId) {
    final updatedDots = state.dots.where((d) => d.id != dotId).toList();
    emit(state.copyWith(dots: updatedDots));
  }

  void setProfile(String? profileId) {
    emit(state.copyWith(currentProfileId: profileId));
  }

  Future<void> saveDots() async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      final profileId = state.currentProfileId;
      String? effectiveProfileId = profileId ?? await _profileService.getActiveProfileId();
      if (effectiveProfileId == null) {
        throw Exception('No active profile. Please create/select a profile first.');
      }
      await _service.saveDots(state.dots, profileId: effectiveProfileId);
      emit(state.copyWith(isLoading: false, currentProfileId: effectiveProfileId));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

 Future<void> _autoTapAt(int x, int y, int holdMs) async {
    // dispatch mousedown
    final jsDown = """
      (function() {
        var el = document.elementFromPoint($x, $y);
        if (!el) return 'notfound';
        var down = new MouseEvent('mousedown', {
          bubbles: true,
          cancelable: true,
          clientX: $x,
          clientY: $y,
          buttons: 1
        });
        el.dispatchEvent(down);
        return 'down';
      })();
    """;

    try {
      final resDown = await webController.evaluateJavascript(source: jsDown);
      debugPrint('mousedown result: $resDown');
    } catch (e) {
      debugPrint('JS mousedown error: $e');
    }

    if (holdMs > 0) {
      await Future.delayed(Duration(milliseconds: holdMs));
    }

    // dispatch mouseup and click as fallback
    final jsUp = """
      (function() {
        var el = document.elementFromPoint($x, $y);
        if (!el) return 'notfound';
        var up = new MouseEvent('mouseup', {
          bubbles: true,
          cancelable: true,
          clientX: $x,
          clientY: $y,
          button: 0
        });
        el.dispatchEvent(up);
        var click = new MouseEvent('click', {
          bubbles: true,
          cancelable: true,
          clientX: $x,
          clientY: $y
        });
        el.dispatchEvent(click);
        return 'up+click';
      })();
    """;

    try {
      final resUp = await webController.evaluateJavascript(source: jsUp);
      debugPrint('mouseup/click result: $resUp');
    } catch (e) {
      debugPrint('JS mouseup error: $e');
    }
  }

void startAutoTap() {
  for (var dot in state.dots) {
    final dotId = dot.id;
    final startDelay = dot.startDelay;
    
    // Tạo một Timer để delay việc bắt đầu
    Timer(Duration(milliseconds: startDelay), () {
      // Sau khi delay xong, tạo Timer periodic cho dot này
      dot.timer = Timer.periodic(
        Duration(milliseconds: dot.actionIntervalTime),
        (_) {
          Dot? current;
          for (final d in state.dots) {
            if (d.id == dotId) {
              current = d;
              break;
            }
          }
          if (current == null) {
            return;
          }

          final radius = current.antiDetection.toDouble();
          double jitterX = 0;
          double jitterY = 0;
          if (radius > 0) {
            // uniform random point inside circle with given radius
            final rand = math.Random();
            final t = 2 * math.pi * rand.nextDouble();
            final r = radius * math.sqrt(rand.nextDouble());
            jitterX = r * math.cos(t);
            jitterY = r * math.sin(t);
          }
          final x = (current.position.dx + jitterX).toInt();
          final y = (current.position.dy + jitterY).toInt();
          _autoTapAt(x, y, current.holdTime);
        },
      );
    });
  }
}

  void stopAutoTap() {
    for (var dot in state.dots) {
      dot.timer?.cancel();
      dot.timer = null;
    }
  }
}
