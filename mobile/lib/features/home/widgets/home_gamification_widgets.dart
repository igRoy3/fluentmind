import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/gamification/gamification.dart';

/// Home screen gamification card showing XP, level, and streak
class HomeGamificationCard extends ConsumerWidget {
  const HomeGamificationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gamificationProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    if (state.isLoading) {
      return const SizedBox.shrink();
    }

    final progress = state.userProgress;

    return GestureDetector(
      onTap: () => context.push('/progress-dashboard'),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 14 : 20),
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
                  width: isSmallScreen ? 48 : 60,
                  height: isSmallScreen ? 48 : 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${progress.level}',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 18 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        Text(
                          'LVL',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 8 : 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 10 : 16),

                // Level info and XP
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          LevelSystem.titles[progress.level - 1],
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${progress.totalXP} XP',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                // Streak
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 10 : 14,
                    vertical: isSmallScreen ? 8 : 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '🔥',
                        style: TextStyle(fontSize: isSmallScreen ? 14 : 18),
                      ),
                      SizedBox(width: isSmallScreen ? 4 : 6),
                      Text(
                        '${progress.currentStreak}',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),

            // Level progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Level ${progress.level + 1}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      '${progress.currentLevelXP}/${progress.xpToNextLevel} XP',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: 8,
                          width: constraints.maxWidth * progress.levelProgress,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }
}

/// Compact daily goal widget for home screen
class HomeDailyGoalWidget extends ConsumerWidget {
  const HomeDailyGoalWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(gamificationProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    if (state.isLoading) {
      return const SizedBox.shrink();
    }

    final goal = state.userProgress.dailyGoal;
    final progress = (goal.xpEarned / goal.xpTarget).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () => context.push('/progress-dashboard'),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circle progress
            SizedBox(
              width: isSmallScreen ? 40 : 50,
              height: isSmallScreen ? 40 : 50,
              child: Stack(
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: isSmallScreen ? 4 : 5,
                    backgroundColor: isDark
                        ? AppColors.surfaceVariantDark
                        : AppColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      goal.isCompleted
                          ? AppColors.success
                          : AppColors.accentYellow,
                    ),
                  ),
                  Center(
                    child: goal.isCompleted
                        ? Icon(
                            Icons.check_rounded,
                            color: AppColors.success,
                            size: isSmallScreen ? 18 : 24,
                          )
                        : Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 10 : 12,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            SizedBox(width: isSmallScreen ? 10 : 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      goal.isCompleted
                          ? 'Daily Goal Complete! 🎉'
                          : 'Daily Goal',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 13 : 15,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      goal.isCompleted
                          ? 'Come back tomorrow!'
                          : '${goal.xpEarned}/${goal.xpTarget} XP • ${goal.gamesPlayed}/${goal.gamesTarget} games',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              size: isSmallScreen ? 14 : 16,
              color: isDark ? AppColors.textHintDark : AppColors.textHint,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1);
  }
}

/// Quick stats row for home screen
class HomeQuickStats extends ConsumerWidget {
  const HomeQuickStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(gamificationProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    if (state.isLoading) {
      return const SizedBox.shrink();
    }

    final progress = state.userProgress;
    final unlockedAchievements = state.achievements
        .where((a) => a.isUnlocked)
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildQuickStat(
            '${progress.totalGamesPlayed}',
            'Games',
            Icons.sports_esports_rounded,
            AppColors.primary,
            isDark,
            isSmallScreen,
          ),
        ),
        SizedBox(width: isSmallScreen ? 6 : 10),
        Expanded(
          child: _buildQuickStat(
            '${progress.totalWordsLearned}',
            'Words',
            Icons.book_rounded,
            AppColors.secondary,
            isDark,
            isSmallScreen,
          ),
        ),
        SizedBox(width: isSmallScreen ? 6 : 10),
        Expanded(
          child: _buildQuickStat(
            '$unlockedAchievements',
            'Awards',
            Icons.emoji_events_rounded,
            AppColors.accentYellow,
            isDark,
            isSmallScreen,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildQuickStat(
    String value,
    String label,
    IconData icon,
    Color color,
    bool isDark,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 10 : 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: isSmallScreen ? 18 : 22),
          SizedBox(height: isSmallScreen ? 4 : 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 9 : 11,
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

/// Streak reminder widget for home screen
class HomeStreakReminder extends ConsumerWidget {
  const HomeStreakReminder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(gamificationProvider);

    if (state.isLoading) {
      return const SizedBox.shrink();
    }

    final progress = state.userProgress;
    final hasPlayedToday = progress.dailyGoal.gamesPlayed > 0;

    // Don't show if already played today
    if (hasPlayedToday) {
      return const SizedBox.shrink();
    }

    // Show streak at risk warning if user has a streak
    if (progress.currentStreak > 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.warning.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🔥', style: TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keep your streak alive!',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Play today to maintain your ${progress.currentStreak}-day streak',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 300.ms).shake(hz: 2, rotation: 0.02, delay: 500.ms);
    }

    return const SizedBox.shrink();
  }
}
