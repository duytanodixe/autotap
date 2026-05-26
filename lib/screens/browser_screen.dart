import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../widgets/webview_panel.dart';
import '../widgets/toolbar.dart';

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

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.url;
    _urlController = TextEditingController(text: widget.url);
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

  @override
  Widget build(BuildContext context) {
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
              ),
            ),
          ),
          if (_webController != null)
            Positioned(
              bottom: 20,
              right: 20,
              child: Toolbar(webController: _webController!),
            ),
        ],
      ),
    );
  }
}
