import 'package:flutter/material.dart';
import 'dart:async';
class Dot {
  final String id; // Firestore doc id
  final int actionIntervalTime;
  final int holdTime;
  final int antiDetection;
  final int startDelay; // Thời gian delay trước khi bắt đầu (ms)
  final Offset position;
  Timer? timer;

  Dot({
    required this.id,
    required this.actionIntervalTime,
    required this.holdTime,
    required this.antiDetection,
    required this.startDelay,
    required this.position,
  });

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
        actionIntervalTime: map['actionIntervalTime'],
        holdTime: map['holdTime'],
        antiDetection: map['antiDetection'],
        startDelay: map['startDelay'] ?? 0, // Default 0 nếu không có
        position: Offset(
          (map['position']['x'] as num).toDouble(),
          (map['position']['y'] as num).toDouble(),
        ),
      );
}