import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewPanel extends StatefulWidget {
  final String url;
  final void Function(InAppWebViewController controller)? onWebViewCreated;

  const WebViewPanel({Key? key, required this.url, this.onWebViewCreated}) : super(key: key);

  @override
  State<WebViewPanel> createState() => _WebViewPanelState();
}

class _WebViewPanelState extends State<WebViewPanel> {
  InAppWebViewController? _controller;
  String? _lastLoadedUrl;

  /// Public method để kiểm tra scale từ bên ngoài
  Future<void> checkScale() async {
    if (_controller != null) {
      await _checkCurrentScale(_controller!);
    }
  }

  /// Public method để force fix zoom
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
      initialUrlRequest:
          widget.url.isNotEmpty ? URLRequest(url: WebUri(widget.url)) : null,
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true, // cho phép chạy JavaScript
            // Disable zoom gestures
            supportZoom: false,
            displayZoomControls: false,
            // Set initial scale
            initialScale: 100, // 100% = scale 1.0
            // Disable user scaling
            minimumZoomScale: 1.0,
            maximumZoomScale: 1.0,
          ),
      onWebViewCreated: (controller) {
        _controller = controller;
        if (widget.onWebViewCreated != null) {
          widget.onWebViewCreated!(controller);
        }
      },
      onLoadStop: (controller, url) async {
        _lastLoadedUrl = widget.url;
        
        // Inject JavaScript để đảm bảo scale = 1.0
        await _injectZoomFix(controller);
      },
    );
  }

  /// Inject JavaScript để fix zoom và đảm bảo scale = 1.0
  Future<void> _injectZoomFix(InAppWebViewController controller) async {
    try {
      await controller.evaluateJavascript(source: """
        (function() {
          // 1. Fix viewport meta tag
          var meta = document.querySelector('meta[name="viewport"]');
          if (!meta) {
            meta = document.createElement('meta');
            meta.name = 'viewport';
            document.head.appendChild(meta);
          }
          meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no';
          
          // 2. Force body zoom to 1
          document.body.style.zoom = '1';
          document.documentElement.style.zoom = '1';
          
          // 3. Disable touch events that could cause zoom
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
          
          // 4. Disable double-tap zoom
          var lastTouchEnd = 0;
          document.addEventListener('touchend', function(e) {
            var now = (new Date()).getTime();
            if (now - lastTouchEnd <= 300) {
              e.preventDefault();
            }
            lastTouchEnd = now;
          }, false);
          
          // 5. Disable wheel zoom
          document.addEventListener('wheel', function(e) {
            if (e.ctrlKey) {
              e.preventDefault();
            }
          }, { passive: false });
          
          console.log('Zoom fix applied - scale should be 1.0');
        })();
      """);
      
      debugPrint('WebView zoom fix injected successfully');
      
      // Kiểm tra scale sau khi inject
      await _checkCurrentScale(controller);
    } catch (e) {
      debugPrint('Failed to inject zoom fix: $e');
    }
  }

  /// Kiểm tra scale hiện tại của WebView
  Future<void> _checkCurrentScale(InAppWebViewController controller) async {
    try {
      final result = await controller.evaluateJavascript(source: """
        (function() {
          return {
            viewportWidth: window.innerWidth,
            viewportHeight: window.innerHeight,
            devicePixelRatio: window.devicePixelRatio,
            bodyZoom: document.body.style.zoom || '1',
            htmlZoom: document.documentElement.style.zoom || '1',
            metaViewport: document.querySelector('meta[name="viewport"]')?.content || 'not found'
          };
        })();
      """);
      
      debugPrint('WebView scale info: $result');
    } catch (e) {
      debugPrint('Failed to check scale: $e');
    }
  }
}
