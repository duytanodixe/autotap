import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/setting_cubit.dart';
import '../cubit/dot_cubit.dart';
import '../models/dot.dart';
import '../utils/constants.dart';

enum SettingMode { all, single }

class SettingScreen extends StatefulWidget {
  final SettingMode mode;
  final String? dotId;

  const SettingScreen({
    super.key,
    required this.mode,
    this.dotId,
  });

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late TextEditingController _actionCtl;
  late TextEditingController _holdCtl;
  late TextEditingController _startDelayCtl;
  double _antiDetectionValue = 0;
  bool _isInitialized = false;
  String? _actionError;
  String? _holdError;
  String? _delayError;

  @override
  void dispose() {
    _actionCtl.dispose();
    _holdCtl.dispose();
    _startDelayCtl.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    bool isValid = true;
    setState(() {
      _actionError = null;
      _holdError = null;
      _delayError = null;
    });

    final action = int.tryParse(_actionCtl.text);
    if (action == null || action < AppConstants.minValue) {
      setState(() => _actionError = 'Must be >= ${AppConstants.minValue}');
      isValid = false;
    } else if (action > AppConstants.maxValue) {
      setState(() => _actionError = 'Must be <= ${AppConstants.maxValue}');
      isValid = false;
    }

    final hold = int.tryParse(_holdCtl.text);
    if (hold == null || hold < AppConstants.minValue) {
      setState(() => _holdError = 'Must be >= ${AppConstants.minValue}');
      isValid = false;
    } else if (hold > AppConstants.maxValue) {
      setState(() => _holdError = 'Must be <= ${AppConstants.maxValue}');
      isValid = false;
    }

    final startDelay = int.tryParse(_startDelayCtl.text);
    if (startDelay == null || startDelay < AppConstants.minValue) {
      setState(() => _delayError = 'Must be >= ${AppConstants.minValue}');
      isValid = false;
    } else if (startDelay > AppConstants.maxValue) {
      setState(() => _delayError = 'Must be <= ${AppConstants.maxValue}');
      isValid = false;
    }

    return isValid;
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
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(AppConstants.miniAppBarHeight),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                widget.mode == SettingMode.all
                    ? 'Dot Settings (All)'
                    : 'Dot Settings (Single)',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
        body: BlocBuilder<DotSettingCubit, List<Dot>>(
          builder: (context, dots) {
            final target = dots.isNotEmpty ? dots.first : null;

            if (target == null) {
              return const Center(
                child: Text(
                  'No dot selected',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            if (!_isInitialized) {
              _actionCtl = TextEditingController(
                  text: target.actionIntervalTime.toString());
              _holdCtl = TextEditingController(text: target.holdTime.toString());
              _startDelayCtl = TextEditingController(
                  text: target.startDelay.toString());
              _antiDetectionValue = target.antiDetection.toDouble();
              _isInitialized = true;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.mediumPadding,
                vertical: 14,
              ),
              child: ListView(
                children: [
                  _buildSectionCard(
                    icon: Icons.timer_outlined,
                    title: 'Action interval time',
                    errorText: _actionError,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('ms', _actionError),
                      controller: _actionCtl,
                      onChanged: (_) {
                        if (_actionError != null) {
                          setState(() => _actionError = null);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  _buildSectionCard(
                    icon: Icons.touch_app_outlined,
                    title: 'Hold time',
                    errorText: _holdError,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('ms', _holdError),
                      controller: _holdCtl,
                      onChanged: (_) {
                        if (_holdError != null) {
                          setState(() => _holdError = null);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  _buildSectionCard(
                    icon: Icons.hourglass_bottom_outlined,
                    title: 'Start delay',
                    errorText: _delayError,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('ms', _delayError),
                      controller: _startDelayCtl,
                      onChanged: (_) {
                        if (_delayError != null) {
                          setState(() => _delayError = null);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  _buildSectionCard(
                    icon: Icons.shield_outlined,
                    title: 'Anti-detection (radius/randomness)',
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Random radius',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(AppConstants.primaryDark)
                                    .withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: Colors.blueAccent),
                              ),
                              child: Text(
                                '${_antiDetectionValue.toInt()} px',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.blueAccent,
                            inactiveTrackColor: Colors.white24,
                            thumbColor: Colors.blueAccent,
                            overlayColor: Colors.blueAccent.withValues(alpha: 0.15),
                            valueIndicatorColor:
                                const Color(AppConstants.primaryDark),
                          ),
                          child: Slider(
                            min: 0,
                            max: AppConstants.maxAntiDetectionRadius.toDouble(),
                            divisions: AppConstants.maxAntiDetectionRadius,
                            value: _antiDetectionValue,
                            label: '${_antiDetectionValue.toInt()}px',
                            onChanged: (v) {
                              setState(() => _antiDetectionValue = v);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => _onConfirm(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(AppConstants.primaryDark),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppConstants.largeRadius),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Confirm',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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

  void _onConfirm(BuildContext context) async {
    if (!_validateInputs()) return;

    final action = int.parse(_actionCtl.text);
    final hold = int.parse(_holdCtl.text);
    final startDelay = int.parse(_startDelayCtl.text);
    final anti = _antiDetectionValue.toInt();

    final cubit = context.read<DotSettingCubit>();
    cubit.setActionInterval(action);
    cubit.setHoldTime(hold);
    cubit.setStartDelay(startDelay);
    cubit.setAntiDetection(anti);

    final dotCubit = context.read<DotCubit>();
    final navigator = Navigator.of(context);
    final success = await dotCubit.saveDots();

    if (!success || !mounted) return;
    navigator.pop();
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
    String? errorText,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(AppConstants.surfaceDark),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(title, icon),
          const SizedBox(height: 10),
          child,
          if (errorText != null) ...[
            const SizedBox(height: 4),
            Text(
              errorText,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue[200], size: 18),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String suffix, String? errorText) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(AppConstants.inputSurfaceDark),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      suffixText: suffix,
      suffixStyle: const TextStyle(color: Colors.white70),
      labelStyle: const TextStyle(color: Colors.white70),
      errorText: errorText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.largeRadius),
        borderSide: BorderSide(
          color: errorText != null ? Colors.redAccent : Colors.white24,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.largeRadius),
        borderSide: BorderSide(
          color: errorText != null ? Colors.redAccent : Colors.white24,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.largeRadius),
        borderSide: BorderSide(
          color: errorText != null ? Colors.redAccent : Colors.blue,
        ),
      ),
    );
  }
}
