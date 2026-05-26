import 'package:equatable/equatable.dart';
import '../models/dot.dart';

class DotState extends Equatable {
  final List<Dot> dots;       // danh sách dot
  final bool isLoading;       // đang tải
  final String? errorMessage; // lỗi (nếu có)
  final String? currentProfileId; // profile hiện tại

  const DotState({
    this.dots = const [],
    this.isLoading = false,
    this.errorMessage,
    this.currentProfileId,
  });

  DotState copyWith({
    List<Dot>? dots,
    bool? isLoading,
    String? errorMessage,
    String? currentProfileId,
  }) {
    return DotState(
      dots: dots ?? this.dots,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentProfileId: currentProfileId ?? this.currentProfileId,
    );
  }

  @override
  List<Object?> get props => [dots, isLoading, errorMessage, currentProfileId];
}
