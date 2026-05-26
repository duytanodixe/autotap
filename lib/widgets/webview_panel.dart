import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewPanel extends StatefulWidget {
  final String url;
  final Function(InAppWebViewController)? onWebViewCreated;
  final Function(Offset)? onTapPosition;

  const WebViewPanel({
    Key? key,
    required this.url,
    this.onWebViewCreated,
    this.onTapPosition,
  }) : super(key: key);

  @override
  State<WebViewPanel> createState() => _WebViewPanelState();
}

class _WebViewPanelState extends State<WebViewPanel> {
  InAppWebViewController? _controller;
  double _progress = 1.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTapUp: (details) {
            widget.onTapPosition?.call(details.localPosition);
          },
          child: InAppWebView(
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
        ),
        if (_progress < 1.0)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
            ),
          ),
      ],
    );
  }
}
