import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/toolbar_cubit.dart';
import '../cubit/dot_cubit.dart';
import '../models/dot.dart';
import '../services/dot_local_service.dart';
import '../services/toolbar_storage.dart';
import '../state/dot_state.dart';
import '../state/toolbar_state.dart';
import '../screens/profile_screen.dart';
import '../widgets/dot_widget.dart';
import '../utils/constants.dart';

class Toolbar extends StatefulWidget {
  final dynamic webController;

  const Toolbar({super.key, required this.webController});

  @override
  State<Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  late final ToolbarStorage _storage;

  @override
  void initState() {
    super.initState();
    _storage = ToolbarStorage();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => DotCubit(DotLocalService(), widget.webController)..loadDots(),
        ),
        BlocProvider(
          create: (ctx) => ToolbarCubit(_storage)..loadPosition(),
        ),
      ],
      child: BlocConsumer<ToolbarCubit, ToolbarState>(
        listener: (context, toolbarState) {
          final dotCubit = context.read<DotCubit>();
          if (toolbarState.isRunning) {
            dotCubit.startAutoTap();
          } else {
            dotCubit.stopAutoTap();
          }
        },
        builder: (context, toolbarState) {
          return BlocBuilder<DotCubit, DotState>(
            builder: (context, dotState) {
              return Stack(
                children: [
                  Positioned(
                    left: toolbarState.posX,
                    top: toolbarState.posY,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        context.read<ToolbarCubit>().updatePosition(
                              details.delta.dx,
                              details.delta.dy,
                            );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                toolbarState.isRunning ? Icons.pause : Icons.play_arrow,
                                color: toolbarState.isRunning ? Colors.green : Colors.red,
                              ),
                              onPressed: () {
                                context.read<ToolbarCubit>().toggleRunning();
                              },
                            ),
                            if (toolbarState.isExpanded) ...[
                              IconButton(
                                icon: const Icon(Icons.add, color: Colors.white),
                                onPressed: () => _addDot(context, dotState),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove, color: Colors.white),
                                onPressed: () => _removeLastDot(context, dotState),
                              ),
                              IconButton(
                                icon: const Icon(Icons.save, color: Colors.green),
                                onPressed: () => _saveDots(context),
                              ),
                              IconButton(
                                icon: const Icon(Icons.account_circle, color: Colors.white),
                                onPressed: () => _openProfileScreen(context),
                              ),
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
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  for (final dot in dotState.dots)
                    DotWidget(
                      dot: dot,
                      onPositionChanged: (newPos) {
                        final updatedDot = dot.copyWith(position: newPos);
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

  void _addDot(BuildContext context, DotState dotState) {
    int maxId = 0;
    if (dotState.dots.isNotEmpty) {
      maxId = dotState.dots
          .map((d) => int.tryParse(d.id) ?? 0)
          .reduce((a, b) => a > b ? a : b);
    }
    final newId = (maxId + 1).toString();
    final newDot = Dot(
      id: newId,
      actionIntervalTime: AppConstants.defaultActionInterval,
      holdTime: AppConstants.defaultHoldTime,
      antiDetection: AppConstants.defaultAntiDetection,
      startDelay: AppConstants.defaultStartDelay,
      position: const Offset(100, 200),
    );
    context.read<DotCubit>().addDot(newDot);
  }

  void _removeLastDot(BuildContext context, DotState dotState) {
    if (dotState.dots.isNotEmpty) {
      final maxDot = dotState.dots.reduce(
        (a, b) => int.parse(a.id) > int.parse(b.id) ? a : b,
      );
      context.read<DotCubit>().deleteDot(maxDot.id);
    }
  }

  Future<void> _saveDots(BuildContext context) async {
    final cubit = context.read<DotCubit>();
    final success = await cubit.saveDots();
    final error = cubit.state.errorMessage;
    
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Saved dots successfully' : 'Save failed: $error',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openProfileScreen(BuildContext context) async {
    final selected = await Navigator.push<String?>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<DotCubit>(),
          child: const ProfileScreen(),
        ),
      ),
    );
    
    if (selected != null && context.mounted) {
      final dotCubit = context.read<DotCubit>();
      dotCubit.setProfile(selected);
      await dotCubit.loadDots(profileId: selected);
    }
  }
}
