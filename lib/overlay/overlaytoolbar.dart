import 'package:flutter/material.dart';

class OverlayToolbar extends StatefulWidget {
  const OverlayToolbar({super.key});

  @override
  State<OverlayToolbar> createState() => _SimpleToolbarState();
}

class _SimpleToolbarState extends State<OverlayToolbar> {
  double posX = 50;
  double posY = 200;
  bool isRunning = false;
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ==== TOOLBAR DRAGGABLE ====
        Positioned(
          left: posX,
          top: posY,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                posX += details.delta.dx;
                posY += details.delta.dy;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Play / Pause
                  IconButton(
                    icon: Icon(
                      isRunning ? Icons.pause : Icons.play_arrow,
                      color: isRunning ? Colors.green : Colors.red,
                    ),
                    onPressed: () {
                      setState(() {
                        isRunning = !isRunning;
                      });
                    },
                  ),

                  // Expanded zone
                  if (isExpanded) ...[
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.save, color: Colors.green),
                      onPressed: () {},
                    ),//123123123
                    IconButton(
                      icon: const Icon(Icons.account_circle, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.zoom_out_map, color: Colors.orange),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.expand_less, color: Colors.white),
                      onPressed: () {
                        setState(() => isExpanded = false);
                      },
                    ),
                  ] else ...[
                    IconButton(
                      icon: const Icon(Icons.expand_more, color: Colors.white),
                      onPressed: () {
                        setState(() => isExpanded = true);
                      },
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
