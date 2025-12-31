import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';

class StreakCard extends ConsumerWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsState = ref.watch(statsProvider);
    final currentStreak = statsState.stats?.currentStreak ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Streak Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.accentYellow.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: AppColors.accentYellow,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),

          // Streak Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentStreak == 0
                      ? 'Start Your Streak! 🔥'
                      : currentStreak == 1
                      ? '1 Day Streak! 🔥'
                      : '$currentStreak Day Streak! 🔥',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentStreak == 0
                      ? 'Practice today to start your streak!'
                      : "You're on fire! Keep practicing daily.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Days Display
          Column(
            children: [
              Text(
                '$currentStreak',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                currentStreak == 1 ? 'day' : 'days',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
