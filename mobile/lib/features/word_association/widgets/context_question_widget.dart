import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../models/word_association_models.dart';

class ContextQuestionWidget extends StatefulWidget {
  final GameQuestion question;
  final bool isAnswered;
  final bool isDark;
  final Function(String) onSubmit;

  const ContextQuestionWidget({
    super.key,
    required this.question,
    required this.isAnswered,
    required this.isDark,
    required this.onSubmit,
  });

  @override
  State<ContextQuestionWidget> createState() => _ContextQuestionWidgetState();
}

class _ContextQuestionWidgetState extends State<ContextQuestionWidget> {
  String? _selectedWord;

  @override
  void didUpdateWidget(ContextQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _selectedWord = null;
    }
  }

  void _selectWord(String word) {
    if (widget.isAnswered) return;
    setState(() {
      _selectedWord = word;
    });
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.question.options ?? [];
    final sentence = widget.question.sentenceWithBlank ?? '';
    final correctAnswer = widget.question.correctAnswer ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Context icon
          Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.format_quote_rounded,
                  color: AppColors.secondary,
                  size: 32,
                ),
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .scale(begin: const Offset(0.8, 0.8)),

          const SizedBox(height: 20),

          // Instructions
          Text(
            'Choose the best word to complete the sentence',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: widget.isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimary,
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

          const SizedBox(height: 24),

          // Sentence with blank
          Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: widget.isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        widget.isDark ? 0.2 : 0.05,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.6,
                      color: widget.isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                    children: _buildSentenceSpans(sentence),
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.1),

          const SizedBox(height: 32),

          // Word options
          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            final optionWord = entry.value;
            final isSelected = _selectedWord == optionWord;
            final isCorrect = optionWord == correctAnswer;

            Color backgroundColor;
            Color borderColor;
            Color textColor;
            IconData? icon;

            if (widget.isAnswered) {
              if (isCorrect) {
                backgroundColor = AppColors.success.withOpacity(0.15);
                borderColor = AppColors.success;
                textColor = AppColors.success;
                icon = Icons.check_circle;
              } else if (isSelected && !isCorrect) {
                backgroundColor = AppColors.error.withOpacity(0.15);
                borderColor = AppColors.error;
                textColor = AppColors.error;
                icon = Icons.cancel;
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

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child:
                  GestureDetector(
                        onTap: () => _selectWord(optionWord),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color:
                                      isSelected ||
                                          (widget.isAnswered && isCorrect)
                                      ? (widget.isAnswered
                                            ? (isCorrect
                                                  ? AppColors.success
                                                  : AppColors.error)
                                            : AppColors.primary)
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        isSelected ||
                                            (widget.isAnswered &&
                                                (isCorrect ||
                                                    (isSelected && !isCorrect)))
                                        ? Colors.transparent
                                        : (widget.isDark
                                              ? AppColors.dividerDark
                                              : AppColors.divider),
                                    width: 2,
                                  ),
                                ),
                                child:
                                    (isSelected ||
                                        (widget.isAnswered && isCorrect))
                                    ? Icon(
                                        widget.isAnswered
                                            ? (isCorrect
                                                  ? Icons.check
                                                  : Icons.close)
                                            : Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  optionWord,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              if (widget.isAnswered && icon != null)
                                Icon(
                                  icon,
                                  color: isCorrect
                                      ? AppColors.success
                                      : AppColors.error,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      )
                      .animate(delay: Duration(milliseconds: 300 + 100 * index))
                      .fadeIn(duration: 300.ms)
                      .slideX(begin: 0.1),
            );
          }),

          const SizedBox(height: 20),

          // Submit button
          if (!widget.isAnswered)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _selectedWord != null
                    ? () => widget.onSubmit(_selectedWord!)
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
                  'Check Answer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _selectedWord != null
                        ? Colors.white
                        : (widget.isDark
                              ? AppColors.textHintDark
                              : AppColors.textHint),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 600.ms, duration: 300.ms),
        ],
      ),
    );
  }

  List<TextSpan> _buildSentenceSpans(String sentence) {
    final parts = sentence.split('______');
    final spans = <TextSpan>[];

    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(text: parts[i]));

      if (i < parts.length - 1) {
        String blankText;
        Color blankColor;

        if (widget.isAnswered) {
          blankText = widget.question.correctAnswer ?? '______';
          blankColor = AppColors.success;
        } else if (_selectedWord != null) {
          blankText = _selectedWord!;
          blankColor = AppColors.primary;
        } else {
          blankText = '______';
          blankColor = widget.isDark
              ? AppColors.textHintDark
              : AppColors.textHint;
        }

        spans.add(
          TextSpan(
            text: blankText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: blankColor,
              decoration: widget.isAnswered || _selectedWord != null
                  ? null
                  : TextDecoration.underline,
            ),
          ),
        );
      }
    }

    return spans;
  }
}
