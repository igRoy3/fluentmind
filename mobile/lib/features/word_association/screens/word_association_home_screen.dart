import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../models/word_association_models.dart';
import '../providers/word_association_provider.dart';
import '../widgets/game_instructions_dialog.dart';

class WordAssociationHomeScreen extends ConsumerWidget {
  const WordAssociationHomeScreen({super.key});

  void _showInstructionsAndStart(BuildContext context, GameMode mode) {
    showDialog(
      context: context,
      builder: (ctx) => GameInstructionsDialog(
        mode: mode,
        onStart: () {
          context.push('/word-association/play', extra: mode);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wordAssociationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Word Association',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Card
              _StatsCard(
                state: state,
                isDark: isDark,
              ).animate().fadeIn(duration: 500.ms),

              const SizedBox(height: 24),

              // How It Works
              Text(
                'Learn Through Association',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Build vocabulary by understanding word relationships and intensity levels.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              // Game Modes
              Text(
                'Choose Your Mode',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 16),

              // Association Mode
              _GameModeCard(
                    icon: Icons.link_rounded,
                    title: 'Association',
                    description: 'Connect related words to build associations',
                    color: AppColors.primary,
                    isDark: isDark,
                    onTap: () => _showInstructionsAndStart(
                      context,
                      GameMode.association,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 400.ms)
                  .slideX(begin: -0.1),

              const SizedBox(height: 12),

              // Context Mode
              _GameModeCard(
                    icon: Icons.format_quote_rounded,
                    title: 'Context',
                    description: 'Choose the right word for each sentence',
                    color: AppColors.secondary,
                    isDark: isDark,
                    onTap: () =>
                        _showInstructionsAndStart(context, GameMode.context),
                  )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideX(begin: -0.1),

              const SizedBox(height: 12),

              // Strength Ordering Mode
              _GameModeCard(
                    icon: Icons.sort_rounded,
                    title: 'Strength Ordering',
                    description: 'Arrange words from weakest to strongest',
                    color: AppColors.accentGreen,
                    isDark: isDark,
                    onTap: () => _showInstructionsAndStart(
                      context,
                      GameMode.strengthOrdering,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms)
                  .slideX(begin: -0.1),

              const SizedBox(height: 12),

              // Daily Challenge
              _DailyChallengeCard(
                    isDark: isDark,
                    completedToday: state.dailyChallengesCompleted,
                    onTap: () => _showInstructionsAndStart(
                      context,
                      GameMode.dailyChallenge,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 400.ms)
                  .slideX(begin: -0.1),

              const SizedBox(height: 24),

              // Word Chain Example
              _WordChainExample(
                isDark: isDark,
              ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final WordAssociationState state;
  final bool isDark;

  const _StatsCard({required this.state, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.stars_rounded,
            value: '${state.totalXP}',
            label: 'Total XP',
          ),
          Container(width: 1, height: 50, color: Colors.white24),
          _StatItem(
            icon: Icons.local_fire_department_rounded,
            value: '${state.currentStreak}',
            label: 'Streak',
          ),
          Container(width: 1, height: 50, color: Colors.white24),
          _StatItem(
            icon: Icons.emoji_events_rounded,
            value: '${state.longestStreak}',
            label: 'Best',
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
      ],
    );
  }
}

class _GameModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _GameModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.cardDark : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
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
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? AppColors.textHintDark : AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyChallengeCard extends StatelessWidget {
  final bool isDark;
  final int completedToday;
  final VoidCallback onTap;

  const _DailyChallengeCard({
    required this.isDark,
    required this.completedToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.warmGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.today_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Challenge',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      completedToday > 0
                          ? 'Completed $completedToday time${completedToday > 1 ? "s" : ""} today'
                          : '5 mixed questions • Earn bonus XP',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.play_circle_filled_rounded,
                color: Colors.white,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WordChainExample extends StatelessWidget {
  final bool isDark;

  const _WordChainExample({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
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
                Icons.lightbulb_outline_rounded,
                color: AppColors.accentYellow,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Example Word Chain',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ChainWord(word: 'Happy', level: 0, isDark: isDark),
              _ChainArrow(isDark: isDark),
              _ChainWord(word: 'Joyful', level: 1, isDark: isDark),
              _ChainArrow(isDark: isDark),
              _ChainWord(word: 'Elated', level: 2, isDark: isDark),
              _ChainArrow(isDark: isDark),
              _ChainWord(word: 'Ecstatic', level: 3, isDark: isDark),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Words increase in intensity as you move along the chain',
            textAlign: TextAlign.center,
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

class _ChainWord extends StatelessWidget {
  final String word;
  final int level;
  final bool isDark;

  const _ChainWord({
    required this.word,
    required this.level,
    required this.isDark,
  });

  Color get _color {
    switch (level) {
      case 0:
        return AppColors.primary;
      case 1:
        return AppColors.secondary;
      case 2:
        return AppColors.accentGreen;
      case 3:
        return AppColors.accent;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Text(
        word,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}

class _ChainArrow extends StatelessWidget {
  final bool isDark;

  const _ChainArrow({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Icon(
        Icons.arrow_forward_rounded,
        size: 14,
        color: isDark ? AppColors.textHintDark : AppColors.textHint,
      ),
    );
  }
}
