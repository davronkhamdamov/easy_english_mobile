import 'package:flutter/material.dart';

class CefrLevelChips extends StatelessWidget {
  final String selectedLevel;
  final ValueChanged<String> onLevelSelected;

  const CefrLevelChips({
    super.key,
    required this.selectedLevel,
    required this.onLevelSelected,
  });

  static const levels = ['All', 'A1', 'A2', 'B1', 'B2', 'C1'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: levels.map((lvl) {
          final isSelected = selectedLevel.toUpperCase() == lvl.toUpperCase();
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(lvl),
              selected: isSelected,
              onSelected: (_) => onLevelSelected(lvl),
              selectedColor: theme.colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
