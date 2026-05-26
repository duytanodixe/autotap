import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/toolbar_cubit.dart';
import '../state/toolbar_state.dart';
// import '../screens/setting_screen.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../cubit/dot_cubit.dart';
import '../state/dot_state.dart';
import '../widgets/dot_widget.dart';
import '../models/dot.dart';
import '../services/dot_local_service.dart';
import '../screens/profile_screen.dart';
class Toolbar extends StatelessWidget {
  final InAppWebViewController webController;

  const Toolbar({super.key, required this.webController});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => DotCubit(DotLocalService(), webController)..loadDots(),
        ),
        BlocProvider(
          create: (ctx) => ToolbarCubit(ctx.read<DotCubit>()),
        ),
      ],
      child: BlocBuilder<ToolbarCubit, ToolbarState>(
        builder: (context, state) {
          return BlocBuilder<DotCubit, DotState>(
            builder: (context, dotState) {
              final dots = dotState.dots;

              return Stack(
                children: [
                  Positioned(
                    left: state.posX,
                    top: state.posY,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        context.read<ToolbarCubit>().updatePosition(
                              details.delta.dx,
                              details.delta.dy,
                            );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                state.isRunning
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: state.isRunning
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              onPressed: () {
                                context.read<ToolbarCubit>().toggleRunning();
                              },
                            ),

                            if (state.isExpanded) ...[
                              IconButton(
                                icon: const Icon(Icons.add, color: Colors.white),
                                onPressed: () {
                                  int maxId = 0;
                                  if (dots.isNotEmpty) {
                                    maxId = dots
                                        .map((d) => int.tryParse(d.id) ?? 0)
                                        .reduce((a, b) => a > b ? a : b);
                                  }
                                  final newId = (maxId + 1).toString();
                                  final newDot = Dot(
                                    id: newId,
                                    actionIntervalTime: 1000,
                                    holdTime: 500,
                                    antiDetection: 0,
                                    startDelay: 0,
                                    position: const Offset(100, 200),
                                  );
                                  context.read<DotCubit>().addDot(newDot);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove, color: Colors.white),
                                onPressed: () {
                                  if (dots.isNotEmpty) {
                                    final maxDot = dots.reduce((a, b) =>
                                        int.parse(a.id) > int.parse(b.id)
                                            ? a
                                            : b);
                                    context.read<DotCubit>().deleteDot(maxDot.id);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.save, color: Colors.green),
                                onPressed: () async {
                                  final cubit = context.read<DotCubit>();
                                  await cubit.saveDots();
                                  final error = cubit.state.errorMessage;
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(error == null ? 'Saved dots successfully' : 'Save failed: $error'),
                                      ),
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.account_circle, color: Colors.white),
                                onPressed: () async {
                                  final selected = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider.value(
                                        value: context.read<DotCubit>(),
                                        child: const ProfileScreen(),
                                      ),
                                    ),
                                  );
                                  if (selected is String?) {
                                    final dotCubit = context.read<DotCubit>();
                                    dotCubit.setProfile(selected);
                                    await dotCubit.loadDots(profileId: selected);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.zoom_out_map, color: Colors.orange),
                                onPressed: () async {
                                  // Debug: Kiểm tra scale của WebView
                                  try {
                                    final result = await webController.evaluateJavascript(source: """
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
                                    
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('WebView Scale Info: $result'),
                                          duration: const Duration(seconds: 3),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Error checking scale: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                              // Removed global settings entry; per-dot settings only via DotWidget
                              IconButton(
                                icon: const Icon(Icons.expand_less, color: Colors.white),
                                onPressed: () {
                                  context.read<ToolbarCubit>().toggleExpanded();
                                },
                              ),
                            ] else ...[
                              IconButton(
                                icon: const Icon(Icons.expand_more, color: Colors.white),
                                onPressed: () {
                                  context.read<ToolbarCubit>().toggleExpanded();
                                },
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                  for (var dot in dots)
                    DotWidget(
                      dot: dot,
                      onPositionChanged: (newPos) {
                        final updatedDot = Dot(
                          id: dot.id,
                          actionIntervalTime: dot.actionIntervalTime,
                          holdTime: dot.holdTime,
                          antiDetection: dot.antiDetection,
                          startDelay: dot.startDelay,
                          position: newPos,
                        );
                        context.read<DotCubit>().updateDot(updatedDot);
                      },
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
