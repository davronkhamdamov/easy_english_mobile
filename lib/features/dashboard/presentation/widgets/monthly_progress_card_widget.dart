import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Monthly progress card widget inspired by Apple Health/Fitness dashboard.
/// Renders a 3-month activity dot grid with glowing active day indicators
/// and a bottom circular gauge progress status.
/// Automatically adapts between Light and Dark theme modes using global color tokens.
class MonthlyProgressCardWidget extends StatelessWidget {
  final List<String> months;
  final Map<int, Set<int>> activeDaysPerMonth;
  final String gaugeNumber;
  final double gaugeProgress;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const MonthlyProgressCardWidget({
    super.key,
    this.months = const ['Jan', 'Feb', 'Mar'],
    this.activeDaysPerMonth = const {
      0: {4, 12, 19},
      1: {5, 11, 18},
      2: {3, 10},
    },
    this.gaugeNumber = '2',
    this.gaugeProgress = 0.65,
    this.title = 'Monthly Progress',
    this.subtitle = '18 active days this term',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBgColor = isDark ? const Color(0xFF222327) : AppColors.lightSurface;
    final textPrimaryColor = isDark ? Colors.white : AppColors.lightTextPrimary;
    final textSecondaryColor =
        isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.lightTextSecondary;
    final dividerColor = isDark ? const Color(0xFF2E2F35) : AppColors.lightBorder;

    final cardBorder = isDark
        ? null
        : Border.all(color: AppColors.lightBorder, width: 1);
    final cardShadow = isDark
        ? null
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ];

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(22),
        border: cardBorder,
        boxShadow: cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Section: 3 Months Activity Dot Grids with Glowing Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(months.length, (monthIdx) {
                    final monthName = months[monthIdx];
                    final activeSet = activeDaysPerMonth[monthIdx] ?? {};
                    return _buildMonthGrid(monthName, activeSet, textPrimaryColor, isDark);
                  }),
                ),
                const SizedBox(height: 20),
                Divider(
                  color: dividerColor,
                  height: 1,
                  thickness: 1,
                ),
                const SizedBox(height: 16),

                // Bottom Section: Ring Gauge + Title & Subtitle
                Row(
                  children: [
                    _RingGaugeWidget(
                      progress: gaugeProgress,
                      label: gaugeNumber,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: textPrimaryColor,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: textSecondaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthGrid(
    String monthName,
    Set<int> activeDayIndices,
    Color textPrimaryColor,
    bool isDark,
  ) {
    return Column(
      children: [
        Text(
          monthName,
          style: TextStyle(
            color: textPrimaryColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 78,
          child: Wrap(
            spacing: 7,
            runSpacing: 7,
            children: List.generate(28, (index) {
              final isActive = activeDayIndices.contains(index);
              return _buildDot(isActive: isActive, isDark: isDark);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildDot({required bool isActive, required bool isDark}) {
    Color activeColor;
    Color inactiveColor;
    List<BoxShadow>? shadow;

    if (isDark) {
      activeColor = Colors.white;
      inactiveColor = Colors.white.withValues(alpha: 0.15);
      shadow = isActive
          ? [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.85),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ]
          : null;
    } else {
      activeColor = AppColors.primary;
      inactiveColor = AppColors.lightBorder;
      shadow = isActive
          ? [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ]
          : null;
    }

    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? activeColor : inactiveColor,
        boxShadow: shadow,
      ),
    );
  }
}

/// Custom circular ring gauge with background track and progress arc.
class _RingGaugeWidget extends StatelessWidget {
  final double progress;
  final String label;
  final bool isDark;

  static const double size = 46.0;

  const _RingGaugeWidget({
    required this.progress,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : AppColors.lightTextPrimary;
    final trackColor = isDark ? const Color(0xFF38383E) : AppColors.lightBorder;
    final arcColor = isDark ? Colors.white : AppColors.primary;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(size, size),
            painter: _RingGaugePainter(
              progress: progress,
              trackColor: trackColor,
              arcColor: arcColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingGaugePainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color arcColor;

  _RingGaugePainter({
    required this.progress,
    required this.trackColor,
    required this.arcColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 3.8;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track Paint
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress Arc Paint
    final progressPaint = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -1.5707963267948966; // Top (-pi/2)
    final sweepAngle = 2 * 3.141592653589793 * progress.clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingGaugePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.arcColor != arcColor;
}
