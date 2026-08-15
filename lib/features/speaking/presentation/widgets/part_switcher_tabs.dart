import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';

class PartSwitcherTabs extends StatelessWidget {
  final int selectedPart;
  final ValueChanged<int> onPartSelected;

  const PartSwitcherTabs({
    super.key,
    required this.selectedPart,
    required this.onPartSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final parts = [
      {'part': 1, 'label': 'Part 1'},
      {'part': 2, 'label': 'Part 2 (Cue Card)'},
      {'part': 3, 'label': 'Part 3'},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: parts.map((item) {
          final part = item['part'] as int;
          final label = item['label'] as String;
          final isSelected = selectedPart == part;

          return Expanded(
            child: GestureDetector(
              onTap: () => onPartSelected(part),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isSelected
                          ? Colors.white
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
