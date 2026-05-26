import 'package:equatable/equatable.dart';

class SettingState extends Equatable {
  final int actionInterval; // ms
  final double slidingInterval; // ms
  final bool neverStop;
  final int hours;
  final int minutes;
  final int seconds;
  final int times;
  final double antiDetectionRadius; // px

  const SettingState({
    this.actionInterval = 300,
    this.slidingInterval = 50,
    this.neverStop = true,
    this.hours = 0,
    this.minutes = 0,
    this.seconds = 0,
    this.times = 1,
    this.antiDetectionRadius = 0,
  });

  SettingState copyWith({
    int? actionInterval,
    double? slidingInterval,
    bool? neverStop,
    int? hours,
    int? minutes,
    int? seconds,
    int? times,
    double? antiDetectionRadius,
  }) {
    return SettingState(
      actionInterval: actionInterval ?? this.actionInterval,
      slidingInterval: slidingInterval ?? this.slidingInterval,
      neverStop: neverStop ?? this.neverStop,
      hours: hours ?? this.hours,
      minutes: minutes ?? this.minutes,
      seconds: seconds ?? this.seconds,
      times: times ?? this.times,
      antiDetectionRadius: antiDetectionRadius ?? this.antiDetectionRadius,
    );
  }

  @override
  List<Object?> get props => [
        actionInterval,
        slidingInterval,
        neverStop,
        hours,
        minutes,
        seconds,
        times,
        antiDetectionRadius,
      ];
}
