import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/gamification/gamification.dart';
import '../models/word_association_models.dart';
import '../providers/word_association_provider.dart';

/// Enhanced game results screen with gamification integration
class EnhancedGameResultScreen extends ConsumerStatefulWidget {
  final GameSession session;
  final GameMode mode;

  const EnhancedGameResultScreen({
    super.key,
    required this.session,
    required this.mode,
  });

  @override
  ConsumerState<EnhancedGameResultScreen> createState() =>
      _EnhancedGameResultScreenState();
}

class _EnhancedGameResultScreenState
    extends ConsumerState<EnhancedGameResultScreen> {
  late ConfettiController _confettiController;
  bool _showingAchievement = false;
  int _currentAchievementIndex = 0;
  List<Achievement> _unlockedAchievements = [];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Process game completion through gamification system
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processGameCompletion();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _processGameCompletion() {
    final gamificationNotifier = ref.read(gamificationProvider.notifier);

    // Report game completion to gamification system
    final wordsPlayed = <String>[];
    // We don't have direct access to words here, so use placeholder
    gamificationNotifier.completeGame(
      mode: _getGameTypeString(widget.mode),
      questionsAnswered: widget.session.totalQuestions,
      correctAnswers: widget.session.correctAnswers,
      comboMax: widget.session.bestStreak,
      duration: widget.session.totalTime,
      wordsLearned: wordsPlayed,
      weakWords: [],
    );

    // Check for new achievements
    final gamificationState = ref.read(gamificationProvider);
    _unlockedAchievements = gamificationState.newAchievements;

    // Show celebration if good performance
    if (widget.session.accuracy >= 0.8) {
      _confettiController.play();
    }

    // Show achievement celebrations
    if (_unlockedAchievements.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _showNextAchievement();
      });
    }
  }

  void _showNextAchievement() {
    if (_currentAchievementIndex < _unlockedAchievements.length) {
      setState(() {
        _showingAchievement = true;
      });
    }
  }

  void _dismissAchievement() {
    setState(() {
      _showingAchievement = false;
      _currentAchievementIndex++;
    });

    // Show next achievement after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_currentAchievementIndex < _unlockedAchievements.length) {
        _showNextAchievement();
      }
    });
  }

  String _getGameTypeString(GameMode mode) {
    switch (mode) {
      case GameMode.association:
        return 'word_association';
      case GameMode.context:
        return 'context';
      case GameMode.strengthOrdering:
        return 'strength_ordering';
      case GameMode.dailyChallenge:
        return 'daily_challenge';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gamificationState = ref.watch(gamificationProvider);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: isDark
              ? AppColors.backgroundDark
              : AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Performance emoji and title
                  _buildPerformanceHeader(isDark),
                  const SizedBox(height: 32),

                  // XP earned with animation
                  _buildXPSection(isDark, gamificationState),
                  const SizedBox(height: 24),

                  // Stats grid
                  _buildStatsGrid(isDark),
                  const SizedBox(height: 24),

                  // Level progress
                  if (gamificationState.showLevelUpAnimation)
                    _buildLevelUpBanner(isDark, gamificationState)
                  else
                    _buildLevelProgress(isDark, gamificationState),
                  const SizedBox(height: 24),

                  // Daily goal progress
                  _buildDailyGoalProgress(isDark, gamificationState),
                  const SizedBox(height: 24),

                  // Feedback section
                  if (gamificationState.lastSessionSummary != null)
                    _buildFeedbackSection(isDark, gamificationState),
                  const SizedBox(height: 32),

                  // Action buttons
                  _buildActionButtons(isDark),
                ],
              ),
            ),
          ),
        ),

        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 30,
            gravity: 0.2,
            colors: [
              AppColors.primary,
              AppColors.accentYellow,
              AppColors.accentGreen,
              AppColors.secondary,
              AppColors.accent,
            ],
          ),
        ),

        // Achievement overlay
        if (_showingAchievement &&
            _currentAchievementIndex < _unlockedAchievements.length)
          AchievementUnlockCelebration(
            achievement: _unlockedAchievements[_currentAchievementIndex],
            onDismiss: _dismissAchievement,
            isDark: isDark,
          ),
      ],
    );
  }

  Widget _buildPerformanceHeader(bool isDark) {
    final emoji = _getPerformanceEmoji();
    final title = _getPerformanceTitle();
    final subtitle = _getPerformanceSubtitle();

    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 72)).animate().scale(
          begin: const Offset(0.5, 0.5),
          duration: 500.ms,
          curve: Curves.elasticOut,
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  String _getPerformanceEmoji() {
    final accuracy = widget.session.accuracy;
    if (accuracy >= 0.9) return '🏆';
    if (accuracy >= 0.8) return '🌟';
    if (accuracy >= 0.7) return '😊';
    if (accuracy >= 0.5) return '💪';
    return '📚';
  }

  String _getPerformanceTitle() {
    final accuracy = widget.session.accuracy;
    if (accuracy >= 0.9) return 'Outstanding!';
    if (accuracy >= 0.8) return 'Excellent Work!';
    if (accuracy >= 0.7) return 'Great Job!';
    if (accuracy >= 0.5) return 'Good Effort!';
    return 'Keep Practicing!';
  }

  String _getPerformanceSubtitle() {
    final accuracy = widget.session.accuracy;
    if (accuracy >= 0.9) {
      return 'You\'re on fire! Perfect or near-perfect score!';
    }
    if (accuracy >= 0.8) return 'You\'re making amazing progress!';
    if (accuracy >= 0.7) return 'You\'re getting the hang of it!';
    if (accuracy >= 0.5) return 'Every session makes you stronger!';
    return 'Learning takes practice. You\'ve got this!';
  }

  Widget _buildXPSection(bool isDark, GamificationState state) {
    final xpEarned = state.pendingXP > 0
        ? state.pendingXP
        : widget.session.totalScore;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentYellow.withValues(alpha: 0.15),
            AppColors.warning.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentYellow.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_rounded, color: AppColors.accentYellow, size: 32),
              const SizedBox(width: 8),
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: xpEarned),
                duration: const Duration(milliseconds: 1500),
                builder: (context, value, child) {
                  return Text(
                    '+$value XP',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentYellow,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Experience Points Earned',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildStatsGrid(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '${widget.session.correctAnswers}/${widget.session.totalQuestions}',
            'Correct',
            Icons.check_circle_rounded,
            AppColors.success,
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '${(widget.session.accuracy * 100).toInt()}%',
            'Accuracy',
            Icons.adjust_rounded,
            AppColors.accentGreen,
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '${widget.session.bestStreak}',
            'Best Streak',
            Icons.local_fire_department_rounded,
            AppColors.warning,
            isDark,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildLevelProgress(bool isDark, GamificationState state) {
    final progress = state.userProgress;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${progress.level}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LevelSystem.titles[progress.level - 1],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${progress.currentLevelXP} / ${progress.xpToNextLevel} XP to next level',
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
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceVariantDark
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 10,
                width:
                    MediaQuery.of(context).size.width *
                    0.85 *
                    progress.levelProgress,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1);
  }

  Widget _buildLevelUpBanner(bool isDark, GamificationState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          const Text(
            'LEVEL UP!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'You reached Level ${state.newLevel}!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            LevelSystem.titles[(state.newLevel ?? 1) - 1],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildDailyGoalProgress(bool isDark, GamificationState state) {
    final goal = state.userProgress.dailyGoal;
    final progress = goal.xpEarned / goal.xpTarget;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              if (goal.isCompleted)
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
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${goal.xpEarned} / ${goal.xpTarget} XP',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceVariantDark
                                : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: 8,
                          width:
                              MediaQuery.of(context).size.width *
                              0.6 *
                              progress.clamp(0.0, 1.0),
                          decoration: BoxDecoration(
                            color: goal.isCompleted
                                ? AppColors.success
                                : AppColors.accentYellow,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1);
  }

  Widget _buildFeedbackSection(bool isDark, GamificationState state) {
    final summary = state.lastSessionSummary!;
    final feedback = SessionFeedback.generate(
      accuracy: summary.accuracy,
      combo: summary.comboMax,
      streak: state.userProgress.currentStreak,
      weakWords: [],
      gameMode: _getGameTypeString(widget.mode),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Feedback',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        FeedbackCard(feedback: feedback, isDark: isDark),
      ],
    ).animate().fadeIn(delay: 800.ms);
  }

  Widget _buildActionButtons(bool isDark) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              ref.read(wordAssociationProvider.notifier).startGame(widget.mode);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.replay_rounded),
            label: const Text('Play Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  context.push('/progress-dashboard');
                },
                icon: const Icon(Icons.bar_chart_rounded),
                label: const Text('Progress'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(wordAssociationProvider.notifier).resetGame();
                  context.pop();
                },
                icon: const Icon(Icons.home_rounded),
                label: const Text('Home'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  side: BorderSide(
                    color: isDark ? AppColors.dividerDark : AppColors.divider,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 900.ms);
  }
}
