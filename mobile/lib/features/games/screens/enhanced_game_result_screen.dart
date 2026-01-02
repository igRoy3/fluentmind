/// Enhanced Game Result Screen for FluentMind
/// Shows real performance data with confidence-building feedback
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/gamification/models/game_difficulty_models.dart';
import '../../../core/gamification/providers/adaptive_difficulty_provider.dart';
import '../../../core/gamification/providers/gamification_provider.dart';

class EnhancedGameResultScreen extends ConsumerStatefulWidget {
  final GameSession session;
  final String gameName;

  const EnhancedGameResultScreen({
    super.key,
    required this.session,
    required this.gameName,
  });

  @override
  ConsumerState<EnhancedGameResultScreen> createState() =>
      _EnhancedGameResultScreenState();
}

class _EnhancedGameResultScreenState
    extends ConsumerState<EnhancedGameResultScreen> {
  late ConfettiController _confettiController;
  int _displayedXP = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Record session in performance tracker
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processGameCompletion();
    });
  }

  void _processGameCompletion() async {
    // Calculate XP with difficulty multiplier
    final tracker = ref.read(gamePerformanceProvider.notifier);
    final expectedTime = _getExpectedTime(widget.session.difficulty);
    final xpEarned = tracker.calculateSessionXP(widget.session, expectedTime);

    // Record session
    await tracker.completeSession(widget.session.copyWith(xpEarned: xpEarned));

    // Update gamification system
    final gamification = ref.read(gamificationProvider.notifier);
    gamification.completeGame(
      mode: widget.session.gameId,
      questionsAnswered: widget.session.questionsAnswered,
      correctAnswers: widget.session.correctAnswers,
      comboMax: widget.session.maxCombo,
      duration: widget.session.completionTime,
      wordsLearned: [],
      weakWords: [],
    );

    // Trigger animations
    if (widget.session.accuracy >= 0.8 || widget.session.isPerfect) {
      _confettiController.play();
    }

    // Animate XP counter
    for (int i = 0; i <= xpEarned; i += (xpEarned / 30).ceil().clamp(1, 10)) {
      await Future.delayed(const Duration(milliseconds: 20));
      if (mounted) {
        setState(() => _displayedXP = i.clamp(0, xpEarned));
      }
    }
    if (mounted) {
      setState(() => _displayedXP = xpEarned);
    }
  }

  int _getExpectedTime(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.beginner:
        return 90;
      case GameDifficulty.intermediate:
        return 60;
      case GameDifficulty.advanced:
        return 45;
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = ref.watch(gamePerformanceProvider)[widget.session.gameId];
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

                  // Performance Header
                  _buildPerformanceHeader(isDark),
                  const SizedBox(height: 24),

                  // XP Earned
                  _buildXPSection(isDark),
                  const SizedBox(height: 20),

                  // Stats Grid
                  _buildStatsGrid(isDark),
                  const SizedBox(height: 20),

                  // Difficulty Badge
                  _buildDifficultyBadge(isDark),
                  const SizedBox(height: 20),

                  // Progress Comparison
                  if (stats != null && stats.totalPlays > 1)
                    _buildProgressComparison(stats, isDark),
                  const SizedBox(height: 20),

                  // Confidence Message
                  _buildConfidenceMessage(isDark),
                  const SizedBox(height: 24),

                  // Level Progress
                  _buildLevelProgress(gamificationState, isDark),
                  const SizedBox(height: 32),

                  // Action Buttons
                  _buildActionButtons(context, isDark),
                  const SizedBox(height: 20),
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
            gravity: 0.1,
            colors: [
              AppColors.primary,
              AppColors.secondary,
              AppColors.accent,
              AppColors.success,
              AppColors.warning,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceHeader(bool isDark) {
    final accuracy = widget.session.accuracy;
    String emoji;
    String title;
    String subtitle;

    if (widget.session.isPerfect) {
      emoji = '🏆';
      title = 'Perfect!';
      subtitle = 'Incredible performance!';
    } else if (accuracy >= 0.9) {
      emoji = '🌟';
      title = 'Excellent!';
      subtitle = 'You\'re on fire!';
    } else if (accuracy >= 0.8) {
      emoji = '💪';
      title = 'Great Job!';
      subtitle = 'Keep up the momentum!';
    } else if (accuracy >= 0.6) {
      emoji = '👍';
      title = 'Good Effort!';
      subtitle = 'You\'re improving!';
    } else {
      emoji = '📚';
      title = 'Keep Learning!';
      subtitle = 'Practice makes perfect!';
    }

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
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 8),
        Text(
          subtitle,
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

  Widget _buildXPSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withOpacity(0.15),
            AppColors.warning.withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_rounded, color: AppColors.accent, size: 36),
              const SizedBox(width: 8),
              Text(
                '+$_displayedXP XP',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
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
          if (widget.session.difficulty != GameDifficulty.intermediate) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.session.difficulty == GameDifficulty.advanced
                    ? '1.5x Difficulty Bonus!'
                    : '0.8x Beginner Rate',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildStatsGrid(bool isDark) {
    final accuracy = (widget.session.accuracy * 100).round();
    final timeInSeconds = widget.session.completionTime.inSeconds;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_rounded,
            value:
                '${widget.session.correctAnswers}/${widget.session.questionsAnswered}',
            label: 'Correct',
            color: AppColors.success,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.percent_rounded,
            value: '$accuracy%',
            label: 'Accuracy',
            color: _getAccuracyColor(widget.session.accuracy),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.timer_rounded,
            value: '${timeInSeconds}s',
            label: 'Time',
            color: AppColors.secondary,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department_rounded,
            value: '${widget.session.maxCombo}',
            label: 'Max Combo',
            color: AppColors.warning,
            isDark: isDark,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 0.9) return AppColors.success;
    if (accuracy >= 0.7) return AppColors.warning;
    return AppColors.error;
  }

  Widget _buildDifficultyBadge(bool isDark) {
    final difficulty = widget.session.difficulty;
    final color = difficulty == GameDifficulty.beginner
        ? AppColors.success
        : difficulty == GameDifficulty.intermediate
        ? AppColors.warning
        : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(difficulty.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            '${difficulty.displayName} Mode',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 550.ms);
  }

  Widget _buildProgressComparison(GamePerformanceStats stats, bool isDark) {
    final improvement = widget.session.accuracy - stats.avgAccuracy;
    final isImprovement = improvement > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up_rounded,
                color: AppColors.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Progress Comparison',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ComparisonItem(
                  label: 'This Game',
                  value: '${(widget.session.accuracy * 100).round()}%',
                  isDark: isDark,
                  highlight: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ComparisonItem(
                  label: 'Your Average',
                  value: '${(stats.avgAccuracy * 100).round()}%',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ComparisonItem(
                  label: 'Best Score',
                  value: '${stats.bestScore}',
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: (isImprovement ? AppColors.success : AppColors.info)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  isImprovement
                      ? Icons.arrow_upward_rounded
                      : Icons.remove_rounded,
                  color: isImprovement ? AppColors.success : AppColors.info,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  isImprovement
                      ? 'You\'re ${(improvement * 100).abs().round()}% above your average!'
                      : 'Keep practicing to beat your average!',
                  style: TextStyle(
                    fontSize: 13,
                    color: isImprovement ? AppColors.success : AppColors.info,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildConfidenceMessage(bool isDark) {
    final message = ConfidenceBuilder.getEncouragingMessage(
      widget.session.accuracy,
      widget.session.maxCombo,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.1);
  }

  Widget _buildLevelProgress(GamificationState state, bool isDark) {
    final progress = state.userProgress;
    final levelProgress = progress.levelProgress;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${progress.level}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      progress.levelTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
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
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: levelProgress,
              backgroundColor: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms);
  }

  Widget _buildActionButtons(BuildContext context, bool isDark) {
    return Column(
      children: [
        // Play Again Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              context.pop();
              // Navigate back to game with same difficulty
            },
            icon: const Icon(Icons.replay_rounded),
            label: const Text('Play Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Back to Games Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              context.go('/games');
            },
            icon: const Icon(Icons.grid_view_rounded),
            label: const Text('All Games'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 900.ms);
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final bool highlight;

  const _ComparisonItem({
    required this.label,
    required this.value,
    required this.isDark,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: highlight
                ? AppColors.primary
                : isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
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
