// Vocabulary Preview Section
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/models/user_journey.dart';
import '../../../core/services/user_journey_service.dart';

final recentWordsProvider = FutureProvider.autoDispose<List<LearnedWord>>((
  ref,
) async {
  final service = ref.watch(userJourneyServiceProvider);
  final words = await service.getLearnedWords();
  // Get 5 most recent words
  final sorted = List<LearnedWord>.from(words)
    ..sort((a, b) => b.learnedAt.compareTo(a.learnedAt));
  return sorted.take(5).toList();
});

final vocabularyStatsProvider = FutureProvider.autoDispose<Map<String, int>>((
  ref,
) async {
  final service = ref.watch(userJourneyServiceProvider);
  final words = await service.getLearnedWords();
  final retained = words.where((w) => w.masteryLevel >= 3).length;
  final needsReview = words
      .where((w) => w.isDecaying || w.nextReviewAt.isBefore(DateTime.now()))
      .length;
  return {
    'total': words.length,
    'retained': retained,
    'needsReview': needsReview,
  };
});

class VocabularyPreviewSection extends ConsumerWidget {
  final bool isDark;

  const VocabularyPreviewSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentWords = ref.watch(recentWordsProvider);
    final stats = ref.watch(vocabularyStatsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Vocabulary Bank',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/vocabulary'),
              child: Text(
                'See All',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Stats Row
        stats.when(
          data: (data) => Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _VocabStat(
                  value: '${data['total']}',
                  label: 'Total Words',
                  color: AppColors.primary,
                  isDark: isDark,
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: isDark ? AppColors.dividerDark : AppColors.divider,
                ),
                _VocabStat(
                  value: '${data['retained']}',
                  label: 'Retained',
                  color: AppColors.success,
                  isDark: isDark,
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: isDark ? AppColors.dividerDark : AppColors.divider,
                ),
                _VocabStat(
                  value: '${data['needsReview']}',
                  label: 'Need Review',
                  color: data['needsReview']! > 0
                      ? AppColors.warning
                      : AppColors.textHint,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          loading: () => _shimmerContainer(isDark, 70),
          error: (_, __) => const SizedBox.shrink(),
        ),

        const SizedBox(height: 12),

        // Recent Words
        recentWords.when(
          data: (words) {
            if (words.isEmpty) {
              return _EmptyVocabularyCard(isDark: isDark);
            }
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recently Learned',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...words.map(
                    (word) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _WordItem(word: word, isDark: isDark),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => _shimmerContainer(isDark, 200),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _shimmerContainer(bool isDark, double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _VocabStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _VocabStat({
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
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

class _WordItem extends StatelessWidget {
  final LearnedWord word;
  final bool isDark;

  const _WordItem({required this.word, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final retentionPercent = (word.masteryLevel / 5 * 100).toInt();
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: _getRetentionColor(retentionPercent.toDouble()),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                word.word,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              Text(
                word.definition,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getRetentionColor(
              retentionPercent.toDouble(),
            ).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$retentionPercent%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _getRetentionColor(retentionPercent.toDouble()),
            ),
          ),
        ),
      ],
    );
  }

  Color _getRetentionColor(double score) {
    if (score >= 80) return AppColors.success;
    if (score >= 50) return AppColors.warning;
    return AppColors.error;
  }
}

class _EmptyVocabularyCard extends StatelessWidget {
  final bool isDark;

  const _EmptyVocabularyCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.divider,
          width: 1,
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
            child: Icon(
              Icons.menu_book_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Start Building Your Vocabulary',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Learn new words and track your retention',
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.push('/vocabulary'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Learn Words'),
          ),
        ],
      ),
    );
  }
}
