import 'package:equatable/equatable.dart';

class BrowserState extends Equatable {
  final bool isLoading;
  final bool loadFail;
  final bool loadSuccess;

  const BrowserState({
    this.isLoading = false,
    this.loadFail = false,
    this.loadSuccess = false,
  });

  BrowserState copyWith({
    bool? isLoading,
    bool? loadFail,
    bool? loadSuccess,
  }) {
    return BrowserState(
      isLoading: isLoading ?? this.isLoading,
      loadFail: loadFail ?? this.loadFail,
      loadSuccess: loadSuccess ?? this.loadSuccess,
    );
  }

  @override
  List<Object> get props => [isLoading, loadFail, loadSuccess];
}
