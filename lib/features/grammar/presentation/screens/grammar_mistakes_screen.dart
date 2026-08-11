import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/grammar_seed_data.dart';
import '../../domain/entities/grammar_mistake_record.dart';
import 'grammar_exercise_screen.dart';

/// Long-term Grammar Mistake Tracking & Error Log Screen.
class GrammarMistakesScreen extends StatefulWidget {
  final List<GrammarMistakeRecord>? initialMistakes;

  const GrammarMistakesScreen({super.key, this.initialMistakes});

  @override
  State<GrammarMistakesScreen> createState() => _GrammarMistakesScreenState();
}

class _GrammarMistakesScreenState extends State<GrammarMistakesScreen> {
  late List<GrammarMistakeRecord> _mistakes;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _mistakes = widget.initialMistakes ?? GrammarSeedData.sampleMistakes;
  }

  List<String> get _categories {
    final set = {'All'};
    for (final m in _mistakes) {
      set.add(m.topicCategory);
    }
    return set.toList();
  }

  List<GrammarMistakeRecord> get _filteredMistakes {
    return _mistakes.where((m) {
      final matchesCategory =
          _selectedCategory == 'All' || m.topicCategory == _selectedCategory;
      final matchesSearch =
          _searchQuery.isEmpty ||
          m.originalSentence.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          m.correctedSentence.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          m.explanation.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _toggleResolve(GrammarMistakeRecord mistake) {
    setState(() {
      final idx = _mistakes.indexWhere((m) => m.id == mistake.id);
      if (idx != -1) {
        _mistakes[idx] = _mistakes[idx].copyWith(
          isResolved: !_mistakes[idx].isResolved,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final filtered = _filteredMistakes;
    final unresolvedCount = _mistakes.where((m) => !m.isResolved).length;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Grammar Mistake Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Filtering by highest occurrence count.'),
                ),
              );
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Statistics Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildStatsCard(theme, isDark, unresolvedCount),
            ),
          ),

          // Search Bar & Category Filter Chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search mistake sentences or rules...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkSurface
                          : AppColors.lightSurface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Category Filter Chips horizontal scroll
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            selected: isSelected,
                            label: Text(cat),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary),
                            ),
                            selectedColor: AppColors.primary,
                            backgroundColor: isDark
                                ? AppColors.darkSurface
                                : AppColors.lightSurface,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Mistakes List
          if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 64,
                      color: AppColors.success.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No mistakes found!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Keep practicing exercises to maintain high accuracy.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final mistake = filtered[index];
                  return _buildMistakeCard(context, mistake, theme, isDark);
                }, childCount: filtered.length),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildStatsCard(ThemeData theme, bool isDark, int unresolvedCount) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statCol('Total Logged', '${_mistakes.length}', AppColors.primary),
          Container(
            width: 1,
            height: 40,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          _statCol('Unresolved', '$unresolvedCount', AppColors.warning),
          Container(
            width: 1,
            height: 40,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          _statCol(
            'Resolved',
            '${_mistakes.length - unresolvedCount}',
            AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _statCol(String label, String val, Color color) {
    return Column(
      children: [
        Text(
          val,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMistakeCard(
    BuildContext context,
    GrammarMistakeRecord mistake,
    ThemeData theme,
    bool isDark,
  ) {
    final isResolved = mistake.isResolved;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isResolved
              ? AppColors.success.withValues(alpha: 0.4)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              // Category Chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  mistake.topicCategory,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Occurrence Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: mistake.occurrenceCount >= 3
                      ? AppColors.danger.withValues(alpha: 0.15)
                      : AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.repeat_rounded,
                      size: 12,
                      color: mistake.occurrenceCount >= 3
                          ? AppColors.danger
                          : AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Occurred ${mistake.occurrenceCount}x',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: mistake.occurrenceCount >= 3
                            ? AppColors.danger
                            : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Resolved Status Toggle
              IconButton(
                icon: Icon(
                  isResolved
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked,
                  color: isResolved ? AppColors.success : Colors.grey,
                ),
                tooltip: isResolved ? 'Mark as Unresolved' : 'Mark as Resolved',
                onPressed: () => _toggleResolve(mistake),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Original (Incorrect) Sentence
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF450A0A) : AppColors.dangerLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.close_rounded,
                  color: AppColors.danger,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Original: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.danger,
                            fontSize: 13,
                          ),
                        ),
                        TextSpan(
                          text: mistake.originalSentence,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white : Colors.black87,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Corrected Sentence
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF064E3B) : AppColors.successLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_rounded,
                  color: AppColors.success,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Corrected: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                            fontSize: 13,
                          ),
                        ),
                        TextSpan(
                          text: mistake.correctedSentence,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Rule Explanation
          Text(
            'Rule Breakdown:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            mistake.explanation,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),

          const SizedBox(height: 12),

          // Practice Action Button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                // Find topic matching category for practice
                final sampleTopic = GrammarSeedData.sampleTopics.firstWhere(
                  (t) => t.title.toLowerCase().contains(
                    mistake.topicCategory.toLowerCase(),
                  ),
                  orElse: () => GrammarSeedData.sampleTopics.first,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        GrammarExerciseScreen(topic: sampleTopic),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: Text('Practice ${mistake.topicCategory}'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
