import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/word_association_models.dart';

class GameInstructionsDialog extends StatelessWidget {
  final GameMode mode;
  final VoidCallback onStart;

  const GameInstructionsDialog({
    super.key,
    required this.mode,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final instructions = _getInstructions();

    return Dialog(
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: instructions.color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                instructions.icon,
                color: instructions.color,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              instructions.title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // How to play
            Text(
              'How to Play',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: instructions.color,
              ),
            ),
            const SizedBox(height: 12),

            // Instructions
            ...instructions.steps.map(
              (step) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: instructions.color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${instructions.steps.indexOf(step) + 1}',
                          style: TextStyle(
                            color: instructions.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
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
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Tip
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentYellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.accentYellow,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      instructions.tip,
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
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Start Game',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _GameInstructions _getInstructions() {
    switch (mode) {
      case GameMode.association:
        return _GameInstructions(
          title: 'Association Mode',
          icon: Icons.link_rounded,
          color: AppColors.primary,
          steps: [
            'You\'ll see a word at the top of the screen',
            'Select the words that are related or similar in meaning',
            'Tap "Submit" when you\'ve made your selections',
          ],
          tip: 'Think about synonyms and words with similar feelings!',
        );
      case GameMode.context:
        return _GameInstructions(
          title: 'Context Mode',
          icon: Icons.format_quote_rounded,
          color: AppColors.secondary,
          steps: [
            'Read the sentence with a blank space',
            'Choose the word that best fits the context',
            'The right word should make the sentence natural',
          ],
          tip: 'Read the whole sentence to understand the context!',
        );
      case GameMode.strengthOrdering:
        return _GameInstructions(
          title: 'Strength Ordering',
          icon: Icons.sort_rounded,
          color: AppColors.accentGreen,
          steps: [
            'You\'ll see a list of related words',
            'Drag and drop to arrange from weakest to strongest',
            'Submit when the order feels right',
          ],
          tip: 'Think about intensity - from mild to extreme!',
        );
      case GameMode.dailyChallenge:
        return _GameInstructions(
          title: 'Daily Challenge',
          icon: Icons.star_rounded,
          color: AppColors.accentYellow,
          steps: [
            'Complete a mix of different question types',
            'Earn bonus XP for daily challenges',
            'Build your streak by playing every day',
          ],
          tip: 'Daily challenges give 50 bonus XP when completed!',
        );
    }
  }
}

class _GameInstructions {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> steps;
  final String tip;

  _GameInstructions({
    required this.title,
    required this.icon,
    required this.color,
    required this.steps,
    required this.tip,
  });
}
