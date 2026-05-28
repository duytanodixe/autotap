import 'package:flutter/material.dart';

class Dot {
  final String id;
  final int actionIntervalTime;
  final int holdTime;
  final int antiDetection;
  final int startDelay;
  final Offset position;

  const Dot({
    required this.id,
    required this.actionIntervalTime,
    required this.holdTime,
    required this.antiDetection,
    required this.startDelay,
    required this.position,
  });

  Dot copyWith({
    String? id,
    int? actionIntervalTime,
    int? holdTime,
    int? antiDetection,
    int? startDelay,
    Offset? position,
  }) {
    return Dot(
      id: id ?? this.id,
      actionIntervalTime: actionIntervalTime ?? this.actionIntervalTime,
      holdTime: holdTime ?? this.holdTime,
      antiDetection: antiDetection ?? this.antiDetection,
      startDelay: startDelay ?? this.startDelay,
      position: position ?? this.position,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'actionIntervalTime': actionIntervalTime,
        'holdTime': holdTime,
        'antiDetection': antiDetection,
        'startDelay': startDelay,
        'position': {'x': position.dx, 'y': position.dy},
      };

  factory Dot.fromMap(Map<String, dynamic> map) => Dot(
        id: map['id'],
        actionIntervalTime: map['actionIntervalTime'] as int,
        holdTime: map['holdTime'] as int,
        antiDetection: map['antiDetection'] as int,
        startDelay: map['startDelay'] as int? ?? 0,
        position: Offset(
          (map['position']['x'] as num).toDouble(),
          (map['position']['y'] as num).toDouble(),
        ),
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Dot &&
        other.id == id &&
        other.actionIntervalTime == actionIntervalTime &&
        other.holdTime == holdTime &&
        other.antiDetection == antiDetection &&
        other.startDelay == startDelay &&
        other.position == position;
  }

  @override
  int get hashCode => Object.hash(
        id,
        actionIntervalTime,
        holdTime,
        antiDetection,
        startDelay,
        position,
      );
}
