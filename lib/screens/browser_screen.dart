import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/webview_panel.dart';
import '../widgets/toolbar.dart';
import '../widgets/dot_widget.dart';
import '../cubit/dot_cubit.dart';
import '../cubit/toolbar_cubit.dart';
import '../state/dot_state.dart';
import '../models/dot.dart';
import 'setting_screen.dart';

class BrowserScreen extends StatefulWidget {
  final String url;
  const BrowserScreen({Key? key, required this.url}) : super(key: key);

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  late TextEditingController _urlController;
  late String _currentUrl;
  InAppWebViewController? _webController;
  final Map<String, Timer> _dotTimers = {};

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.url;
    _urlController = TextEditingController(text: widget.url);
  }

  @override
  void dispose() {
    _stopAllTimers();
    super.dispose();
  }

  void _stopAllTimers() {
    for (var timer in _dotTimers.values) {
      timer.cancel();
    }
    _dotTimers.clear();
  }

  void _loadUrl() {
    String newUrl = _urlController.text.trim();
    if (newUrl.isNotEmpty) {
      if (!newUrl.startsWith('http://') && !newUrl.startsWith('https://')) {
        newUrl = 'https://$newUrl';
      }
      setState(() {
        _currentUrl = newUrl;
      });
    }
  }

  void _onTapPosition(Offset position) {
    context.read<DotCubit>().addDot(position);
  }

  void _deleteDot(String id) {
    context.read<DotCubit>().deleteDot(id);
    _dotTimers[id]?.cancel();
    _dotTimers.remove(id);
  }

  void _showSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<DotCubit>(),
          child: const SettingScreen(mode: SettingMode.all),
        ),
      ),
    );
  }

  void _showSingleDotSettings(String dotId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<DotCubit>(),
          child: SettingScreen(mode: SettingMode.single, dotId: dotId),
        ),
      ),
    );
  }

  void _togglePlayPause(bool isRunning) {
    if (isRunning) {
      _stopAllTimers();
    } else {
      _startAutoTap();
    }
  }

  void _startAutoTap() {
    final dotState = context.read<DotCubit>().state;
    for (final dot in dotState.dots) {
      if (dot.isRunning) continue;
      _executeTap(dot);
      Timer(Duration(milliseconds: dot.actionIntervalTime), () {
        _executeTap(dot);
      });
    }
  }

  void _executeTap(Dot dot) {
    final random = Random();
    double offsetX = 0;
    double offsetY = 0;
    if (dot.antiDetection > 0) {
      offsetX = (random.nextDouble() * 2 - 1) * dot.antiDetection;
      offsetY = (random.nextDouble() * 2 - 1) * dot.antiDetection;
    }

    final x = (dot.position.dx + offsetX).toInt();
    final y = (dot.position.dy + offsetY).toInt();

    _webController?.evaluateJavascript(
      source: '''
        (function() {
          var event = new MouseEvent('mousedown', {
            bubbles: true,
            cancelable: true,
            view: window,
            clientX: $x,
            clientY: $y
          });
          var target = document.elementFromPoint($x, $y);
          if (target) {
            target.dispatchEvent(event);
            setTimeout(function() {
              var upEvent = new MouseEvent('mouseup', {
                bubbles: true,
                cancelable: true,
                view: window,
                clientX: $x,
                clientY: $y
              });
              target.dispatchEvent(upEvent);
              var clickEvent = new MouseEvent('click', {
                bubbles: true,
                cancelable: true,
                view: window,
                clientX: $x,
                clientY: $y
              });
              target.dispatchEvent(clickEvent);
            }, ${dot.holdTime});
          }
        })();
      ''',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DotCubit()),
        BlocProvider(create: (_) => ToolbarCubit()),
      ],
      child: BlocBuilder<DotCubit, DotState>(
        builder: (context, dotState) {
          return Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Container(
                padding: const EdgeInsets.only(top: 40, left: 10, right: 10, bottom: 10),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _urlController,
                          onSubmitted: (_) => _loadUrl(),
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Nhập địa chỉ web',
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _loadUrl,
                    ),
                  ],
                ),
              ),
            ),
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: WebViewPanel(
                      url: _currentUrl,
                      onWebViewCreated: (controller) {
                        setState(() {
                          _webController = controller;
                        });
                      },
                      onTapPosition: _onTapPosition,
                    ),
                  ),
                ),
                ...dotState.dots.map((dot) => DotWidget(
                  key: ValueKey(dot.id),
                  dot: dot,
                  onTap: () => context.read<DotCubit>().toggleDot(dot.id),
                  onDelete: () => _deleteDot(dot.id),
                  onSettings: () => _showSingleDotSettings(dot.id),
                )),
                BlocBuilder<ToolbarCubit, dynamic>(
                  builder: (context, toolbarState) {
                    final isRunning = context.watch<ToolbarCubit>().state.isRunning;
                    return Positioned(
                      bottom: 20,
                      right: 20,
                      child: Toolbar(
                        webController: _webController!,
                        isRunning: isRunning,
                        onAddDot: () => _showAddDotDialog(context),
                        onPlayPause: () {
                          context.read<ToolbarCubit>().toggleRunning();
                          _togglePlayPause(isRunning);
                        },
                        onSettings: _showSettings,
                        onSave: () {
                          context.read<DotCubit>().saveDots();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Dots saved!')),
                          );
                        },
                        onClearAll: () {
                          _stopAllTimers();
                          context.read<DotCubit>().clearAllDots();
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddDotDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text('Auto-Tap Mode', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Tap anywhere on the screen to add a tap point.\n\nLong press a dot to edit or delete it.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
