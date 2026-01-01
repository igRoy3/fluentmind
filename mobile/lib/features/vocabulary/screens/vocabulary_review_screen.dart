// Vocabulary Review Screen - Quick review for words needing attention
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/models/user_journey.dart';
import '../../../core/services/user_journey_service.dart';

class VocabularyReviewScreen extends ConsumerStatefulWidget {
  const VocabularyReviewScreen({super.key});

  @override
  ConsumerState<VocabularyReviewScreen> createState() =>
      _VocabularyReviewScreenState();
}

class _VocabularyReviewScreenState
    extends ConsumerState<VocabularyReviewScreen> {
  List<LearnedWord> _wordsToReview = [];
  int _currentIndex = 0;
  bool _showAnswer = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWordsToReview();
  }

  Future<void> _loadWordsToReview() async {
    final service = ref.read(userJourneyServiceProvider);
    await service.markDecayingWords();
    final words = await service.getWordsNeedingReview();

    setState(() {
      _wordsToReview = words;
      _isLoading = false;
      _currentIndex = 0;
      _showAnswer = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: const Text('Quick Review'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark
            ? AppColors.textPrimaryDark
            : AppColors.textPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _wordsToReview.isEmpty
          ? _EmptyState(isDark: isDark)
          : _ReviewContent(
              word: _wordsToReview[_currentIndex],
              currentIndex: _currentIndex,
              totalWords: _wordsToReview.length,
              showAnswer: _showAnswer,
              onShowAnswer: () => setState(() => _showAnswer = true),
              onRate: _rateWord,
              isDark: isDark,
            ),
    );
  }

  Future<void> _rateWord(int quality) async {
    final service = ref.read(userJourneyServiceProvider);
    final currentWord = _wordsToReview[_currentIndex];
    await service.updateWordReview(
      word: currentWord.word,
      wasCorrect: quality >= 3, // 3+ is considered correct
    );

    if (_currentIndex < _wordsToReview.length - 1) {
      setState(() {
        _currentIndex++;
        _showAnswer = false;
      });
    } else {
      // Session complete
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 48,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'All Done!',
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
              'You reviewed ${_wordsToReview.length} words.\nYour memory is getting stronger!',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;

  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.celebration_rounded,
                size: 56,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'All Caught Up!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No words need review right now.\nKeep learning to grow your vocabulary!',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Go Back'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95));
  }
}

class _ReviewContent extends StatelessWidget {
  final LearnedWord word;
  final int currentIndex;
  final int totalWords;
  final bool showAnswer;
  final VoidCallback onShowAnswer;
  final Function(int) onRate;
  final bool isDark;

  const _ReviewContent({
    required this.word,
    required this.currentIndex,
    required this.totalWords,
    required this.showAnswer,
    required this.onShowAnswer,
    required this.onRate,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Progress indicator
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (currentIndex + 1) / totalWords,
                    backgroundColor: isDark
                        ? AppColors.dividerDark
                        : AppColors.divider,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${currentIndex + 1}/$totalWords',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Word card
          Expanded(
            child: GestureDetector(
              onTap: showAnswer ? null : onShowAnswer,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (word.isDecaying)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: AppColors.warning,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Memory fading',
                              style: TextStyle(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Word
                    Text(
                          word.word,
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .scale(begin: const Offset(0.9, 0.9)),

                    const SizedBox(height: 24),

                    if (!showAnswer) ...[
                      Text(
                        'Do you remember this word?',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.touch_app_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Tap to reveal',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.03, 1.03),
                            duration: 1000.ms,
                          ),
                    ] else ...[
                      Divider(
                        color: isDark
                            ? AppColors.dividerDark
                            : AppColors.divider,
                        height: 32,
                      ),

                      // Definition
                      Text(
                        word.definition,
                        style: TextStyle(
                          fontSize: 20,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),

                      if (word.example.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.secondary.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EXAMPLE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '"${word.example}"',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 150.ms, duration: 300.ms),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Rating buttons
          if (showAnswer)
            ...[
              Text(
                'How well did you remember?',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _RatingButton(
                    label: 'Forgot',
                    emoji: '😕',
                    color: AppColors.error,
                    onTap: () => onRate(0),
                  ),
                  const SizedBox(width: 10),
                  _RatingButton(
                    label: 'Hard',
                    emoji: '😅',
                    color: AppColors.warning,
                    onTap: () => onRate(2),
                  ),
                  const SizedBox(width: 10),
                  _RatingButton(
                    label: 'Good',
                    emoji: '😊',
                    color: AppColors.secondary,
                    onTap: () => onRate(4),
                  ),
                  const SizedBox(width: 10),
                  _RatingButton(
                    label: 'Easy',
                    emoji: '🎯',
                    color: AppColors.success,
                    onTap: () => onRate(5),
                  ),
                ],
              ),
            ].animate().fadeIn(delay: 200.ms, duration: 300.ms),
        ],
      ),
    );
  }
}

class _RatingButton extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;
  final VoidCallback onTap;

  const _RatingButton({
    required this.label,
    required this.emoji,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
