import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class Toolbar extends StatelessWidget {
  final InAppWebViewController webController;

  const Toolbar({Key? key, required this.webController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.zoom_in, color: Colors.white, size: 20),
            onPressed: () => webController.zoomBy(1.5),
            tooltip: 'Zoom In',
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out, color: Colors.white, size: 20),
            onPressed: () => webController.zoomBy(0.67),
            tooltip: 'Zoom Out',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
            onPressed: () => webController.reload(),
            tooltip: 'Reload',
          ),
        ],
      ),
    );
  }
}
