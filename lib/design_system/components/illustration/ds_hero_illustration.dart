import 'package:flutter/material.dart';

/// Reusable vector-drawn hero illustration component for onboarding & auth screens.
class DSHeroIllustration extends StatelessWidget {
  final double height;
  final Color lineColor;

  const DSHeroIllustration({
    super.key,
    this.height = 290.0,
    this.lineColor = const Color(0xFF1E293B),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveLineColor = isDark ? Colors.white : lineColor;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _HeroIllustrationPainter(lineColor: effectiveLineColor),
      ),
    );
  }
}

class _HeroIllustrationPainter extends CustomPainter {
  final Color lineColor;

  _HeroIllustrationPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final double baseHeight = 220.0;
    final double scale = size.height / baseHeight;

    canvas.save();
    // Scale around center
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale);
    canvas.translate(-size.width / 2, -baseHeight / 2);

    final Paint linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Paint fillDarkPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final double cx = size.width / 2;
    final double cy = baseHeight * 0.45;

    // 1. Laptop Base & Screen
    final double laptopW = 120.0;
    final double laptopH = 75.0;
    final double laptopTop = cy + 25;
    final Rect laptopRect = Rect.fromCenter(
      center: Offset(cx, laptopTop + laptopH / 2),
      width: laptopW,
      height: laptopH,
    );

    // Laptop Body (filled dark rectangle for laptop lid in image)
    final RRect laptopRRect = RRect.fromRectAndRadius(laptopRect, const Radius.circular(6.0));
    canvas.drawRRect(laptopRRect, fillDarkPaint);

    // Laptop Logo Dot
    canvas.drawCircle(Offset(cx, laptopTop + laptopH / 2), 7.0, fillPaint);

    // Laptop Base Line / Desk
    final double deskY = laptopTop + laptopH + 4;
    canvas.drawLine(
      Offset(cx - 90, deskY),
      Offset(cx + 90, deskY),
      linePaint,
    );

    // Desk shadow oval under laptop base
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 30, deskY + 8), width: 22, height: 6),
      fillDarkPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 45, deskY + 10), width: 18, height: 5),
      linePaint,
    );

    // 2. Person's Body (Sitting cross-legged behind laptop)
    // Shoulders & Shirt Collar
    final Path bodyPath = Path()
      ..moveTo(cx - 45, cy + 30)
      ..cubicTo(cx - 45, cy + 5, cx - 25, cy - 5, cx - 12, cy - 5)
      ..lineTo(cx + 12, cy - 5)
      ..cubicTo(cx + 25, cy - 5, cx + 45, cy + 5, cx + 45, cy + 30);
    canvas.drawPath(bodyPath, linePaint);

    // Shirt Neckline
    final Path neckPath = Path()
      ..moveTo(cx - 14, cy - 5)
      ..quadraticBezierTo(cx, cy + 8, cx + 14, cy - 5);
    canvas.drawPath(neckPath, linePaint);

    // Left Arm Waving (Upwards and Left)
    final Path leftArmPath = Path()
      ..moveTo(cx - 40, cy + 10)
      ..quadraticBezierTo(cx - 65, cy - 10, cx - 55, cy - 25);
    canvas.drawPath(leftArmPath, linePaint);

    // Left Hand (Waving Fingers)
    final Path handPath = Path()
      ..moveTo(cx - 55, cy - 25)
      ..quadraticBezierTo(cx - 65, cy - 35, cx - 60, cy - 40) // Thumb
      ..quadraticBezierTo(cx - 72, cy - 30, cx - 68, cy - 20);
    canvas.drawPath(handPath, linePaint);

    // Wave lines near hand
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx - 50, cy - 35), radius: 10),
      3.14,
      1.2,
      false,
      linePaint..strokeWidth = 1.6,
    );
    linePaint.strokeWidth = 2.2;

    // Right Arm (resting on desk / laptop)
    final Path rightArmPath = Path()
      ..moveTo(cx + 40, cy + 10)
      ..quadraticBezierTo(cx + 58, cy + 20, cx + 48, cy + 32);
    canvas.drawPath(rightArmPath, linePaint);

    // Legs / Knees sitting cross-legged
    final Path legsPath = Path()
      ..moveTo(cx - 65, deskY - 5)
      ..quadraticBezierTo(cx - 45, deskY - 25, cx - 25, deskY - 5)
      ..moveTo(cx + 25, deskY - 5)
      ..quadraticBezierTo(cx + 45, deskY - 25, cx + 65, deskY - 5);
    canvas.drawPath(legsPath, linePaint);

    // 3. Head & Face
    final double headY = cy - 38;
    final double headR = 20.0;

    // Head Outline
    canvas.drawCircle(Offset(cx, headY), headR, fillPaint);
    canvas.drawCircle(Offset(cx, headY), headR, linePaint);

    // Curly / Wavy Hair
    final Path hairPath = Path();
    final List<Offset> hairBumps = [
      Offset(cx - 18, headY - 10),
      Offset(cx - 24, headY - 22),
      Offset(cx - 12, headY - 32),
      Offset(cx, headY - 36),
      Offset(cx + 14, headY - 32),
      Offset(cx + 24, headY - 22),
      Offset(cx + 18, headY - 10),
    ];
    hairPath.moveTo(hairBumps[0].dx, hairBumps[0].dy);
    for (int i = 1; i < hairBumps.length; i++) {
      hairPath.quadraticBezierTo(
        hairBumps[i - 1].dx,
        hairBumps[i - 1].dy,
        hairBumps[i].dx,
        hairBumps[i].dy,
      );
    }
    hairPath.close();
    canvas.drawPath(hairPath, fillDarkPaint);

    // Glasses (Two Circles + Bridge)
    final double glassR = 7.0;
    canvas.drawCircle(Offset(cx - 9, headY - 2), glassR, linePaint);
    canvas.drawCircle(Offset(cx + 9, headY - 2), glassR, linePaint);
    canvas.drawLine(Offset(cx - 2, headY - 2), Offset(cx + 2, headY - 2), linePaint);

    // Eyes (Dots inside glasses)
    canvas.drawCircle(Offset(cx - 9, headY - 2), 1.8, fillDarkPaint);
    canvas.drawCircle(Offset(cx + 9, headY - 2), 1.8, fillDarkPaint);

    // Smile
    final Path smilePath = Path()
      ..moveTo(cx - 5, headY + 8)
      ..quadraticBezierTo(cx, headY + 13, cx + 5, headY + 8);
    canvas.drawPath(smilePath, linePaint);

    // 4. Over-ear Headphones
    // Headband
    final Path headbandPath = Path()
      ..moveTo(cx - headR - 2, headY - 5)
      ..quadraticBezierTo(cx, headY - headR - 22, cx + headR + 2, headY - 5);
    canvas.drawPath(headbandPath, linePaint..strokeWidth = 3.5);
    linePaint.strokeWidth = 2.2;

    // Ear Cups (Rectangles / Pill shapes on sides of head)
    final RRect leftCup = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx - headR - 5, headY - 2), width: 12, height: 24),
      const Radius.circular(5),
    );
    final RRect rightCup = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx + headR + 5, headY - 2), width: 12, height: 24),
      const Radius.circular(5),
    );
    canvas.drawRRect(leftCup, fillPaint);
    canvas.drawRRect(leftCup, linePaint);
    canvas.drawRRect(rightCup, fillPaint);
    canvas.drawRRect(rightCup, linePaint);

    // Sound wave lines coming out of right ear cup
    canvas.drawLine(
      Offset(cx + headR + 15, headY - 14),
      Offset(cx + headR + 24, headY - 22),
      linePaint,
    );
    canvas.drawLine(
      Offset(cx + headR + 16, headY - 2),
      Offset(cx + headR + 26, headY - 4),
      linePaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
