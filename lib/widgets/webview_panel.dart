import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewPanel extends StatefulWidget {
  final String url;
  final Function(InAppWebViewController)? onWebViewCreated;

  const WebViewPanel({
    Key? key,
    required this.url,
    this.onWebViewCreated,
  }) : super(key: key);

  @override
  State<WebViewPanel> createState() => _WebViewPanelState();
}

class _WebViewPanelState extends State<WebViewPanel> {
  InAppWebViewController? _controller;
  double _progress = 1.0;

  @override
  void initState() {
    super.initState();
    InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
        javaScriptEnabled: true,
        supportZoom: true,
        cacheEnabled: true,
      ),
      android: AndroidInAppWebViewOptions(
        useShouldInterceptRequest: true,
        builtInZoomControls: true,
        displayZoomControls: false,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ),
    );

    _controller?.loadUrl(
      urlRequest: URLRequest(url: Uri.parse(widget.url)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              useShouldOverrideUrlLoading: true,
              mediaPlaybackRequiresUserGesture: false,
              javaScriptEnabled: true,
              supportZoom: true,
              cacheEnabled: true,
            ),
            android: AndroidInAppWebViewOptions(
              useShouldInterceptRequest: true,
              builtInZoomControls: true,
              displayZoomControls: false,
            ),
            ios: IOSInAppWebViewOptions(
              allowsInlineMediaPlayback: true,
            ),
          ),
          onWebViewCreated: (controller) {
            _controller = controller;
            widget.onWebViewCreated?.call(controller);
          },
          onProgressChanged: (controller, progress) {
            setState(() {
              _progress = progress / 100;
            });
          },
        ),
        if (_progress < 1.0)
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
          ),
      ],
    );
  }
}
