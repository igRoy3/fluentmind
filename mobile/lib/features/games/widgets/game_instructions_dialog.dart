import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';

/// Universal game instructions dialog for all brain games
class UniversalGameInstructionsDialog extends StatelessWidget {
  final GameInstructions instructions;
  final VoidCallback onStart;
  final VoidCallback? onCancel;

  const UniversalGameInstructionsDialog({
    super.key,
    required this.instructions,
    required this.onStart,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: instructions.color.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        instructions.color,
                        instructions.color.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: instructions.color.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(instructions.icon, color: Colors.white, size: 40),
                ).animate().scale(
                  begin: const Offset(0.5, 0.5),
                  curve: Curves.elasticOut,
                  duration: 600.ms,
                ),

                const SizedBox(height: 20),

                // Title
                Text(
                  instructions.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  instructions.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ).animate().fadeIn(delay: 150.ms),

                const SizedBox(height: 24),

                // How to play header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: instructions.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 16,
                            color: instructions.color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'How to Play',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: instructions.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 16),

                // Steps
                ...instructions.steps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: instructions.color.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: instructions.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  step,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 250 + (index * 50)))
                      .slideX(begin: -0.1);
                }),

                const SizedBox(height: 12),

                // Tip box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accentYellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.accentYellow.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_rounded,
                        color: AppColors.accentYellow,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pro Tip',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.accentYellow,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              instructions.tip,
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
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 24),

                // Start button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onStart();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: instructions.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_arrow_rounded, size: 24),
                        const SizedBox(width: 8),
                        const Text(
                          'Start Game',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.2),

                const SizedBox(height: 8),

                // Cancel button
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onCancel?.call();
                  },
                  child: Text(
                    'Maybe Later',
                    style: TextStyle(
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
      ),
    );
  }
}

/// Game instructions data class
class GameInstructions {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<String> steps;
  final String tip;

  const GameInstructions({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.steps,
    required this.tip,
  });

  /// Get instructions for a specific game by ID
  static GameInstructions forGame(String gameId) {
    switch (gameId) {
      case 'math_speed':
        return GameInstructions(
          title: 'Math Speed',
          subtitle: 'Test your mental math abilities',
          icon: Icons.calculate_rounded,
          color: AppColors.primary,
          steps: [
            'Solve math problems as fast as you can',
            'Tap the correct answer from the options',
            'Earn 10 points for each correct answer',
            'Wrong answers deduct 5 points',
          ],
          tip: 'Focus on accuracy first, speed will come naturally!',
        );

      case 'memory_match':
        return GameInstructions(
          title: 'Memory Match',
          subtitle: 'Find all matching pairs',
          icon: Icons.grid_view_rounded,
          color: AppColors.secondary,
          steps: [
            'Tap cards to reveal what\'s underneath',
            'Remember the positions of each card',
            'Match pairs of identical cards',
            'Clear all pairs before time runs out',
          ],
          tip: 'Create a mental map of the grid to remember positions!',
        );

      case 'word_scramble':
        return GameInstructions(
          title: 'Word Scramble',
          subtitle: 'Unscramble the letters',
          icon: Icons.spellcheck_rounded,
          color: AppColors.accentGreen,
          steps: [
            'Look at the scrambled letters shown',
            'Figure out the original English word',
            'Type your answer in the text field',
            'Press submit to check your answer',
          ],
          tip: 'Look for common letter patterns like "ing", "tion", "ed"!',
        );

      case 'logic_sequence':
        return GameInstructions(
          title: 'Logic Sequence',
          subtitle: 'Find the pattern and predict',
          icon: Icons.psychology_rounded,
          color: AppColors.accent,
          steps: [
            'Study the sequence of numbers or shapes',
            'Identify the underlying pattern',
            'Select the next item in the sequence',
            'Patterns can be mathematical or visual',
          ],
          tip: 'Look for additions, multiplications, or alternating patterns!',
        );

      case 'category_sort':
        return GameInstructions(
          title: 'Category Sort',
          subtitle: 'Group items by category',
          icon: Icons.category_rounded,
          color: Colors.orange,
          steps: [
            'Items will appear on screen one by one',
            'Quickly decide which category it belongs to',
            'Swipe or tap the correct category',
            'Be fast but accurate to maximize score',
          ],
          tip: 'Read quickly and trust your first instinct!',
        );

      case 'pattern_recognition':
        return GameInstructions(
          title: 'Pattern Recognition',
          subtitle: 'Complete the visual patterns',
          icon: Icons.pattern_rounded,
          color: Colors.purple,
          steps: [
            'Observe the pattern in the grid',
            'Find the missing piece that completes it',
            'Consider rotation, color, and shape',
            'Select the correct answer from options',
          ],
          tip: 'Look at rows, columns, AND diagonals for patterns!',
        );

      default:
        return GameInstructions(
          title: 'Brain Game',
          subtitle: 'Challenge your mind',
          icon: Icons.psychology_rounded,
          color: AppColors.primary,
          steps: [
            'Follow the on-screen instructions',
            'Complete challenges before time runs out',
            'Earn points for correct answers',
            'Try to beat your high score!',
          ],
          tip: 'Stay focused and have fun!',
        );
    }
  }
}

/// Helper function to show game instructions
Future<void> showGameInstructions(
  BuildContext context, {
  required String gameId,
  required VoidCallback onStart,
  VoidCallback? onCancel,
}) {
  final instructions = GameInstructions.forGame(gameId);
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => UniversalGameInstructionsDialog(
      instructions: instructions,
      onStart: onStart,
      onCancel: onCancel,
    ),
  );
}
