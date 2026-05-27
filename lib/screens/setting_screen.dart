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
    super.key,
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
  bool _isDarkTheme = true;
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
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            title: Text(
              widget.mode == SettingMode.all
                  ? "Dot Settings (All)"
                  : "Dot Settings (Single)",
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
          ),
        ),
        body: BlocBuilder<DotSettingCubit, List<Dot>>(
          builder: (context, dots) {
            final cubit = context.read<DotSettingCubit>();
            final target = dots.isNotEmpty ? dots.first : null;

            if (target == null) {
              return const Center(
                child: Text(
                  "No dot selected",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            // Chỉ khởi tạo một lần, tránh reset slider mỗi lần rebuild
            if (!_initialized) {
              actionCtl = TextEditingController(
                  text: target.actionIntervalTime.toString());
              holdCtl =
                  TextEditingController(text: target.holdTime.toString());
              startDelayCtl = TextEditingController(
                  text: target.startDelay.toString());
              antiDetectionValue = target.antiDetection.toDouble();
              _initialized = true;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: ListView(
                children: [
                  _buildSectionCard(
                    icon: Icons.timer_outlined,
                    title: "Action interval time",
                    child: TextField(
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("ms"),
                      controller: actionCtl,
                    ),
                  ),
                  const SizedBox(height: 14),

                  _buildSectionCard(
                    icon: Icons.touch_app_outlined,
                    title: "Hold time",
                    child: TextField(
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("ms"),
                      controller: holdCtl,
                    ),
                  ),
                  const SizedBox(height: 14),

                  _buildSectionCard(
                    icon: Icons.hourglass_bottom_outlined,
                    title: "Start delay",
                    child: TextField(
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("ms"),
                      controller: startDelayCtl,
                    ),
                  ),
                  const SizedBox(height: 14),

                  _buildSectionCard(
                    icon: Icons.shield_outlined,
                    title: "Anti-detection (radius/randomness)",
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Random radius",
                              style: TextStyle(color: Colors.white70),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1565C0).withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: Colors.blueAccent),
                              ),
                              child: Text(
                                "${antiDetectionValue.toInt()} px",
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
                            valueIndicatorColor: const Color(0xFF1565C0),
                          ),
                          child: Slider(
                            min: 0,
                            max: 100,
                            divisions: 100,
                            value: antiDetectionValue,
                            label: "${antiDetectionValue.toInt()}px",
                            onChanged: (v) {
                              setState(() {
                                antiDetectionValue = v;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  _buildSectionCard(
                    icon: Icons.palette_outlined,
                    title: "Appearance",
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        "Dark Theme",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: const Text(
                        "Use dark visuals for this screen",
                        style: TextStyle(color: Colors.white70),
                      ),
                      value: _isDarkTheme,
                      activeColor: Colors.blueAccent,
                      onChanged: (value) {
                        setState(() {
                          _isDarkTheme = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        // chỉ cập nhật khi nhấn Xác nhận
                        final action = int.tryParse(actionCtl.text) ?? 0;
                        final hold = int.tryParse(holdCtl.text) ?? 0;
                        final startDelay = int.tryParse(startDelayCtl.text) ?? 0;
                        final anti = antiDetectionValue.toInt();

                        cubit.setActionInterval(action);
                        cubit.setHoldTime(hold);
                        cubit.setStartDelay(startDelay);
                        cubit.setAntiDetection(anti);

                        // lưu vào Firestore cho profile hiện tại/active
                        final dotCubit = context.read<DotCubit>();
                        await dotCubit.saveDots();

                        if (!mounted) return;
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x4D1565C0),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
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
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(title, icon),
          const SizedBox(height: 10),
          child,
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

  InputDecoration _inputDecoration(String suffix) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      suffixText: suffix,
      suffixStyle: const TextStyle(color: Colors.white70),
      labelStyle: const TextStyle(color: Colors.white70),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white24),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blue),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
