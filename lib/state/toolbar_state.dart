import 'dart:ui';
import 'package:equatable/equatable.dart';

class ToolbarState extends Equatable {
  final bool isRunning;
  final bool isExpanded;
  final Offset position;

  const ToolbarState({
    this.isRunning = false,
    this.isExpanded = false,
    this.position = const Offset(20, 100),
  });

  ToolbarState copyWith({
    bool? isRunning,
    bool? isExpanded,
    Offset? position,
  }) {
    return ToolbarState(
      isRunning: isRunning ?? this.isRunning,
      isExpanded: isExpanded ?? this.isExpanded,
      position: position ?? this.position,
    );
  }

  @override
  List<Object?> get props => [isRunning, isExpanded, position];
}
