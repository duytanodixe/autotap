import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/dot.dart';
import '../cubit/dot_cubit.dart';
import '../screens/setting_screen.dart';
import '../utils/constants.dart';

class DotWidget extends StatefulWidget {
  final Dot dot;
  final VoidCallback? onTap;
  final Function(Offset)? onPositionChanged;

  const DotWidget({
    super.key,
    required this.dot,
    this.onTap,
    this.onPositionChanged,
  });

  @override
  State<DotWidget> createState() => _DotWidgetState();
}

class _DotWidgetState extends State<DotWidget> {
  late Offset _position;

  @override
  void initState() {
    super.initState();
    _position = widget.dot.position;
  }

  @override
  void didUpdateWidget(covariant DotWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dot.position != widget.dot.position) {
      _position = widget.dot.position;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _position += details.delta;
          });
          widget.onPositionChanged?.call(_position);
        },
        onTap: widget.onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: AppConstants.dotWidgetSize,
              height: AppConstants.dotWidgetSize,
              color: Colors.black.withValues(alpha: 0.2),
            ),
            CustomPaint(
              size: const Size(
                AppConstants.dotCrosshairSize,
                AppConstants.dotCrosshairSize,
              ),
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
                onPressed: () => _openSettings(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openSettings(BuildContext context) {
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
  }
}

class CrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final circlePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppConstants.dotCrosshairStrokeWidth;

    final linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = AppConstants.dotCrosshairStrokeWidth;

    final centerDotPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    canvas.drawCircle(center, radius, circlePaint);
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      linePaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      linePaint,
    );
    canvas.drawCircle(center, AppConstants.dotCenterDotRadius, centerDotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
