import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'screens/home_screen.dart';
import 'cubit/dot_cubit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DotCubit(),
      child: const MaterialApp(
        title: 'Auto Tap Pro',
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
