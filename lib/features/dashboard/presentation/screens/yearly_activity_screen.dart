import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Full-screen 12-Month Activity Heatmap Screen inspired by habit tracking apps.
/// Displays month-by-month activity grids (3x4 layout) for the full year.
class YearlyActivityScreen extends StatelessWidget {
  final String title;
  final String year;
  final Map<int, Map<int, int>>? yearlyData; // monthIndex (0-11) -> {dayIndex -> activityLevel}

  const YearlyActivityScreen({
    super.key,
    this.title = 'Learning Activity',
    this.year = '2026',
    this.yearlyData,
  });

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar',
    'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep',
    'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPrimaryColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
            size: 30,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textPrimaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title & Year
              Text(
                title,
                style: TextStyle(
                  color: textPrimaryColor,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                year,
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),

              // 3x4 Grid of 12 Months
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 12,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 24,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (context, monthIndex) {
                  final monthName = _months[monthIndex];
                  final monthMap = yearlyData?[monthIndex] ?? _generateMockMonthData(monthIndex);
                  return _buildMonthBlock(context, monthName, monthMap, isDark);
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthBlock(
    BuildContext context,
    String monthName,
    Map<int, int> dayActivity,
    bool isDark,
  ) {
    final textPrimaryColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          monthName,
          style: TextStyle(
            color: textPrimaryColor,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tileSize = (constraints.maxWidth - (6 * 3.0)) / 7;
              return Wrap(
                spacing: 3,
                runSpacing: 3,
                children: List.generate(28, (dayIdx) {
                  final level = dayActivity[dayIdx] ?? 0;
                  return Container(
                    width: tileSize.clamp(6.0, 14.0),
                    height: tileSize.clamp(6.0, 14.0),
                    decoration: BoxDecoration(
                      color: _getHeatmapColor(level, isDark),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getHeatmapColor(int level, bool isDark) {
    if (level == 0) {
      return isDark ? const Color(0xFF2D2E33) : const Color(0xFFE9ECEF);
    } else if (level == 1) {
      return const Color(0xFFD8F3DC); // Light green
    } else if (level == 2) {
      return const Color(0xFF74C69D); // Medium green
    } else if (level == 3) {
      return const Color(0xFF2D6A4F); // Deep green
    } else {
      return const Color(0xFF1B4332); // Dark green
    }
  }

  Map<int, int> _generateMockMonthData(int monthIndex) {
    final Map<int, int> data = {};
    for (int day = 0; day < 28; day++) {
      // Create varied activity density
      final seed = (monthIndex * 7 + day) % 5;
      data[day] = (seed == 0 || seed == 2 || seed == 4) ? (seed % 4) : 0;
    }
    return data;
  }
}
