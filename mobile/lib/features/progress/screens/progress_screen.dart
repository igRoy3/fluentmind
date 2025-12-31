import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    // Load stats when progress screen is displayed
    Future.microtask(() => ref.read(statsProvider.notifier).loadStats());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statsState = ref.watch(statsProvider);
    final stats = statsState.stats;

    if (statsState.isLoading && stats == null) {
      return Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Your Progress',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ).animate().fadeIn(duration: 500.ms),
              ),
            ),

            // Stats Overview Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.local_fire_department_rounded,
                        iconColor: AppColors.accentYellow,
                        value: '${stats?.currentStreak ?? 0}',
                        label: 'Day Streak',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.mic_rounded,
                        iconColor: AppColors.primary,
                        value: '${stats?.totalSessions ?? 0}',
                        label: 'Sessions',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.star_rounded,
                        iconColor: AppColors.accentGreen,
                        value: '${stats?.avgPronunciationScore?.round() ?? 0}',
                        label: 'Avg Score',
                        isDark: isDark,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Weekly Progress Chart
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child:
                    Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  isDark ? 0.3 : 0.05,
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Weekly Activity',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary,
                                    ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 200,
                                child: _WeeklyChart(isDark: isDark),
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 500.ms)
                        .slideY(begin: 0.1),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Score Distribution
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child:
                    Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  isDark ? 0.3 : 0.05,
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Score Breakdown',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary,
                                    ),
                              ),
                              const SizedBox(height: 20),
                              _ScoreBreakdownItem(
                                label: 'Pronunciation',
                                score: 88,
                                color: AppColors.primary,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 16),
                              _ScoreBreakdownItem(
                                label: 'Grammar',
                                score: 82,
                                color: AppColors.secondary,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 16),
                              _ScoreBreakdownItem(
                                label: 'Fluency',
                                score: 79,
                                color: AppColors.accent,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 16),
                              _ScoreBreakdownItem(
                                label: 'Vocabulary',
                                score: 91,
                                color: AppColors.accentGreen,
                                isDark: isDark,
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 500.ms)
                        .slideY(begin: 0.1),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Achievements
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Achievements',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _AchievementCard(
                      icon: Icons.local_fire_department_rounded,
                      title: '7 Day Streak',
                      isUnlocked: true,
                      isDark: isDark,
                    ),
                    _AchievementCard(
                      icon: Icons.emoji_events_rounded,
                      title: 'First 90+',
                      isUnlocked: true,
                      isDark: isDark,
                    ),
                    _AchievementCard(
                      icon: Icons.bolt_rounded,
                      title: '10 Sessions',
                      isUnlocked: true,
                      isDark: isDark,
                    ),
                    _AchievementCard(
                      icon: Icons.diamond_rounded,
                      title: 'Perfect Score',
                      isUnlocked: false,
                      isDark: isDark,
                    ),
                  ],
                ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final bool isDark;

  const _WeeklyChart({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    days[value.toInt()],
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                );
              },
              reservedSize: 28,
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          _makeBarGroup(0, 75),
          _makeBarGroup(1, 82),
          _makeBarGroup(2, 68),
          _makeBarGroup(3, 90),
          _makeBarGroup(4, 85),
          _makeBarGroup(5, 88),
          _makeBarGroup(6, 92),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: AppColors.primaryGradient,
          width: 24,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }
}

class _ScoreBreakdownItem extends StatelessWidget {
  final String label;
  final int score;
  final Color color;
  final bool isDark;

  const _ScoreBreakdownItem({
    required this.label,
    required this.score,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            Text(
              '$score%',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 100,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isUnlocked;
  final bool isDark;

  const _AchievementCard({
    required this.icon,
    required this.title,
    required this.isUnlocked,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked
            ? (isDark ? AppColors.cardDark : Colors.white)
            : (isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariant),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? AppColors.accentYellow.withOpacity(0.15)
                  : (isDark ? AppColors.disabledDark : AppColors.disabled)
                        .withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isUnlocked
                  ? AppColors.accentYellow
                  : (isDark ? AppColors.textHintDark : AppColors.textHint),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: isUnlocked
                  ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)
                  : (isDark ? AppColors.textHintDark : AppColors.textHint),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
