import 'dart:ui';

class Dot {
  final String id;
  final Offset position;
  final int actionIntervalTime;
  final int holdTime;
  final int startDelay;
  final int antiDetection;
  final bool isRunning;

  Dot({
    required this.id,
    required this.position,
    this.actionIntervalTime = 1000,
    this.holdTime = 100,
    this.startDelay = 0,
    this.antiDetection = 0,
    this.isRunning = false,
  });

  Dot copyWith({
    String? id,
    Offset? position,
    int? actionIntervalTime,
    int? holdTime,
    int? startDelay,
    int? antiDetection,
    bool? isRunning,
  }) {
    return Dot(
      id: id ?? this.id,
      position: position ?? this.position,
      actionIntervalTime: actionIntervalTime ?? this.actionIntervalTime,
      holdTime: holdTime ?? this.holdTime,
      startDelay: startDelay ?? this.startDelay,
      antiDetection: antiDetection ?? this.antiDetection,
      isRunning: isRunning ?? this.isRunning,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'positionX': position.dx,
      'positionY': position.dy,
      'actionIntervalTime': actionIntervalTime,
      'holdTime': holdTime,
      'startDelay': startDelay,
      'antiDetection': antiDetection,
    };
  }

  factory Dot.fromJson(Map<String, dynamic> json) {
    return Dot(
      id: json['id'] ?? '',
      position: Offset(
        (json['positionX'] ?? 0).toDouble(),
        (json['positionY'] ?? 0).toDouble(),
      ),
      actionIntervalTime: json['actionIntervalTime'] ?? 1000,
      holdTime: json['holdTime'] ?? 100,
      startDelay: json['startDelay'] ?? 0,
      antiDetection: json['antiDetection'] ?? 0,
    );
  }
}
