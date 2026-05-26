import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DotCubit extends Cubit<void> {
  DotCubit() : super(null);

  void setProfile(String profileId) {}
  Future<void> loadDots({required String profileId}) async {}
}
