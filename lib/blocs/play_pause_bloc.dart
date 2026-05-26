import 'package:flutter_bloc/flutter_bloc.dart';

// Các trạng thái play/pause
enum PlayPauseState { playing, paused }

// Sự kiện cho bloc
abstract class PlayPauseEvent {}
class PlayEvent extends PlayPauseEvent {}
class PauseEvent extends PlayPauseEvent {}

// Bloc quản lý trạng thái play/pause
class PlayPauseBloc extends Bloc<PlayPauseEvent, PlayPauseState> {
  PlayPauseBloc() : super(PlayPauseState.paused) {
    on<PlayEvent>((event, emit) => emit(PlayPauseState.playing));
    on<PauseEvent>((event, emit) => emit(PlayPauseState.paused));
  }
}
