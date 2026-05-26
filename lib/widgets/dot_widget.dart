import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/dot.dart';
import '../cubit/dot_cubit.dart';
import '../screens/setting_screen.dart'; // để dùng SettingScreen & SettingMode

class DotWidget extends StatefulWidget {
  final Dot dot;
  final VoidCallback? onTap;
  final Function(Offset)? onPositionChanged;

  const DotWidget({
    Key? key,
    required this.dot,
    this.onTap,
    this.onPositionChanged,
  }) : super(key: key);

  @override
  State<DotWidget> createState() => _DotWidgetState();
}

class _DotWidgetState extends State<DotWidget> {
  late Offset position;

  @override
  void initState() {
    super.initState();
    position = widget.dot.position;
  }

  @override
  void didUpdateWidget(covariant DotWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dot.position != widget.dot.position) {
      position = widget.dot.position;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            position += details.delta;
          });
          widget.onPositionChanged?.call(position);
        },
        onTap: widget.onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              color: Colors.black.withOpacity(0.2),
            ),
            CustomPaint(
              size: const Size(60, 60),
              painter: CrosshairPainter(),
            ),
            Positioned(
              left: 2,
              top: 2,
              child: Text(
                widget.dot.id.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              right: -17,
              top: -17,
              child: IconButton(
                icon: const Icon(Icons.settings, color: Colors.white, size: 18),
                onPressed: () {
                  final dotCubit = context.read<DotCubit>();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: dotCubit,
                        child: SettingScreen(
                          mode: SettingMode.single,
                          dotId: widget.dot.id,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint circlePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final Paint linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2;

    final Paint centerDotPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2 - 4;

    // Vẽ vòng tròn
    canvas.drawCircle(center, radius, circlePaint);

    // Vẽ dấu cộng
    canvas.drawLine(Offset(center.dx - radius, center.dy),
        Offset(center.dx + radius, center.dy), linePaint);
    canvas.drawLine(Offset(center.dx, center.dy - radius),
        Offset(center.dx, center.dy + radius), linePaint);

    // Vẽ chấm đỏ ở tâm
    canvas.drawCircle(center, 3, centerDotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
