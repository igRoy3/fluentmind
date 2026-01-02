// Redesigned Home Screen - Personalized Daily Experience
// Shows real user data, no mock content

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/models/user_journey.dart';
import '../../../core/services/user_journey_service.dart';
import '../widgets/daily_focus_card.dart';
import '../widgets/vocabulary_preview.dart';
import '../widgets/quick_actions_grid.dart';

// Providers for home screen data - autoDispose ensures fresh data each visit
final greetingProvider = FutureProvider.autoDispose<String>((ref) async {
  final service = ref.watch(userJourneyServiceProvider);
  return service.getPersonalizedGreeting();
});

final dailyFocusProvider = FutureProvider.autoDispose<DailyFocus>((ref) async {
  final service = ref.watch(userJourneyServiceProvider);
  return service.generateDailyFocus();
});

final journeyStatsProvider = FutureProvider.autoDispose<UserJourneyStats>((
  ref,
) async {
  final service = ref.watch(userJourneyServiceProvider);
  // Recalculate stats from actual data to ensure accuracy
  return service.getJourneyStats();
});

final todaySessionProvider = FutureProvider.autoDispose<DailySession>((
  ref,
) async {
  final service = ref.watch(userJourneyServiceProvider);
  return service.getTodaySession();
});

final decayingWordsProvider = FutureProvider.autoDispose<List<LearnedWord>>((
  ref,
) async {
  final service = ref.watch(userJourneyServiceProvider);
  await service.markDecayingWords();
  return service.getDecayingWords();
});

final userProfileProvider = FutureProvider.autoDispose<UserProfile?>((
  ref,
) async {
  final service = ref.watch(userJourneyServiceProvider);
  return service.getUserProfile();
});

class NewHomeScreen extends ConsumerStatefulWidget {
  const NewHomeScreen({super.key});

  @override
  ConsumerState<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends ConsumerState<NewHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final greeting = ref.watch(greetingProvider);
    final dailyFocus = ref.watch(dailyFocusProvider);
    final todaySession = ref.watch(todaySessionProvider);
    final decayingWords = ref.watch(decayingWordsProvider);
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(greetingProvider);
            ref.invalidate(dailyFocusProvider);
            ref.invalidate(journeyStatsProvider);
            ref.invalidate(todaySessionProvider);
            ref.invalidate(decayingWordsProvider);
          },
          child: CustomScrollView(
            slivers: [
              // Header with personalized greeting
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            greeting.when(
                              data: (text) => Text(
                                text,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                maxLines: 2,
                              ),
                              loading: () => _shimmerText(isDark),
                              error: (_, __) => Text(
                                'Ready to practice?',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary,
                                    ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 400.ms),
                      ),
                      GestureDetector(
                            onTap: () => context.push('/profile'),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .scale(begin: const Offset(0.8, 0.8)),
                    ],
                  ),
                ),
              ),

              // Brain Games Featured Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: BrainGamesCard(
                    isDark: isDark,
                    onTap: () => context.push('/games'),
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
              ),

              // Decaying Words Alert (if any)
              SliverToBoxAdapter(
                child: decayingWords.when(
                  data: (words) {
                    if (words.isEmpty) return const SizedBox.shrink();
                    return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                          child: DecayingWordsAlert(
                            words: words,
                            isDark: isDark,
                            onTap: () => context.push('/vocabulary-review'),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 150.ms)
                        .shake(hz: 2, duration: 500.ms);
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),

              // Daily Focus Card
              SliverToBoxAdapter(
                child:
                    Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: dailyFocus.when(
                            data: (focus) => DailyFocusCard(
                              focus: focus,
                              isDark: isDark,
                              onStartPressed: () => _startDailySession(focus),
                            ),
                            loading: () => _shimmerFocusCard(isDark),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 400.ms)
                        .slideY(begin: 0.05),
              ),

              // Today's Progress
              SliverToBoxAdapter(
                child:
                    Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: todaySession.when(
                            data: (session) => profile.when(
                              data: (prof) => TodayProgressCard(
                                session: session,
                                commitment:
                                    prof?.commitment ??
                                    DailyCommitment.moderate,
                                isDark: isDark,
                              ),
                              loading: () => _shimmerProgressCard(isDark),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                            loading: () => _shimmerProgressCard(isDark),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 250.ms, duration: 400.ms)
                        .slideY(begin: 0.05),
              ),

              // Quick Actions Grid
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Text(
                    'Practice',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: QuickActionsGrid(isDark: isDark),
                ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
              ),

              // Vocabulary Preview
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: VocabularyPreviewSection(isDark: isDark),
                ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
              ),

              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  void _startDailySession(DailyFocus focus) {
    switch (focus.type) {
      case FocusType.vocabulary:
        context.push('/vocabulary');
        break;
      case FocusType.fluency:
      case FocusType.pronunciation:
      case FocusType.hesitation:
        context.push('/practice');
        break;
      case FocusType.cognitive:
        context.push('/games');
        break;
    }
  }

  Widget _shimmerText(bool isDark) {
    return Container(
      width: 200,
      height: 20,
      decoration: BoxDecoration(
        color: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _shimmerFocusCard(bool isDark) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _shimmerProgressCard(bool isDark) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

// Brain Games Featured Card - Replaces old stats row
class BrainGamesCard extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const BrainGamesCard({super.key, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF6C5CE7), const Color(0xFF8E7CF3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C5CE7).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.psychology_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Brain Games',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '6 Games',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Train your mind with fun challenges',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Decaying Words Alert
class DecayingWordsAlert extends StatelessWidget {
  final List<LearnedWord> words;
  final bool isDark;
  final VoidCallback onTap;

  const DecayingWordsAlert({
    super.key,
    required this.words,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstWord = words.first.word;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.warning.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"$firstWord" is slipping away!',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${words.length} word${words.length > 1 ? 's' : ''} need review',
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
            Icon(Icons.chevron_right_rounded, color: AppColors.warning),
          ],
        ),
      ),
    );
  }
}

// Today's Progress Card
class TodayProgressCard extends StatelessWidget {
  final DailySession session;
  final DailyCommitment commitment;
  final bool isDark;

  const TodayProgressCard({
    super.key,
    required this.session,
    required this.commitment,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (session.durationMinutes / commitment.minutes).clamp(
      0.0,
      1.0,
    );
    final isComplete = session.isComplete;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Progress',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              if (isComplete)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Complete!',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark
                  ? AppColors.dividerDark
                  : AppColors.divider,
              valueColor: AlwaysStoppedAnimation(
                isComplete ? AppColors.success : AppColors.primary,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${session.durationMinutes} min practiced',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              Text(
                'Goal: ${commitment.minutes} min',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (session.wordsLearned.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: session.wordsLearned
                  .take(3)
                  .map(
                    (word) => Chip(
                      label: Text(word, style: const TextStyle(fontSize: 11)),
                      backgroundColor: AppColors.secondary.withOpacity(0.1),
                      labelStyle: TextStyle(color: AppColors.secondary),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
