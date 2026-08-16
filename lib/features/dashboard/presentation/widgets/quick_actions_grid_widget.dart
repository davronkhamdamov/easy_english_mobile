import 'package:flutter/material.dart';
import '../../../../design_system/components/card/ds_card.dart';
import 'quick_action_item_tile.dart';

/// Data class representing a Quick Action module item.
class QuickActionModuleData {
  final String key;
  final String label;
  final IconData icon;
  final Color? color;

  const QuickActionModuleData({
    required this.key,
    required this.label,
    required this.icon,
    this.color,
  });
}

/// Quick Actions Grid component for the Dashboard.
/// Renders a 4-column grid of IELTS feature modules inside a clean monochrome card container.
class QuickActionsGridWidget extends StatelessWidget {
  final Function(String moduleKey)? onModuleTap;
  final String title;

  static const List<QuickActionModuleData> defaultModules = [
    QuickActionModuleData(
      key: 'ai_coach',
      label: 'AI Coach',
      icon: Icons.psychology_outlined,
    ),
    QuickActionModuleData(
      key: 'writing',
      label: 'Writing',
      icon: Icons.edit_note_rounded,
    ),
    QuickActionModuleData(
      key: 'speaking',
      label: 'Speaking',
      icon: Icons.mic_none_rounded,
    ),
    QuickActionModuleData(
      key: 'placement',
      label: 'Placement',
      icon: Icons.assignment_turned_in_outlined,
    ),
    QuickActionModuleData(
      key: 'grammar',
      label: 'Grammar',
      icon: Icons.spellcheck_rounded,
    ),
    QuickActionModuleData(
      key: 'sentence',
      label: 'Sentence',
      icon: Icons.extension_outlined,
    ),
    QuickActionModuleData(
      key: 'word_bank',
      label: 'Word Bank',
      icon: Icons.style_outlined,
    ),
    QuickActionModuleData(
      key: 'mock_exam',
      label: 'Mock Exam',
      icon: Icons.school_outlined,
    ),
  ];

  const QuickActionsGridWidget({
    super.key,
    this.onModuleTap,
    this.title = 'Quick actions',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        DSCard(
          variant: DSCardVariant.elevated,
          interactive: false,
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: defaultModules.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final module = defaultModules[index];
              return QuickActionItemTile(
                label: module.label,
                icon: module.icon,
                iconColor: module.color,
                onTap: () => onModuleTap?.call(module.key),
              );
            },
          ),
        ),
      ],
    );
  }
}
