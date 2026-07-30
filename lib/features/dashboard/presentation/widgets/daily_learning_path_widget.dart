import 'package:flutter/material.dart';
import '../../domain/models/learning_path_model.dart';

class DailyLearningPathWidget extends StatefulWidget {
  final LearningPathResponse learningPath;
  final Function(DailyTask task)? onTaskTap;

  const DailyLearningPathWidget({
    super.key,
    required this.learningPath,
    this.onTaskTap,
  });

  @override
  State<DailyLearningPathWidget> createState() => _DailyLearningPathWidgetState();
}

class _DailyLearningPathWidgetState extends State<DailyLearningPathWidget> {
  int _selectedTab = 0;
  late Map<String, bool> _completedTaskState;

  @override
  void initState() {
    super.initState();
    _completedTaskState = {
      for (var t in widget.learningPath.todayPlan.tasks) t.id: t.isCompleted,
    };
  }

  Color _getModuleColor(String moduleType) {
    switch (moduleType.toLowerCase()) {
      case 'vocabulary':
      case 'flashcard':
        return Colors.amber.shade700;
      case 'grammar':
        return Colors.blue.shade700;
      case 'writing':
        return Colors.indigo.shade700;
      case 'speaking':
        return Colors.purple.shade700;
      case 'reading':
        return Colors.teal.shade700;
      case 'sentence_builder':
        return Colors.deepOrange.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  IconData _getModuleIcon(String moduleType) {
    switch (moduleType.toLowerCase()) {
      case 'vocabulary':
      case 'flashcard':
        return Icons.menu_book;
      case 'grammar':
        return Icons.spellcheck;
      case 'writing':
        return Icons.edit_note;
      case 'speaking':
        return Icons.mic;
      case 'reading':
        return Icons.article;
      case 'sentence_builder':
        return Icons.build;
      default:
        return Icons.assignment;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activePlan = _selectedTab == 0
        ? widget.learningPath.todayPlan
        : widget.learningPath.tomorrowPlan;

    final completedCount = _selectedTab == 0
        ? _completedTaskState.values.where((v) => v).length
        : 0;
    final totalCount = activePlan.tasks.length;
    final progressPct = totalCount > 0 ? (completedCount / totalCount) : 0.0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Tab Switcher (Today vs Tomorrow)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.route, color: theme.colorScheme.primary, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Daily Learning Path',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Row(
                    children: [
                      _buildTabButton('Today', 0),
                      _buildTabButton('Tomorrow', 1),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Focus Skill Banner & Progress Line
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FOCUS: ${activePlan.focusSkill}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _selectedTab == 0
                                  ? '$completedCount of $totalCount tasks completed (${(progressPct * 100).toInt()}%)'
                                  : 'Preview study schedule for tomorrow',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              '${activePlan.totalEstimatedMinutes} mins',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_selectedTab == 0) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progressPct,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tasks List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activePlan.tasks.length,
              separatorBuilder: (context, idx) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final task = activePlan.tasks[idx];
                final isDone = _selectedTab == 0
                    ? (_completedTaskState[task.id] ?? false)
                    : false;
                final modColor = _getModuleColor(task.moduleType);
                final modIcon = _getModuleIcon(task.moduleType);

                return InkWell(
                  onTap: () => widget.onTaskTap?.call(task),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDone ? Colors.grey.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDone
                            ? Colors.grey.shade300
                            : modColor.withValues(alpha: 0.3),
                        width: isDone ? 1 : 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Checkbox for Today's Plan
                        if (_selectedTab == 0)
                          Checkbox(
                            value: isDone,
                            activeColor: modColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) {
                              setState(() {
                                _completedTaskState[task.id] = val ?? false;
                              });
                            },
                          ),
                        const SizedBox(width: 4),

                        // Icon badge
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: modColor.withValues(alpha: 0.15),
                          child: Icon(modIcon, color: modColor, size: 18),
                        ),
                        const SizedBox(width: 12),

                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      task.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        decoration: isDone ? TextDecoration.lineThrough : null,
                                        color: isDone ? Colors.grey : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: modColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${task.durationMinutes}m',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: modColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                task.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDone ? Colors.grey : Colors.grey.shade700,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (task.targetObjective.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '🎯 ${task.targetObjective}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    color: isDone ? Colors.grey : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Action arrow
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right,
                          color: isDone ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int tabIdx) {
    final isSelected = _selectedTab == tabIdx;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = tabIdx;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4)]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
