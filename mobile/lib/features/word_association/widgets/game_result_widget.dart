import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';

import '../../../core/theme/app_colors.dart';
import '../models/word_association_models.dart';

class GameResultWidget extends StatefulWidget {
  final GameSession session;
  final int xpEarned;
  final int streakDays;
  final bool isDark;
  final VoidCallback onPlayAgain;
  final VoidCallback onGoHome;

  const GameResultWidget({
    super.key,
    required this.session,
    required this.xpEarned,
    required this.streakDays,
    required this.isDark,
    required this.onPlayAgain,
    required this.onGoHome,
  });

  @override
  State<GameResultWidget> createState() => _GameResultWidgetState();
}

class _GameResultWidgetState extends State<GameResultWidget> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Play confetti if performance is good
    if (widget.session.accuracy >= 0.7) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _confettiController.play();
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accuracy = widget.session.accuracy;
    final isPerfect = accuracy >= 1.0;
    final isGreat = accuracy >= 0.8;
    final isGood = accuracy >= 0.6;

    String title;
    String subtitle;
    IconData icon;
    Color color;

    if (isPerfect) {
      title = 'Perfect! 🎉';
      subtitle = 'You nailed every question!';
      icon = Icons.star_rounded;
      color = AppColors.accent;
    } else if (isGreat) {
      title = 'Excellent! 🌟';
      subtitle = 'You\'re building strong vocabulary!';
      icon = Icons.emoji_events_rounded;
      color = AppColors.accentGreen;
    } else if (isGood) {
      title = 'Good Job! 👍';
      subtitle = 'Keep practicing to improve!';
      icon = Icons.thumb_up_rounded;
      color = AppColors.primary;
    } else {
      title = 'Keep Going! 💪';
      subtitle = 'Practice makes perfect!';
      icon = Icons.trending_up_rounded;
      color = AppColors.secondary;
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Result icon
              Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 50),
                  )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(begin: const Offset(0.5, 0.5)),

              const SizedBox(height: 24),

              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: widget.isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

              const SizedBox(height: 8),

              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: widget.isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 300.ms),

              const SizedBox(height: 32),

              // Stats cards
              Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.check_circle_rounded,
                          label: 'Correct',
                          value:
                              '${widget.session.correctAnswers}/${widget.session.totalQuestions}',
                          color: AppColors.success,
                          isDark: widget.isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.percent_rounded,
                          label: 'Accuracy',
                          value: '${(accuracy * 100).round()}%',
                          color: _getAccuracyColor(accuracy),
                          isDark: widget.isDark,
                        ),
                      ),
                    ],
                  )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 300.ms)
                  .slideY(begin: 0.2),

              const SizedBox(height: 12),

              Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.auto_awesome_rounded,
                          label: 'XP Earned',
                          value: '+${widget.xpEarned}',
                          color: AppColors.accent,
                          isDark: widget.isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.local_fire_department_rounded,
                          label: 'Streak',
                          value: '${widget.streakDays} days',
                          color: AppColors.warning,
                          isDark: widget.isDark,
                        ),
                      ),
                    ],
                  )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 300.ms)
                  .slideY(begin: 0.2),

              const SizedBox(height: 24),

              // Mode badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: widget.isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.isDark
                        ? AppColors.dividerDark
                        : AppColors.divider,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getModeIcon(widget.session.mode),
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getModeTitle(widget.session.mode),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: widget.isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 300.ms),

              const SizedBox(height: 32),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onGoHome,
                      icon: const Icon(Icons.home_rounded),
                      label: const Text('Home'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: widget.isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                        side: BorderSide(
                          color: widget.isDark
                              ? AppColors.dividerDark
                              : AppColors.divider,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: widget.onPlayAgain,
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Play Again',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 700.ms, duration: 300.ms),

              const SizedBox(height: 24),

              // Tips section
              if (!isGood)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.info.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: AppColors.info,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Pro Tip',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.info,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getRandomTip(),
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 800.ms, duration: 300.ms),
            ],
          ),
        ),

        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: [
              AppColors.primary,
              AppColors.accent,
              AppColors.accentGreen,
              AppColors.secondary,
              AppColors.warning,
            ],
            numberOfParticles: 30,
            maxBlastForce: 20,
            minBlastForce: 5,
          ),
        ),
      ],
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 0.8) return AppColors.success;
    if (accuracy >= 0.6) return AppColors.accentGreen;
    if (accuracy >= 0.4) return AppColors.warning;
    return AppColors.error;
  }

  IconData _getModeIcon(GameMode mode) {
    switch (mode) {
      case GameMode.association:
        return Icons.link_rounded;
      case GameMode.context:
        return Icons.article_rounded;
      case GameMode.strengthOrdering:
        return Icons.sort_rounded;
      case GameMode.dailyChallenge:
        return Icons.calendar_today_rounded;
    }
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

  String _getRandomTip() {
    final tips = [
      'Try to visualize the intensity difference between words to remember their order.',
      'Reading books helps you see words in context, making them easier to remember.',
      'Create your own sentences with new words to reinforce learning.',
      'Practice daily for just 5 minutes to see significant improvement.',
      'Group similar words together to understand subtle differences.',
      'Pay attention to word endings - they often indicate intensity levels.',
    ];
    return tips[DateTime.now().second % tips.length];
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
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
