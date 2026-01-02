import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../models/word_association_models.dart';

class OrderingQuestionWidget extends StatefulWidget {
  final GameQuestion question;
  final bool isAnswered;
  final bool isDark;
  final Function(List<String>) onSubmit;

  const OrderingQuestionWidget({
    super.key,
    required this.question,
    required this.isAnswered,
    required this.isDark,
    required this.onSubmit,
  });

  @override
  State<OrderingQuestionWidget> createState() => _OrderingQuestionWidgetState();
}

class _OrderingQuestionWidgetState extends State<OrderingQuestionWidget> {
  late List<String> _orderedWords;

  @override
  void initState() {
    super.initState();
    _orderedWords = _getShuffledOptions();
  }

  /// Shuffle options to ensure they're not in the correct order by default
  List<String> _getShuffledOptions() {
    final options = List<String>.from(widget.question.options ?? []);
    final correctOrder = widget.question.correctOrder ?? [];

    // Keep shuffling until the order is different from the correct order
    final random = Random();
    int attempts = 0;
    do {
      options.shuffle(random);
      attempts++;
      // Prevent infinite loop if there's only 1-2 options
      if (attempts > 10) break;
    } while (_listsEqual(options, correctOrder) && options.length > 2);

    return options;
  }

  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void didUpdateWidget(OrderingQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _orderedWords = _getShuffledOptions();
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (widget.isAnswered) return;

    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = _orderedWords.removeAt(oldIndex);
      _orderedWords.insert(newIndex, item);
    });
  }

  bool _isCorrectPosition(int index) {
    if (widget.question.correctOrder == null) return false;
    if (index >= widget.question.correctOrder!.length) return false;
    return _orderedWords[index] == widget.question.correctOrder![index];
  }

  @override
  Widget build(BuildContext context) {
    final correctOrder = widget.question.correctOrder ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header icon
          Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sort_rounded,
                  color: AppColors.accentGreen,
                  size: 32,
                ),
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .scale(begin: const Offset(0.8, 0.8)),

          const SizedBox(height: 20),

          // Instructions
          Text(
            'Arrange words from weakest to strongest',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: widget.isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimary,
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

          const SizedBox(height: 8),

          Text(
            'Drag and drop to reorder',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: widget.isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 150.ms, duration: 300.ms),

          const SizedBox(height: 24),

          // Intensity scale
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: widget.isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(widget.isDark ? 0.2 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _IntensityLabel(
                  label: 'Weakest',
                  color: AppColors.primary.withOpacity(0.6),
                  isDark: widget.isDark,
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: widget.isDark
                      ? AppColors.textHintDark
                      : AppColors.textHint,
                  size: 20,
                ),
                _IntensityLabel(
                  label: 'Strongest',
                  color: AppColors.accent,
                  isDark: widget.isDark,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

          const SizedBox(height: 24),

          // Reorderable list
          Container(
            decoration: BoxDecoration(
              color: widget.isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false, // We'll add custom drag handles
              itemCount: _orderedWords.length,
              onReorder: _onReorder,
              proxyDecorator: (child, index, animation) {
                return Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.transparent,
                  child: child,
                );
              },
              itemBuilder: (context, index) {
                final wordText = _orderedWords[index];
                final isCorrect = _isCorrectPosition(index);
                final correctPosition = correctOrder.indexOf(wordText);

                Color backgroundColor;
                Color borderColor;
                Color textColor;

                if (widget.isAnswered) {
                  if (isCorrect) {
                    backgroundColor = AppColors.success.withOpacity(0.15);
                    borderColor = AppColors.success;
                    textColor = AppColors.success;
                  } else {
                    backgroundColor = AppColors.error.withOpacity(0.15);
                    borderColor = AppColors.error;
                    textColor = AppColors.error;
                  }
                } else {
                  backgroundColor = widget.isDark
                      ? AppColors.cardDark
                      : Colors.white;
                  borderColor = _getIntensityColor(index, _orderedWords.length);
                  textColor = widget.isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary;
                }

                return Material(
                  key: ValueKey(wordText),
                  color: Colors.transparent,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              widget.isDark ? 0.15 : 0.05,
                            ),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Position number
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: widget.isAnswered
                                  ? (isCorrect
                                        ? AppColors.success
                                        : AppColors.error)
                                  : _getIntensityColor(
                                      index,
                                      _orderedWords.length,
                                    ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: widget.isAnswered
                                  ? Icon(
                                      isCorrect ? Icons.check : Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    )
                                  : Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Word
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  wordText,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                                if (widget.isAnswered && !isCorrect)
                                  Text(
                                    'Should be #${correctPosition + 1}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.error.withOpacity(0.8),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Custom drag handle with ReorderableDragStartListener
                          if (!widget.isAnswered)
                            ReorderableDragStartListener(
                              index: index,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  Icons.drag_handle_rounded,
                                  color: widget.isDark
                                      ? AppColors.textHintDark
                                      : AppColors.textHint,
                                  size: 28,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

          const SizedBox(height: 24),

          // Correct order display (only shown after answering)
          if (widget.isAnswered)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Correct Order',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    correctOrder.join('  →  '),
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 24),

          // Submit button
          if (!widget.isAnswered)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => widget.onSubmit(_orderedWords),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Check Order',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 500.ms, duration: 300.ms),
        ],
      ),
    );
  }

  Color _getIntensityColor(int index, int total) {
    final colors = [
      AppColors.primary.withOpacity(0.7),
      AppColors.secondary,
      AppColors.accentGreen,
      AppColors.accent,
    ];

    if (total <= 4) {
      return colors[index.clamp(0, colors.length - 1)];
    }

    final colorIndex = (index * colors.length / total).floor();
    return colors[colorIndex.clamp(0, colors.length - 1)];
  }
}

class _IntensityLabel extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDark;

  const _IntensityLabel({
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
