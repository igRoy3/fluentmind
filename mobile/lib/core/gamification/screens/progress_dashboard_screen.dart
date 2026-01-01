import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../models/gamification_models.dart';
import '../providers/gamification_provider.dart';
import '../widgets/achievement_widgets.dart';
import '../widgets/streak_widgets.dart';
import '../widgets/feedback_widgets.dart';

/// Main progress dashboard screen
class ProgressDashboardScreen extends ConsumerStatefulWidget {
  const ProgressDashboardScreen({super.key});

  @override
  ConsumerState<ProgressDashboardScreen> createState() =>
      _ProgressDashboardScreenState();
}

class _ProgressDashboardScreenState
    extends ConsumerState<ProgressDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(gamificationProvider);

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            // Custom app bar
            SliverToBoxAdapter(child: _buildHeader(isDark, state)),

            // Tab bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Achievements'),
                    Tab(text: 'Statistics'),
                  ],
                ),
                isDark,
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(isDark, state),
              _buildAchievementsTab(isDark, state),
              _buildStatisticsTab(isDark, state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, GamificationState state) {
    final progress = state.userProgress;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Back button and title
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 48), // Balance the back button
            ],
          ),
          const SizedBox(height: 20),

          // Level and XP card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Level badge
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${progress.level}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Level info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LevelSystem.titles[progress.level - 1],
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${progress.totalXP} Total XP',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Streak
                    Column(
                      children: [
                        Text('🔥', style: const TextStyle(fontSize: 24)),
                        Text(
                          '${progress.currentStreak}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'days',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // XP Progress
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Level ${progress.level + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        Text(
                          '${progress.currentLevelXP}/${progress.xpToNextLevel} XP',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      children: [
                        Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: 10,
                          width:
                              MediaQuery.of(context).size.width *
                              0.85 *
                              progress.levelProgress,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.1),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(bool isDark, GamificationState state) {
    final progress = state.userProgress;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Daily goal
          DailyGoalWidget(
            goal: progress.dailyGoal,
            isDark: isDark,
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
          const SizedBox(height: 20),

          // Weekly streak calendar
          WeeklyStreakCalendar(
            daysCompleted: progress.weeklyStats.dailyCompletion,
            isDark: isDark,
          ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
          const SizedBox(height: 20),

          // Quick stats
          _buildQuickStats(isDark, progress),
          const SizedBox(height: 20),

          // Word mastery
          WordMasteryProgressCard(
            words: state.wordMasteryMap.values.toList(),
            isDark: isDark,
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
          const SizedBox(height: 20),

          // Recent achievements
          if (state.achievements.where((a) => a.isUnlocked).isNotEmpty)
            AchievementsSummary(
              achievements: state.achievements,
              isDark: isDark,
              onViewAll: () => _tabController.animateTo(1),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }

  Widget _buildQuickStats(bool isDark, UserProgress progress) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Games',
            '${progress.totalGamesPlayed}',
            Icons.sports_esports_rounded,
            AppColors.primary,
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Words',
            '${progress.totalWordsLearned}',
            Icons.book_rounded,
            AppColors.secondary,
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Best',
            '${progress.longestStreak}',
            Icons.local_fire_department_rounded,
            AppColors.warning,
            isDark,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab(bool isDark, GamificationState state) {
    final categories = AchievementCategory.values;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress summary
          _buildAchievementProgress(isDark, state),
          const SizedBox(height: 24),

          // By category
          ...categories.map((category) {
            final achievements = state.achievements
                .where((a) => a.category == category)
                .toList();
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: AchievementCategorySection(
                title: _getCategoryTitle(category),
                achievements: achievements,
                isDark: isDark,
                onAchievementTap: (a) => _showAchievementDetails(a, isDark),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAchievementProgress(bool isDark, GamificationState state) {
    final unlocked = state.achievements.where((a) => a.isUnlocked).length;
    final total = state.achievements.length;
    final progress = unlocked / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentYellow.withValues(alpha: 0.15),
            AppColors.warning.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Text(
                '$unlocked / $total',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Achievements Unlocked',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceVariantDark
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 12,
                width: MediaQuery.of(context).size.width * 0.8 * progress,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accentYellow, AppColors.warning],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab(bool isDark, GamificationState state) {
    final progress = state.userProgress;
    final weeklyStats = progress.weeklyStats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly XP chart
          _buildWeeklyXPChart(isDark, weeklyStats),
          const SizedBox(height: 24),

          // Detailed stats
          Text(
            'All Time Stats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          _buildDetailedStatRow(
            'Total XP',
            '${progress.totalXP}',
            Icons.star_rounded,
            AppColors.accentYellow,
            isDark,
          ),
          _buildDetailedStatRow(
            'Games Played',
            '${progress.totalGamesPlayed}',
            Icons.sports_esports_rounded,
            AppColors.primary,
            isDark,
          ),
          _buildDetailedStatRow(
            'Words Learned',
            '${progress.totalWordsLearned}',
            Icons.book_rounded,
            AppColors.secondary,
            isDark,
          ),
          _buildDetailedStatRow(
            'Current Streak',
            '${progress.currentStreak} days',
            Icons.local_fire_department_rounded,
            AppColors.warning,
            isDark,
          ),
          _buildDetailedStatRow(
            'Longest Streak',
            '${progress.longestStreak} days',
            Icons.emoji_events_rounded,
            AppColors.accentYellow,
            isDark,
          ),
          _buildDetailedStatRow(
            'Average Accuracy',
            '${(progress.averageAccuracy * 100).toInt()}%',
            Icons.gps_fixed_rounded,
            AppColors.accentGreen,
            isDark,
          ),

          const SizedBox(height: 24),

          // This week stats
          Text(
            'This Week',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          _buildDetailedStatRow(
            'XP Earned',
            '${weeklyStats.totalXP}',
            Icons.star_rounded,
            AppColors.accentYellow,
            isDark,
          ),
          _buildDetailedStatRow(
            'Games Played',
            '${weeklyStats.gamesPlayed}',
            Icons.sports_esports_rounded,
            AppColors.primary,
            isDark,
          ),
          _buildDetailedStatRow(
            'Practice Days',
            '${weeklyStats.dailyXP.where((xp) => xp > 0).length}/7',
            Icons.calendar_today_rounded,
            AppColors.secondary,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyXPChart(bool isDark, WeeklyStats stats) {
    final maxXP = stats.dailyXP.reduce((a, b) => a > b ? a : b);
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final today = DateTime.now().weekday - 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              Text(
                '${stats.totalXP} XP',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final xp = stats.dailyXP[index];
                final height = maxXP > 0 ? (xp / maxXP) * 120 : 0.0;
                final isToday = index == today;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (xp > 0)
                      Text(
                        '$xp',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isToday
                              ? AppColors.primary
                              : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary),
                        ),
                      ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300 + index * 50),
                      width: 32,
                      height: height.clamp(8.0, 120.0),
                      decoration: BoxDecoration(
                        color: isToday
                            ? AppColors.primary
                            : (xp > 0
                                  ? AppColors.primary.withValues(alpha: 0.4)
                                  : (isDark
                                        ? AppColors.surfaceVariantDark
                                        : AppColors.surfaceVariant)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      days[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isToday
                            ? AppColors.primary
                            : (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStatRow(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryTitle(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.streak:
        return '🔥 Streak';
      case AchievementCategory.xp:
        return '⭐ Experience';
      case AchievementCategory.accuracy:
        return '🎯 Accuracy';
      case AchievementCategory.games:
        return '🎮 Games';
      case AchievementCategory.words:
        return '📚 Vocabulary';
      case AchievementCategory.special:
        return '✨ Special';
    }
  }

  void _showAchievementDetails(Achievement achievement, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: achievement.isUnlocked
                    ? _getCategoryColor(
                        achievement.category,
                      ).withValues(alpha: 0.15)
                    : (isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.surfaceVariant),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: achievement.isUnlocked
                    ? Text(
                        achievement.icon,
                        style: const TextStyle(fontSize: 40),
                      )
                    : Icon(
                        Icons.lock_outline_rounded,
                        size: 36,
                        color: isDark
                            ? AppColors.textHintDark
                            : AppColors.textHint,
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              achievement.name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentYellow.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+${achievement.xpReward} XP',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentYellow,
                ),
              ),
            ),
            if (!achievement.isUnlocked && !achievement.isSecret) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceVariantDark
                                : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: 8,
                          width:
                              MediaQuery.of(context).size.width *
                              0.7 *
                              achievement.progress,
                          decoration: BoxDecoration(
                            color: _getCategoryColor(achievement.category),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${achievement.currentValue}/${achievement.targetValue}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.streak:
        return AppColors.warning;
      case AchievementCategory.xp:
        return AppColors.accentYellow;
      case AchievementCategory.accuracy:
        return AppColors.accentGreen;
      case AchievementCategory.games:
        return AppColors.primary;
      case AchievementCategory.words:
        return AppColors.secondary;
      case AchievementCategory.special:
        return AppColors.accent;
    }
  }
}

/// Sliver delegate for pinned tab bar
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final bool isDark;

  _SliverTabBarDelegate(this.tabBar, this.isDark);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: isDark ? AppColors.backgroundDark : AppColors.background,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
