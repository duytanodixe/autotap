import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../models/dot.dart';

typedef TapCallback = void Function(int x, int y, int holdMs);

class AutoTapService {
  final InAppWebViewController webController;
  final Map<String, Timer?> _timers = {};
  bool _isRunning = false;

  AutoTapService({required this.webController});

  bool get isRunning => _isRunning;

  void startAutoTap({
    required List<Dot> dots,
    required TapCallback onTap,
  }) {
    if (_isRunning) return;
    _isRunning = true;

    for (final dot in dots) {
      _startDotTimer(dot);
    }
  }

  void _startDotTimer(Dot dot) {
    final delay = Timer(Duration(milliseconds: dot.startDelay), () {
      _timers[dot.id] = Timer.periodic(
        Duration(milliseconds: dot.actionIntervalTime),
        (_) => _executeTap(dot),
      );
    });
    _timers[dot.id] = delay;
  }

  void _executeTap(Dot dot) {
    final radius = dot.antiDetection.toDouble();
    double jitterX = 0;
    double jitterY = 0;

    if (radius > 0) {
      final random = math.Random();
      final angle = 2 * math.pi * random.nextDouble();
      final r = radius * math.sqrt(random.nextDouble());
      jitterX = r * math.cos(angle);
      jitterY = r * math.sin(angle);
    }

    final x = (dot.position.dx + jitterX).toInt();
    final y = (dot.position.dy + jitterY).toInt();

    _dispatchTapEvent(x, y, dot.holdTime);
  }

  Future<void> _dispatchTapEvent(int x, int y, int holdMs) async {
    final jsDown = '''
      (function() {
        var el = document.elementFromPoint($x, $y);
        if (!el) return 'notfound';
        var down = new MouseEvent('mousedown', {
          bubbles: true,
          cancelable: true,
          clientX: $x,
          clientY: $y,
          buttons: 1
        });
        el.dispatchEvent(down);
        return 'down';
      })();
    ''';

    try {
      await webController.evaluateJavascript(source: jsDown);
    } catch (e) {
      debugPrint('JS mousedown error: $e');
    }

    if (holdMs > 0) {
      await Future.delayed(Duration(milliseconds: holdMs));
    }

    final jsUp = '''
      (function() {
        var el = document.elementFromPoint($x, $y);
        if (!el) return 'notfound';
        var up = new MouseEvent('mouseup', {
          bubbles: true,
          cancelable: true,
          clientX: $x,
          clientY: $y,
          button: 0
        });
        el.dispatchEvent(up);
        var click = new MouseEvent('click', {
          bubbles: true,
          cancelable: true,
          clientX: $x,
          clientY: $y
        });
        el.dispatchEvent(click);
        return 'up+click';
      })();
    ''';

    try {
      await webController.evaluateJavascript(source: jsUp);
    } catch (e) {
      debugPrint('JS mouseup error: $e');
    }
  }

  void stopAutoTap() {
    _isRunning = false;
    for (final timer in _timers.values) {
      timer?.cancel();
    }
    _timers.clear();
  }

  void dispose() {
    stopAutoTap();
  }
}
