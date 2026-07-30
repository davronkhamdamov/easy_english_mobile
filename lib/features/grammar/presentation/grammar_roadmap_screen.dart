import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../domain/grammar_model.dart';
import 'grammar_exercise_screen.dart';
import 'grammar_mistakes_screen.dart';

/// Adaptive Grammar Roadmap Visual Node Graph Progression Screen.
class GrammarRoadmapScreen extends StatefulWidget {
  final List<GrammarTopic>? initialTopics;

  const GrammarRoadmapScreen({Key? key, this.initialTopics}) : super(key: key);

  @override
  State<GrammarRoadmapScreen> createState() => _GrammarRoadmapScreenState();
}

class _GrammarRoadmapScreenState extends State<GrammarRoadmapScreen> {
  late List<GrammarTopic> _topics;
  int _mistakeCount = 4; // Mock initial count

  @override
  void initState() {
    super.initState();
    _topics = widget.initialTopics ?? GrammarSeedData.sampleTopics;
  }

  double get _overallMastery {
    if (_topics.isEmpty) return 0.0;
    final total = _topics.fold<double>(0.0, (sum, t) => sum + t.masteryPercentage);
    return total / _topics.length;
  }

  GrammarTopic? get _weakestTopic {
    final active = _topics.where((t) => t.status != GrammarTopicStatus.locked).toList();
    if (active.isEmpty) return null;
    active.sort((a, b) => a.masteryPercentage.compareTo(b.masteryPercentage));
    return active.first;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Grammar Roadmap', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Weak Topic Analysis',
            onPressed: _showWeakTopicDialog,
          ),
          IconButton(
            icon: const Icon(Icons.history_edu),
            tooltip: 'Mistake Tracker',
            onPressed: _navigateToMistakesScreen,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Header Card with Overall Mastery & Mistake Tracker shortcut
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: _buildHeaderCard(theme, isDark),
            ),
          ),

          // Weak Topic Alert Banner if applicable
          if (_weakestTopic != null && _weakestTopic!.masteryPercentage < 70)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: _buildWeakTopicBanner(theme, isDark, _weakestTopic!),
              ),
            ),

          // Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Visual Topic Progression',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                  Text(
                    '${_topics.where((t) => t.status == GrammarTopicStatus.completed).length}/${_topics.length} Mastered',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Visual Node Graph Progression List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final topic = _topics[index];
                  final isLast = index == _topics.length - 1;
                  return _buildNodeGraphItem(context, topic, index, isLast, theme, isDark);
                },
                childCount: _topics.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme, bool isDark) {
    final mastery = _overallMastery;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
              : [AppColors.primary, AppColors.primaryHover],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overall Grammar Mastery',
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${mastery.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),

              // Mistake Tracker Quick Button
              ElevatedButton.icon(
                onPressed: _navigateToMistakesScreen,
                icon: const Icon(Icons.warning_amber_rounded, size: 18),
                label: Text('Mistakes ($_mistakeCount)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Master Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: mastery / 100.0,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield_outlined, color: Colors.white70, size: 15),
                  const SizedBox(width: 4),
                  Text(
                    'Band 7.5 GRA Goal Alignment',
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                  ),
                ],
              ),
              Text(
                'Adaptive Learning Active',
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeakTopicBanner(ThemeData theme, bool isDark, GrammarTopic weakTopic) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C1C13) : AppColors.warningLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended Practice Target',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? Colors.amber[200] : const Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your accuracy in "${weakTopic.title}" is ${weakTopic.masteryPercentage.toStringAsFixed(0)}%. Practice to boost score!',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _startExercise(weakTopic),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Practice', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeGraphItem(
    BuildContext context,
    GrammarTopic topic,
    int index,
    bool isLast,
    ThemeData theme,
    bool isDark,
  ) {
    final status = topic.status;
    final isLocked = status == GrammarTopicStatus.locked;
    final isCurrent = status == GrammarTopicStatus.current;
    final isCompleted = status == GrammarTopicStatus.completed;

    Color badgeColor;
    IconData badgeIcon;
    if (isCompleted) {
      badgeColor = AppColors.success;
      badgeIcon = Icons.check_circle_rounded;
    } else if (isCurrent) {
      badgeColor = AppColors.primary;
      badgeIcon = Icons.play_circle_fill_rounded;
    } else {
      badgeColor = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
      badgeIcon = Icons.lock_outline_rounded;
    }

    Color cefrBgColor;
    switch (topic.cefrLevel.toUpperCase()) {
      case 'C2':
        cefrBgColor = Colors.purple;
        break;
      case 'C1':
        cefrBgColor = Colors.deepOrange;
        break;
      case 'B2':
        cefrBgColor = AppColors.secondary;
        break;
      case 'B1':
      default:
        cefrBgColor = AppColors.success;
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visual Node Line Column
          Column(
            children: [
              // Node Circle Avatar
              GestureDetector(
                onTap: () => _onTopicTapped(topic),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? badgeColor
                        : (isCompleted
                            ? badgeColor.withOpacity(0.2)
                            : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant)),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: badgeColor,
                      width: isCurrent ? 3.0 : 2.0,
                    ),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: badgeColor.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                  child: Icon(
                    badgeIcon,
                    color: isCurrent
                        ? Colors.white
                        : (isCompleted ? badgeColor : (isDark ? Colors.white38 : Colors.black38)),
                    size: 24,
                  ),
                ),
              ),

              // Connecting Line to next topic node
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 3,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.success.withOpacity(0.6)
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 14),

          // Topic Detail Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _onTopicTapped(topic),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCurrent
                            ? AppColors.primary.withOpacity(0.6)
                            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        width: isCurrent ? 1.5 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // CEFR Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: cefrBgColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: cefrBgColor.withOpacity(0.4)),
                              ),
                              child: Text(
                                topic.cefrLevel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: cefrBgColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Topic Status Tag
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: badgeColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                status.value.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: badgeColor,
                                ),
                              ),
                            ),
                            const Spacer(),

                            // Mastery Percent
                            Text(
                              '${topic.masteryPercentage.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isCompleted
                                    ? AppColors.success
                                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Title
                        Text(
                          topic.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isLocked
                                ? (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
                                : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Description
                        Text(
                          topic.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 12),

                        // Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: topic.masteryPercentage / 100.0,
                            minHeight: 6,
                            backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isCompleted
                                  ? AppColors.success
                                  : (isCurrent ? AppColors.primary : Colors.grey),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Card Action Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${topic.rules.length} Rules • ${topic.exercises.length} Exercises',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),

                            if (!isLocked)
                              ElevatedButton.icon(
                                onPressed: () => _startExercise(topic),
                                icon: Icon(
                                  isCompleted ? Icons.refresh : Icons.play_arrow_rounded,
                                  size: 16,
                                ),
                                label: Text(isCompleted ? 'Review' : 'Practice'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isCurrent ? AppColors.primary : AppColors.secondary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              )
                            else
                              const Text(
                                'Locked',
                                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onTopicTapped(GrammarTopic topic) {
    if (topic.status == GrammarTopicStatus.locked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Complete prerequisite topics to unlock "${topic.title}".'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    _showTopicDetailBottomSheet(topic);
  }

  void _showTopicDetailBottomSheet(GrammarTopic topic) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Level: ${topic.cefrLevel} • Mastery: ${topic.masteryPercentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                topic.description,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 16),
              const Text('Included Grammar Rules:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),

              ...topic.rules.map((rule) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rule.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rule.summary,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  )),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _startExercise(topic);
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start Interactive Practice', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _startExercise(GrammarTopic topic) async {
    final result = await Navigator.push<double>(
      context,
      MaterialPageRoute(
        builder: (context) => GrammarExerciseScreen(topic: topic),
      ),
    );

    if (result != null) {
      setState(() {
        final idx = _topics.indexWhere((t) => t.id == topic.id);
        if (idx != -1) {
          final updatedMastery = result;
          final updatedStatus = updatedMastery >= 90.0
              ? GrammarTopicStatus.completed
              : GrammarTopicStatus.current;
          
          _topics[idx] = _topics[idx].copyWith(
            masteryPercentage: updatedMastery,
            status: updatedStatus,
          );

          // Unlock next topic if current completed
          if (updatedStatus == GrammarTopicStatus.completed && idx + 1 < _topics.length) {
            if (_topics[idx + 1].status == GrammarTopicStatus.locked) {
              _topics[idx + 1] = _topics[idx + 1].copyWith(status: GrammarTopicStatus.current);
            }
          }
        }
      });
    }
  }

  void _navigateToMistakesScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GrammarMistakesScreen(),
      ),
    );
  }

  void _showWeakTopicDialog() {
    final weak = _weakestTopic;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.analytics, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Weak Topic Analysis'),
          ],
        ),
        content: Text(
          weak != null
              ? 'Based on exercise performance and mistake frequency, your primary area for improvement is "${weak.title}" (Mastery: ${weak.masteryPercentage.toStringAsFixed(0)}%).'
              : 'Great job! You have high mastery across all unlocked grammar topics.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (weak != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _startExercise(weak);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Practice Topic'),
            ),
        ],
      ),
    );
  }
}
