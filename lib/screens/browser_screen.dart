import 'package:flutter/material.dart';

class BrowserScreen extends StatelessWidget {
  final String url;
  const BrowserScreen({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Browser')),
      body: Center(child: Text('URL: $url')),
    );
  }
}
