/// Difficulty Selection Dialog for FluentMind Games
/// Allows users to choose difficulty before starting a game

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/gamification/models/game_difficulty_models.dart';
import '../../../core/gamification/providers/adaptive_difficulty_provider.dart';

class DifficultySelectionDialog extends ConsumerStatefulWidget {
  final String gameId;
  final String gameName;
  final VoidCallback onCancel;
  final Function(GameDifficulty) onSelect;

  const DifficultySelectionDialog({
    super.key,
    required this.gameId,
    required this.gameName,
    required this.onCancel,
    required this.onSelect,
  });

  @override
  ConsumerState<DifficultySelectionDialog> createState() =>
      _DifficultySelectionDialogState();
}

class _DifficultySelectionDialogState
    extends ConsumerState<DifficultySelectionDialog> {
  GameDifficulty? _selectedDifficulty;
  GameDifficulty? _recommendedDifficulty;

  @override
  void initState() {
    super.initState();
    _loadRecommendation();
  }

  void _loadRecommendation() {
    final preferences = ref.read(userDifficultyPreferencesProvider);
    final currentPref =
        preferences[widget.gameId] ?? GameDifficulty.intermediate;
    final performanceTracker = ref.read(gamePerformanceProvider.notifier);
    _recommendedDifficulty = performanceTracker.getRecommendedDifficulty(
      widget.gameId,
      currentPref,
    );
    _selectedDifficulty = currentPref;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = ref.watch(gamePerformanceProvider)[widget.gameId];
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child:
          Container(
                constraints: BoxConstraints(
                  maxWidth: 400,
                  maxHeight: screenHeight * 0.85,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header - fixed at top
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Choose Difficulty',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  widget.gameName,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Scrollable content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Column(
                          children: [
                            // Performance stats (if available) - more compact
                            if (stats != null && stats.totalPlays > 0) ...[
                              _buildStatsCard(stats, isDark),
                              const SizedBox(height: 12),
                            ],

                            // Difficulty options - more compact
                            ...GameDifficulty.values.map((difficulty) {
                              final isRecommended =
                                  difficulty == _recommendedDifficulty;
                              final isSelected =
                                  difficulty == _selectedDifficulty;
                              return _DifficultyOptionCompact(
                                difficulty: difficulty,
                                isSelected: isSelected,
                                isRecommended: isRecommended,
                                isDark: isDark,
                                onTap: () {
                                  setState(() {
                                    _selectedDifficulty = difficulty;
                                  });
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                    ),

                    // Action buttons - fixed at bottom
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: widget.onCancel,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: BorderSide(
                                  color: isDark
                                      ? AppColors.dividerDark
                                      : AppColors.divider,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _selectedDifficulty != null
                                  ? () {
                                      // Save preference
                                      ref
                                          .read(
                                            userDifficultyPreferencesProvider
                                                .notifier,
                                          )
                                          .setDifficulty(
                                            widget.gameId,
                                            _selectedDifficulty!,
                                          );
                                      widget.onSelect(_selectedDifficulty!);
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.play_arrow_rounded,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Start Game',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
    );
  }

  Widget _buildStatsCard(GamePerformanceStats stats, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.stars_rounded,
            value: '${stats.bestScore}',
            label: 'Best',
            color: AppColors.accent,
          ),
          Container(
            width: 1,
            height: 36,
            color: isDark ? AppColors.dividerDark : AppColors.divider,
          ),
          _StatItem(
            icon: Icons.percent_rounded,
            value: '${(stats.avgAccuracy * 100).round()}%',
            label: 'Accuracy',
            color: AppColors.success,
          ),
          Container(
            width: 1,
            height: 36,
            color: isDark ? AppColors.dividerDark : AppColors.divider,
          ),
          _StatItem(
            icon: Icons.sports_esports_rounded,
            value: '${stats.totalPlays}',
            label: 'Played',
            color: AppColors.secondary,
          ),
        ],
      ),
    );
  }
}

// Compact difficulty option for better fit
class _DifficultyOptionCompact extends StatelessWidget {
  final GameDifficulty difficulty;
  final bool isSelected;
  final bool isRecommended;
  final bool isDark;
  final VoidCallback onTap;

  const _DifficultyOptionCompact({
    required this.difficulty,
    required this.isSelected,
    required this.isRecommended,
    required this.isDark,
    required this.onTap,
  });

  Color get _difficultyColor {
    switch (difficulty) {
      case GameDifficulty.beginner:
        return AppColors.success;
      case GameDifficulty.intermediate:
        return AppColors.warning;
      case GameDifficulty.advanced:
        return AppColors.error;
    }
  }

  String get _xpMultiplier {
    switch (difficulty) {
      case GameDifficulty.beginner:
        return '0.8x';
      case GameDifficulty.intermediate:
        return '1.0x';
      case GameDifficulty.advanced:
        return '1.5x';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? _difficultyColor.withOpacity(0.1)
              : isDark
              ? AppColors.surfaceVariantDark
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _difficultyColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Emoji icon - smaller
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _difficultyColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  difficulty.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info - compact
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        difficulty.displayName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '★',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    difficulty.description,
                    style: TextStyle(
                      fontSize: 11,
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

            // XP multiplier badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _xpMultiplier,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? _difficultyColor : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? _difficultyColor
                      : isDark
                      ? AppColors.dividerDark
                      : AppColors.divider,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
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
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
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
    );
  }
}

/// Shows the difficulty selection dialog
Future<GameDifficulty?> showDifficultySelectionDialog({
  required BuildContext context,
  required String gameId,
  required String gameName,
}) async {
  return showDialog<GameDifficulty>(
    context: context,
    barrierDismissible: false,
    builder: (context) => DifficultySelectionDialog(
      gameId: gameId,
      gameName: gameName,
      onCancel: () => Navigator.of(context).pop(null),
      onSelect: (difficulty) => Navigator.of(context).pop(difficulty),
    ),
  );
}
