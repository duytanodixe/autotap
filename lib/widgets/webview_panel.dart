import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewPanel extends StatefulWidget {
  final String url;
  final void Function(InAppWebViewController controller)? onWebViewCreated;

  const WebViewPanel({
    super.key,
    required this.url,
    this.onWebViewCreated,
  });

  @override
  State<WebViewPanel> createState() => _WebViewPanelState();
}

class _WebViewPanelState extends State<WebViewPanel> {
  InAppWebViewController? _controller;
  String? _lastLoadedUrl;

  Future<void> checkScale() async {
    if (_controller != null) {
      await _checkCurrentScale(_controller!);
    }
  }

  Future<void> forceFixZoom() async {
    if (_controller != null) {
      await _injectZoomFix(_controller!);
    }
  }

  @override
  void didUpdateWidget(covariant WebViewPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller != null &&
        widget.url.isNotEmpty &&
        widget.url != _lastLoadedUrl) {
      _controller!.loadUrl(
        urlRequest: URLRequest(url: WebUri(widget.url)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: widget.url.isNotEmpty
          ? URLRequest(url: WebUri(widget.url))
          : null,
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        supportZoom: false,
        displayZoomControls: false,
        initialScale: 100,
        minimumZoomScale: 1.0,
        maximumZoomScale: 1.0,
      ),
      onWebViewCreated: (controller) {
        _controller = controller;
        widget.onWebViewCreated?.call(controller);
      },
      onLoadStop: (controller, url) async {
        _lastLoadedUrl = widget.url;
        await _injectZoomFix(controller);
      },
    );
  }

  Future<void> _injectZoomFix(InAppWebViewController controller) async {
    try {
      await controller.evaluateJavascript(source: '''
        (function() {
          var meta = document.querySelector('meta[name="viewport"]');
          if (!meta) {
            meta = document.createElement('meta');
            meta.name = 'viewport';
            document.head.appendChild(meta);
          }
          meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no';
          
          document.body.style.zoom = '1';
          document.documentElement.style.zoom = '1';
          
          document.addEventListener('touchstart', function(e) {
            if (e.touches.length > 1) {
              e.preventDefault();
            }
          }, { passive: false });
          
          document.addEventListener('touchmove', function(e) {
            if (e.touches.length > 1) {
              e.preventDefault();
            }
          }, { passive: false });
          
          var lastTouchEnd = 0;
          document.addEventListener('touchend', function(e) {
            var now = (new Date()).getTime();
            if (now - lastTouchEnd <= 300) {
              e.preventDefault();
            }
            lastTouchEnd = now;
          }, false);
          
          document.addEventListener('wheel', function(e) {
            if (e.ctrlKey) {
              e.preventDefault();
            }
          }, { passive: false });
        })();
      ''');
    } catch (e) {
      debugPrint('Failed to inject zoom fix: \$e');
    }
  }

  Future<void> _checkCurrentScale(InAppWebViewController controller) async {
    try {
      await controller.evaluateJavascript(source: '''
        (function() {
          return {
            viewportWidth: window.innerWidth,
            viewportHeight: window.innerHeight,
            devicePixelRatio: window.devicePixelRatio
          };
        })();
      ''');
    } catch (e) {
      debugPrint('Failed to check scale: \$e');
    }
  }
}
