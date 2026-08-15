import 'package:flutter/material.dart';

class WritingTaskSelector extends StatelessWidget {
  final String selectedTaskType; // 'task1' or 'task2'
  final ValueChanged<String> onTaskSelected;

  const WritingTaskSelector({
    super.key,
    required this.selectedTaskType,
    required this.onTaskSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isTask1 = selectedTaskType.toLowerCase() == 'task1';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: ChoiceChip(
              showCheckmark: false,
              label: const Center(
                child: Text(
                  'Task 1 (Graph/Diagram)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              selected: isTask1,
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isTask1 ? Colors.white : null,
              ),
              onSelected: (_) => onTaskSelected('task1'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ChoiceChip(
              showCheckmark: false,
              label: const Center(
                child: Text(
                  'Task 2 (Essay)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              selected: !isTask1,
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: !isTask1 ? Colors.white : null,
              ),
              onSelected: (_) => onTaskSelected('task2'),
            ),
          ),
        ],
      ),
    );
  }
}
