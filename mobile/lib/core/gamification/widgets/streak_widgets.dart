import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../models/gamification_models.dart';

/// Animated streak indicator with fire icon
class StreakIndicator extends StatelessWidget {
  final int streak;
  final bool showAnimation;
  final bool compact;
  final bool isDark;

  const StreakIndicator({
    super.key,
    required this.streak,
    this.showAnimation = false,
    this.compact = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (streak <= 0) return const SizedBox.shrink();

    final color = _getStreakColor(streak);

    Widget indicator = Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(compact ? 12 : 16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: color,
            size: compact ? 16 : 20,
          ),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: TextStyle(
              color: color,
              fontSize: compact ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: 4),
            Text(
              'day${streak > 1 ? 's' : ''}',
              style: TextStyle(
                color: color.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );

    if (showAnimation) {
      indicator = indicator
          .animate(onComplete: (controller) => controller.repeat(reverse: true))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.1, 1.1),
            duration: 600.ms,
          );
    }

    return indicator;
  }

  Color _getStreakColor(int streak) {
    if (streak >= 30) return AppColors.error;
    if (streak >= 7) return AppColors.warning;
    return AppColors.accentYellow;
  }
}

/// Large streak celebration card
class StreakCard extends StatelessWidget {
  final int streak;
  final int longestStreak;
  final bool isDark;
  final VoidCallback? onTap;

  const StreakCard({
    super.key,
    required this.streak,
    required this.longestStreak,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final message = MotivationalMessages.getStreakMessage(streak);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.accentYellow, AppColors.warning],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.warning.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Fire icon with glow
                Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.local_fire_department_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    )
                    .animate(onComplete: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.1, 1.1),
                      duration: 800.ms,
                    ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$streak Day Streak!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _StreakStat(
                  label: 'Current',
                  value: '$streak',
                  icon: Icons.trending_up_rounded,
                ),
                const SizedBox(width: 24),
                _StreakStat(
                  label: 'Longest',
                  value: '$longestStreak',
                  icon: Icons.emoji_events_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StreakStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 18),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Streak freeze indicator (future feature)
class StreakFreeze extends StatelessWidget {
  final int freezesAvailable;
  final bool isDark;

  const StreakFreeze({
    super.key,
    required this.freezesAvailable,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.ac_unit_rounded, color: AppColors.info, size: 18),
          const SizedBox(width: 6),
          Text(
            '$freezesAvailable',
            style: TextStyle(
              color: AppColors.info,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Freeze${freezesAvailable != 1 ? 's' : ''}',
            style: TextStyle(
              color: AppColors.info.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Daily goal progress widget
class DailyGoalWidget extends StatelessWidget {
  final DailyGoal goal;
  final bool compact;
  final bool isDark;
  final VoidCallback? onTap;

  const DailyGoalWidget({
    super.key,
    required this.goal,
    this.compact = false,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompact();
    }
    return _buildFull();
  }

  Widget _buildCompact() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: goal.isComplete
              ? AppColors.success.withValues(alpha: 0.15)
              : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: goal.isComplete
                ? AppColors.success.withValues(alpha: 0.3)
                : (isDark ? AppColors.dividerDark : AppColors.divider),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    value: goal.overallProgress,
                    strokeWidth: 3,
                    backgroundColor: isDark
                        ? AppColors.surfaceVariantDark
                        : AppColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation(
                      goal.isComplete ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ),
                if (goal.isComplete)
                  Icon(Icons.check, color: AppColors.success, size: 14),
              ],
            ),
            const SizedBox(width: 8),
            Text(
              goal.isComplete ? 'Goal Complete!' : 'Daily Goal',
              style: TextStyle(
                color: goal.isComplete
                    ? AppColors.success
                    : (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFull() {
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
                'Daily Goal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              if (goal.isComplete)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Complete!',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // XP Goal
          _GoalRow(
            icon: Icons.stars_rounded,
            label: 'Earn XP',
            current: goal.earnedXP,
            target: goal.targetXP,
            color: AppColors.accentYellow,
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          // Words Goal
          _GoalRow(
            icon: Icons.school_rounded,
            label: 'Learn Words',
            current: goal.learnedWords,
            target: goal.targetWords,
            color: AppColors.primary,
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          // Games Goal
          _GoalRow(
            icon: Icons.sports_esports_rounded,
            label: 'Play Games',
            current: goal.playedGames,
            target: goal.targetGames,
            color: AppColors.accentGreen,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int current;
  final int target;
  final Color color;
  final bool isDark;

  const _GoalRow({
    required this.icon,
    required this.label,
    required this.current,
    required this.target,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final isComplete = current >= target;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '$current / $target',
                    style: TextStyle(
                      fontSize: 12,
                      color: isComplete
                          ? AppColors.success
                          : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary),
                      fontWeight: isComplete
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Stack(
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    height: 6,
                    width: MediaQuery.of(context).size.width * progress * 0.55,
                    decoration: BoxDecoration(
                      color: isComplete ? AppColors.success : color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (isComplete)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 20,
            ),
          ),
      ],
    );
  }
}

/// Weekly streak calendar view
class WeeklyStreakCalendar extends StatelessWidget {
  final List<bool> daysCompleted; // Last 7 days, starting from today
  final bool isDark;

  const WeeklyStreakCalendar({
    super.key,
    required this.daysCompleted,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final now = DateTime.now();
    final currentDayIndex = now.weekday - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        final isToday = index == currentDayIndex;
        final isCompleted =
            index < daysCompleted.length && daysCompleted[index];
        final isPast = index < currentDayIndex;

        return Column(
          children: [
            Text(
              days[index],
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.success
                    : (isToday
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : (isDark
                                ? AppColors.surfaceVariantDark
                                : AppColors.surfaceVariant)),
                shape: BoxShape.circle,
                border: isToday
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : (isPast && !isCompleted
                          ? Icon(
                              Icons.close,
                              color: AppColors.error.withValues(alpha: 0.5),
                              size: 16,
                            )
                          : null),
              ),
            ),
          ],
        );
      }),
    );
  }
}

/// Streak milestone celebration
class StreakMilestoneCard extends StatelessWidget {
  final int milestone;
  final bool isDark;
  final VoidCallback onDismiss;

  const StreakMilestoneCard({
    super.key,
    required this.milestone,
    required this.isDark,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    String title;
    String message;
    int xpBonus;

    switch (milestone) {
      case 3:
        title = '3-Day Streak! 🔥';
        message = 'You\'re building momentum!';
        xpBonus = XPRewards.streakBonus3Days;
        break;
      case 7:
        title = 'Week Warrior! ⚡';
        message = 'A full week of learning!';
        xpBonus = XPRewards.streakBonus7Days;
        break;
      case 30:
        title = 'Monthly Master! 🏆';
        message = '30 days of dedication!';
        xpBonus = XPRewards.streakBonus30Days;
        break;
      default:
        title = '$milestone-Day Streak!';
        message = 'Keep up the amazing work!';
        xpBonus = 0;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.warning, AppColors.accentYellow],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
                Icons.local_fire_department_rounded,
                color: Colors.white,
                size: 64,
              )
              .animate(onComplete: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.2, 1.2),
                duration: 600.ms,
              ),

          const SizedBox(height: 16),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            message,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),

          if (xpBonus > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, color: Colors.white, size: 18),
                  Text(
                    '$xpBonus XP Bonus!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onDismiss,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.warning,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Awesome!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
