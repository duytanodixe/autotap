import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_app_minimizer_plus/flutter_app_minimizer_plus.dart';
import '../utils/constants.dart';

class ActionScreen extends StatefulWidget {
  const ActionScreen({super.key});

  @override
  State<ActionScreen> createState() => _ActionScreenState();
}

class _ActionScreenState extends State<ActionScreen> {
  bool _isPressed = false;
  bool _isLoading = false;

  Future<void> _onTapButton() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);

    try {
      final permissionStatus = await FlutterOverlayWindow.isPermissionGranted();

      if (permissionStatus != true) {
        await FlutterOverlayWindow.requestPermission();
        final newStatus = await FlutterOverlayWindow.isPermissionGranted();
        if (newStatus != true) {
          if (mounted) {
            _showSnackBar('Overlay permission denied');
          }
          return;
        }
      }

      await FlutterOverlayWindow.showOverlay(
        overlayTitle: 'Auto Tap Overlay',
        height: WindowSize.matchParent,
        width: WindowSize.matchParent,
        alignment: OverlayAlignment.centerRight,
        flag: OverlayFlag.defaultFlag,
        visibility: NotificationVisibility.visibilityPrivate,
      );

      try {
        await FlutterAppMinimizerPlus.minimizeApp();
      } catch (e) {
        debugPrint('Cannot minimize app: $e');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundDark),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(AppConstants.appBarHeight),
        child: Container(
          padding: const EdgeInsets.only(
            top: 40,
            left: 20,
            right: 20,
            bottom: 20,
          ),
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
            onTapDown: (_) {
              if (!_isLoading) setState(() => _isPressed = true);
            },
            onTapUp: (_) {
              if (!_isLoading) {
                setState(() => _isPressed = false);
                _onTapButton();
              }
            },
            onTapCancel: () => setState(() => _isPressed = false),
            child: AnimatedContainer(
              duration: AppConstants.shortAnimation,
              height: AppConstants.profileButtonHeight,
              width: AppConstants.profileButtonWidth,
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
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 60,
                        ),
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
    );
  }
}
