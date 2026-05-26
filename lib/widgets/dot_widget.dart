import 'package:flutter/material.dart';
import '../models/dot.dart';

class DotWidget extends StatelessWidget {
  final Dot dot;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onSettings;

  const DotWidget({
    Key? key,
    required this.dot,
    this.onTap,
    this.onDelete,
    this.onSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: dot.position.dx - 15,
      top: dot.position.dy - 15,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.grey[850],
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (ctx) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.tune, color: Colors.blueAccent),
                    title: const Text('Settings', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(ctx);
                      onSettings?.call();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.redAccent),
                    title: const Text('Delete', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(ctx);
                      onDelete?.call();
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dot.isRunning ? Colors.red.withOpacity(0.8) : Colors.blue.withOpacity(0.8),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: dot.isRunning ? Colors.red.withOpacity(0.5) : Colors.blue.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.touch_app, color: Colors.white, size: 16),
          ),
        ),
      ),
    );
  }
}
