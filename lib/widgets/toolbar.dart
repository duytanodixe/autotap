import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../cubit/toolbar_cubit.dart';
import '../state/toolbar_state.dart';

class Toolbar extends StatelessWidget {
  final InAppWebViewController webController;
  final VoidCallback? onAddDot;
  final VoidCallback? onPlayPause;
  final VoidCallback? onClearAll;
  final VoidCallback? onSettings;
  final VoidCallback? onSave;
  final bool isRunning;

  const Toolbar({
    Key? key,
    required this.webController,
    this.onAddDot,
    this.onPlayPause,
    this.onClearAll,
    this.onSettings,
    this.onSave,
    this.isRunning = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ToolbarCubit, ToolbarState>(
      builder: (context, state) {
        return Positioned(
          bottom: state.position.dy,
          right: state.position.dx,
          child: GestureDetector(
            onPanUpdate: (details) {
              context.read<ToolbarCubit>().updatePosition(
                Offset(
                  state.position.dx + details.delta.dx,
                  state.position.dy + details.delta.dy,
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey[900]?.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIconButton(
                    icon: isRunning ? Icons.pause : Icons.play_arrow,
                    color: isRunning ? Colors.orange : Colors.green,
                    onPressed: onPlayPause,
                    tooltip: isRunning ? 'Pause' : 'Play',
                  ),
                  _buildIconButton(
                    icon: Icons.add_location_alt,
                    color: Colors.blueAccent,
                    onPressed: onAddDot,
                    tooltip: 'Add Dot',
                  ),
                  _buildIconButton(
                    icon: Icons.tune,
                    color: Colors.purpleAccent,
                    onPressed: onSettings,
                    tooltip: 'Settings',
                  ),
                  _buildIconButton(
                    icon: Icons.save,
                    color: Colors.amber,
                    onPressed: onSave,
                    tooltip: 'Save',
                  ),
                  _buildIconButton(
                    icon: Icons.delete_sweep,
                    color: Colors.redAccent,
                    onPressed: onClearAll,
                    tooltip: 'Clear All',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    VoidCallback? onPressed,
    String? tooltip,
  }) {
    return IconButton(
      icon: Icon(icon, color: color, size: 24),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
}
