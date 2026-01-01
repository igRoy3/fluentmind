import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../models/word_association_models.dart';

class AssociationQuestionWidget extends StatefulWidget {
  final GameQuestion question;
  final bool isAnswered;
  final bool isDark;
  final Function(List<String>) onSubmit;

  const AssociationQuestionWidget({
    super.key,
    required this.question,
    required this.isAnswered,
    required this.isDark,
    required this.onSubmit,
  });

  @override
  State<AssociationQuestionWidget> createState() =>
      _AssociationQuestionWidgetState();
}

class _AssociationQuestionWidgetState extends State<AssociationQuestionWidget> {
  final Set<String> _selectedWords = {};

  @override
  void didUpdateWidget(AssociationQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _selectedWords.clear();
    }
  }

  void _toggleWord(String word) {
    if (widget.isAnswered) return;

    setState(() {
      if (_selectedWords.contains(word)) {
        _selectedWords.remove(word);
      } else {
        _selectedWords.add(word);
      }
    });
  }

  bool _isCorrectAnswer(String word) {
    return widget.question.wordData.associations.any((a) => a.word == word);
  }

  @override
  Widget build(BuildContext context) {
    final word = widget.question.wordData;
    final options = widget.question.options ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Base word card
          Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
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
                child: Column(
                  children: [
                    const Text(
                      'Base Word',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      word.baseWord,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      word.baseDefinition,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.95, 0.95)),

          const SizedBox(height: 24),

          // Instructions
          Text(
            'Select 2 words that are associated with "${word.baseWord}"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: widget.isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 20),

          // Options grid
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: options.asMap().entries.map((entry) {
              final index = entry.key;
              final optionWord = entry.value;
              final isSelected = _selectedWords.contains(optionWord);
              final isCorrect = _isCorrectAnswer(optionWord);

              Color backgroundColor;
              Color borderColor;
              Color textColor;

              if (widget.isAnswered) {
                if (isCorrect) {
                  backgroundColor = AppColors.success.withOpacity(0.15);
                  borderColor = AppColors.success;
                  textColor = AppColors.success;
                } else if (isSelected && !isCorrect) {
                  backgroundColor = AppColors.error.withOpacity(0.15);
                  borderColor = AppColors.error;
                  textColor = AppColors.error;
                } else {
                  backgroundColor = widget.isDark
                      ? AppColors.surfaceVariantDark
                      : AppColors.surfaceVariant;
                  borderColor = Colors.transparent;
                  textColor = widget.isDark
                      ? AppColors.textHintDark
                      : AppColors.textHint;
                }
              } else {
                if (isSelected) {
                  backgroundColor = AppColors.primary.withOpacity(0.15);
                  borderColor = AppColors.primary;
                  textColor = AppColors.primary;
                } else {
                  backgroundColor = widget.isDark
                      ? AppColors.cardDark
                      : Colors.white;
                  borderColor = widget.isDark
                      ? AppColors.dividerDark
                      : AppColors.divider;
                  textColor = widget.isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary;
                }
              }

              return GestureDetector(
                    onTap: () => _toggleWord(optionWord),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor, width: 2),
                        boxShadow: isSelected && !widget.isAnswered
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.isAnswered && isCorrect)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                                size: 20,
                              ),
                            ),
                          if (widget.isAnswered && isSelected && !isCorrect)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                Icons.cancel,
                                color: AppColors.error,
                                size: 20,
                              ),
                            ),
                          Text(
                            optionWord,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .animate(delay: Duration(milliseconds: 100 * index))
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.2);
            }).toList(),
          ),

          const SizedBox(height: 32),

          // Submit button
          if (!widget.isAnswered)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _selectedWords.length >= 2
                    ? () => widget.onSubmit(_selectedWords.toList())
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: widget.isDark
                      ? AppColors.disabledDark
                      : AppColors.disabled,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _selectedWords.length < 2
                      ? 'Select ${2 - _selectedWords.length} more'
                      : 'Check Answer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _selectedWords.length >= 2
                        ? Colors.white
                        : (widget.isDark
                              ? AppColors.textHintDark
                              : AppColors.textHint),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 300.ms),
        ],
      ),
    );
  }
}
