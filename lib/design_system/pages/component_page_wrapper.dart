import 'package:flutter/material.dart';
import '../design_system.dart';

class ComponentPageWrapper extends StatefulWidget {
  final String title;
  final String subtitle;
  final String category;
  final ThemeController themeController;
  final Widget playground;
  final Widget matrix;
  final Widget codeSnippet;
  final Widget specs;
  final VoidCallback? onBackToOverview;

  const ComponentPageWrapper({
    super.key,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.themeController,
    required this.playground,
    required this.matrix,
    required this.codeSnippet,
    required this.specs,
    this.onBackToOverview,
  });

  @override
  State<ComponentPageWrapper> createState() => _ComponentPageWrapperState();
}

class _ComponentPageWrapperState extends State<ComponentPageWrapper> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeController.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: widget.onBackToOverview != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: widget.onBackToOverview,
                tooltip: 'Back to Overview',
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  widget.category.toUpperCase(),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const Text('  /  ', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text(
                  widget.title,
                  style: AppTypography.label.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
            Text(
              widget.subtitle,
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => widget.themeController.toggleTheme(),
            tooltip: 'Toggle Theme',
            icon: AnimatedSwitcher(
              duration: AppAnimations.fast,
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                key: ValueKey<bool>(isDark),
                color: isDark ? AppColors.warning : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.tune_rounded, size: 18), text: 'Playground'),
            Tab(icon: Icon(Icons.grid_view_rounded, size: 18), text: 'Matrix'),
            Tab(icon: Icon(Icons.code_rounded, size: 18), text: 'Code'),
            Tab(icon: Icon(Icons.description_rounded, size: 18), text: 'API Specs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabPadding(widget.playground),
          _buildTabPadding(widget.matrix),
          _buildTabPadding(widget.codeSnippet),
          _buildTabPadding(widget.specs),
        ],
      ),
    );
  }

  Widget _buildTabPadding(Widget child) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: child,
        ),
      ),
    );
  }
}
