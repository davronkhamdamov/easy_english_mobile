import 'package:flutter/material.dart';

class WordBankFilterBar extends StatelessWidget {
  final String searchQuery;
  final String selectedCefr;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCefrChanged;

  static const List<String> cefrLevels = ['All', 'B2', 'C1', 'C2'];

  const WordBankFilterBar({
    super.key,
    required this.searchQuery,
    required this.selectedCefr,
    required this.onSearchChanged,
    required this.onCefrChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Input Bar
        TextField(
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search vocabulary or definitions...',
            hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurface),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: theme.colorScheme.onSurface),
                    onPressed: () => onSearchChanged(''),
                  )
                : null,
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.15 : 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.15 : 0.2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // CEFR Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: cefrLevels.map((level) {
              final isSelected = selectedCefr.toUpperCase() == level.toUpperCase();
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(level),
                  selected: isSelected,
                  onSelected: (_) => onCefrChanged(level),
                  selectedColor: theme.colorScheme.onSurface,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? theme.colorScheme.surface
                        : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor:
                      theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  side: BorderSide(
                    color: isSelected
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.outline.withValues(alpha: isDark ? 0.2 : 0.15),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
