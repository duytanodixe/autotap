import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'overlay/overlaytoolbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    title: 'Auto Tap Pro',
    home: MainScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

@pragma('vm:entry-point')
void overlayMain() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OverlayToolbar(),
  ));
}
