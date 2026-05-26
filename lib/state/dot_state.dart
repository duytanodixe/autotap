import 'package:equatable/equatable.dart';
import '../models/dot.dart';

class DotState extends Equatable {
  final List<Dot> dots;
  final bool isLoading;
  final String? error;
  final String? currentProfileId;

  const DotState({
    this.dots = const [],
    this.isLoading = false,
    this.error,
    this.currentProfileId,
  });

  DotState copyWith({
    List<Dot>? dots,
    bool? isLoading,
    String? error,
    String? currentProfileId,
  }) {
    return DotState(
      dots: dots ?? this.dots,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentProfileId: currentProfileId ?? this.currentProfileId,
    );
  }

  @override
  List<Object?> get props => [dots, isLoading, error, currentProfileId];
}
