import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/setting_cubit.dart';
import '../cubit/dot_cubit.dart';
import '../models/dot.dart';

enum SettingMode { all, single }

class SettingScreen extends StatefulWidget {
  final SettingMode mode;
  final String? dotId;

  const SettingScreen({
    Key? key,
    required this.mode,
    this.dotId,
  });

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late TextEditingController actionCtl;
  late TextEditingController holdCtl;
  late TextEditingController startDelayCtl;
  double antiDetectionValue = 0;
  bool _initialized = false;

  @override
  void dispose() {
    actionCtl.dispose();
    holdCtl.dispose();
    startDelayCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotCubit = context.read<DotCubit>();

    return BlocProvider(
      create: (_) => DotSettingCubit(
        dotCubit: dotCubit,
        isGlobal: widget.mode == SettingMode.all,
        dotId: widget.dotId,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          backgroundColor: const Color(0xFF1565C0),
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            widget.mode == SettingMode.all ? "Dot Settings (All)" : "Dot Settings (Single)",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: BlocBuilder<DotSettingCubit, List<Dot>>(
          builder: (context, dots) {
            final cubit = context.read<DotSettingCubit>();
            final target = dots.isNotEmpty ? dots.first : null;

            if (target == null) {
              return const Center(
                child: Text("No dot selected", style: TextStyle(color: Colors.white)),
              );
            }

            if (!_initialized) {
              actionCtl = TextEditingController(text: target.actionIntervalTime.toString());
              holdCtl = TextEditingController(text: target.holdTime.toString());
              startDelayCtl = TextEditingController(text: target.startDelay.toString());
              antiDetectionValue = target.antiDetection.toDouble();
              _initialized = true;
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _sectionTitle("Action Interval Time"),
                  const SizedBox(height: 8),
                  TextField(
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("ms"),
                    controller: actionCtl,
                  ),
                  const SizedBox(height: 20),

                  _sectionTitle("Hold Time"),
                  const SizedBox(height: 8),
                  TextField(
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("ms"),
                    controller: holdCtl,
                  ),
                  const SizedBox(height: 20),

                  _sectionTitle("Start Delay"),
                  const SizedBox(height: 8),
                  TextField(
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("ms"),
                    controller: startDelayCtl,
                  ),
                  const SizedBox(height: 20),

                  _sectionTitle("Anti-Detection (random offset radius)"),
                  const SizedBox(height: 8),
                  Slider(
                    min: 0,
                    max: 100,
                    divisions: 100,
                    value: antiDetectionValue,
                    label: "${antiDetectionValue.toInt()}px",
                    activeColor: const Color(0xFF42A5F5),
                    inactiveColor: Colors.grey[700],
                    onChanged: (v) {
                      setState(() {
                        antiDetectionValue = v;
                      });
                    },
                  ),
                  Center(
                    child: Text(
                      "${antiDetectionValue.toInt()} pixels random offset",
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        final action = int.tryParse(actionCtl.text) ?? 1000;
                        final hold = int.tryParse(holdCtl.text) ?? 100;
                        final startDelay = int.tryParse(startDelayCtl.text) ?? 0;
                        final anti = antiDetectionValue.toInt();

                        cubit.setActionInterval(action);
                        cubit.setHoldTime(hold);
                        cubit.setStartDelay(startDelay);
                        cubit.setAntiDetection(anti);

                        final dotCubit = context.read<DotCubit>();
                        await dotCubit.saveDots();

                        if (!mounted) return;
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  InputDecoration _inputDecoration(String suffix) {
    return InputDecoration(
      suffixText: suffix,
      suffixStyle: const TextStyle(color: Colors.white70),
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.grey[800],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF42A5F5)),
      ),
    );
  }
}
