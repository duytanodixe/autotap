import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter/material.dart';
import '../widgets/navbar_widget.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_minimizer_plus/flutter_app_minimizer_plus.dart';
class ActionScreen extends StatefulWidget {
  const ActionScreen({Key? key}) : super(key: key);

  @override
  State<ActionScreen> createState() => _ActionScreenState();
}

class _ActionScreenState extends State<ActionScreen> {
  bool _isPressed = false;

Future<void> _onTapButton() async {
  bool? permissionStatus = await FlutterOverlayWindow.isPermissionGranted();

  // Nếu chưa có quyền → xin quyền
  if (permissionStatus != true) {
    await FlutterOverlayWindow.requestPermission();

    permissionStatus = await FlutterOverlayWindow.isPermissionGranted();
    if (permissionStatus != true) {
      debugPrint("❌ Người dùng chưa cấp quyền overlay");
      return;
    }
  }

  // ⭐ Gọi overlay entry point của bạn
  await FlutterOverlayWindow.showOverlay(
    overlayTitle: "overlayMain",   // <-- RẤT QUAN TRỌNG, phải KHỚP tên entry point
    height: WindowSize.matchParent,
    width: WindowSize.matchParent,
    alignment: OverlayAlignment.centerRight,
    flag: OverlayFlag.defaultFlag,
    visibility: NotificationVisibility.visibilityPrivate,
  );

  //Thu nhỏ app
  try {
    await FlutterAppMinimizerPlus.minimizeApp();
  } catch (e) {
    debugPrint("⚠️ Không thể thu nhỏ app: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF101820),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          padding:
              const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                offset: Offset(0, 4),
                blurRadius: 10,
              ),
              BoxShadow(
                color: Colors.white10,
                offset: Offset(0, -1),
                blurRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Auto Tap Action',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: Center(
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) {
              setState(() => _isPressed = false);
              _onTapButton();
            },
            onTapCancel: () => setState(() => _isPressed = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              height: 180,
              width: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: _isPressed
                    ? const [
                        BoxShadow(
                          color: Colors.black54,
                          offset: Offset(1, 1),
                          blurRadius: 6,
                        ),
                        BoxShadow(
                          color: Colors.white10,
                          offset: Offset(-1, -1),
                          blurRadius: 6,
                        ),
                      ]
                    : const [
                        BoxShadow(
                          color: Colors.black87,
                          offset: Offset(5, 5),
                          blurRadius: 15,
                        ),
                        BoxShadow(
                          color: Colors.white10,
                          offset: Offset(-5, -5),
                          blurRadius: 15,
                        ),
                      ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.play_arrow, color: Colors.white, size: 60),
                  SizedBox(height: 6),
                  Text(
                    'START',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
}
