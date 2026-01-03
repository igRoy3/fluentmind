import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/gamification/providers/gamification_provider.dart';
import '../../../core/gamification/providers/adaptive_difficulty_provider.dart';
import '../widgets/game_instructions_dialog.dart';
import '../widgets/difficulty_selection_dialog.dart';

class GamesScreen extends ConsumerWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesState = ref.watch(brainGamesProvider);
    final gamificationState = ref.watch(gamificationProvider);
    final gamePerformance = ref.watch(gamePerformanceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate total score from all games
    final totalScore = gamePerformance.values.fold<int>(
      0,
      (sum, stats) => sum + stats.totalScore,
    );

    // Get streak from gamification provider (real data)
    final dayStreak = gamificationState.userProgress.currentStreak;

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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          'Brain Games',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Header - using real data
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatItem(
                          icon: Icons.stars_rounded,
                          value: '$totalScore',
                          label: 'Total Score',
                        ),
                      ),
                      Container(width: 1, height: 40, color: Colors.white24),
                      Expanded(
                        child: _StatItem(
                          icon: Icons.local_fire_department,
                          value: '$dayStreak',
                          label: 'Day Streak',
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms),
              ),

              // Featured Game - Word Association
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Featured',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _FeaturedGameCard(
                      onTap: () {
                        showGameInstructions(
                          context,
                          gameId: 'word_association',
                          onStart: () => context.push('/word-association'),
                        );
                      },
                      isDark: isDark,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              const SizedBox(height: 16),

              // Math Facts Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _MathFactsCard(
                  onTap: () => context.push('/math-facts'),
                  isDark: isDark,
                ),
              ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

              const SizedBox(height: 24),

              // Other Games Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'More Games',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Games Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Adjust grid based on available width
                    final screenWidth = MediaQuery.of(context).size.width;
                    final crossAxisCount = screenWidth < 360 ? 2 : 2;
                    final childAspectRatio = screenWidth < 360 ? 0.75 : 0.85;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: childAspectRatio,
                        crossAxisSpacing: screenWidth < 360 ? 12 : 16,
                        mainAxisSpacing: screenWidth < 360 ? 12 : 16,
                      ),
                      itemCount: gamesState.availableGames.length,
                      itemBuilder: (context, index) {
                        final game = gamesState.availableGames[index];
                        // Get real best score from game performance provider
                        final gameStats = gamePerformance[game.id];
                        final realBestScore = gameStats?.bestScore;

                        return _GameCard(
                              game: game,
                              realBestScore: realBestScore,
                              onTap: () async {
                                // Show difficulty selection dialog
                                final difficulty =
                                    await showDifficultySelectionDialog(
                                      context: context,
                                      gameId: game.id,
                                      gameName: game.name,
                                    );

                                if (difficulty != null && context.mounted) {
                                  ref
                                      .read(brainGamesProvider.notifier)
                                      .startGame(game.id);
                                  // Pass difficulty as query parameter
                                  context.push(
                                    '/games/${game.id}?difficulty=${difficulty.index}',
                                  );
                                }
                              },
                            )
                            .animate(
                              delay: Duration(milliseconds: 100 * index + 300),
                            )
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.2);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedGameCard extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDark;

  const _FeaturedGameCard({required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.8),
              AppColors.accent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
          children: [
            // Icon
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.link_rounded,
                color: Colors.white,
                size: 36,
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Word Association',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Build vocabulary chains and master word intensity',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
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

class _MathFactsCard extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDark;

  const _MathFactsCard({required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF10B981)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: isSmallScreen ? 50 : 60,
              height: isSmallScreen ? 50 : 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.functions_rounded,
                color: Colors.white,
                size: isSmallScreen ? 28 : 32,
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Math Facts',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Learn tables 11-20, squares & cubes with practice games',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: isSmallScreen ? 12 : 13,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Column(
      children: [
        Icon(icon, color: Colors.white, size: isSmallScreen ? 22 : 28),
        SizedBox(height: isSmallScreen ? 4 : 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 18 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: isSmallScreen ? 10 : 12,
          ),
        ),
      ],
    );
  }
}

class _GameCard extends StatelessWidget {
  final BrainGame game;
  final VoidCallback onTap;
  final int? realBestScore;

  const _GameCard({
    required this.game,
    required this.onTap,
    this.realBestScore,
  });

  IconData _getIconData(IconType type) {
    switch (type) {
      case IconType.calculate:
        return Icons.calculate;
      case IconType.gridView:
        return Icons.grid_view_rounded;
      case IconType.spellcheck:
        return Icons.spellcheck;
      case IconType.psychology:
        return Icons.psychology;
      case IconType.category:
        return Icons.category;
      case IconType.pattern:
        return Icons.pattern;
      case IconType.math:
        return Icons.calculate;
      case IconType.logic:
        return Icons.psychology;
      case IconType.memory:
        return Icons.grid_view_rounded;
      case IconType.vocabulary:
        return Icons.spellcheck;
      case IconType.puzzle:
        return Icons.extension;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [game.color, game.color.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _getIconData(game.iconType),
                color: Colors.white,
                size: isSmallScreen ? 26 : 32,
              ),
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                game.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 12 : 14,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ),
            const Spacer(),
            // High Score - use real data if available
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 10,
                  vertical: isSmallScreen ? 3 : 4,
                ),
                decoration: BoxDecoration(
                  color: game.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Best: ${realBestScore ?? game.highScore}',
                  style: TextStyle(
                    color: game.color,
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 10 : 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
