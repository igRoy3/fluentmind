// Enhanced Progress Screen - Real data tracking
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/models/user_journey.dart';
import '../../../core/services/user_journey_service.dart';

// Providers for progress data - autoDispose ensures fresh data on each visit
final progressStatsProvider = FutureProvider.autoDispose<UserJourneyStats>((
  ref,
) async {
  final service = ref.watch(userJourneyServiceProvider);
  return service.getJourneyStats();
});

final progressProfileProvider = FutureProvider.autoDispose<UserProfile?>((
  ref,
) async {
  final service = ref.watch(userJourneyServiceProvider);
  return service.getUserProfile();
});

final progressWordsProvider = FutureProvider.autoDispose<List<LearnedWord>>((
  ref,
) async {
  final service = ref.watch(userJourneyServiceProvider);
  return service.getLearnedWords();
});

final progressRecordingsProvider =
    FutureProvider.autoDispose<List<VoiceRecording>>((ref) async {
      final service = ref.watch(userJourneyServiceProvider);
      return service.getVoiceRecordings();
    });

final progressAchievementsProvider =
    FutureProvider.autoDispose<List<Achievement>>((ref) async {
      final service = ref.watch(userJourneyServiceProvider);
      return service.getAchievements();
    });

class EnhancedProgressScreen extends ConsumerWidget {
  const EnhancedProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = ref.watch(progressStatsProvider);
    final profile = ref.watch(progressProfileProvider);
    final words = ref.watch(progressWordsProvider);
    final recordings = ref.watch(progressRecordingsProvider);
    final achievements = ref.watch(progressAchievementsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: isDark
                ? AppColors.backgroundDark
                : AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(gradient: AppColors.primaryGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        profile.when(
                          data: (p) => Text(
                            p?.name != null
                                ? '${p!.name}\'s Progress'
                                : 'Your Progress',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const Text(
                            'Your Progress',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        stats.when(
                          data: (s) => Text(
                            'Day ${s.currentStreak} of your journey',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            title: Text(
              'Progress',
              style: TextStyle(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
          ),

          // Main Stats Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: stats.when(
                data: (s) => _MainStatsGrid(stats: s, isDark: isDark),
                loading: () => _ShimmerStatsGrid(isDark: isDark),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
          ),

          // Vocabulary Progress
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: words.when(
                data: (w) => _VocabularyProgressCard(words: w, isDark: isDark),
                loading: () => _ShimmerCard(height: 160, isDark: isDark),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          ),

          // Voice Progress
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: recordings.when(
                data: (r) => _VoiceProgressCard(recordings: r, isDark: isDark),
                loading: () => _ShimmerCard(height: 140, isDark: isDark),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
          ),

          // Achievements
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Achievements',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  achievements.when(
                    data: (a) =>
                        _AchievementsGrid(achievements: a, isDark: isDark),
                    loading: () => _ShimmerCard(height: 120, isDark: isDark),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
          ),

          // Weekly Activity
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: stats.when(
                data: (s) => _WeeklyActivityCard(stats: s, isDark: isDark),
                loading: () => _ShimmerCard(height: 180, isDark: isDark),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

// Main Stats Grid
class _MainStatsGrid extends StatelessWidget {
  final UserJourneyStats stats;
  final bool isDark;

  const _MainStatsGrid({required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.local_fire_department_rounded,
                value: '${stats.currentStreak}',
                label: 'Day Streak',
                color: AppColors.accentYellow,
                subtitle: stats.longestStreak > stats.currentStreak
                    ? 'Best: ${stats.longestStreak}'
                    : 'Personal best!',
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.schedule_rounded,
                value: '${stats.totalMinutesPracticed}',
                label: 'Minutes',
                color: AppColors.secondary,
                subtitle: 'Total practice time',
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.menu_book_rounded,
                value: '${stats.wordsRetained}/${stats.totalWordsLearned}',
                label: 'Words Retained',
                color: AppColors.success,
                subtitle: stats.totalWordsLearned > 0
                    ? '${((stats.wordsRetained / stats.totalWordsLearned) * 100).toInt()}% retention'
                    : 'Start learning!',
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.mic_rounded,
                value: '${stats.totalRecordings}',
                label: 'Recordings',
                color: AppColors.primary,
                subtitle: 'Voice practices',
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final String subtitle;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
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
              fontSize: 13,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Vocabulary Progress Card
class _VocabularyProgressCard extends StatelessWidget {
  final List<LearnedWord> words;
  final bool isDark;

  const _VocabularyProgressCard({required this.words, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return _EmptyStateCard(
        icon: Icons.menu_book_rounded,
        title: 'Start Learning Words',
        subtitle: 'Build your vocabulary to track progress here',
        isDark: isDark,
        actionText: 'Go to Vocabulary',
        onTap: () => context.push('/vocabulary'),
      );
    }

    final retained = words.where((w) => w.masteryLevel >= 3).length;
    final decaying = words.where((w) => w.isDecaying).length;
    final retentionRate = words.isNotEmpty
        ? (retained / words.length * 100).toDouble()
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
            blurRadius: 12,
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
                'Vocabulary Progress',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getRetentionColor(retentionRate).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${retentionRate.toInt()}% retained',
                  style: TextStyle(
                    color: _getRetentionColor(retentionRate),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: retentionRate / 100,
              backgroundColor: isDark
                  ? AppColors.dividerDark
                  : AppColors.divider,
              valueColor: AlwaysStoppedAnimation(
                _getRetentionColor(retentionRate),
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _VocabStatBadge(
                label: 'Total',
                value: '${words.length}',
                color: AppColors.primary,
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              _VocabStatBadge(
                label: 'Retained',
                value: '$retained',
                color: AppColors.success,
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              _VocabStatBadge(
                label: 'Need Review',
                value: '$decaying',
                color: decaying > 0 ? AppColors.warning : AppColors.textHint,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRetentionColor(double rate) {
    if (rate >= 70) return AppColors.success;
    if (rate >= 40) return AppColors.warning;
    return AppColors.error;
  }
}

class _VocabStatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _VocabStatBadge({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color,
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
        ),
      ),
    );
  }
}

// Voice Progress Card
class _VoiceProgressCard extends StatelessWidget {
  final List<VoiceRecording> recordings;
  final bool isDark;

  const _VoiceProgressCard({required this.recordings, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (recordings.isEmpty) {
      return _EmptyStateCard(
        icon: Icons.mic_rounded,
        title: 'Record Your Voice',
        subtitle: 'Practice speaking to see your progress',
        isDark: isDark,
        actionText: 'Start Speaking Practice',
        onTap: () => context.push('/practice'),
      );
    }

    final baseline = recordings.where((r) => r.isBaseline).firstOrNull;
    final totalDuration = recordings.fold<int>(
      0,
      (sum, r) => sum + r.duration.inSeconds,
    );
    final avgDuration = totalDuration ~/ recordings.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
            blurRadius: 12,
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
                'Voice Progress',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              Icon(Icons.graphic_eq_rounded, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _VoiceStat(
                  icon: Icons.mic_rounded,
                  value: '${recordings.length}',
                  label: 'Recordings',
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: _VoiceStat(
                  icon: Icons.timer_rounded,
                  value: '${avgDuration}s',
                  label: 'Avg Duration',
                  isDark: isDark,
                ),
              ),
              if (baseline != null)
                Expanded(
                  child: _VoiceStat(
                    icon: Icons.flag_rounded,
                    value: '${baseline.duration}s',
                    label: 'Baseline',
                    isDark: isDark,
                  ),
                ),
            ],
          ),
          if (recordings.length >= 3 && baseline != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Keep practicing! Regular recordings help track improvement.',
                      style: TextStyle(fontSize: 12, color: AppColors.success),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VoiceStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isDark;

  const _VoiceStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
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

// Achievements Grid
class _AchievementsGrid extends StatelessWidget {
  final List<Achievement> achievements;
  final bool isDark;

  const _AchievementsGrid({required this.achievements, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) {
      return _EmptyStateCard(
        icon: Icons.emoji_events_rounded,
        title: 'Earn Achievements',
        subtitle: 'Complete challenges to unlock badges',
        isDark: isDark,
      );
    }

    // Use crossAxisCount: 3 for better spacing on most screens
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: achievements.length.clamp(0, 9),
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _AchievementBadge(achievement: achievement, isDark: isDark);
      },
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final bool isDark;

  const _AchievementBadge({required this.achievement, required this.isDark});

  @override
  Widget build(BuildContext context) {
    // All achievements in the list are already earned/unlocked
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.accentYellow.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.accentYellow.withOpacity(0.3)),
          ),
          child: Text(achievement.icon, style: const TextStyle(fontSize: 24)),
        ),
        const SizedBox(height: 6),
        Text(
          achievement.title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// Weekly Activity Card
class _WeeklyActivityCard extends StatelessWidget {
  final UserJourneyStats stats;
  final bool isDark;

  const _WeeklyActivityCard({required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final today = DateTime.now().weekday - 1; // 0-indexed

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final isToday = index == today;
              final isPast = index < today;
              // Calculate if day had activity based on streak
              // If streak is 3 and today is Wed (index 2), then Mon, Tue, Wed had activity
              final streakStartIndex = today - stats.currentStreak + 1;
              final hasActivity =
                  isPast &&
                  stats.currentStreak > 0 &&
                  index >= streakStartIndex;
              final missedDay =
                  isPast && !hasActivity && stats.currentStreak < today;

              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: hasActivity || (isToday && stats.currentStreak > 0)
                          ? AppColors.success
                          : missedDay
                          ? AppColors.error.withOpacity(0.1)
                          : (isToday
                                ? AppColors.primary.withOpacity(0.2)
                                : (isDark
                                      ? AppColors.surfaceDark
                                      : AppColors.surface)),
                      borderRadius: BorderRadius.circular(10),
                      border: isToday
                          ? Border.all(color: AppColors.primary, width: 2)
                          : missedDay
                          ? Border.all(
                              color: AppColors.error.withOpacity(0.3),
                              width: 1,
                            )
                          : null,
                    ),
                    child: Center(
                      child: hasActivity || (isToday && stats.currentStreak > 0)
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 18,
                            )
                          : missedDay
                          ? Icon(
                              Icons.close_rounded,
                              color: AppColors.error.withOpacity(0.5),
                              size: 16,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday
                          ? AppColors.primary
                          : missedDay
                          ? AppColors.error.withOpacity(0.7)
                          : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary),
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    stats.currentStreak > 0
                        ? 'Keep your streak alive by practicing today!'
                        : 'Practice today to start building your streak!',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Empty State Card
class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final String? actionText;
  final VoidCallback? onTap;

  const _EmptyStateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    this.actionText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.divider,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onTap != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionText!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Shimmer placeholders
class _ShimmerStatsGrid extends StatelessWidget {
  final bool isDark;
  const _ShimmerStatsGrid({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _ShimmerCard(height: 130, isDark: isDark)),
            const SizedBox(width: 12),
            Expanded(child: _ShimmerCard(height: 130, isDark: isDark)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _ShimmerCard(height: 130, isDark: isDark)),
            const SizedBox(width: 12),
            Expanded(child: _ShimmerCard(height: 130, isDark: isDark)),
          ],
        ),
      ],
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  final double height;
  final bool isDark;
  const _ShimmerCard({required this.height, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}
