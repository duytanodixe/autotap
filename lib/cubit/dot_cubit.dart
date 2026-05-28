import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../models/dot.dart';
import '../services/auto_tap_service.dart';
import '../services/dot_local_service.dart';
import '../services/profile_local_service.dart';
import '../state/dot_state.dart';

class DotCubit extends Cubit<DotState> {
  final DotLocalService _service;
  final InAppWebViewController webController;
  final ProfileLocalService _profileService = ProfileLocalService();
  late final AutoTapService _autoTapService;
  bool _isDisposed = false;

  DotCubit(this._service, this.webController)
      : super(const DotState(dots: [], isLoading: false, errorMessage: null)) {
    _autoTapService = AutoTapService(webController: webController);
  }

  bool get isAutoTapRunning => _autoTapService.isRunning;

  Future<void> loadDots({String? profileId}) async {
    if (_isDisposed) return;
    
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      String? effectiveProfileId = profileId ?? state.currentProfileId;
      effectiveProfileId ??= await _profileService.getActiveProfileId();
      
      effectiveProfileId ??= await _profileService.getActiveProfileId();
      effectiveProfileId ??= 'default';
      
      final dots = await _service.fetchDots(profileId: effectiveProfileId);
      
      if (!_isDisposed) {
        emit(state.copyWith(
          dots: dots,
          isLoading: false,
          currentProfileId: effectiveProfileId,
        ));
      }
    } catch (e) {
      if (!_isDisposed) {
        emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      }
    }
  }

  void addDot(Dot dot) {
    final updatedDots = List<Dot>.from(state.dots)..add(dot);
    emit(state.copyWith(dots: updatedDots));
  }

  void updateDot(Dot dot) {
    final updatedDots = state.dots.map((d) {
      if (d.id == dot.id) return dot;
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

  Future<bool> saveDots() async {
    if (_isDisposed) return false;
    
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      final profileId = state.currentProfileId ?? await _profileService.getActiveProfileId();
      
      if (profileId == null) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'No active profile. Please create/select a profile first.',
        ));
        return false;
      }
      
      await _service.saveDots(state.dots, profileId: profileId);
      
      if (!_isDisposed) {
        emit(state.copyWith(isLoading: false, currentProfileId: profileId));
      }
      return true;
    } catch (e) {
      if (!_isDisposed) {
        emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      }
      return false;
    }
  }

  void startAutoTap() {
    _autoTapService.startAutoTap(
      dots: state.dots,
      onTap: (x, y, holdMs) {},
    );
  }

  void stopAutoTap() {
    _autoTapService.stopAutoTap();
  }

  @override
  Future<void> close() {
    _isDisposed = true;
    _autoTapService.dispose();
    return super.close();
  }
}
