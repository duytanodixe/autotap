import 'package:equatable/equatable.dart';

class ToolbarState extends Equatable {
  final double posX;
  final double posY;
  final bool isExpanded;
  final bool isRunning;

  const ToolbarState({
    required this.posX,
    required this.posY,
    this.isExpanded = false,
    this.isRunning = false,
  });

  ToolbarState copyWith({
    double? posX,
    double? posY,
    bool? isExpanded,
    bool? isRunning,
  }) {
    return ToolbarState(
      posX: posX ?? this.posX,
      posY: posY ?? this.posY,
      isExpanded: isExpanded ?? this.isExpanded,
      isRunning: isRunning ?? this.isRunning,
    );
  }

  @override
  List<Object> get props => [posX, posY, isExpanded, isRunning];
}
