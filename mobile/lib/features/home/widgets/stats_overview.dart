// Stats Overview Widget
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/models/user_journey.dart';

class StatsOverview extends StatelessWidget {
  final UserJourneyStats stats;
  final bool isDark;

  const StatsOverview({super.key, required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Journey',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                icon: Icons.local_fire_department_rounded,
                value: '${stats.currentStreak}',
                label: 'Day Streak',
                color: AppColors.accentYellow,
                isDark: isDark,
              ),
              _StatItem(
                icon: Icons.menu_book_rounded,
                value: '${stats.wordsRetained}',
                label: 'Words Retained',
                color: AppColors.secondary,
                isDark: isDark,
              ),
              _StatItem(
                icon: Icons.mic_rounded,
                value: '${stats.totalRecordings}',
                label: 'Recordings',
                color: AppColors.primary,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ProgressBar(
            label: 'Vocabulary Retention',
            value: stats.totalWordsLearned > 0
                ? stats.wordsRetained / stats.totalWordsLearned
                : 0,
            isDark: isDark,
            color: AppColors.secondary,
          ),
          const SizedBox(height: 8),
          _ProgressBar(
            label: 'Speaking Improvement',
            value: stats.avgFluencyScore / 100,
            isDark: isDark,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool isDark;

  const _ProgressBar({
    required this.label,
    required this.value,
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
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            backgroundColor: isDark ? AppColors.dividerDark : AppColors.divider,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
