import 'package:flutter/material.dart';

/// A reusable Google logo component that renders the official multi-colored Google "G".
class DSGoogleLogo extends StatelessWidget {
  final double size;

  const DSGoogleLogo({super.key, this.size = 20.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPainterWidget(size: size),
    );
  }
}

class CustomPainterWidget extends StatelessWidget {
  final double size;

  const CustomPainterWidget({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _GoogleLogoPainter());
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double center = size.width / 2;
    final double radius = size.width / 2;
    final double strokeWidth = size.width * 0.22;
    final Rect rect = Rect.fromCircle(
      center: Offset(center, center),
      radius: radius - (strokeWidth / 2),
    );

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Red arc (top / top-right)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -0.6 * 3.14159, 1.15 * 3.14159, false, paint);

    // Yellow arc (bottom-left)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 0.55 * 3.14159, 0.7 * 3.14159, false, paint);

    // Green arc (bottom / bottom-right)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.05 * 3.14159, 0.5 * 3.14159, false, paint);

    // Blue arc (right & center bar)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.1 * 3.14159, 0.4 * 3.14159, false, paint);

    // Blue horizontal crossbar
    final Paint fillPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    final double barHeight = strokeWidth * 0.9;
    canvas.drawRect(
      Rect.fromLTWH(
        center - strokeWidth * 0.1,
        center - (barHeight / 2),
        radius,
        barHeight,
      ),
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
