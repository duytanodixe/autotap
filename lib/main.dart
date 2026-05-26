import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'overlay/overlaytoolbar.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MaterialApp(
    title: 'Simple WebView App',
    home: HomeScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

/// Entry point dành cho Overlay
@pragma("vm:entry-point")
void overlayMain() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OverlayToolbar(), // ⭐ gọi widget ở file khác
    ),
  );
}
