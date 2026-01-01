import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../models/gamification_models.dart';

/// Session summary card showing performance overview
class SessionSummaryCard extends StatelessWidget {
  final SessionSummary summary;
  final bool isDark;

  const SessionSummaryCard({
    super.key,
    required this.summary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getPerformanceIcon(),
                color: _getPerformanceColor(),
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                _getPerformanceTitle(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                '${summary.totalXPEarned}',
                'XP Earned',
                Icons.star_rounded,
                AppColors.accentYellow,
              ),
              _buildDivider(),
              _buildStatItem(
                '${(summary.accuracy * 100).toInt()}%',
                'Accuracy',
                Icons.gps_fixed_rounded,
                AppColors.accentGreen,
              ),
              _buildDivider(),
              _buildStatItem(
                '${summary.correctAnswers}/${summary.questionsAnswered}',
                'Correct',
                Icons.check_circle_rounded,
                AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
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
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 60,
      color: isDark ? AppColors.dividerDark : AppColors.divider,
    );
  }

  IconData _getPerformanceIcon() {
    if (summary.accuracy >= 0.9) return Icons.emoji_events_rounded;
    if (summary.accuracy >= 0.7) return Icons.sentiment_very_satisfied_rounded;
    if (summary.accuracy >= 0.5) return Icons.sentiment_satisfied_rounded;
    return Icons.sentiment_dissatisfied_rounded;
  }

  Color _getPerformanceColor() {
    if (summary.accuracy >= 0.9) return AppColors.accentYellow;
    if (summary.accuracy >= 0.7) return AppColors.accentGreen;
    if (summary.accuracy >= 0.5) return AppColors.warning;
    return AppColors.error;
  }

  String _getPerformanceTitle() {
    if (summary.accuracy >= 0.9) return 'Outstanding!';
    if (summary.accuracy >= 0.7) return 'Great Job!';
    if (summary.accuracy >= 0.5) return 'Nice Try!';
    return 'Keep Practicing!';
  }
}

/// Intelligent feedback card
class FeedbackCard extends StatelessWidget {
  final SessionFeedback feedback;
  final bool isDark;

  const FeedbackCard({super.key, required this.feedback, required this.isDark});

  Color get _primaryColor {
    // Determine color based on title
    if (feedback.title.contains('Perfect') ||
        feedback.title.contains('Excellent')) {
      return AppColors.accentYellow;
    } else if (feedback.title.contains('Great') ||
        feedback.title.contains('Good')) {
      return AppColors.accentGreen;
    } else if (feedback.title.contains('Keep')) {
      return AppColors.warning;
    }
    return AppColors.primary;
  }

  String get _emoji {
    if (feedback.title.contains('Perfect')) return '🎉';
    if (feedback.title.contains('Excellent')) return '🌟';
    if (feedback.title.contains('Great')) return '👏';
    if (feedback.title.contains('Good')) return '👍';
    if (feedback.title.contains('Keep')) return '💪';
    return '🌱';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _primaryColor.withValues(alpha: 0.1),
            _primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Headline
          Row(
            children: [
              Text(_emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  feedback.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Subtitle/Encouragement
          Text(
            feedback.encouragement,
            style: TextStyle(
              fontSize: 15,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Strengths
          if (feedback.strengths.isNotEmpty) ...[
            _buildSection(
              'Strengths',
              feedback.strengths,
              Icons.thumb_up_rounded,
              AppColors.success,
            ),
            const SizedBox(height: 12),
          ],

          // Areas to improve
          if (feedback.areasToImprove.isNotEmpty) ...[
            _buildSection(
              'Keep working on',
              feedback.areasToImprove,
              Icons.trending_up_rounded,
              AppColors.warning,
            ),
            const SizedBox(height: 12),
          ],

          // Recommendation
          if (feedback.recommendation.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentYellow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_rounded,
                    size: 20,
                    color: AppColors.accentYellow,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feedback.recommendation,
                      style: TextStyle(
                        fontSize: 13,
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
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<String> items,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(left: 26, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '•',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// MotivationalMessages is defined in gamification_models.dart

/// Motivational message widget
class MotivationalMessage extends StatelessWidget {
  final String message;
  final bool isDark;

  const MotivationalMessage({
    super.key,
    required this.message,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
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
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Word mastery progress card
class WordMasteryProgressCard extends StatelessWidget {
  final List<WordMastery> words;
  final bool isDark;

  const WordMasteryProgressCard({
    super.key,
    required this.words,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final byLevel = <MasteryLevel, int>{};
    for (final word in words) {
      byLevel[word.level] = (byLevel[word.level] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Word Mastery',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: MasteryLevel.values.map((level) {
              final count = byLevel[level] ?? 0;
              return _buildMasteryItem(level, count);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMasteryItem(MasteryLevel level, int count) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _getLevelColor(level).withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              _getLevelEmoji(level),
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _getLevelColor(level),
          ),
        ),
        Text(
          _getLevelName(level),
          style: TextStyle(
            fontSize: 10,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Color _getLevelColor(MasteryLevel level) {
    switch (level) {
      case MasteryLevel.newWord:
        return AppColors.error;
      case MasteryLevel.learning:
        return AppColors.warning;
      case MasteryLevel.familiar:
        return AppColors.accentYellow;
      case MasteryLevel.strong:
        return AppColors.accentGreen;
      case MasteryLevel.mastered:
        return AppColors.success;
    }
  }

  String _getLevelEmoji(MasteryLevel level) {
    switch (level) {
      case MasteryLevel.newWord:
        return '🌱';
      case MasteryLevel.learning:
        return '📚';
      case MasteryLevel.familiar:
        return '💡';
      case MasteryLevel.strong:
        return '💪';
      case MasteryLevel.mastered:
        return '⭐';
    }
  }

  String _getLevelName(MasteryLevel level) {
    switch (level) {
      case MasteryLevel.newWord:
        return 'New';
      case MasteryLevel.learning:
        return 'Learning';
      case MasteryLevel.familiar:
        return 'Familiar';
      case MasteryLevel.strong:
        return 'Strong';
      case MasteryLevel.mastered:
        return 'Mastered';
    }
  }
}

/// Session results screen showing complete feedback
class SessionResultsOverlay extends StatelessWidget {
  final SessionSummary summary;
  final SessionFeedback feedback;
  final List<Achievement> newAchievements;
  final VoidCallback onContinue;
  final VoidCallback? onPlayAgain;
  final bool isDark;

  const SessionResultsOverlay({
    super.key,
    required this.summary,
    required this.feedback,
    required this.newAchievements,
    required this.onContinue,
    this.onPlayAgain,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? AppColors.backgroundDark : AppColors.background,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Text(
                'Session Complete!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ).animate().fadeIn().slideY(begin: -0.2),
              const SizedBox(height: 24),

              // Summary card
              SessionSummaryCard(
                summary: summary,
                isDark: isDark,
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
              const SizedBox(height: 20),

              // New achievements
              if (newAchievements.isNotEmpty) ...[
                Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accentYellow.withValues(alpha: 0.15),
                            AppColors.warning.withValues(alpha: 0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '🏆 New Achievements!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: newAchievements
                                .map(
                                  (a) => Chip(
                                    avatar: Text(a.icon),
                                    label: Text(a.name),
                                    backgroundColor: Colors.white,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .scale(begin: const Offset(0.95, 0.95)),
                const SizedBox(height: 20),
              ],

              // Feedback
              FeedbackCard(
                feedback: feedback,
                isDark: isDark,
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
              const SizedBox(height: 20),

              // Motivational message
              MotivationalMessage(
                message: MotivationalMessages.getEncouragementMessage(),
                isDark: isDark,
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 32),

              // Action buttons
              Row(
                children: [
                  if (onPlayAgain != null) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onPlayAgain,
                        icon: const Icon(Icons.replay_rounded),
                        label: const Text('Play Again'),
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
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
