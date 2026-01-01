import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../models/gamification_models.dart';

/// Achievement badge widget
class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final bool compact;
  final bool showProgress;
  final bool isDark;
  final VoidCallback? onTap;

  const AchievementBadge({
    super.key,
    required this.achievement,
    this.compact = false,
    this.showProgress = true,
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
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: achievement.isUnlocked
              ? _getCategoryColor().withValues(alpha: 0.15)
              : (isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariant),
          shape: BoxShape.circle,
          border: Border.all(
            color: achievement.isUnlocked
                ? _getCategoryColor()
                : (isDark ? AppColors.dividerDark : AppColors.divider),
            width: 2,
          ),
        ),
        child: Center(
          child: achievement.isUnlocked
              ? Text(achievement.icon, style: const TextStyle(fontSize: 28))
              : Icon(
                  Icons.lock_outline_rounded,
                  color: isDark ? AppColors.textHintDark : AppColors.textHint,
                  size: 24,
                ),
        ),
      ),
    );
  }

  Widget _buildFull() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: achievement.isUnlocked
              ? Border.all(color: _getCategoryColor(), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Badge icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: achievement.isUnlocked
                    ? _getCategoryColor().withValues(alpha: 0.15)
                    : (isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.surfaceVariant),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: achievement.isUnlocked
                    ? Text(
                        achievement.icon,
                        style: const TextStyle(fontSize: 28),
                      )
                    : Icon(
                        Icons.lock_outline_rounded,
                        color: isDark
                            ? AppColors.textHintDark
                            : AppColors.textHint,
                        size: 24,
                      ),
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.isSecret && !achievement.isUnlocked
                        ? '???'
                        : achievement.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.isSecret && !achievement.isUnlocked
                        ? 'Secret achievement'
                        : achievement.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),

                  // Progress bar
                  if (showProgress &&
                      !achievement.isUnlocked &&
                      !achievement.isSecret) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Stack(
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
                                height: 6,
                                width: 150 * achievement.progress,
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${achievement.currentValue}/${achievement.targetValue}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Unlocked indicator
                  if (achievement.isUnlocked) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Unlocked',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentYellow.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '+${achievement.xpReward} XP',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.accentYellow,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (achievement.category) {
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

/// Achievement unlock celebration overlay
class AchievementUnlockCelebration extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback onDismiss;
  final bool isDark;

  const AchievementUnlockCelebration({
    super.key,
    required this.achievement,
    required this.onDismiss,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Achievement icon
              Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getCategoryColor(),
                          _getCategoryColor().withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _getCategoryColor().withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        achievement.icon,
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                  )
                  .animate()
                  .scale(
                    begin: const Offset(0, 0),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  )
                  .shimmer(delay: 600.ms, duration: 1000.ms),

              const SizedBox(height: 24),

              // Title
              Text(
                'Achievement Unlocked!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _getCategoryColor(),
                  letterSpacing: 1,
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 8),

              Text(
                achievement.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

              const SizedBox(height: 8),

              Text(
                achievement.description,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 20),

              // XP reward
              Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentYellow.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add,
                          color: AppColors.accentYellow,
                          size: 20,
                        ),
                        Text(
                          '${achievement.xpReward} XP',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentYellow,
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 500.ms)
                  .scale(begin: const Offset(0.8, 0.8)),

              const SizedBox(height: 28),

              // Dismiss button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onDismiss,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getCategoryColor(),
                    foregroundColor: Colors.white,
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
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (achievement.category) {
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

/// Grid of achievement badges
class AchievementsGrid extends StatelessWidget {
  final List<Achievement> achievements;
  final bool isDark;
  final Function(Achievement)? onAchievementTap;

  const AchievementsGrid({
    super.key,
    required this.achievements,
    required this.isDark,
    this.onAchievementTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return AchievementBadge(
              achievement: achievement,
              compact: true,
              isDark: isDark,
              onTap: () => onAchievementTap?.call(achievement),
            )
            .animate(delay: Duration(milliseconds: 50 * index))
            .fadeIn()
            .scale(begin: const Offset(0.8, 0.8));
      },
    );
  }
}

/// Achievement category section
class AchievementCategorySection extends StatelessWidget {
  final String title;
  final List<Achievement> achievements;
  final bool isDark;
  final Function(Achievement)? onAchievementTap;

  const AchievementCategorySection({
    super.key,
    required this.title,
    required this.achievements,
    required this.isDark,
    this.onAchievementTap,
  });

  @override
  Widget build(BuildContext context) {
    final unlocked = achievements.where((a) => a.isUnlocked).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$unlocked/${achievements.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...achievements.map(
          (achievement) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AchievementBadge(
              achievement: achievement,
              isDark: isDark,
              onTap: () => onAchievementTap?.call(achievement),
            ),
          ),
        ),
      ],
    );
  }
}

/// Quick achievements summary for home screen
class AchievementsSummary extends StatelessWidget {
  final List<Achievement> achievements;
  final bool isDark;
  final VoidCallback? onViewAll;

  const AchievementsSummary({
    super.key,
    required this.achievements,
    required this.isDark,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final unlocked = achievements.where((a) => a.isUnlocked).toList();
    final recentUnlocked = unlocked.take(4).toList();
    final totalUnlocked = unlocked.length;
    final total = achievements.length;

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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Achievements',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalUnlocked of $total unlocked',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: recentUnlocked
                .map(
                  (a) => AchievementBadge(
                    achievement: a,
                    compact: true,
                    isDark: isDark,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
