import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../models/word_association_models.dart';
import '../providers/word_association_provider.dart';
import '../widgets/association_question_widget.dart';
import '../widgets/context_question_widget.dart';
import '../widgets/ordering_question_widget.dart';
import 'enhanced_game_result_screen.dart';

class WordAssociationPlayScreen extends ConsumerStatefulWidget {
  final GameMode mode;

  const WordAssociationPlayScreen({super.key, required this.mode});

  @override
  ConsumerState<WordAssociationPlayScreen> createState() =>
      _WordAssociationPlayScreenState();
}

class _WordAssociationPlayScreenState
    extends ConsumerState<WordAssociationPlayScreen> {
  bool _gameStarted = false;

  @override
  void initState() {
    super.initState();
    // Start the game when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_gameStarted) {
        _gameStarted = true;
        ref.read(wordAssociationProvider.notifier).startGame(widget.mode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wordAssociationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Show results if game is complete
    if (state.currentSession != null &&
        state.currentQuestion == null &&
        state.questionQueue.isNotEmpty) {
      return EnhancedGameResultScreen(
        session: state.currentSession!,
        mode: widget.mode,
      );
    }

    // Show loading or error
    if (state.currentQuestion == null) {
      return Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          onPressed: () {
            _showExitConfirmation(context, isDark);
          },
        ),
        title: Text(
          _getModeTitle(state.currentMode),
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        actions: [
          // Streak indicator
          if (state.currentSession != null && state.currentSession!.streak > 0)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentYellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: AppColors.accentYellow,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${state.currentSession!.streak}',
                    style: const TextStyle(
                      color: AppColors.accentYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ).animate().scale(begin: const Offset(0.8, 0.8)).fadeIn(),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            _ProgressBar(
              progress: state.sessionProgress,
              currentQuestion: state.currentQuestionIndex + 1,
              totalQuestions: state.questionQueue.length,
              isDark: isDark,
            ),

            // Score display
            _ScoreDisplay(
              score: state.currentSession?.totalScore ?? 0,
              isDark: isDark,
            ),

            // Question content
            Expanded(child: _buildQuestionWidget(state, isDark)),

            // Feedback and navigation
            if (state.isAnswered)
              _FeedbackSection(
                isCorrect: state.lastAnswerCorrect ?? false,
                explanation: state.lastExplanation ?? '',
                hasMoreQuestions: state.hasMoreQuestions,
                isDark: isDark,
                onNext: () {
                  ref.read(wordAssociationProvider.notifier).nextQuestion();
                },
                onFinish: () {
                  ref.read(wordAssociationProvider.notifier).endGame();
                  setState(() {}); // Trigger rebuild to show results
                },
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }

  String _getModeTitle(GameMode mode) {
    switch (mode) {
      case GameMode.association:
        return 'Association Mode';
      case GameMode.context:
        return 'Context Mode';
      case GameMode.strengthOrdering:
        return 'Strength Ordering';
      case GameMode.dailyChallenge:
        return 'Daily Challenge';
    }
  }

  Widget _buildQuestionWidget(WordAssociationState state, bool isDark) {
    final question = state.currentQuestion!;

    switch (question.mode) {
      case GameMode.association:
        return AssociationQuestionWidget(
          question: question,
          isAnswered: state.isAnswered,
          isDark: isDark,
          onSubmit: (selectedWords) {
            ref
                .read(wordAssociationProvider.notifier)
                .submitAssociationAnswer(selectedWords);
          },
        );

      case GameMode.context:
        return ContextQuestionWidget(
          question: question,
          isAnswered: state.isAnswered,
          isDark: isDark,
          onSubmit: (selectedWord) {
            ref
                .read(wordAssociationProvider.notifier)
                .submitContextAnswer(selectedWord);
          },
        );

      case GameMode.strengthOrdering:
        return OrderingQuestionWidget(
          question: question,
          isAnswered: state.isAnswered,
          isDark: isDark,
          onSubmit: (orderedWords) {
            ref
                .read(wordAssociationProvider.notifier)
                .submitOrderingAnswer(orderedWords);
          },
        );

      case GameMode.dailyChallenge:
        // Daily challenge uses mixed modes, so use the question's actual mode
        return _buildQuestionWidget(
          state.copyWith(
            currentQuestion: GameQuestion(
              id: question.id,
              mode: question.mode,
              wordData: question.wordData,
              sentenceWithBlank: question.sentenceWithBlank,
              correctAnswer: question.correctAnswer,
              options: question.options,
              correctOrder: question.correctOrder,
            ),
          ),
          isDark,
        );
    }
  }

  void _showExitConfirmation(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Exit Game?',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Your progress in this session will be lost.',
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Continue', style: TextStyle(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(wordAssociationProvider.notifier).resetGame();
              context.pop();
            },
            child: Text('Exit', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  final int currentQuestion;
  final int totalQuestions;
  final bool isDark;

  const _ProgressBar({
    required this.progress,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question $currentQuestion of $totalQuestions',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariant,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreDisplay extends StatelessWidget {
  final int score;
  final bool isDark;

  const _ScoreDisplay({required this.score, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.stars_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            '$score XP',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackSection extends StatelessWidget {
  final bool isCorrect;
  final String explanation;
  final bool hasMoreQuestions;
  final bool isDark;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  const _FeedbackSection({
    required this.isCorrect,
    required this.explanation,
    required this.hasMoreQuestions,
    required this.isDark,
    required this.onNext,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Result indicator with enhanced feedback
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isCorrect ? AppColors.success : AppColors.error)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (isCorrect ? AppColors.success : AppColors.error)
                    .withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: (isCorrect ? AppColors.success : AppColors.error)
                            .withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCorrect ? Icons.check_rounded : Icons.close_rounded,
                        color: isCorrect ? AppColors.success : AppColors.error,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCorrect ? 'Correct! 🎉' : 'Not quite right 💪',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isCorrect
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                          if (!isCorrect)
                            Text(
                              'Keep trying, you\'ll get it!',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (isCorrect)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentYellow.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add,
                              color: AppColors.accentYellow,
                              size: 16,
                            ),
                            SizedBox(width: 2),
                            Text(
                              '10 XP',
                              style: TextStyle(
                                color: AppColors.accentYellow,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Explanation with icon
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isCorrect ? Icons.lightbulb_outline : Icons.school_outlined,
                  color: isCorrect ? AppColors.accentYellow : AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    explanation,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Next button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: hasMoreQuestions ? onNext : onFinish,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                hasMoreQuestions ? 'Next Question' : 'See Results',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
